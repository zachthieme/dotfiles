function clean-disk --description="Reclaim root-disk space: Nix GC + regenerable build caches (--deep for module caches)"
    argparse d/deep n/dry-run h/help r/root= -- $argv
    or return 1

    if set -q _flag_help
        echo "clean-disk — reclaim space on the root disk"
        echo
        echo "Usage: clean-disk [--deep] [--dry-run] [--root DIR]"
        echo
        echo "  Default   Nix GC (user + system old generations), Rust incremental"
        echo "            caches, and the Go build cache. All regenerate automatically"
        echo "            on the next build — nothing you lose but one slower rebuild."
        echo "  -d/--deep Also clear caches that cost a full rebuild or re-download:"
        echo "            whole Rust target dirs, the Go module cache, and Playwright"
        echo "            browsers."
        echo "  -n/--dry-run  Show what would be removed without deleting anything."
        echo "  -r/--root DIR Where to scan for Rust target dirs (default: ~/code)."
        return 0
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
    set -l rust_root "$HOME/code"
    set -q _flag_root; and set rust_root "$_flag_root"
    if test -d "$rust_root"
        echo
        if set -q _flag_deep
            echo "==> Rust target dirs under $rust_root (full rebuild next time)…"
        else
            echo "==> Rust incremental caches under $rust_root…"
        end

        set -l rust_freed 0
        # Cargo stamps every target dir with CACHEDIR.TAG. Requiring it keeps us
        # from deleting an unrelated directory that merely happens to be named
        # "target" (Maven, Makefile output, a source tree, …).
        for t in (find "$rust_root" -type d -name target -prune 2>/dev/null)
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

    if set -q _flag_deep
        # 4. Go module cache — re-downloads on the next build
        if type -q go
            echo
            echo "==> Go module cache (will re-download)…"
            if set -q _flag_dry_run
                echo "would run: go clean -modcache"
            else
                go clean -modcache
            end
        end

        # 5. Playwright browsers — re-download on the next `playwright install`
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
end
