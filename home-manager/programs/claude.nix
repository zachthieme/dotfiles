# Claude Code plugins (mods) from claude/ — a local marketplace.
# Add a mod: drop its folder in claude/plugins/, list it in
# claude/.claude-plugin/marketplace.json and in `plugins` below.
{
  config,
  lib,
  pkgs,
  ...
}: let
  marketplace = "dotfiles";
  plugins = ["next-steps"];
  # Stable path for the marketplace: Claude Code records it in
  # ~/.claude/settings.json, so it must not be a store path that changes on
  # every rebuild. Edits to claude/ land on the next switch.
  marketplaceDir = "${config.home.homeDirectory}/.local/share/claude-marketplace";
in {
  home.file.".local/share/claude-marketplace".source = ../../claude;

  # Only where a `claude` binary exists: claude-code comes from the home
  # context's packages, but a host may also have it from the native installer
  # or Homebrew — or not at all, in which case this is a no-op. Installs are
  # idempotent; an already-installed plugin is only updated (never
  # re-enabled), so disabling one with `claude plugin disable` sticks across
  # switches.
  home.activation.claudePlugins = lib.hm.dag.entryAfter ["writeBoundary" "linkGeneration"] ''
    claude=""
    for c in \
      "${config.home.profileDirectory}/bin/claude" \
      "${config.home.homeDirectory}/.local/bin/claude" \
      /opt/homebrew/bin/claude \
      /usr/local/bin/claude; do
      if [ -x "$c" ]; then
        claude="$c"
        break
      fi
    done

    if [ -n "$claude" ]; then
      list="$("$claude" plugin list --json 2>/dev/null || echo '[]')"
      installed="$(printf '%s' "$list" | ${pkgs.jq}/bin/jq -r '.[].id' 2>/dev/null || true)"
      # Installed copies live in a per-version cache, so an edited mod only
      # lands once its plugin.json version is bumped: update when the
      # marketplace folder's version differs from the installed one.
      stale="$(printf '%s' "$list" | ${pkgs.jq}/bin/jq -r '.[] | select(.folderVersion != null and .folderVersion != .version) | .id' 2>/dev/null || true)"
      for p in ${lib.escapeShellArgs plugins}; do
        id="$p@${marketplace}"
        if ! printf '%s\n' "$installed" | grep -qxF "$id"; then
          if run "$claude" plugin install "$p" --marketplace ${lib.escapeShellArg marketplaceDir} </dev/null >/dev/null; then
            noteEcho "claude: installed plugin $id"
          else
            warnEcho "claude: could not install plugin $id"
          fi
        elif printf '%s\n' "$stale" | grep -qxF "$id"; then
          if run "$claude" plugin update "$id" </dev/null >/dev/null; then
            noteEcho "claude: updated plugin $id (restart claude to apply)"
          else
            warnEcho "claude: could not update plugin $id"
          fi
        fi
      done
    fi
  '';
}
