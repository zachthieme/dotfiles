# Linux-specific configuration
{ pkgs, lib, ... }:

{
  # Mark as home context (not work)
  local.isWork = false;

  # Set home directory path for Linux
  users.users.${config.local.username} = lib.mkForce {
    home = "/home/${config.local.username}";
    shell = pkgs.zsh;
  };

  # Linux-specific packages
  environment.systemPackages = with pkgs; [
    # GUI applications
  ];

  # Linux-specific hardware configuration
  hardware = {
  };

  # Linux networking
  networking = {
  };

  # Fonts
  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      dejavu_fonts
      font-awesome
      noto-fonts
      noto-fonts-emoji
      fira-code
      fira-code-symbols
    ];
  };

  # Enable some system services
  services = {
    # openssh.enable = true;
  };

  # Time zone and locale
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";
}
