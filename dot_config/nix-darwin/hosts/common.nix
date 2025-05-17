{ pkgs, ... }:

{
  users.users.zach = {
    name = "zach";
    home = "/Users/zach";
  };

  nix.settings.experimental-features = "nix-command flakes";
  nixpkgs.hostPlatform = "aarch64-darwin"; # or "x86_64-darwin"
  system.stateVersion = 6;

  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    neovim bat fzf git zoxide tmux
  ];

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
