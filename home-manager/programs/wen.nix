# Wen calendar tool configuration
{ config, pkgs, lib, ... }:

let
  yaml = pkgs.formats.yaml { };
in
{
  xdg.configFile."wen/config.yaml".source = yaml.generate "wen-config.yaml" {
    theme = "catppuccin-mocha";
    fiscal_year_start = 10;
    show_fiscal_quarter = true;
    show_quarter_bar = true;
    highlight_source = "~/.local/share/pike/due.json";
  };
}
