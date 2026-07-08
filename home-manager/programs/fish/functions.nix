# Symlinks every .fish file in config/fish/functions/ into fish's autoload
# directory. Functions live as real .fish files (editable, lintable with
# `fish -n`, testable via the fish-functions flake check) instead of Nix
# string literals — see CLAUDE.md "Fish Functions".
#
# Files in darwin/ are macOS-only and symlinked only on Darwin hosts.
{
  pkgs,
  lib,
  ...
}: let
  functionsDir = ../../../config/fish/functions;

  fishFiles = dir:
    lib.filterAttrs
    (name: type: type == "regular" && lib.hasSuffix ".fish" name)
    (builtins.readDir dir);

  linkFunctions = dir:
    lib.mapAttrs'
    (name: _:
      lib.nameValuePair "fish/functions/${name}" {source = dir + "/${name}";})
    (fishFiles dir);
in {
  xdg.configFile =
    linkFunctions functionsDir
    // lib.optionalAttrs pkgs.stdenv.isDarwin (linkFunctions (functionsDir + "/darwin"));
}
