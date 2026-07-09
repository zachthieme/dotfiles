# Repository Review Rubric

A pinned, reproducible scoring rubric for principal-level reviews of this repo.

## Why this exists

Ad-hoc letter grades drift between review sessions: the same code scored "A-"
one round and "B+" the next, not because the repo changed but because each
round audited different territory (round 1–3 read the code; round 4 tested the
repo's contracts with external CLIs). A letter grade anchored to that round's
findings is a summary of *what the reviewer happened to look at*, not a
measure of the repo.

This rubric fixes the axes. Score every category the same way each round; the
number can only move when the repo moves. When a reviewer finds a new failure
mode, add a checklist item under the right category rather than letting it
silently deflate an unrelated score.

## How to score

- Each **category** has weighted **criteria**. A criterion is `pass` (full
  points), `partial` (half), or `fail` (zero). Prefer objective, runnable
  checks over judgement calls — every criterion names how to verify it.
- Category score = `sum(earned) / sum(possible)`. Overall = weighted mean of
  category scores.
- Map overall to a letter only at the end, using the fixed band below. Do not
  reverse-engineer criteria to hit a target letter.
- Record each round's scorecard in `## Score history` with the date, commit,
  and per-criterion verdicts, so drift is visible.

### Letter bands (fixed)

| Score   | Letter |
|---------|--------|
| ≥ 0.97  | A+     |
| ≥ 0.93  | A      |
| ≥ 0.90  | A-     |
| ≥ 0.87  | B+     |
| ≥ 0.83  | B      |
| ≥ 0.80  | B-     |
| ≥ 0.70  | C      |
| < 0.70  | D / F  |

A grade above A- **requires zero open Critical findings and no failing
`Bootstrap & lifecycle` criterion** — a repo whose installer can't boot a fresh
machine is not an A-repo regardless of how elegant its modules are. This gate
overrides the numeric band.

---

## Categories & weights

| # | Category                     | Weight |
|---|------------------------------|--------|
| 1 | Bootstrap & lifecycle        | 25%    |
| 2 | Correctness & evaluation gate| 20%    |
| 3 | Architecture & DRY           | 15%    |
| 4 | Abstraction integrity        | 10%    |
| 5 | Testing & CI coverage        | 15%    |
| 6 | Security & secrets           | 10%    |
| 7 | Maintainability & docs       | 5%     |

The weights encode a thesis: **for a dotfiles repo, the bootstrap path and the
evaluation gate matter more than module elegance**, because that's where an
outage actually comes from (a machine that won't rebuild) and it's the hardest
thing to test. Categories 1–2 are 45% of the grade for that reason.

---

### 1. Bootstrap & lifecycle (25%)

The installer's contract is with external, version-drifting CLIs (`nix`,
`nix-darwin`, the Determinate installer, Homebrew). shellcheck cannot verify
these; only execution can. This is the category round 4 found broken.

| Criterion | Weight | How to verify |
|-----------|--------|---------------|
| `install.sh` boots a fresh Linux host end-to-end on the oldest supported Nix | 3 | Run in a clean container/VM on the Nix version the Pis ship (see CLAUDE.md — 2.25.3). No CLI-signature failures (`nix profile add` vs `install`, `flake update` arg form). |
| `install.sh` boots a fresh macOS host end-to-end | 3 | Run on a clean mac or VM: Homebrew install verified, nix-darwin bootstrap path (no `darwin-rebuild` yet) succeeds. |
| `-f`/`--flake-update` runs the correct current CLI signature | 2 | `nix flake update --flake .` form; not the removed positional-path form. |
| Every external-CLI invocation is verified after the fact | 2 | Each `curl\|sh` / install step followed by `command -v … \|\| die` (no masked-failure command substitutions). |
| Failure paths give correct, reachable recovery advice | 1 | Rollback hints valid on both platforms and possible on the branch that prints them (e.g. no `darwin-rebuild --rollback` on the pre-bootstrap branch). |
| Re-running the installer is idempotent | 1 | Second run on a configured host is a no-op or clean rebuild (no `.backup` clobber abort, no duplicate `.bashrc`/`/etc/shells` lines). |
| Degrades gracefully without sudo | 1 | Standalone Home Manager install completes (or skips optional steps with a warning) when `sudo -n true` fails. |

### 2. Correctness & evaluation gate (20%)

| Criterion | Weight | How to verify |
|-----------|--------|---------------|
| `nix flake check` forces evaluation of every host config | 3 | A deliberate option typo in `base.nix` fails `nix flake check` locally, not only in CI. |
| CI covers the actual development workflow | 2 | Commits that land on `main` are gated (push trigger and/or required PR checks). Direct-to-main commits don't bypass evaluation. |
| No dead or self-contradicting config | 2 | No options set that the platform ignores (e.g. `nix.*` under `nix.enable = false`); comments match behavior. |
| `lib.mkIf`/`mkDefault`/merge precedence is correct | 2 | No override that silently loses to a default; conditional modules actually gate on the intended condition. |
| Host validation rejects malformed input | 2 | Unknown host fields throw; partial `vcs` override merges rather than clobbers; invalid system/profile throw with actionable messages. |
| CI eval loops fail closed | 1 | Pipeline failures in `nix eval \| jq` loops abort the step (pipefail), not silently iterate zero hosts. |

### 3. Architecture & DRY (15%)

| Criterion | Weight | How to verify |
|-----------|--------|---------------|
| Single source of truth for host facts | 2 | Username/system/isWork/home-dir declared once; no re-derivation in modules. |
| No duplicated logic across modules | 2 | Same behavior (task-toggle, notes workspace, home-dir path, theme) implemented once, not N times. Grep for the known duplication set. |
| Layer separation holds | 2 | System layer doesn't read HM config and vice versa; context modules carry deltas only, not base-layer work. |
| Supported-platform list declared once | 1 | `validSystems`, checks systems, formatter systems derive from one source. |

### 4. Abstraction integrity (10%)

Abstractions must deliver what they claim, measurably.

| Criterion | Weight | How to verify |
|-----------|--------|---------------|
| `packageProfile = "core"` actually produces a minimal closure | 3 | `nix path-info -Sh` on a core-profile host (pi5) excludes GUI/dev closures (nixvim LSP set, ghostty, claude-code). Measure, don't assume. |
| Profile tiers gate all heavy modules, not just `home.packages` | 2 | Heavy program modules (`neovim`, `ghostty`) guard their `config` on profile. |
| Overlaid inputs provide packages for every target system | 1 | Each `input.packages.${system}.default` referenced actually exists for aarch64-linux (Pi) and both darwins. |

### 5. Testing & CI coverage (15%)

| Criterion | Weight | How to verify |
|-----------|--------|---------------|
| State-mutating functions have tests | 3 | Functions that write files / rewrite VCS (`notes-sync`, `_hx_ensure_note`, `_note_create`) are covered; the suite fails if they break. |
| Tests are hermetic | 2 | Own tmpdir, env save/restore, no dependence on the developer's machine. |
| No tautological tests | 1 | Every test can fail (no `pass` in both branches). |
| Bootstrap path has runtime coverage, not only lint | 2 | Pure installer functions (`get_nix_system`, result parsing, `user_in_trusted`) unit-tested; `--help` smoke-run in CI. |
| CI builds (not just evals) at least one host per platform | 1 | Confirm a build step exists per platform; document what eval-only misses (aarch64 build gap). |

### 6. Security & secrets (10%)

| Criterion | Weight | How to verify |
|-----------|--------|---------------|
| No secrets or private endpoints in the repo | 3 | Grep history; secrets sourced from machine-local files. |
| No predictable shared-`/tmp` rendezvous paths | 2 | Editor/shell integrations use `$XDG_RUNTIME_DIR`/`mktemp`, not fixed `/tmp/foo` on multi-user hosts. |
| No unsanitized user data spliced into shells/evals | 2 | Buffer names, hostnames, filenames escaped before entering `fish -c`/Nix eval strings. |
| Remote code is pinned or TLS-forced | 1 | Installer downloads pin a ref or force `--proto =https --tlsv1.2`; CI actions pinned to SHA/tag, not `@main`. |
| Privilege grants are consented | 1 | `trusted-users` (root-equivalent) grant is announced or gated, not silent. |

### 7. Maintainability & docs (5%)

| Criterion | Weight | How to verify |
|-----------|--------|---------------|
| CLAUDE.md matches reality | 2 | Documented symlinks/functions exist as described (no stale `fifc`/`ft`/`jrnl` references). |
| Non-obvious decisions carry their "why" | 2 | Failure-mode comments present at the tricky spots (this repo's established strength — preserve it). |
| No unexplained magic constants with expiry | 1 | Hardcoded IDs/deadlines (zellij `tick --hosts`, dates) are documented or hoisted to options. |

---

## Score history

### 2026-07-09 — commit 86269a5 (round 4, first rubric scoring)

**Overall: 0.41 → D. Hard gate: FAIL** (Bootstrap criteria fail + open Criticals) —
capped below A- independent of the number.

| # | Category | Score | Evidence (V = verified this session, R = round-4 finding) |
|---|----------|-------|-----------|
| 1 | Bootstrap & lifecycle (25%) | 0.35 | V: `nix flake update "$SCRIPT_DIR"` is a **silent no-op** — path treated as an input name, exit 0, lock untouched, `\|\| die` never fires. `nix profile add` risks old-Nix (Pi 2.25.3) break (R). Rollback advice wrong both platforms (R). Unconditional sudo (R). Fresh mac/linux boot on old Nix **unverified** (no host) — scored partial. |
| 2 | Correctness & eval gate (20%) | 0.33 | V: `nix flake check` runs only `fish-functions` + `install-script` — **zero host eval**. V: CI triggers only `workflow_dispatch`/`pull_request`, not `push`. Dead `nix.*` under `nix.enable=false` (R). Partial-`vcs` clobber + unknown-field acceptance (V, `definitions.nix:52`). |
| 3 | Architecture & DRY (15%) | 0.64 | Thin symmetric builders (strength). Task-toggle logic ×3, notes workspace ×2 (drifted), catppuccin theme ×2 (R); platform list declared 3× (V). |
| 4 | Abstraction integrity (10%) | 0.08 | V: `neovim.nix`/`ghostty.nix` enable unconditionally, `contexts/home-manager/home.nix:19-20` adds claude-code+herdr to every non-work host → **all core-profile Pis get the heavy closure**. Profile gates only `home.packages`. |
| 5 | Testing & CI coverage (15%) | 0.50 | V: `notes-sync` tested; `_hx_ensure_note`/`_note_create` have **0 test refs**. Hermetic (strength). Tautological `_is_gnu_date` test (R). Installer has lint only, no runtime coverage (V). |
| 6 | Security & secrets (10%) | 0.50 | No secrets/endpoints in repo (strength). Predictable `/tmp` rendezvous paths (R); trusted-users granted silently (R); homebrew HEAD + CI `@main` unpinned (R). |
| 7 | Maintainability & docs (5%) | 0.60 | Failure-mode comments (strength). Stale CLAUDE.md refs (fifc/ft/jrnl); expiring zellij `tick` deadline (R). |

Takeaway: the repo scores **well on the low-weight categories (architecture,
docs) and poorly on the high-weight ones (bootstrap, correctness gate,
abstraction)**. Because the rubric weights the outage-causing categories highest
— and round 4 found the breakage there — the "A-" from earlier rounds collapses
once the axes are pinned and actually executed. This is the rubric working as
intended, not the repo regressing.

### 2026-07-09 — round 5 (after -f fix, nixvim removal, ghostty gating, tests)

**Overall: 0.60 → D** (up from 0.41). Hard gate still FAIL (Bootstrap criteria
open). Δ from round 4 in **bold**.

Two round-4 assumptions were corrected by the user this round and re-scored:
(1) the Pis run current Nix (not 2.25.3), so `nix profile add` is valid — the
old-Nix bootstrap risk is void; (2) claude-code + herdr on the Pis is
**intended** config, not closure bloat — and V: pi5's aarch64 package set
resolves with both present, so the overlay does ship aarch64 builds.

| # | Category | Score | Change / evidence (V = verified this round) |
|---|----------|-------|-----------|
| 1 | Bootstrap & lifecycle (25%) | **0.62** ↑ | V: `-f` now uses `flake update --flake` (PASS). V: `nix profile add` valid on current Nix + Pis updated → fresh-Linux-boot defect void. Still open: rollback advice wrong both platforms, unconditional sudo, Homebrew masked-failure. |
| 2 | Correctness & eval gate (20%) | 0.33 = | Unchanged — not in scope. Host-eval gate + main-push CI + pipefail + vcs-clobber still open. (User deprioritized the host-eval criterion; see note.) |
| 3 | Architecture & DRY (15%) | **0.68** ↑ | V: deleting `neovim.nix` removed the Lua task-toggle copy → task-toggle down to ×2 (helix sed + fish fn, distinct ops). Notes-workspace ×2 and platform-list ×3 still open. |
| 4 | Abstraction integrity (10%) | **1.00** ↑↑ | V: nixvim removed (LSP closure gone); ghostty gated on `dotfiles.gui` (Pis=false); heavy modules gated. claude-code+herdr on Pis is intended and V: resolves for aarch64-linux. Closure now delivers the intended core set. |
| 5 | Testing & CI coverage (15%) | **0.67** ↑ | V: `_note_create` + `_hx_ensure_note` now covered (41 tests, hermetic check green). Still open: tautological `_is_gnu_date` test, no installer runtime/unit coverage. |
| 6 | Security & secrets (10%) | 0.50 = | Unchanged — `/tmp/hx_note_path` + `/tmp/unique-file` predictable paths, silent trusted-users grant, unpinned homebrew/CI still open. |
| 7 | Maintainability & docs (5%) | 0.60 = | Unchanged — stale CLAUDE.md refs, expiring zellij `tick` deadline still open. |

Note: the user has stated they don't care about the host-evaluation criterion
(2.1, weight 3). Scored as-is here for continuity; if that criterion is dropped
as accepted-risk, category 2 → 0.44 and overall → ~0.62 (still D). Abstraction
integrity is now maxed (1.00). The grade remains D because the two heaviest
categories (bootstrap 25%, correctness 20%) still hold most of the open
criteria — reaching C (0.70) means closing the cheap bootstrap items (rollback
strings, `sudo -n` guard, Homebrew verify) and the security `/tmp` + tautology
nits.

### 2026-07-09 — round 6 (installer hardening, secure /tmp, falsifiable test)

**Overall: 0.73 → C** (up from 0.60). First crossing out of D. Hard gate no
longer relevant at this tier (nowhere near A-). Δ from round 5 in **bold**.

| # | Category | Score | Change / evidence (V = verified this round) |
|---|----------|-------|-----------|
| 1 | Bootstrap & lifecycle (25%) | **0.96** ↑↑ | V: Homebrew now download-then-run + verify (masked-failure closed); rollback advice corrected both platforms; `have_sudo` lets trusted-users + chsh skip instead of abort. Both fresh-boot criteria scored pass on *no known defect* — but **not executed on real hardware this round** (verification gap, not a defect). Only idempotency (`.backup` clobber on re-run) partial. |
| 2 | Correctness & eval gate (20%) | 0.33 = | Unchanged — out of scope (user deprioritized the host-eval criterion). |
| 3 | Architecture & DRY (15%) | 0.68 = | Unchanged — notes-workspace ×2, platform-list ×3 still open. |
| 4 | Abstraction integrity (10%) | 1.00 = | Maxed last round. |
| 5 | Testing & CI coverage (15%) | **0.78** ↑ | V: `_is_gnu_date` test now cross-checks an independent `date --version` probe (falsifiability demonstrated by injecting broken detection → fail branch). Still open: no installer runtime/unit coverage. |
| 6 | Security & secrets (10%) | **0.72** ↑ | V: `/tmp/hx_note_path` write deleted (was dead); helix yazi chooser moved to `$HOME/.cache`. Still open: unpinned homebrew/CI refs, unsanitized `space.T`/hostname, unannounced trusted-users grant. |
| 7 | Maintainability & docs (5%) | 0.60 = | Unchanged — stale CLAUDE.md refs, expiring zellij `tick` deadline. |

Note: score sits at **0.73**, clear of the 0.70 C-line. The swing factor is
criterion 1.2 (fresh macOS boot): scored pass for consistency with 1.1 (both
"no known defect, standard path"), but neither was executed on real hardware —
a strict "must run on metal" reading drops both to partial and lands the
overall at ~0.70 (right on the D/C boundary). Honest range this round: **0.70–0.73,
C**. To push into B territory: close the Correctness category (host-eval gate is
the user's call), the remaining Architecture dedup (notes-workspace, platform
list), and add installer runtime coverage (5.4).

<!--
Append one block per review round going forward. Re-score every criterion;
never reverse-engineer criteria to hit a target letter.
-->
