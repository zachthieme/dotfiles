function clean-disk --description="Reclaim root-disk space: Nix GC + regenerable build caches (--deep for module caches)"
    argparse d/deep n/dry-run h/help r/root= tmp-age= no-report -- $argv
    or return 1

    if set -q _flag_help
        echo "clean-disk — reclaim space on the root disk"
        echo
        echo "Usage: clean-disk [--deep] [--dry-run] [--root DIR] [--tmp-age DAYS]"
        echo "                  [--no-report]"
        echo
        echo "  Default   Nix GC (user + system old generations), Rust incremental"
        echo "            caches, the Go build cache, Docker build cache + dangling"
        echo "            images, unreferenced pnpm/uv store entries, and abandoned"
        echo "            build scratch under /tmp. All regenerate automatically on"
        echo "            the next build — nothing you lose but one slower rebuild."
        echo "  -d/--deep Also clear caches that cost a full rebuild or re-download:"
        echo "            whole Rust target dirs, the Go module cache, ALL unused"
        echo "            Docker images (docker system prune -a), npm/pip download"
        echo "            caches, the cargo registry, Nix fetcher caches, unbuilt"
        echo "            Helix grammar sources, the shared sccache, and"
        echo "            Playwright browsers. Docker volumes are never touched."
        echo "  -n/--dry-run  Show what would be removed without deleting anything."
        echo "  -r/--root DIR Where to scan for Rust target dirs (default: ~/code)."
        echo "                \$CARGO_TARGET_DIR is always included when set."
        echo "  --tmp-age DAYS  Only reap /tmp scratch untouched for this many days"
        echo "                  (default: 2). Guards against deleting live builds."
        echo "  --no-report   Skip the closing scan of the largest space consumers."
        return 0
    end

    set -l tmp_age 2
    if set -q _flag_tmp_age
        if not string match -qr '^[0-9]+$' -- "$_flag_tmp_age"
            echo "clean-disk: --tmp-age expects a whole number of days" >&2
            return 1
        end
        set tmp_age "$_flag_tmp_age"
    end

    set -l avail_before (df -k / | tail -1 | awk '{print $4}')

    echo "Root disk before:"
    df -h /

    # 1. Nix store — remove old generations and unreferenced paths (usually the biggest win)
    echo
    echo "==> Nix store: collecting garbage…"
    # nix-collect-garbage lives in the Nix profile — on the user's PATH but not
    # in root's sudo PATH, so bare `sudo nix-collect-garbage` fails with
    # "command not found". Resolve the absolute path and hand that to sudo.
    set -l ngc (command -v nix-collect-garbage)
    if test -z "$ngc"
        echo "clean-disk: nix-collect-garbage not found on PATH" >&2
        return 1
    end
    # Two passes. The user pass (no sudo) expires THIS user's profile
    # generations — including standalone Home Manager under
    # ~/.local/state/nix/profiles, which the root pass does not reap. The system
    # pass (sudo) expires root/system generations and does the privileged store
    # sweep. User first so its now-unreferenced paths get swept by the root pass.
    set -l gc_flags -d
    set -q _flag_dry_run; and set -a gc_flags --dry-run
    echo "-- user generations --"
    $ngc $gc_flags
    echo "-- system generations --"
    sudo $ngc $gc_flags

    # 2. Rust target dirs — on a dev machine these dwarf everything else. Two
    # tiers: `incremental/` alone is a pure rebuild-speed cache (compiled
    # dependencies in `deps/` survive, so nothing re-downloads and no cold
    # rebuild), while --deep drops whole target dirs and costs a full rebuild.
    #
    # Two sources, and BOTH matter. Scanning only for per-project target/ dirs
    # silently reclaimed nothing on any machine that sets CARGO_TARGET_DIR:
    # cargo redirects every build there, so no project ever grows a local
    # target/ for the scan to find. That blind spot let a shared target dir
    # reach 51 GiB unnoticed.
    set -l rust_root "$HOME/code"
    set -q _flag_root; and set rust_root "$_flag_root"

    set -l target_dirs
    if set -q CARGO_TARGET_DIR; and test -d "$CARGO_TARGET_DIR"
        set -a target_dirs "$CARGO_TARGET_DIR"
    end
    if test -d "$rust_root"
        for t in (find "$rust_root" -type d -name target -prune 2>/dev/null)
            contains -- "$t" $target_dirs; or set -a target_dirs "$t"
        end
    end

    if test (count $target_dirs) -gt 0
        echo
        if set -q _flag_deep
            echo "==> Rust target dirs (full rebuild next time)…"
        else
            echo "==> Rust incremental caches…"
        end

        set -l rust_freed 0
        # Cargo stamps every target dir with CACHEDIR.TAG. Requiring it keeps us
        # from deleting an unrelated directory that merely happens to be named
        # "target" (Maven, Makefile output, a source tree, …).
        for t in $target_dirs
            test -f "$t/CACHEDIR.TAG"; or continue

            set -l victims
            if set -q _flag_deep
                set victims "$t"
            else
                # incremental/ sits at target/<profile>/ or target/<triple>/<profile>/
                set victims (find "$t" -maxdepth 3 -type d -name incremental 2>/dev/null)
            end

            for v in $victims
                set -l sz (du -sm "$v" 2>/dev/null | cut -f1)
                test -n "$sz"; or continue
                set rust_freed (math "$rust_freed + $sz")
                if set -q _flag_dry_run
                    printf "  would remove %6s MB  %s\n" $sz "$v"
                else
                    printf "  removing %6s MB  %s\n" $sz "$v"
                    rm -rf "$v"
                end
            end
        end

        if test $rust_freed -eq 0
            echo "  nothing to reclaim"
        else if test $rust_freed -lt 1024
            printf "  subtotal: %s MB\n" $rust_freed
        else
            printf "  subtotal: %.1f GiB\n" (math "$rust_freed / 1024")
        end
    end

    # 3. Go build cache — fully regenerates on the next build
    if type -q go
        echo
        echo "==> Go build cache…"
        if set -q _flag_dry_run
            echo "would run: go clean -cache"
        else
            go clean -cache
        end
    end

    # 4. Docker — build cache and dangling images regenerate on the next
    # build/pull. --deep widens to everything unused (stopped containers,
    # networks, ALL unreferenced images). Volumes are never pruned — they can
    # hold real data, not just cache.
    if type -q docker; and docker info >/dev/null 2>&1
        echo
        if set -q _flag_deep
            echo "==> Docker: all unused images, containers, build cache…"
            if set -q _flag_dry_run
                docker system df
                echo "would run: docker system prune -af"
            else
                docker system prune -af
            end
        else
            echo "==> Docker: build cache + dangling images…"
            if set -q _flag_dry_run
                docker system df
                echo "would run: docker builder prune -f; docker image prune -f"
            else
                docker builder prune -f
                docker image prune -f
            end
        end
    end

    # 5. Abandoned build scratch under /tmp. Agent sessions and worktree builds
    # strand whole cargo target dirs and Go temp dirs here; on a machine that
    # never reboots nothing ever reaps them. Three guards keep this from
    # touching live work: only paths owned by this user, only recognised build
    # scratch (CACHEDIR.TAG-stamped target dirs, go-build*/go-link*), and only
    # when nothing inside has been touched for --tmp-age days. The mtime probe
    # looks *inside* each directory — a directory's own mtime only moves when
    # entries are added or removed, so an actively-compiling target dir can
    # look stale from the outside.
    if test -d /tmp
        echo
        echo "==> Abandoned build scratch in /tmp (untouched $tmp_age+ days)…"

        set -l tmp_victims
        for tag in (find /tmp -maxdepth 4 -name CACHEDIR.TAG -user "$USER" 2>/dev/null)
            set -a tmp_victims (path dirname "$tag")
        end
        for d in (find /tmp -maxdepth 1 -type d -user "$USER" \( -name 'go-build*' -o -name 'go-link*' \) 2>/dev/null)
            set -a tmp_victims "$d"
        end

        set -l tmp_freed 0
        for v in $tmp_victims
            # Skip anything with a file modified inside the window. -quit stops
            # at the first hit, so this stays cheap on huge trees.
            #
            # -mtime -N is POSIX; GNU's relative `-newermt "-N days"` is not.
            # bfs (the find on this machine) rejects that spelling outright and
            # BSD find parses it differently — and with stderr silenced the
            # failure reads as "no recent files", i.e. delete a live build dir.
            set -l recent (find "$v" -mtime -$tmp_age -print -quit 2>/dev/null)
            test -n "$recent"; and continue

            set -l sz (du -sm "$v" 2>/dev/null | cut -f1)
            test -n "$sz"; or continue
            set tmp_freed (math "$tmp_freed + $sz")
            if set -q _flag_dry_run
                printf "  would remove %6s MB  %s\n" $sz "$v"
            else
                printf "  removing %6s MB  %s\n" $sz "$v"
                rm -rf "$v"
            end
        end

        if test $tmp_freed -eq 0
            echo "  nothing to reclaim"
        else if test $tmp_freed -lt 1024
            printf "  subtotal: %s MB\n" $tmp_freed
        else
            printf "  subtotal: %.1f GiB\n" (math "$tmp_freed / 1024")
        end
    end

    # 6. Package-store prunes that only drop unreferenced entries — safe by design
    if type -q pnpm
        echo
        echo "==> pnpm store (unreferenced packages)…"
        if set -q _flag_dry_run
            echo "would run: pnpm store prune"
        else
            pnpm store prune
        end
    end
    if type -q uv
        echo
        echo "==> uv cache (unused entries)…"
        if set -q _flag_dry_run
            echo "would run: uv cache prune"
        else
            uv cache prune
        end
    end

    if set -q _flag_deep
        # 6. Go module cache — re-downloads on the next build
        if type -q go
            echo
            echo "==> Go module cache (will re-download)…"
            if set -q _flag_dry_run
                echo "would run: go clean -modcache"
            else
                go clean -modcache
            end
        end

        # 7. Download caches — everything here re-downloads on demand
        if type -q npm
            echo
            echo "==> npm cache (will re-download)…"
            if set -q _flag_dry_run
                echo "would run: npm cache clean --force"
            else
                npm cache clean --force
            end
        end
        if type -q pip
            echo
            echo "==> pip cache (will re-download)…"
            if set -q _flag_dry_run
                echo "would run: pip cache purge"
            else
                pip cache purge
            end
        end

        # 8. Cargo registry — crate sources and index re-download on the next build
        set -l cargo_reg "$HOME/.cargo/registry"
        if test -d "$cargo_reg"
            echo
            echo "==> Cargo registry (will re-download)…"
            if set -q _flag_dry_run
                echo "would remove: $cargo_reg ("(du -sh "$cargo_reg" | cut -f1)")"
            else
                rm -rf "$cargo_reg"
            end
        end

        # 9. Nix eval/fetcher caches — evals redo, flake inputs re-download.
        # This is ~/.cache/nix, NOT the store; the store is handled by GC above.
        set -l nix_cache "$HOME/.cache/nix"
        if test -d "$nix_cache"
            echo
            echo "==> Nix eval/fetcher caches (will re-download)…"
            if set -q _flag_dry_run
                echo "would remove: $nix_cache ("(du -sh "$nix_cache" | cut -f1)")"
            else
                rm -rf "$nix_cache"
            end
        end

        # 10. Helix tree-sitter grammar sources. `hx --grammar fetch` clones a
        # git checkout per grammar; `--grammar build` then compiles them to
        # .so files and never needs the sources again. A nix-installed helix
        # ships its own prebuilt runtime, so a sources/ tree with no compiled
        # .so beside it is a stranded fetch — pure dead weight. Bail out if
        # anything was actually built here, since then this runtime is live.
        set -l hx_grammars "$HOME/.config/helix/runtime/grammars"
        if test -d "$hx_grammars/sources"
            set -l built (find "$hx_grammars" -maxdepth 1 -name '*.so' 2>/dev/null)
            if test (count $built) -gt 0
                echo
                echo "==> Helix grammar sources: skipped ("(count $built)" built grammars present)"
            else
                echo
                echo "==> Helix grammar sources (unbuilt, will re-fetch)…"
                if set -q _flag_dry_run
                    echo "would remove: $hx_grammars/sources ("(du -sh "$hx_grammars/sources" | cut -f1)")"
                else
                    rm -rf "$hx_grammars/sources"
                end
            end
        end

        # 11. sccache. Only in --deep: it is LRU-bounded by SCCACHE_CACHE_SIZE,
        # so unlike the unbounded target dir it replaced it cannot run away —
        # and dropping it costs a cold recompile for every project sharing it.
        set -l scc_dir "$SCCACHE_DIR"
        test -n "$scc_dir"; or set scc_dir "$HOME/.cache/sccache"
        if test -d "$scc_dir"
            echo
            echo "==> sccache (shared rustc cache, will recompile)…"
            if set -q _flag_dry_run
                echo "would remove: $scc_dir ("(du -sh "$scc_dir" | cut -f1)")"
            else
                # Stop the server first: it holds the LRU index in memory and
                # would rewrite entries into a directory we just emptied.
                type -q sccache; and sccache --stop-server >/dev/null 2>&1
                rm -rf "$scc_dir"
                mkdir -p "$scc_dir"
            end
        end

        # 12. Playwright browsers — re-download on the next `playwright install`
        set -l pw "$HOME/.cache/ms-playwright"
        if test -d "$pw"
            echo
            echo "==> Playwright browser cache (will re-download)…"
            if set -q _flag_dry_run
                echo "would remove: $pw ("(du -sh "$pw" | cut -f1)")"
            else
                rm -rf "$pw"
            end
        end
    end

    echo
    echo "Root disk after:"
    df -h /

    if not set -q _flag_dry_run
        set -l avail_after (df -k / | tail -1 | awk '{print $4}')
        set -l reclaimed_gib (math "($avail_after - $avail_before) / 1024 / 1024")
        echo
        printf "Reclaimed: %.1f GiB\n" $reclaimed_gib
    end

    # What's left, largest first. Every cache this function knows about is now
    # empty, so whatever tops this list is either real data or a new kind of
    # drift worth teaching clean-disk about. Without it, growth in a directory
    # nobody thought to check stays invisible until the disk fills.
    if not set -q _flag_no_report
        echo
        echo "Largest remaining (>1 GiB, one level under ~ and /tmp):"
        begin
            du -x -d1 "$HOME" 2>/dev/null
            du -x -d1 /tmp 2>/dev/null
        end | awk -v home="$HOME" '
            $1 > 1048576 && $2 != home && $2 != "/tmp" {
                printf "  %6.1f GiB  %s\n", $1 / 1048576, $2
            }' | sort -rn -k1
    end
end
