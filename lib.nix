{lib}: let
  # Unfree packages allowed on all hosts (vault has a BSL license)
  unfreePackages = ["vault"];

  # Get the home directory path based on the OS
  # user: string - username
  # system: string - system identifier (e.g., "aarch64-darwin", "x86_64-linux")
  # returns: string - full path to user's home directory
  getHomeDirectory = user: system:
    if lib.strings.hasSuffix "-darwin" system
    then "/Users/${user}"
    else "/home/${user}";
in {
  inherit unfreePackages getHomeDirectory;

  # Predicate for nixpkgs.config.allowUnfreePredicate — single source of truth
  # for unfree packages across darwin and standalone Home Manager builders
  allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) unfreePackages;

  # Home Manager module wiring the per-host facts from definitions.nix into
  # the user configuration — shared by both builders so they can't drift.
  # Accepts a validated host attrset (validateHost guarantees the fields).
  mkUserModule = {
    user,
    system,
    vcs,
    packageProfile,
    packages,
    gui,
    ...
  }: {
    home.username = user;
    home.homeDirectory = getHomeDirectory user system;
    # Host-specific packages install at the user level on both platforms
    home.packages = packages;
    dotfiles.vcs = vcs;
    dotfiles.packageProfile = packageProfile;
    dotfiles.gui = gui;
  };

  # Check if the system is Darwin (macOS)
  # system: string - system identifier
  # returns: bool
  isDarwin = system: lib.strings.hasSuffix "-darwin" system;

  # Check if the system is Linux
  # system: string - system identifier
  # returns: bool
  isLinux = system: lib.strings.hasSuffix "-linux" system;

  # Select the appropriate context module based on work flag
  # isWork: bool - whether this is a work machine
  # homeModule: path - path to home context module
  # workModule: path - path to work context module
  # returns: path - selected module path
  selectContextModule = isWork: homeModule: workModule:
    if isWork
    then workModule
    else homeModule;
}
