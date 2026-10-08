# Voice Memos → Markdown transcripts, fully local: whisper.cpp (Metal on Apple
# Silicon) with the large-v3-turbo model. Enabled per host with
# `transcribeVoiceMemos = true` in hosts/definitions.nix; macOS only.
#
# The launchd agent itself is a nix-darwin user agent (system/voice-memos.nix),
# not a Home Manager one — see that file for why. This module owns the option,
# the model and the package, and hands the package to it.
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
in {
  options.dotfiles.voiceMemos = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Transcribe new Apple Voice Memos to ~/Documents/Voice Memo Transcripts with a launchd agent. macOS only; set per-host via transcribeVoiceMemos in hosts/definitions.nix.";
    };
    package = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      internal = true;
      default = transcribe-memos;
      description = "The transcribe-memos script, for the nix-darwin agent in system/voice-memos.nix.";
    };
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
  };
}
