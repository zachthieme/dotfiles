# transcribe-memos: the Voice Memos → Markdown script. Every dependency is a
# store path on its PATH, and writeShellApplication shellchecks it at build
# time. Callable on any platform so `nix flake check` (Linux) builds — and so
# shellchecks — it too; only the launchd agent is macOS-specific.
{
  coreutils,
  ffmpeg,
  gnugrep,
  gnused,
  sqlite,
  whisper-cpp,
  writeShellApplication,
  # Model file baked in as the default; WHISPER_MODEL overrides at runtime.
  model,
}:
writeShellApplication {
  name = "transcribe-memos";
  runtimeInputs = [coreutils ffmpeg gnugrep gnused sqlite whisper-cpp];
  runtimeEnv.DEFAULT_WHISPER_MODEL = "${model}";
  text = builtins.readFile ../config/transcribe-memos/transcribe-memos.sh;
}
