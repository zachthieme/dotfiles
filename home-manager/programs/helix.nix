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
        shell = ["fish" "-lc"];
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
        space.t = ["extend_to_line_bounds" ":pipe sed -e '/^[[:space:]]*- \\[ \\] /{s/^\\([[:space:]]*\\)- \\[ \\] /\\1/;b' -e '}' -e '/^[[:space:]]*- \\[x\\] /{s/^\\([[:space:]]*\\)- \\[x\\] /\\1/;b' -e '}' -e 's/^\\([[:space:]]*\\)/\\1- [ ] /'" "collapse_selection"];
        space.x = ["extend_to_line_bounds" ":pipe _hx_toggle_task" "collapse_selection"];
        H = [":buffer-previous"];
        L = [":buffer-next"];
        ret = ["goto_word"];
        A-j = ["move_line_down"];
        A-k = ["move_line_up"];
        C-y = [
          ":sh rm -f /tmp/unique-file"
          ":insert-output yazi %{buffer_name} --chooser-file=/tmp/unique-file"
          '':insert-output echo "\\x1b[?1049h\\x1b[?2004h" > /dev/tty''
          ":open %sh{cat /tmp/unique-file}"
          ":redraw"
        ];
      };
      keys.select = {
        space.t = ["extend_to_line_bounds" ":pipe sed -e '/^[[:space:]]*- \\[ \\] /{s/^\\([[:space:]]*\\)- \\[ \\] /\\1/;b' -e '}' -e '/^[[:space:]]*- \\[x\\] /{s/^\\([[:space:]]*\\)- \\[x\\] /\\1/;b' -e '}' -e 's/^\\([[:space:]]*\\)/\\1- [ ] /'" "collapse_selection"];
        space.x = ["extend_to_line_bounds" ":pipe _hx_toggle_task" "collapse_selection"];
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
          language-servers = [ "markdown-oxide" ];
          formatter = {
            command = "prettier";
            args = [ "--parser" "markdown" "--prose-wrap" "never" ];
          };
        }
      ];
      language-server.markdown-oxide.command = "markdown-oxide";
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
