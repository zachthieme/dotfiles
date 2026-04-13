# Fish shell configuration — settings, abbreviations, plugins, and shared helpers
{ pkgs, ... }:

{
  imports = [
    ./notes.nix
    ./tasks.nix
    ./utils.nix
  ];

  programs.fish = {
    enable = true;

    shellInit = ''
      # Disable greeting
      set -g fish_greeting

      # Add Home Manager and Nix paths early (Linux only - must happen before interactiveShellInit)
      ${pkgs.lib.optionalString pkgs.stdenv.isLinux ''
        fish_add_path --prepend $HOME/.cargo/bin
        fish_add_path --prepend ~/.local/state/nix/profiles/home-manager/home-path/bin
        fish_add_path --prepend ~/.nix-profile/bin
        fish_add_path --prepend /nix/var/nix/profiles/default/bin
      ''}
    '';

    interactiveShellInit = ''
      # Set catppuccin flavor
      set -g catppuccin_flavor mocha

      # Source nix and home-manager profiles (Linux only - macOS uses nix-darwin)
      ${pkgs.lib.optionalString pkgs.stdenv.isLinux ''
        if test -e /nix/var/nix/profiles/default/etc/profile.d/nix.fish
          source /nix/var/nix/profiles/default/etc/profile.d/nix.fish
        end
      ''}

      # Add tool-specific paths
      fish_add_path "$HOME/.jjforge/bin"
      fish_add_path "$HOME/.bin"

      # Enable vi key bindings
      fish_vi_key_bindings

      # source secrets file if it exists
      test -f ~/.config/fish/secrets.fish && source ~/.config/fish/secrets.fish

      set -x VAULT_ADDR "https://vault.jjforge.cloud:8200"
      set -x VAULT_SKIP_VERIFY true
      set -gx NOTES "$HOME/CloudDocs/Notes"

      # Set LS_COLORS using vivid with catppuccin theme
      set -gx LS_COLORS (vivid generate catppuccin-mocha)
    '';

    shellAbbrs = {
      j = "jrnl";
      jl = "jrnl --format short";
      jf = "jrnl @fire";
      n = "notes";
      fw = "pike -w Priority";
      fo = "pike -w Overdue";
      fu = "pike -w 'Next 3 Days'";
      td = "pike --summary";
      vi = "hx";
      ls = "eza";
      ll = "eza -la --git";
      lt = "eza -T --level=2";
    };

    functions = {
      _require_notes = {
        description = "Check NOTES env var is set and non-empty";
        body = ''
          if not set -q NOTES; or test -z "$NOTES"
            echo -e "\033[31mError:\033[0m NOTES environment variable not set"
            return 1
          end
        '';
      };

      _require_notes_dir = {
        description = "Check NOTES env var is set and directory exists";
        body = ''
          _require_notes; or return 1
          if not test -d "$NOTES"
            echo -e "\033[31mError:\033[0m NOTES directory does not exist: $NOTES"
            return 1
          end
        '';
      };

      _slugify = {
        description = "Convert string to lowercase slug";
        body = ''
          string lower -- $argv | string replace -a ' ' '-'
        '';
      };

      _titlecase = {
        description = "Convert string to Title Case";
        body = ''
          set -l result
          for word in (string split ' ' -- $argv)
            set -l first (string sub -l 1 -- $word | string upper)
            set -l rest (string sub -s 2 -- $word | string lower)
            set result $result "$first$rest"
          end
          string join ' ' -- $result
        '';
      };

      _is_gnu_date = {
        description = "Test whether date is GNU coreutils (vs BSD)";
        body = ''
          date -d "1 day ago" +%Y-%m-%d &>/dev/null
        '';
      };
    };

    plugins = [
      {
        name = "catppuccin";
        src = pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "fish";
          rev = "af622a6e247806f6260c00c6d261aa22680e5201";
          hash = "sha256-KD/sWXSXYVlV+n7ft4vKFYpIMBB3PSn6a6jz+ZIMZvQ=";
        };
      }
      {
        name = "pure";
        src = pkgs.fishPlugins.pure.src;
      }
    ];
  };
}
