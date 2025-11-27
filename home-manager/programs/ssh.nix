# SSH configuration
{ ... }:

{
  programs.ssh = {
    enable = true;
    # matchBlocks = {
    #   "pi*" = {
    #     remoteCommand = "tmux attach-session -t default || tmux new-session -s default";
    #     requestTTY = "yes";
    #   };
    # };
  };
}
