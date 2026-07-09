# Fish shell configuration — settings, abbreviations, and plugins
# Functions live as real .fish files in config/fish/functions/ (see functions.nix)
{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./functions.nix
  ];

  programs.fish = {
    enable = true;

    shellInit = ''
      # Disable greeting
      set -g fish_greeting

      # Add Home Manager and Nix paths early (Linux only - must happen before interactiveShellInit)
      ${pkgs.lib.optionalString pkgs.stdenv.isLinux ''
        fish_add_path --prepend ~/.local/state/nix/profiles/home-manager/home-path/bin
        fish_add_path --prepend ~/.nix-profile/bin
        fish_add_path --prepend /nix/var/nix/profiles/default/bin
      ''}
      ${pkgs.lib.optionalString (config.dotfiles.packageProfile != "core") ''
        # rustup-managed binaries — dev profiles only (core hosts have no rust toolchain)
        fish_add_path --prepend $HOME/.cargo/bin
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

      # NOTES is set via home.sessionVariables from dotfiles.notesDir (base.nix)

      # Default only — secrets.fish (sourced above) may set its own VAULT_ADDR
      if not set -q VAULT_ADDR
        set -x VAULT_ADDR "https://vault.jjforge.cloud:8200"
      end
      # TLS verification stays ON by default. The server uses a private CA:
      # set VAULT_CACERT in secrets.fish (or, as a last resort, explicitly
      # export VAULT_SKIP_VERIFY there). Never skip verification implicitly —
      # an absent secrets.fish must not silently downgrade security.

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
