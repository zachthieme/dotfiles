{ lib }:

{
  # Get the home directory path based on the OS
  # user: string - username
  # system: string - system identifier (e.g., "aarch64-darwin", "x86_64-linux")
  # returns: string - full path to user's home directory
  getHomeDirectory = user: system:
    if lib.strings.hasSuffix "-darwin" system
    then "/Users/${user}"
    else "/home/${user}";

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
    if isWork then workModule else homeModule;
}
