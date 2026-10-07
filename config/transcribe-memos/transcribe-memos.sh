# transcribe-memos — transcribe new Apple Voice Memos to Markdown with
# whisper.cpp, fully locally.
#
# Built by packages/transcribe-memos.nix with writeShellApplication, which adds
# the shebang, `set -o errexit -o nounset -o pipefail`, a PATH of store paths
# (whisper-cpp, ffmpeg, coreutils, sqlite, ...) and DEFAULT_WHISPER_MODEL.
# Run by the launchd agent in home-manager/programs/voice-memos.nix.
#
# Strictly read-only on the Voice Memos container: audio is read in place, and
# CloudRecordings.db is copied out before it is queried (see "Memo metadata").
#
# Every path can be overridden from the environment, which is how it is
# tested off-mac: VOICE_MEMOS_DIR, TRANSCRIPTS_DIR, WHISPER_MODEL,
# TRANSCRIBE_LOG, TRANSCRIBE_STATE_DIR, STABLE_SECS.

recordings="${VOICE_MEMOS_DIR:-$HOME/Library/Group Containers/group.com.apple.VoiceMemos.shared/Recordings}"
out_dir="${TRANSCRIPTS_DIR:-$HOME/Documents/Voice Memo Transcripts}"
model="${WHISPER_MODEL:-$DEFAULT_WHISPER_MODEL}"
log_file="${TRANSCRIBE_LOG:-$HOME/Library/Logs/transcribe-memos.log}"
state_dir="${TRANSCRIBE_STATE_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/transcribe-memos}"
# How long a file's size must hold still before we trust iCloud is done
# writing it, and how many such checks to make before deferring to a later run.
stable_secs="${STABLE_SECS:-10}"
stable_tries=30

# --- Logging -----------------------------------------------------------------
# Everything (including whisper/ffmpeg stderr) goes to the log. Interactive
# runs also echo to the terminal. launchd's StandardErrorPath points at the same
# file, so only failures before this redirect (e.g. bash itself) land there.
mkdir -p "$(dirname "$log_file")"
if [[ -t 1 ]]; then
  exec > >(tee -a "$log_file") 2>&1
else
  exec >>"$log_file" 2>&1
fi

log() { printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"; }
die() {
  log "ERROR: $*"
  exit 1
}

# --- Lock ----------------------------------------------------------------------
# mkdir is atomic and needs no extra tools (macOS ships no flock). A lock left
# by a killed run is reclaimed when its pid is gone.
mkdir -p "$state_dir"
lock_dir="$state_dir/lock"
if ! mkdir "$lock_dir" 2>/dev/null; then
  holder=$(cat "$lock_dir/pid" 2>/dev/null || true)
  if [[ -n "$holder" ]] && kill -0 "$holder" 2>/dev/null; then
    log "another run (pid $holder) is in progress; exiting"
    exit 0
  fi
  log "reclaiming stale lock (pid ${holder:-unknown})"
  rm -rf "$lock_dir"
  mkdir "$lock_dir" || die "could not take lock $lock_dir"
fi
echo "$$" >"$lock_dir/pid"
work=$(mktemp -d)
trap 'rm -rf "$work" "$lock_dir"' EXIT

# --- Preconditions -------------------------------------------------------------
if [[ ! -e "$recordings" ]]; then
  die "Voice Memos folder not found: $recordings — check that Voice Memos syncs with iCloud on this Mac (System Settings > Apple Account > iCloud), and that /bin/bash has Full Disk Access (TCC can hide the folder entirely)"
fi
if ! ls "$recordings" >/dev/null 2>&1; then
  die "cannot read $recordings — grant Full Disk Access to /bin/bash in System Settings > Privacy & Security > Full Disk Access"
fi
[[ -r "$model" ]] || die "whisper model not readable: $model"
mkdir -p "$out_dir"

# --- Already transcribed ---------------------------------------------------------
# Keyed on the `source:` line in each transcript, not on the transcript's file
# name: the name comes from the memo title, which can change after the fact.
# Deleting a transcript re-queues its memo.
declare -A have=()
shopt -s nullglob
existing=("$out_dir"/*.md)
if ((${#existing[@]})); then
  while IFS= read -r line; do
    src=${line#source: \"}
    have["${src%\"}"]=1
  done < <(grep -h -m1 '^source: "' "${existing[@]}" || true)
fi

pending=()
for f in "$recordings"/*.m4a; do
  [[ -f "$f" ]] || continue
  [[ -n "${have[$(basename "$f")]+x}" ]] && continue
  pending+=("$f")
done
shopt -u nullglob

if ((${#pending[@]} == 0)); then
  log "nothing to transcribe"
  exit 0
fi
log "${#pending[@]} memo(s) to transcribe"

# --- Memo metadata ---------------------------------------------------------------
# CloudRecordings.db holds each memo's real title and date. It is a WAL
# database, and even a `mode=ro` connection to a WAL database opens (and can
# write) its -shm file — so it is copied to the scratch dir and queried there,
# leaving the container untouched. A copy torn by a concurrent write only loses
# the newest WAL frames (SQLite checksums them), and a missing row falls back to
# the file name below.
db="$recordings/CloudRecordings.db"
dbcopy=""
title_expr=""
if [[ -r "$db" ]] && cp "$db" "$work/db.sqlite" 2>/dev/null; then
  if [[ -r "$db-wal" ]]; then cp "$db-wal" "$work/db.sqlite-wal" 2>/dev/null || true; fi
  dbcopy="$work/db.sqlite"
  # The title column has moved across macOS releases; use whichever exist.
  cols=$(sqlite3 "$dbcopy" "SELECT name FROM pragma_table_info('ZCLOUDRECORDING');" 2>/dev/null || true)
  for c in ZENCRYPTEDTITLE ZCUSTOMLABEL; do
    if grep -qx "$c" <<<"$cols"; then title_expr+="NULLIF(TRIM($c),''), "; fi
  done
  if [[ -z "$cols" ]]; then
    log "warning: CloudRecordings.db has no ZCLOUDRECORDING table; using file names"
    dbcopy=""
  fi
else
  log "warning: cannot read $db; using file names for titles"
fi

# Prints "<unix time>|<title>" for a memo; either field may be empty.
memo_meta() {
  [[ -n "$dbcopy" ]] || return 0
  local f=${1//\'/\'\'}
  sqlite3 "$dbcopy" "
    SELECT COALESCE(CAST(ZDATE + 978307200 AS INTEGER), '')
           || '|' || COALESCE(${title_expr}'')
    FROM ZCLOUDRECORDING
    WHERE ZPATH = '$f' OR substr(ZPATH, -length('$f')) = '$f'
    LIMIT 1;" 2>/dev/null || true
}

# A file-name-safe version of a title: no path separators or control
# characters, collapsed whitespace, at most 80 characters.
safe_name() {
  local s
  s=$(printf '%s' "$1" | tr '/:' '--' | tr -d '\000-\037' | tr -s ' ')
  s=${s#"${s%%[![:space:]]*}"}
  s=${s%"${s##*[![:space:]]}"}
  s=${s:0:80}
  printf '%s' "${s:-Recording}"
}

# Waits for a file's size to stop changing (iCloud may still be writing it).
wait_stable() {
  local prev now i
  prev=$(stat -c %s -- "$1" 2>/dev/null) || return 1
  for ((i = 0; i < stable_tries; i++)); do
    sleep "$stable_secs"
    now=$(stat -c %s -- "$1" 2>/dev/null) || return 1
    if [[ "$now" == "$prev" && "$now" -gt 0 ]]; then return 0; fi
    prev=$now
  done
  return 1
}

model_name=$(basename "$model" .bin)
model_name=${model_name#*-} # drop the store hash

# --- Transcribe one memo -------------------------------------------------------
# Called in an `if`, where errexit does not apply, so every step checks itself.
transcribe() {
  local f=$1 base meta epoch title name stamp secs duration text target tmp n
  base=$(basename "$f")

  if ! wait_stable "$f"; then
    log "skip (still changing, will retry): $base"
    return 0
  fi

  meta=$(memo_meta "$base")
  epoch=${meta%%|*}
  title=${meta#*|}
  if [[ -z "$epoch" ]]; then
    # Voice Memos names files "YYYYMMDD HHMMSS-<id>.m4a" in local time.
    if [[ "$base" =~ ^([0-9]{4})([0-9]{2})([0-9]{2})\ ([0-9]{2})([0-9]{2})([0-9]{2}) ]]; then
      local m=("${BASH_REMATCH[@]}")
      epoch=$(date -d "${m[1]}-${m[2]}-${m[3]} ${m[4]}:${m[5]}:${m[6]}" +%s 2>/dev/null) || epoch=""
    fi
    [[ -n "$epoch" ]] || epoch=$(date -r "$f" +%s) || return 1
  fi
  [[ -n "$title" ]] || title=${base%.m4a}
  name=$(safe_name "$title")
  stamp=$(date -d "@$epoch" '+%Y-%m-%d_%H%M') || return 1

  secs=$(ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 "$f") || secs=0
  secs=${secs%.*}
  secs=${secs:-0}
  duration=$(printf '%02d:%02d:%02d' $((secs / 3600)) $((secs % 3600 / 60)) $((secs % 60)))

  log "transcribing: $base -> ${stamp}_$name.md ($duration)"
  ffmpeg -nostdin -hide_banner -loglevel error -y -i "$f" -ar 16000 -ac 1 -c:a pcm_s16le "$work/audio.wav" ||
    {
      log "ffmpeg failed: $base"
      return 1
    }
  # -np: no progress/info prints; the transcript itself goes to out.txt.
  whisper-cli -np -l auto -m "$model" -f "$work/audio.wav" -otxt -of "$work/out" >/dev/null ||
    {
      log "whisper-cli failed: $base"
      rm -f "$work/audio.wav"
      return 1
    }
  text=$(sed 's/^[[:space:]]*//' "$work/out.txt")
  rm -f "$work/audio.wav" "$work/out.txt"
  [[ -n "$text" ]] || text="_(no speech detected)_"

  target="$out_dir/${stamp}_$name.md"
  n=2
  while [[ -e "$target" ]]; do
    target="$out_dir/${stamp}_$name-$n.md"
    n=$((n + 1))
  done

  # Written beside the target and renamed into place, so an interrupted run
  # never leaves a partial transcript that would count as done.
  tmp="$out_dir/.$base.md.tmp"
  {
    printf -- '---\n'
    printf 'title: "%s"\n' "${title//\"/\\\"}"
    printf 'source: "%s"\n' "$base"
    printf 'recorded: %s\n' "$(date -d "@$epoch" '+%Y-%m-%d %H:%M')"
    printf 'duration: %s\n' "$duration"
    printf 'transcribed: %s\n' "$(date '+%Y-%m-%d %H:%M')"
    printf 'model: %s\n' "$model_name"
    printf -- '---\n\n# %s\n\n%s\n' "$title" "$text"
  } >"$tmp" || {
    rm -f "$tmp"
    log "could not write transcript: $target"
    return 1
  }
  mv "$tmp" "$target" || {
    rm -f "$tmp"
    log "could not move transcript into place: $target"
    return 1
  }
  log "wrote: $target"
}

failed=0
for f in "${pending[@]}"; do
  transcribe "$f" || failed=$((failed + 1))
done
log "done (${#pending[@]} pending, $failed failed)"
((failed == 0))
