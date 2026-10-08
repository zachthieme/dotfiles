# The launchd agent for Voice Memos transcription (home-manager/programs/
# voice-memos.nix owns the option, model and package). Enabled by the same
# per-host transcribeVoiceMemos flag, read back from the Home Manager config.
#
# Full Disk Access, measured with launchd jobs on macOS 27 (not assumed):
# - TCC judges the binary that opens the file. Children do NOT inherit a
#   launchd job's grant: under a granted /bin/bash, a Nix `ls` was denied.
# - The grant only counts for the binary launchd spawned. Through
#   `/bin/sh -c "exec /bin/bash …"`, even bash's own reads were denied.
# So launchd must start /bin/bash directly, and the script has bash itself
# open everything in the container (see transcribe-memos.sh).
#
# Why nix-darwin and not Home Manager's launchd.agents: Home Manager always
# wraps ProgramArguments in `/bin/sh -c "/bin/wait4path /nix/store && exec …"`,
# which is exactly the case above. nix-darwin passes serviceConfig through
# unchanged (it only wraps its `command` option). Without wait4path, a run
# at boot before the store mounts just fails; the next trigger retries it.
#
# Passing the script as a file to /bin/bash means the shebang (Nix's bash) is
# never used, so the script must stay bash 3.2 compatible.
{
  config,
  lib,
  ...
}: let
  user = config.local.username;
  home = config.users.users.${user}.home;
  memos = config.home-manager.users.${user}.dotfiles.voiceMemos;
in {
  config = lib.mkIf memos.enable {
    # Label: org.nixos.transcribe-memos
    launchd.user.agents.transcribe-memos.serviceConfig = {
      ProgramArguments = ["/bin/bash" "${memos.package}/bin/transcribe-memos"];
      # Fires when the folder's entries change (a memo synced in). A file
      # still downloading when that fired is skipped and picked up by the
      # 15-minute fallback.
      WatchPaths = ["${home}/Library/Group Containers/group.com.apple.VoiceMemos.shared/Recordings"];
      StartInterval = 900;
      RunAtLoad = true;
      # The script logs here itself; this catches only failures before its
      # own redirect (e.g. bash failing to start it).
      StandardOutPath = "${home}/Library/Logs/transcribe-memos.log";
      StandardErrorPath = "${home}/Library/Logs/transcribe-memos.log";
    };
  };
}
