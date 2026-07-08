# Fish functions for macOS-specific tools (aerospace, etc.)
{
  pkgs,
  lib,
  ...
}: {
  programs.fish.functions = lib.optionalAttrs pkgs.stdenv.isDarwin {
    aero-tidy = {
      description = "Move all windows to their assigned workspaces";
      body = ''
        set -l moved 0

        for line in (aerospace list-windows --all --format '%{window-id}|%{app-bundle-id}')
          set -l parts (string split '|' -- $line)
          set -l wid $parts[1]
          set -l bid $parts[2]

          set -l target
          switch $bid
            case com.mitchellh.ghostty com.github.wez.wezterm
              set target 1_Code
            case 'com.google.Chrome.app.faolnafnngnfdaknnbpnkhgohbobgegn'
              set target 2_Mail
            case com.tinyspeck.slackmacgap com.apple.MobileSMS
              set target 3_IM
            case com.microsoft.teams2
              set target 4_Teams
            case com.brave.Browser com.google.Chrome
              set target 5_Web
          end

          if set -q target[1]
            aerospace move-node-to-workspace --window-id $wid $target
            set moved (math $moved + 1)
          end
        end

        echo "Moved $moved window(s)"
      '';
    };
  };
}
