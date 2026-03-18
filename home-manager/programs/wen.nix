# Wen calendar tool configuration
{ config, pkgs, lib, ... }:

let
  yaml = pkgs.formats.yaml { };
in
{
  xdg.configFile."wen/config.yaml".source = yaml.generate "wen-config.yaml" {
    theme = "catppuccin-mocha";
  };
}
