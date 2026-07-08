# Fish shell configuration — settings, abbreviations, and plugins
# Functions live as real .fish files in config/fish/functions/ (see functions.nix)
{pkgs, ...}: {
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

      # NOTES is set via home.sessionVariables from dotfiles.notesDir (base.nix)

      set -x VAULT_ADDR "https://vault.jjforge.cloud:8200"
      # Prefer proper TLS: set VAULT_CACERT to the private CA in secrets.fish.
      # Skip verification only as a fallback when no CA cert is configured.
      if not set -q VAULT_CACERT
        set -x VAULT_SKIP_VERIFY true
      end

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
