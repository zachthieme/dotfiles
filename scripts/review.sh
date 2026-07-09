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

RUBRIC_VER="1.4"
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
if $RUN_NIX; then
  if nix eval --json '.#checks.x86_64-linux' --apply 'builtins.attrNames' 2>/dev/null | grep -q 'eval-'; then
    pass 2.1 "flake check evaluates host configs"
  else
    fail 2.1 "flake check evaluates host configs"
  fi
else
  unverified 2.1 "flake check evaluates host configs" "skipped --no-nix"
fi
assert 2.2 "CI triggers on push to main" grep -qE '^[[:space:]]*push:' "$WF"
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
# 7.1 — principle: docs don't name things that no longer exist. Parse the
# function inventory CLAUDE.md claims and verify each resolves to a file
# (derived from actual state, not a hardcoded blocklist of removed names).
stale=""
inv=$(grep 'Migrated core functions' CLAUDE.md 2>/dev/null | grep -oE '\([^)]+\)' | tr -d '()' | tr ',' ' ')
for fn in $inv; do
  [[ -e "config/fish/functions/$fn.fish" || -e "config/fish/functions/darwin/$fn.fish" ]] || stale="$stale $fn"
done
[[ -z "$stale" ]] && pass 7.1 "CLAUDE.md function inventory all resolve" || fail 7.1 "CLAUDE.md names removed fns:$stale"
judged 7.2 "non-obvious decisions carry their 'why'"
# 7.3 — principle: no hardcoded ISO date literals in source (they silently go
# stale). Excludes computed dates (date/%Y) and the test suite's fixtures.
if grep -rnE '20[0-9]{2}-[0-9]{2}-[0-9]{2}' home-manager config/fish --include='*.nix' --include='*.fish' 2>/dev/null \
     | grep -qvE 'date |%Y|strftime|notes-test'; then
  fail 7.3 "hardcoded expiring date literal(s) in source"
else
  pass 7.3 "no hardcoded expiring date literals"
fi

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
