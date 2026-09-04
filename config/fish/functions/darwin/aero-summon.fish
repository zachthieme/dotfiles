function aero-summon --description="Bring an app's window to the focused workspace"
    if test (count $argv) -eq 0
        echo "usage: aero-summon <app-bundle-id>" >&2
        return 2
    end

    set -l wid (aerospace list-windows --all --format '%{window-id}|%{app-bundle-id}' | string match -- "*|$argv[1]" | cut -f1 -d'|' | sort -n | head -n1)

    if test -z "$wid"
        echo "No window found for $argv[1]" >&2
        return 1
    end

    aerospace move-node-to-workspace --focus-follows-window --window-id $wid (aerospace list-workspaces --focused)
end
