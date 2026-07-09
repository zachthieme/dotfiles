#!/usr/bin/env bash
# check-eval.sh — fast local eval gate.
#
# Forces full module evaluation of every Home Manager host that matches THIS
# machine's system, so a bad option / mkIf / merge fails here — before you
# commit — instead of only when a rebuild breaks on some machine later.
#
# Why not a `nix flake check` derivation: `nix flake check` also traverses the
# darwin configs (import-from-derivation, unbuildable on Linux) and builds every
# check, pushing it past 7 minutes — too slow to actually run pre-commit. A
# direct `nix eval` of each same-system host's drvPath is seconds (warm) and
# targets exactly the typo class.
#
# Same-system only: evaluating a cross-arch host pulls catppuccin's IFD, which
# needs a cross-arch build and fails. Shared modules (base.nix, programs/*) are
# covered via the same-system hosts; aarch64-only breakage is caught on a Pi.
#
# Usage: scripts/check-eval.sh          # eval this system's hosts
# Wire as a pre-push hook to make it automatic (see docs/review-rubric.md).
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1

sys=$(nix eval --impure --raw --expr 'builtins.currentSystem' 2>/dev/null)
[[ -z "$sys" ]] && { echo "check-eval: could not determine current system" >&2; exit 1; }

# Which flake output holds this machine's configs: darwin hosts are
# darwinConfigurations.<h>.system, Linux hosts are homeConfigurations.<h>.
# activationPackage. (Same-system only — see the header note on cross-arch IFD.)
case "$sys" in
  *-darwin) out="darwinConfigurations"; drv="system.drvPath" ;;
  *) out="homeConfigurations"; drv="activationPackage.drvPath" ;;
esac

# Hosts whose system matches this machine.
mapfile -t hosts < <(
  nix eval --json '.#lib.hosts' \
    --apply "hs: builtins.filter (n: (hs.\${n}).system == \"$sys\") (builtins.attrNames hs)" 2>/dev/null \
    | tr -d '[]"' | tr ',' '\n' | grep -v '^$'
)

if [[ "${#hosts[@]}" -eq 0 ]]; then
  echo "check-eval: no hosts for $sys (nothing to gate here)"
  exit 0
fi

echo "check-eval: evaluating ${#hosts[@]} host(s) for $sys — ${hosts[*]}"
rc=0
for h in "${hosts[@]}"; do
  if nix eval --raw ".#$out.$h.$drv" >/dev/null 2>eval-err.txt; then
    echo "  ✓ $h"
  else
    echo "  ✗ $h — eval failed:"
    sed 's/^/      /' eval-err.txt >&2
    rc=1
  fi
done
rm -f eval-err.txt
[[ "$rc" -eq 0 ]] && echo "check-eval: all host configs evaluate." || echo "check-eval: a host config failed to evaluate (fix before committing)." >&2
exit "$rc"
