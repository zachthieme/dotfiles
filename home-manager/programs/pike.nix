# Pike task extraction tool configuration
{ config, pkgs, lib, ... }:

let
  yaml = pkgs.formats.yaml { };

  # Catppuccin Mocha palette
  colors = {
    red = "#f38ba8";
    maroon = "#eba0ac";
    peach = "#fab387";
    yellow = "#f9e2af";
    green = "#a6e3a1";
    teal = "#94e2d3";
    sky = "#89dceb";
    sapphire = "#74c7ec";
    blue = "#89b4fa";
    lavender = "#b4befe";
    mauve = "#cba6f7";
    pink = "#f5c2e7";
  };

  commonSettings = {
    notes_dir = "~/CloudDocs/Notes";
    include = [ "**/*.md" ];
    exclude = [
      "templates/**"
      "archive/**"
      "CLAUDE.md"
      "reviews/**"
    ];
    refresh_interval = "5s";
    editor = "hx";
    link_color = colors.sapphire;
    tag_colors = {
      risk = colors.red;
      due = colors.maroon;
      today = colors.green;
      completed = colors.teal;
      weekly = colors.blue;
      monthly = colors.lavender;
      quarterly = colors.mauve;
      horizon = colors.yellow;
      talk = colors.pink;
      delegated = colors.peach;
      _default = colors.sky;
    };
  };
in
{
  xdg.configFile."pike/config.yaml".source = yaml.generate "pike-config.yaml" (commonSettings // {
    views = [
      {
        title = "Weekly";
        query = "open and @weekly";
        sort = "due_asc";
        color = colors.blue;
        order = 1;
      }
      {
        title = "Today";
        query = "open and @today";
        sort = "due_asc";
        color = colors.green;
        order = 2;
      }
      {
        title = "Overdue";
        query = "open and @due < today";
        sort = "due_asc";
        color = colors.red;
        order = 3;
      }
      {
        title = "Next 3 Days";
        query = "open and @due >= today and @due <= today+3d";
        sort = "due_asc";
        color = colors.yellow;
        order = 4;
      }
      {
        title = "Talk";
        query = "open and @talk";
        sort = "file";
        color = colors.pink;
        order = 5;
      }
      {
        title = "Delegated";
        query = "open and @delegated";
        sort = "file";
        color = colors.peach;
        order = 6;
      }
      {
        title = "Horizon";
        query = "@risk or @horizon";
        sort = "file";
        color = colors.mauve;
        order = 7;
      }
    ];
  });

  xdg.configFile."pike/todo.yaml".source = yaml.generate "pike-todo.yaml" (commonSettings // {
    views = [
      {
        title = "Priority";
        query = "open and (@weekly or @today)";
        sort = "due_asc";
        color = colors.sky;
        order = 1;
      }
    ];
  });
}
