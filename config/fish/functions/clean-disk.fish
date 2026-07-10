function clean-disk --description="Reclaim root-disk space: Nix GC + regenerable build caches (--deep for module caches)"
    argparse d/deep n/dry-run h/help -- $argv
    or return 1

    if set -q _flag_help
        echo "clean-disk — reclaim space on the root disk"
        echo
        echo "Usage: clean-disk [--deep] [--dry-run]"
        echo
        echo "  Default   Nix GC (user + system old generations) + Go build cache."
        echo "            Both regenerate automatically on next build — nothing you lose."
        echo "  -d/--deep Also clear caches that must re-download: Go module cache and"
        echo "            Playwright browsers."
        echo "  -n/--dry-run  Show what would be removed without deleting anything."
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

    # 2. Go build cache — fully regenerates on the next build
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
        # 3. Go module cache — re-downloads on the next build
        if type -q go
            echo
            echo "==> Go module cache (will re-download)…"
            if set -q _flag_dry_run
                echo "would run: go clean -modcache"
            else
                go clean -modcache
            end
        end

        # 4. Playwright browsers — re-download on the next `playwright install`
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
