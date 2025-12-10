# Helix editor configuration
{ ... }:

{
  programs.helix = {
    enable = true;
    themes = {
      everforest_dark_multiselect = {
        inherits = "everforest_dark";
        "ui.selection.primary" = { bg = "#3d5a5e"; };
        "ui.selection" = { bg = "#4a3f55"; };
        "ui.cursor.primary" = { fg = "#2d353b"; bg = "#83c092"; modifiers = ["bold"]; };
      };
    };
    settings = {
      editor = {
        auto-format = true;
        auto-save = true;
        color-modes = true;
        completion-replace = true;
        cursor-shape.insert = "bar";
        cursorline = true;
        end-of-line-diagnostics = "hint";
        idle-timeout = 0;
        inline-diagnostics.cursor-line = "warning";
        line-number = "relative";
        lsp.display-messages = true;
        mouse = false;
        true-color = true;
        file-picker = {
          git-ignore = false;
          hidden = false;
        };
        indent-guides = {
          character = "┊";
          render = true;
          skip-levels = 0;
        };
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
        X = ["extend_line_above"];
        H = [":buffer-previous"];
        L = [":buffer-next"];
        ret = ["goto_word"];
        C-y = [
          ":sh rm -f /tmp/unique-file"
          ":insert-output yazi %{buffer_name} --chooser-file=/tmp/unique-file"
          '':insert-output echo "\\x1b[?1049h\\x1b[?2004h" > /dev/tty''
          ":open %sh{cat /tmp/unique-file}"
          ":redraw"
        ];
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
