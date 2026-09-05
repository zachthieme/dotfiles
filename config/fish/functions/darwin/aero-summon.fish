function aero-summon --description="Bring an app's window to the focused workspace"
    if test (count $argv) -eq 0
        echo "usage: aero-summon <app-bundle-id> [title-glob]" >&2
        return 2
    end

    # Optional title glob disambiguates apps with several windows under one
    # bundle id (every ghostty window is com.mitchellh.ghostty).
    set -l title_glob '*'
    if test (count $argv) -ge 2
        set title_glob $argv[2]
    end

    set -l wid (aerospace list-windows --all --format '%{window-id}|%{app-bundle-id}|%{window-title}' | string match -- "*|$argv[1]|$title_glob" | cut -f1 -d'|' | sort -n | head -n1)

    if test -z "$wid"
        if test (count $argv) -ge 2
            echo "No window found for $argv[1] matching title '$title_glob'" >&2
        else
            echo "No window found for $argv[1]" >&2
        end
        return 1
    end

    aerospace move-node-to-workspace --focus-follows-window --window-id $wid (aerospace list-workspaces --focused)
end
