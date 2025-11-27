# Helix editor configuration
{ ... }:

{
  programs.helix = {
    enable = true;
    settings = {
      theme = "everforest_dark";
      editor = {
        auto-format = true;
        auto-save = true;
        color-modes = true;
        completion-replace = true;
        cursorline = true;
        end-of-line-diagnostics = "hint";
        idle-timeout = 0;
        line-number = "relative";
        mouse = false;
        true-color = true;
        inline-diagnostics.cursor-line = "warning";
        cursor-shape.insert = "bar";
        file-picker = {
          git-ignore = false;
          hidden = false;
        };
        indent-guides = {
          character = "┊";
          render = true;
          skip-levels = 0;
        };
        lsp.display-messages = true;
        soft-wrap = {
          enable = true;
          max-indent-retain = 40;
          max-wrap = 10;
        };
        statusline = {
          mode.insert = "I";
          mode.normal = "N";
          mode.select = "S";
        };
      };
      keys.normal = {
        a = [ "append_mode" "collapse_selection" ];
        i = [ "insert_mode" "collapse_selection" ];
        esc = [ "collapse_selection" "keep_primary_selection" ];
        X = "extend_line_above";
        H = ":buffer-previous";
        L = ":buffer-next";
        ret = "goto_word";
      };
    };
    languages = {
      language = [
        {
          name = "nix";
          language-servers = [ "nixd" ];
        }
        {
          name = "go";
          auto-format = true;
          formatter.command = "goimports";
          language-servers = [ "gopls" ];
        }
        {
          name = "markdown";
          auto-format = true;
          formatter = {
            command = "prettier";
            args = [ "--parser" "markdown" "--prose-wrap" "never" ];
          };
        }
      ];
      language-server.nixd.command = "nixd";
      language-server.gopls.config = {
        "ui.diagnostic.analyses" = {
          nilness = true;
          unusedparams = true;
          unusedwrite = true;
        };
      };
    };
  };
}
