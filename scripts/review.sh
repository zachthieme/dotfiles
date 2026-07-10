#!/usr/bin/env bash
# review.sh — executable half of docs/review-rubric.md.
#
# Runs every rubric criterion that can be checked mechanically (grep/eval) and
# prints pass/fail per criterion id. Criteria that need real hardware or human
# judgement are printed as UNVERIFIED / JUDGED so the reviewer knows exactly
# what still needs a person — they are NOT scored here.
#
# This exists so the mechanical criteria grade themselves identically every
# round and can't drift by reviewer (rubric finding #1/#2). The score a human
# records in the Score history is: these automated results + the judged
# criteria they adjudicate by hand.
#
# Usage: scripts/review.sh            # full report; ratchet exit code
#        scripts/review.sh --no-nix   # skip the (slower) nix eval checks
#        scripts/review.sh --strict   # exit non-zero on ANY fail (ignore baseline)
#
# Exit code (ratchet): 0 when the set of failing criteria matches
# scripts/review-baseline.txt exactly. Non-zero on a REGRESSION (a new fail not
# in the baseline) or a STALE baseline entry (a baselined criterion that now
# passes — tighten it). This lets CI gate on "don't backslide" without requiring
# the whole accepted backlog fixed first. --strict ignores the baseline.
#
# Keep in sync with docs/review-rubric.md — same rubric version (see RUBRIC_VER).
set -uo pipefail

RUBRIC_VER="1.7"
cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1

BASELINE=scripts/review-baseline.txt
RUN_NIX=true
STRICT=false
for arg in "$@"; do
  case $arg in
    --no-nix) RUN_NIX=false ;;
    --strict) STRICT=true ;;
  esac
done

auto_pass=0
auto_fail=0
judged_n=0
unver_n=0
pass_ids=()
fail_ids=()

c_green=$'\033[32m'; c_red=$'\033[31m'; c_yel=$'\033[33m'; c_dim=$'\033[2m'; c_bold=$'\033[1m'; c_off=$'\033[0m'

hdr()  { printf '\n%s%s%s\n' "$c_bold" "$1" "$c_off"; }
pass() { printf '  %s✓%s %-5s %s\n' "$c_green" "$c_off" "$1" "$2"; auto_pass=$((auto_pass + 1)); pass_ids+=("$1"); }
fail() { printf '  %s✗%s %-5s %s\n' "$c_red" "$c_off" "$1" "$2"; auto_fail=$((auto_fail + 1)); fail_ids+=("$1"); }
judged()   { printf '  %s?%s %-5s %s %s(judged — needs a human)%s\n' "$c_yel" "$c_off" "$1" "$2" "$c_dim" "$c_off"; judged_n=$((judged_n + 1)); }
unverified() { printf '  %s~%s %-5s %s %s(%s)%s\n' "$c_yel" "$c_off" "$1" "$2" "$c_dim" "$3" "$c_off"; unver_n=$((unver_n + 1)); }

# assert <id> <label> <cmd...> — pass if cmd succeeds, else fail
assert() { local id=$1 label=$2; shift 2; if "$@" >/dev/null 2>&1; then pass "$id" "$label"; else fail "$id" "$label"; fi; }
# refute <id> <label> <cmd...> — pass if cmd FAILS (i.e. the bad pattern is absent)
refute() { local id=$1 label=$2; shift 2; if "$@" >/dev/null 2>&1; then fail "$id" "$label"; else pass "$id" "$label"; fi; }

WF=.github/workflows/check.yml

printf '%sRepository review — automated criteria (rubric v%s)%s\n' "$c_bold" "$RUBRIC_VER" "$c_off"

# ── 1. Bootstrap & lifecycle ──
hdr "1. Bootstrap & lifecycle"
unverified 1.1 "fresh Linux boot end-to-end" "needs a clean host/VM"
unverified 1.2 "fresh macOS boot end-to-end" "needs a clean mac/VM"
assert 1.3 "-f uses 'flake update --flake'" grep -q 'flake update --flake' install.sh
# match the real command, not a comment mentioning the anti-pattern
if grep -E 'bash -c "\$\(curl' install.sh | grep -qvE '^[[:space:]]*#'; then
  fail 1.4 "no masked 'bash -c \"\$(curl)\"'"
else
  pass 1.4 "no masked 'bash -c \"\$(curl)\"'"
fi
# the bug was advising `home-manager activate <path>`; the explanatory note
# "'home-manager activate' subcommand" is fine — match only the invocation form
refute 1.5 "no bogus 'home-manager activate <path>' hint" grep -qE 'home-manager activate [<$/~]' install.sh
judged 1.6 "installer re-run is idempotent"
assert 1.7 "degrades without sudo (have_sudo guard)" bash -c "grep -q 'have_sudo()' install.sh && grep -q 'have_sudo' install.sh"

# ── 2. Correctness & evaluation gate ──
hdr "2. Correctness & evaluation gate"
# 2.1 — a local, pre-merge gate forces host-config evaluation (scripts/
# check-eval.sh evaluates every same-system host), so a bad option is caught
# before commit, not only when a rebuild breaks. File check — fast/deterministic.
assert 2.1 "local eval gate exists (check-eval.sh)" test -x scripts/check-eval.sh
# 2.2 — broken configs can't silently reach a prod-like host. Satisfied by the
# local eval gate OR CI. Cloud-CI-on-push is NOT required: a single maintainer
# who rebuilds locally is covered by the eval gate + allowFlakeUpdate pinning.
if [[ -x scripts/check-eval.sh ]] || grep -qE '^[[:space:]]*push:' "$WF"; then
  pass 2.2 "a gate blocks broken configs pre-merge (local or CI)"
else
  fail 2.2 "a gate blocks broken configs pre-merge"
fi
judged 2.3 "no dead/self-contradicting config"
judged 2.4 "mkIf/mkDefault precedence correct"
assert 2.5 "vcs override merges (not clobbers)" grep -q 'defaultVcs //' hosts/definitions.nix
assert 2.6 "CI eval loops fail closed (pipefail)" grep -q 'pipefail' "$WF"

# ── 3. Architecture & DRY ──
hdr "3. Architecture & DRY"
judged 3.1 "single source of truth for host facts"
# 3.2 — probe for cross-file constant drift: the same constant copied into >1
# file with different values (here: the workspace `--hosts` id). Quoting-agnostic
# extraction — `tick --hosts 23000` and zellij's `"--hosts" "10950"` are the same
# constant in different syntax; an earlier `tick --hosts` grep missed the latter.
hostids=$(grep -rhoE '\-\-hosts["[:space:]]+[0-9]+' config/fish home-manager 2>/dev/null | grep -oE '[0-9]+$' | sort -u | wc -l)
if [[ "$hostids" -le 1 ]]; then
  pass 3.2 "no cross-file drift in workspace host id"
else
  fail 3.2 "cross-file constant drift (workspace --hosts id differs across files)"
fi
judged 3.3 "layer separation holds"
assert 3.4 "platform list has a single source" grep -q 'supportedSystems' lib.nix

# ── 4. Abstraction integrity ──
hdr "4. Abstraction integrity"
if $RUN_NIX; then
  gh=$(nix eval --json '.#homeConfigurations.pi5.config.programs.ghostty.enable' 2>/dev/null)
  [[ "$gh" == "false" ]] && pass 4.1 "core host (pi5) excludes ghostty" || fail 4.1 "core host (pi5) excludes ghostty"
  n=$(nix eval '.#homeConfigurations.pi5.config.home.packages' --apply 'builtins.length' 2>/dev/null)
  [[ "${n:-0}" -gt 0 ]] && pass 4.3 "overlay resolves for aarch64 (pi5 packages eval)" || fail 4.3 "overlay resolves for aarch64 (pi5 packages eval)"
else
  unverified 4.1 "core host (pi5) excludes ghostty" "skipped --no-nix"
  unverified 4.3 "overlay resolves for aarch64" "skipped --no-nix"
fi
assert 4.2 "heavy GUI module (ghostty) gated on dotfiles.gui" grep -q 'config.dotfiles.gui' home-manager/programs/ghostty.nix

# ── 5. Testing & CI coverage ──
hdr "5. Testing & CI coverage"
NT=config/fish/functions/notes-test.fish
# 5.1 — principle, not a fixed list: DISCOVER every function that writes file
# content or rewrites VCS, then require each to be referenced by the suite. A
# new untested mutator fails this automatically (no bias toward known names).
untested=()
for f in config/fish/functions/*.fish; do
  b=$(basename "$f" .fish); [[ "$b" == "notes-test" ]] && continue
  grep -qE '>[[:space:]]*"?\$|jj (commit|push|bookmark)|git (add|commit|push)' "$f" || continue
  grep -qwF "$b" "$NT" || untested+=("$b")
done
if [[ "${#untested[@]}" -eq 0 ]]; then
  pass 5.1 "state-mutating fns are exercised by tests"
else
  fail 5.1 "untested state-mutating fns: ${untested[*]}"
fi
judged 5.2 "tests are hermetic"
judged 5.3 "no tautological tests"
# installer runtime coverage = anything beyond the shellcheck lint check
if grep -qE 'install.sh (--help|-h)|install-(test|smoke)|bats' flake.nix 2>/dev/null; then
  pass 5.4 "installer has runtime coverage (not just lint)"
else
  fail 5.4 "installer has runtime coverage (not just lint)"
fi
assert 5.5 "CI builds (not just evals) a host" grep -q 'nix build' "$WF"

# ── 6. Security & secrets ──
hdr "6. Security & secrets"
judged 6.1 "no secrets/private endpoints in repo"
# fixed /tmp/<name> paths (mktemp / $TMPDIR are fine)
if grep -rnE '/tmp/[A-Za-z][A-Za-z0-9_-]+' config/fish home-manager --include='*.fish' --include='*.nix' 2>/dev/null \
     | grep -vE 'mktemp|\$TMPDIR' >/dev/null; then
  fail 6.2 "no predictable /tmp rendezvous paths"
else
  pass 6.2 "no predictable /tmp rendezvous paths"
fi
judged 6.3 "no unsanitized data spliced into shells/evals"
# 6.4 — principle: third-party actions pinned to an IMMUTABLE ref (vN tag or
# 40-hex SHA), not any mutable branch. Catches @main/@master/@<branch>, not one.
if grep -ohE 'uses: [^@]+@[^[:space:]]+' "$WF" 2>/dev/null | grep -qvE '@v[0-9]|@[0-9a-f]{40}$'; then
  fail 6.4 "CI action(s) on a mutable ref (not vN/SHA)"
else
  pass 6.4 "CI actions pinned to immutable refs"
fi
judged 6.5 "privilege grants (trusted-users) consented"

# ── 7. Maintainability & docs ──
hdr "7. Maintainability & docs"
# 7.1 — principle: BOTH CLAUDE.md and README name only functions that still
# exist. Derived from actual state (not a blocklist): parse CLAUDE.md's
# migrated-functions inventory and README's "Fish Shell Functions" table, and
# verify every name resolves to a real .fish file. This is the class that has
# drifted twice (nix-cleanup in CLAUDE.md, notes fns in README).
fn_exists() { [[ -e "config/fish/functions/$1.fish" || -e "config/fish/functions/darwin/$1.fish" ]]; }
stale=""
for fn in $(grep 'Migrated core functions' CLAUDE.md 2>/dev/null | grep -oE '\([^)]+\)' | tr -d '()' | tr ',' ' '); do
  fn_exists "$fn" || stale="$stale CLAUDE:$fn"
done
for fn in $(awk '/^## Fish Shell Functions/{f=1;next} /^## /{f=0} f' README.md 2>/dev/null | grep -oE '`[a-z][a-z0-9_-]*' | tr -d '`' | sort -u); do
  fn_exists "$fn" || stale="$stale README:$fn"
done
[[ -z "$stale" ]] && pass 7.1 "CLAUDE.md + README name no removed functions" || fail 7.1 "docs name removed fns:$stale"
judged 7.2 "non-obvious decisions carry their 'why'"
# 7.3 — principle: no expiring date constant BURIED in logic where it silently
# rots. A documented single-source `mkOption` default is the endorsed fix ("hoist
# to options"), so those are allowed; inline literals (in commands/args) are not.
# Also excludes computed dates (date/%Y) and the test fixtures.
if grep -rnE '20[0-9]{2}-[0-9]{2}-[0-9]{2}' home-manager config/fish --include='*.nix' --include='*.fish' 2>/dev/null \
     | grep -qvE 'date |%Y|strftime|notes-test|default = "20[0-9]{2}-'; then
  fail 7.3 "expiring date literal buried in logic (not a documented option)"
else
  pass 7.3 "no buried expiring date literals"
fi
# 7.4 — behavioural freshness (the part a grep can't judge): README + CLAUDE.md
# describe how the code CURRENTLY behaves, and are updated in the same commit as
# a behaviour change. Reference-integrity (7.1) catches removed names; this
# catches a stale *description* (e.g. README calling notes-sync "commit + push"
# after it learned to fetch/merge).
judged 7.4 "README + CLAUDE.md describe current behaviour"

# ── Summary ──
auto_total=$((auto_pass + auto_fail))
printf '\n%s──────── summary ────────%s\n' "$c_bold" "$c_off"
printf '  automated:  %s%d/%d pass%s   (%d fail)\n' "$c_green" "$auto_pass" "$auto_total" "$c_off" "$auto_fail"
printf '  judged:     %d criteria need human adjudication\n' "$judged_n"
printf '  unverified: %d criteria need hardware/VM (excluded from denominator)\n' "$unver_n"
printf '\n%sThis is the mechanical subset only. Combine with the judged criteria to\n' "$c_dim"
printf 'produce the Score-history entry; mark any unverified criteria PROVISIONAL.%s\n' "$c_off"

# ── Exit code ──
if $STRICT; then
  [[ "$auto_fail" -eq 0 ]]
  exit $?
fi

# Ratchet against the accepted-failures baseline.
in_list() { local needle=$1; shift; local x; for x in "$@"; do [[ "$x" == "$needle" ]] && return 0; done; return 1; }

baseline=()
if [[ -f "$BASELINE" ]]; then
  while read -r id _; do [[ -n "$id" && "$id" != \#* ]] && baseline+=("$id"); done <"$BASELINE"
fi

regressions=()
for id in ${fail_ids[@]+"${fail_ids[@]}"}; do
  in_list "$id" ${baseline[@]+"${baseline[@]}"} || regressions+=("$id")
done
stale=()
for id in ${baseline[@]+"${baseline[@]}"}; do
  in_list "$id" ${pass_ids[@]+"${pass_ids[@]}"} && stale+=("$id")
done

rc=0
if [[ "${#regressions[@]}" -gt 0 ]]; then
  printf '\n%s✗ REGRESSION%s — newly failing criteria not in %s: %s\n' "$c_red" "$c_off" "$BASELINE" "${regressions[*]}"
  printf '  Fix them, or (if accepted) add them to the baseline with a reason.\n'
  rc=1
fi
if [[ "${#stale[@]}" -gt 0 ]]; then
  printf '\n%s✗ STALE BASELINE%s — these now PASS; remove from %s: %s\n' "$c_yel" "$c_off" "$BASELINE" "${stale[*]}"
  printf '  Tightening the ratchet keeps fixed criteria from silently regressing later.\n'
  rc=1
fi
[[ "$rc" -eq 0 ]] && printf '\n%s✓ ratchet: failing set matches baseline (no regressions)%s\n' "$c_green" "$c_off"
exit "$rc"
