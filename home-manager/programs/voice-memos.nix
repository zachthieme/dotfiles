# Voice Memos → Markdown transcripts, fully local: whisper.cpp (Metal on Apple
# Silicon) with the large-v3-turbo model. Enabled per host with
# `transcribeVoiceMemos = true` in hosts/definitions.nix; macOS only.
#
# Full Disk Access: the Recordings folder is TCC-protected, and TCC grants are
# keyed on the binary's path, so a grant on the script's store path would be
# lost on every rebuild. The agent instead runs the stable /bin/bash, which is
# what gets FDA, once. The script runs as a child of that bash (no `exec`), and
# children inherit their parent's TCC "responsible process" — exec would swap
# the process image for Nix's bash, which is not the binary that was granted.
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.dotfiles.voiceMemos;

  # Pinned to a commit of the upstream model repo; the hash is the file's
  # Git LFS sha256, so the 1.6 GB download is verified and lives in the store.
  model = pkgs.fetchurl {
    name = "ggml-large-v3-turbo.bin";
    url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/5359861c739e955e79d9a303bcbc70fb988958b1/ggml-large-v3-turbo.bin";
    hash = "sha256-H8cPd0046xaZk6w5Huo1fvR8iHV+9y7llDh5t+jivGk=";
  };

  transcribe-memos = pkgs.callPackage ../../packages/transcribe-memos.nix {inherit model;};

  home = config.home.homeDirectory;
in {
  options.dotfiles.voiceMemos.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Transcribe new Apple Voice Memos to ~/Documents/Voice Memo Transcripts with a launchd agent. macOS only; set per-host via transcribeVoiceMemos in hosts/definitions.nix.";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = pkgs.stdenv.isDarwin;
        message = "dotfiles.voiceMemos (transcribeVoiceMemos) is macOS-only: it reads the Voice Memos container and runs as a launchd agent.";
      }
    ];

    # whisper-cpp and ffmpeg also on PATH for ad-hoc use; the script itself
    # references its own store paths and does not depend on these.
    home.packages = [transcribe-memos pkgs.ffmpeg pkgs.whisper-cpp];

    # Label: org.nix-community.home.transcribe-memos
    launchd.agents.transcribe-memos = {
      enable = true;
      config = {
        ProgramArguments = ["/bin/bash" "-c" "${transcribe-memos}/bin/transcribe-memos"];
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
  };
}
