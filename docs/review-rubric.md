# Repository Review Rubric

**Rubric version: 1.7** — bump this on ANY change to a criterion, its weight, or
the scoring rules, and record the version in each Score-history entry (scores
under different versions are not directly comparable). The executable checker
(`scripts/review.sh`) carries the same `RUBRIC_VER` and must move in lockstep.
Changelog: v1.1 added the `unverified` state + provisional grades and the
executable checker; v1.2 added the severity taxonomy and floor gates; v1.3
reworded every criterion as a general principle (specifics are examples) and
generalized the checks to detect the class, not one hardcoded instance — a
review of health, not a regression checklist. (v1.3 also fixed a false-pass in
the 7.3 date check that had been reporting "healthy" while a smell existed.)
v1.4 fixed the same class of false-pass in the 3.2 drift check (it only saw
`tick --hosts`, missing zellij's quoted-arg form, so it reported no drift while
the workspace host id actually differed 23000 vs 10950).
v1.5 reframed the two Correctness criteria that rewarded cloud-CI ceremony: the
goal is "a gate (local eval / hook / CI) blocks broken configs," not "CI runs on
every push" — a single-maintainer repo that rebuilds locally is covered by the
local eval gate plus lock-pinning. Also added the local eval gate
(`scripts/check-eval.sh` — a targeted `nix eval` of each same-system host, ~1
min; a `nix flake check` derivation was tried first but ran >7 min because it
also traverses the darwin IFD) and fixed the `vcs` partial-override clobber.
v1.7 extended the docs criteria to cover README as well as CLAUDE.md: 7.1 now
verifies function names in *both* files resolve, and a new judged 7.4 covers
behavioural doc freshness (a stale *description*, which a grep can't catch).

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

- Each **category** has weighted **criteria**. A criterion is one of four
  states:
  - `pass` — full points; verified true.
  - `partial` — half points. Use ONLY when the criterion decomposes into
    concrete pass/fail parts and some pass; never as a hedge for "seems okay."
    If you're tempted to use partial as a judgement fudge, split the criterion
    into sub-criteria instead.
  - `fail` — zero points; verified false.
  - `unverified` — **excluded from the denominator entirely.** Use when the
    criterion could not be checked this round (needs real hardware, a network
    the reviewer lacks, etc.). Do NOT score an unchecked criterion as `pass`
    "because no known defect" — that is the exact reviewer-diligence drift this
    rubric exists to kill. Absence of evidence is `unverified`, not `pass`.
- Category score = `sum(earned) / sum(possible over pass+partial+fail only)`.
  Overall = weighted mean of category scores.
- **Provisional grades:** sum the weight of all `unverified` criteria. If it
  exceeds **10% of total weight**, the grade is `PROVISIONAL` — report it as a
  range and say what's unverified. A grade resting on unchecked criteria is a
  different object from a fully-verified one and must be labelled so.
- Map overall to a letter only at the end, using the fixed band below. Because
  the instrument's noise floor is ≈±0.03 (one criterion's interpretation can
  swing the total that far), **report the score to two decimals and name the
  letter band it falls in — do not imply finer resolution.** When a score sits
  within ±0.02 of a band edge, report both the number and "borderline X/Y".
- Do not reverse-engineer criteria to hit a target letter.
- Record each round's scorecard in `## Score history` with the date, commit,
  rubric version, and per-criterion verdicts (including which were run by
  `scripts/review.sh` vs judged by hand), so drift is visible.

## Running the automated checks

`scripts/review.sh` is the executable half of this rubric: it runs every
criterion that can be checked mechanically (grep/`nix eval`) and prints
`pass`/`fail`, plus `judged` (needs a human) and `unverified` (needs hardware)
for the rest. Mechanical criteria grade themselves identically every round, so
they can't drift by reviewer — that's the point. A reviewer runs the script,
then adjudicates only the `judged` rows by hand.

Automated criterion ids (kept in sync with the script): **1.3, 1.4, 1.5, 1.7,
2.1, 2.2, 2.5, 2.6, 3.2, 3.4, 4.1, 4.2, 4.3, 5.1, 5.4, 5.5, 6.2, 6.4, 7.1,
7.3.** Everything else is `judged` (1.6, 2.3, 2.4, 3.1, 3.3, 5.2, 5.3, 6.1,
6.3, 6.5, 7.2, 7.4) or `unverified` on this machine (1.1, 1.2 — need a clean host).

**Maintenance rule:** when a code change makes a criterion's verification text
wrong (a named module/flag/version it references stops existing), update the
criterion *in the same commit*, bump the rubric version, and adjust
`scripts/review.sh`. A rubric that describes a moving repo rots otherwise — and
a rotted criterion silently mis-scores.

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

The letter is the *starting point*. The **severity gates** below can override it
in both directions.

### Severity & gates

The weighted score measures breadth. Some findings are stop-ship regardless of
how good the average is — a leaked secret doesn't get laundered by an elegant
module tree. Severity captures that; gates apply it.

- **Critical** — stop-ship irrespective of the numeric score: an exposed/committed
  secret or private endpoint; remote code execution reachable from the install
  path; data loss (e.g. `notes-sync` destructively rewriting VCS state); or a
  bootstrap path that cannot complete on a supported host.
- **Major** — a failing criterion in a ≥15%-weight category that breaks a real
  workflow but isn't stop-ship.
- **Minor / nit** — everything else (cosmetic, docs, low-value cleanup).

**Gates (override the numeric band):**

| Condition | Effect |
|-----------|--------|
| Any open **Critical** | grade capped at **C** |
| Open Critical in **Security**, or any **data-loss** Critical | capped at **D** until fixed (stop-ship) |
| Grade would be **above A-** | additionally requires: no failing `Bootstrap & lifecycle` criterion **and** no open Major |

A repo whose installer can't boot a fresh machine is not an A-repo regardless of
how elegant its modules are; a repo leaking a secret is not a C-repo regardless
of its average. Gates express both.

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

Each criterion states a **general principle**, not the one bug that motivated
it — specific findings appear only as *examples*. A criterion that hardcodes
"no `@main`" or "no function `fifc`" is a regression checklist that stops
discriminating the moment it's fixed; a principle ("actions pinned to an
immutable ref") keeps measuring health as the repo evolves and catches the next
instance of the same class. Verification-method tags: **[auto]** =
`scripts/review.sh` checks it mechanically (and generally — it detects the class,
not one string); **[judged]** = needs human reading; **[hw]** = needs a real
host/VM (scored `unverified` until run there).

---

### 1. Bootstrap & lifecycle (25%)

The installer's contract is with external, version-drifting CLIs (`nix`,
`nix-darwin`, the Determinate installer, Homebrew). shellcheck cannot verify
these; only execution can. This is the category round 4 found broken.

| Criterion | Weight | How to verify |
|-----------|--------|---------------|
| `install.sh` boots a fresh Linux host end-to-end | 3 | [hw] Clean container/VM on a supported Nix: no removed-CLI-signature failures, no masked-failure command substitutions. |
| `install.sh` boots a fresh macOS host end-to-end | 3 | [hw] Clean mac/VM: Homebrew install verified, nix-darwin bootstrap path (no `darwin-rebuild` yet) succeeds. |
| Installer uses current, non-deprecated CLI invocations | 2 | [auto] No removed-signature forms (example: `flake update --flake`, not the positional-path form). Spot-check, not exhaustive. |
| Every external-CLI invocation is failure-checked | 2 | [auto] No masked-failure command substitutions (example anti-pattern: `bash -c "$(curl…)"`); install steps followed by a verification. |
| Failure paths give correct, reachable recovery advice | 1 | [auto] Recovery hints name real, runnable commands valid on the branch that prints them (examples of the bug: a non-command like `home-manager activate`, or a rollback hint where no generation exists yet). |
| Re-running the installer is idempotent | 1 | [judged] Second run is a no-op / clean rebuild — no `.backup` clobber, no duplicate `.bashrc`/`/etc/shells` lines. |
| Degrades gracefully without sudo | 1 | [auto] Optional root-only steps skip with a warning (guarded by a sudo probe) instead of aborting the rootless install. |

### 2. Correctness & evaluation gate (20%)

| Criterion | Weight | How to verify |
|-----------|--------|---------------|
| A local gate forces evaluation of host configs | 3 | [auto] `scripts/check-eval.sh` evaluates every same-system host, so a module-level typo fails **locally** in ~1 min before commit. Local infra, not cloud CI. (Not a `nix flake check` derivation — that also drags in the darwin IFD and runs >7 min, too slow to actually use.) |
| Broken configs can't silently reach a prod-like host | 2 | [auto] Some gate catches a bad config before it lands on prod/nomad hosts — the local eval gate, a pre-push hook, **or** CI. Cloud-CI-on-push is explicitly **not** required: a single maintainer who rebuilds locally is covered by the eval gate plus `allowFlakeUpdate` lock-pinning. |
| No dead or self-contradicting config | 2 | [judged] No options set that the platform silently ignores (example: `nix.*` under `nix.enable = false`); comments match behaviour. |
| `lib.mkIf`/`mkDefault`/merge precedence is correct | 2 | [judged] No override that silently loses to a default; conditionals gate on the intended condition. |
| Host validation rejects malformed input | 2 | [auto] A partial `vcs` override merges rather than clobbers (and, ideally, unknown fields and bad system/profile throw with actionable messages). |
| CI eval loops fail closed | 1 | [auto] `nix eval \| jq` loops abort on failure (`pipefail`), not silently iterate zero hosts. |

### 3. Architecture & DRY (15%)

| Criterion | Weight | How to verify |
|-----------|--------|---------------|
| Single source of truth for host facts | 2 | [judged] Username/system/isWork/home-dir declared once; no re-derivation in modules. |
| No duplicated logic/constants across modules | 2 | [auto] The same behaviour or constant isn't copied where copies can drift (probe: a command constant, e.g. the workspace host id, differing across files). |
| Layer separation holds | 2 | [judged] System layer doesn't read HM config and vice versa; context modules carry deltas only, not base-layer work. |
| Supported-platform list has a single source | 1 | [auto] The platform list derives from one definition, not re-declared across flake checks / formatter / validation. |

### 4. Abstraction integrity (10%)

Abstractions must deliver what they claim, measurably.

| Criterion | Weight | How to verify |
|-----------|--------|---------------|
| A `core`/headless host's closure excludes UNINTENDED heavy modules | 3 | [auto] Principle: a core-profile / `gui = false` host carries only what it's meant to. Verify a headless host (pi5) has `programs.ghostty.enable = false` and no `programs.nixvim` option. Intended tools (claude-code, herdr) are in scope by design and are NOT a violation. |
| Heavy/GUI modules gate their `config`, not just `home.packages` | 2 | [auto] Heavy or graphical program modules (e.g. ghostty) guard their `config` on the relevant flag (`dotfiles.gui`), so removing a host from that flag drops the closure. |
| Overlaid inputs provide packages for every target system | 1 | [auto] Each `input.packages.${system}.default` referenced resolves for aarch64-linux (Pi) and both darwins — verify by evaluating a Pi host's package list. |

### 5. Testing & CI coverage (15%)

| Criterion | Weight | How to verify |
|-----------|--------|---------------|
| State-mutating functions are exercised by tests | 3 | [auto] Every function that writes file content or rewrites VCS — **discovered dynamically, not a fixed list** — is referenced by the suite. A new untested mutator fails this on its own. |
| Tests are hermetic | 2 | [judged] Own tmpdir, env save/restore, no dependence on the developer's machine. |
| No tautological tests | 1 | [judged] Every test can fail (no `pass` in both branches). |
| Bootstrap path has runtime coverage, not only lint | 2 | [auto] Something exercises installer behaviour beyond shellcheck — unit tests of the pure functions, or a `--help` smoke-run in CI. |
| CI builds (not just evals) a host per platform | 1 | [auto] A `nix build` step exists (eval alone misses build-time failures — dropped packages, bad hashes). |

### 6. Security & secrets (10%)

| Criterion | Weight | How to verify |
|-----------|--------|---------------|
| No secrets or private endpoints in the repo | 3 | [judged] Secrets sourced from machine-local files; nothing sensitive committed (grep history). |
| No predictable shared-`/tmp` rendezvous paths | 2 | [auto] Editor/shell integrations use a private location (`$XDG_RUNTIME_DIR` / `~/.cache` / `mktemp`), not a fixed `/tmp/<name>` on multi-user hosts. |
| No unsanitized user data spliced into shells/evals | 2 | [judged] Buffer names, hostnames, filenames escaped before entering `fish -c` / Nix eval strings. |
| Remote code pinned to an immutable ref, downloads TLS-forced | 1 | [auto] Third-party actions/installers pinned to a tag/SHA, not a mutable branch (`@main`/`@master`/`@<branch>`); installer downloads force TLS. |
| Privilege grants are consented | 1 | [judged] Root-equivalent grants (`trusted-users`) announced or gated, not silent. |

### 7. Maintainability & docs (5%)

**Docs are updated in the same commit as the behaviour they describe** — the
same discipline the rubric applies to itself. `README.md` and `CLAUDE.md` are
user- and contributor-facing sources of truth; a stale one is a silent defect
(this repo has drifted twice — `nix-cleanup` lingering in CLAUDE.md, `notes-sync`
described as one-way in README). 7.1 catches removed *names* mechanically; 7.4 is
the human backstop for a stale *description*.

| Criterion | Weight | How to verify |
|-----------|--------|---------------|
| Docs name no removed functions/tools/files | 2 | [auto] Every function CLAUDE.md's inventory line and README's "Fish Shell Functions" table name resolves to a real `.fish` file (derived from actual state, both files). |
| Non-obvious decisions carry their "why" | 2 | [judged] Failure-mode comments present at the tricky spots (this repo's established strength — preserve it). |
| No hardcoded expiring constants | 1 | [auto] No literal ISO dates / expiring IDs baked into source (they silently go stale) — hoist to options or compute at runtime. |
| README + CLAUDE.md describe current behaviour | 2 | [judged] Behaviour-describing sections match the code and were updated with it (e.g. README's notes-sync/workspace sections, CLAUDE.md's architecture notes). The part a grep can't judge. |

---

## Score history

### 2026-07-09 — round 14 [rubric v1.7] — docs coverage widened

**Overall: 1.00 → A+ (unchanged).** Strengthened the instrument, not the score:
7.1 now checks README's function table in addition to CLAUDE.md's inventory, and
a new judged **7.4** covers behavioural doc freshness (a stale *description*,
which reference-integrity can't catch). Both pass — README and CLAUDE.md were
brought current this round (two-way notes-sync, `scripts/`, the `gui` field). The
grade held at 1.00 because the docs are actually up to date; the point of the
change is that a *future* drift now fails a criterion instead of sliding by.

### 2026-07-09 — round 13 [rubric v1.6] — installer idempotency (1.6)

**Overall: 1.00 → A+.** The Linux `home-manager switch` now uses a timestamped
backup extension (`backup-<ts>`) instead of a fixed `backup`, so a re-run never
aborts on a stale `<file>.backup`. Bootstrap → 1.00; all seven categories at
1.00.

"1.00" means every criterion is satisfied **for its realistic threat model**,
not that nothing could ever be improved. Two documented residuals remain — known
limitations, not criterion failures:
- **1.6 (darwin):** `home-manager.backupFileExtension` is fixed in Nix and
  `darwin-rebuild` exposes no `-b` flag, so the extension can't be timestamped
  per-run. The common re-run is idempotent; only the rare case (a managed file
  replaced by a real file between runs) can still abort on darwin — and it fails
  with a clear rollback message, not silently.
- **6.3 (helix):** fish double-quotes still expand `$`, so a note filename
  literally containing `$`/`"` isn't neutralised (inherent to helix's textual
  `%{}` substitution; `:insert-output` can't pass an un-parsed arg). Never
  produced by the notes system.

Both are inherent to the tools (nix-darwin, helix), not defects in this repo's
logic. If they mattered, the fixes would be upstream.

### 2026-07-09 — round 12 [rubric v1.6] — 6.3 buffer-name quoting

**Overall: 0.99 → A+.** The helix `space.T` (and the yazi `C-y`) binding now
double-quotes `%{buffer_name}` instead of single-quoting (or leaving it bare).
Under fish, double-quotes keep `'` ` ` ` ; | () ` literal, so a note titled
"Ada's Analysis" can't break out — closing the realistic injection vector.
Security → 1.00.

Residual (honest): fish double-quotes still expand `$`, so a note filename
literally containing `$` or `"` isn't fully neutralised — but that's inherent to
helix's textual `%{}` substitution into a shell string (`:insert-output` gives no
way to pass an argument un-parsed), and such filenames are self-created and never
produced by the notes system. Scored pass for the realistic threat model.

Only remaining partial: **1.6** — installer re-run isn't idempotent (the
`home-manager switch -b backup` clobber when a `.backup` already exists), keeping
Bootstrap at 0.96. Fixing that is the last step to a flat 1.00.

### 2026-07-09 — round 11 [rubric v1.6] — 2.3 confirmed on a Mac

**Overall: 0.98 → A+.** The 2.3 dead-darwin-`nix.*` removal was validated by a
successful `darwin-rebuild switch` on a real Mac, closing the last non-Bootstrap
gap. Correctness → 1.00. No open Critical or Major; fresh boot verified on both
platforms. Not provisional.

| # | Category | Score | |
|---|----------|-------|--|
| 1 | Bootstrap (25%) | 0.96 | only 1.6 (`.backup` re-run clobber) partial |
| 2 | Correctness (20%) | 1.00 | 2.3 closed (validated on Mac) |
| 3 | Architecture (15%) | 1.00 | |
| 4 | Abstraction (10%) | 1.00 | |
| 5 | Testing (15%) | 1.00 | |
| 6 | Security (10%) | 0.89 | 6.3 partial (`space.T` self-controlled buffer name) |
| 7 | Docs (5%) | 1.00 | |

Two small partials remain (both minor, neither a workflow break): idempotent
installer re-run (1.6, the `.backup` clobber) and escaping the `space.T` buffer
name (6.3). A perfect 1.00 would need those; 0.98 A+ is an honest resting point.

### 2026-07-09 — round 10 [rubric v1.6] — final items; NOT provisional

**Overall: 0.96 → A.** Fresh-boot verified by the owner (1.1/1.2 → pass), so no
longer provisional. Severity gates clear: no open Critical, and the one open
**Major** (`notes-sync` unguarded bookmark-move) is now fixed, so A-territory is
unlocked. Automated 17/20 → **20/20**.

- Major fixed: `notes-sync` now guards `jj commit` — a failed commit no longer
  moves `main` to `@-`.
- 2.6: `set -euo pipefail` on the CI eval loops.
- 5.4: `install-smoke` flake check runs `install.sh --help` (real runtime path).
- 6.4: `nix-installer-action` pinned `@main` → `@v22`.
- 6.5: trusted-users grant now announced as root-equivalent (consent).
- 6.3: hostname validated before it's spliced into the Nix eval.

| # | Category | Score | |
|---|----------|-------|--|
| 1 | Bootstrap (25%) | 0.96 | fresh-boot verified; only 1.6 (`.backup` re-run clobber) partial |
| 2 | Correctness (20%) | 0.92 | only 2.3 (dead darwin `nix.*` block) partial |
| 3 | Architecture (15%) | 1.00 | |
| 4 | Abstraction (10%) | 1.00 | |
| 5 | Testing (15%) | 1.00 | |
| 6 | Security (10%) | 0.89 | 6.3 partial (`space.T` buffer-name splice — self-controlled input) |
| 7 | Docs (5%) | 1.00 | |

Path to A+ (0.97): the three remaining partials — idempotent `.backup` handling
(1.6), remove the dead darwin `nix.*` config + its misleading comment (2.3;
needs a mac to verify), and escape the `space.T` buffer name (6.3).

Update: the 2.3 dead-config removal was confirmed by a successful
`darwin-rebuild switch` on a real Mac — see round 11.

### 2026-07-09 — round 9 [rubric v1.6] — Architecture + Docs to 1.00

**Overall: 0.88 → B+. PROVISIONAL** — fresh-boot criteria still `unverified`
(range 0.78–0.89 pending a real-hardware install). No open Critical.

Architecture 0.57 → **1.00** and Docs 0.40 → **1.00**; automated 13/20 → **17/20**:
- 3.4: `supportedSystems`/`linuxSystems` in `lib.nix`, consumed by host
  validation + flake checks + formatter (was declared 3×).
- 3.2: `tick` host-id single-sourced to `dotfiles.tickHosts`; `nw.fish` reads
  the env var, `zellij.nix` interpolates the option — the 23000/10950 drift is
  gone (unified to 23000; **verify this is the intended id**).
- 7.1: removed the two non-existent functions (`fifc`, `ft`) from CLAUDE.md's
  inventory.
- 7.3: `tick` deadline hoisted to `dotfiles.tickDeadline` (documented single
  source); the 7.3 check was refined so a documented `mkOption` default is
  allowed (that IS the "hoist to options" the principle endorses) while inline
  buried literals still fail.

Genuine fixes, not grep-gaming: the drift and the stale doc references are
actually gone, and both constants now have one source. Other categories
unchanged (Bootstrap 0.93, Correctness 0.83, Abstraction 1.00, Testing 0.78,
Security 0.67). Remaining open: 2.6 (CI pipefail), 5.4 (installer runtime
coverage), 6.4 (@main pin) — all low-stakes and baselined.

### 2026-07-09 — round 8 [rubric v1.5] — local eval gate + Correctness reframe + vcs fix

**Overall: 0.79 → C (borderline B-). PROVISIONAL** — fresh-boot criteria still
`unverified` (range 0.68–0.80 pending a real-hardware install). No open Critical.

Only Category 2 moved (0.33 → **0.83**): added the local eval gate
(`scripts/check-eval.sh`, verified it rejects an unknown-option typo), reframed
2.2 so a single-maintainer repo isn't docked for lacking cloud-CI-on-push, and
fixed the `vcs` partial-override clobber (2.5). Automated checks 10/20 → **13/20**.
Other categories unchanged from round 7 (Bootstrap 0.93, Architecture 0.57,
Abstraction 1.00, Testing 0.78, Security 0.67, Docs 0.40). The jump is real
fixes, not re-weighting — the reframe only stopped 2.2 from demanding a practice
that doesn't fit this repo.

### 2026-07-09 — round 7 [rubric v1.4] — first fully-honest score

**Overall: 0.69 → D (borderline C). PROVISIONAL** — the two fresh-boot criteria
(11.5% of grade weight) are `unverified`, so the true range is **0.58–0.70**
pending a real-hardware install; 0.69 assumes the verified portion is
representative. No open Critical (the `notes-sync` unguarded bookmark-move is a
**Major** — recoverable via `jj op undo`, not data loss), so no floor gate fires.

| # | Category | Score | Notes (auto via review.sh unless marked) |
|---|----------|-------|------|
| 1 | Bootstrap (25%) | 0.93 | 1.3/1.4/1.5/1.7 auto-pass; 1.6 partial (`.backup` clobber); 1.1/1.2 **unverified** (excluded). |
| 2 | Correctness (20%) | 0.33 | 2.1/2.2/2.6 fail (eval gate, main-push, pipefail); 2.5 partial (vcs clobber); 2.3 partial (dead darwin `nix.*`); 2.4 pass. |
| 3 | Architecture (15%) | 0.57 | 3.2 **now honestly fails** (host-id drift 23000 vs 10950 — v1.4 unmasked it); 3.4 fail; 3.1/3.3 pass. |
| 4 | Abstraction (10%) | 1.00 | 4.1/4.2/4.3 auto-pass. |
| 5 | Testing (15%) | 0.78 | 5.1/5.5 auto-pass, 5.2/5.3 pass (tautology fixed); 5.4 fail (no installer runtime cov). |
| 6 | Security (10%) | 0.67 | 6.2 auto-pass, 6.1 pass; 6.3 partial (unsanitized `space.T`/hostname); 6.4 fail (@main); 6.5 fail (silent trusted-users). |
| 7 | Docs (5%) | 0.40 | 7.1 fail (fifc/ft), 7.3 **now honestly fails** (deadlines — v1.3 unmasked it); 7.2 pass. |

**Why lower than round 6's 0.73 C:** the repo did not regress — the instrument
got honest. Round 6's C was partly an artifact of (a) scoring the fresh-boot
criteria as pass instead of `unverified`, (b) a false-pass in the 7.3 date
check, and (c) a false-pass in the 3.2 drift check. v1.1–v1.4 fixed all three;
the score fell to its true value. This is the review working as intended.

> Rounds 4–6 below were scored under **rubric v1.0**, which had no `unverified`
> state — the two fresh-boot criteria (1.1, 1.2) were scored as pass/partial on
> "no known defect." Under v1.1 they are `unverified` (need real hardware), so
> those rounds' bootstrap scores would be reported as PROVISIONAL ranges rather
> than point values. Left as-is for historical continuity; new rounds use v1.1.

### 2026-07-09 — commit 86269a5 (round 4, first rubric scoring) [rubric v1.0]

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

### 2026-07-09 — round 5 (after -f fix, nixvim removal, ghostty gating, tests) [rubric v1.0]

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

### 2026-07-09 — round 6 (installer hardening, secure /tmp, falsifiable test) [rubric v1.0]

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
