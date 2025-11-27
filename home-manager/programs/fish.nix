# Fish shell configuration
{ pkgs, ... }:

{
  programs.fish = {
    enable = true;

    shellInit = ''
      # Disable greeting
      set -g fish_greeting
    '';

    interactiveShellInit = ''
      # Source nix and home-manager profiles (Linux only - macOS uses nix-darwin)
      ${pkgs.lib.optionalString pkgs.stdenv.isLinux ''
        if test -e /nix/var/nix/profiles/default/etc/profile.d/nix.fish
          source /nix/var/nix/profiles/default/etc/profile.d/nix.fish
        end
        # Add Home Manager profile to PATH
        fish_add_path --prepend "$HOME/.local/state/nix/profiles/home-manager/home-path/bin"
      ''}

      # Enable vi key bindings
      fish_vi_key_bindings

      # Enable 24-bit color support
      set -g fish_term24bit 1
    '';

    shellAbbrs = {
      j = "jrnl";
      jl = "jrnl --format short";
      jf = "jrnl @fire";
      vi = "hx";
    };

    functions = {
      ft = {
        description = "Find tasks in notes";
        body = ''
          rg --vimgrep -o -P '(?=.*\[ \])(?=.*#weekly).*' $OBSIDIAN_VAULT | awk -F: '{print $4 ":" $1 ":" $2}' | fzf --ansi --delimiter ':' --with-nth=1 --bind "enter:execute($EDITOR {2}:{3})" --height 7
        '';
      };

      gff = {
        description = "Interactive Git file history explorer";
        body = ''
          if test -z "$argv[1]"
            echo -e "\033[31mError:\033[0m Please provide a file path."
            echo "Usage: gff <file>"
            return 1
          end

          set -l file $argv[1]
          set -l repo_root (git rev-parse --show-toplevel)
          set -l rel_file (string replace "$repo_root/" "" "$file")

          echo -e "\033[34mSearching Git history for:\033[0m $rel_file"

          set -l selected_commit (git log --oneline --follow -- "$rel_file" | \
            fzf --preview "git show {1}:$rel_file --color=always" \
                --preview-window=right:70%:wrap --height=80% --border --ansi)

          if test -z "$selected_commit"
            echo -e "\033[33mNo commit selected.\033[0m"
            return 0
          end

          set -l commit_hash (echo "$selected_commit" | awk '{print $1}')
          echo -e "\033[34mSelected Commit:\033[0m $commit_hash"
          echo -e "\033[34mFile Content Previewed Above.\033[0m"
        '';
      };

      k = {
        description = "Interactive process killer using fzf";
        body = ''
          ps aux | \
          fzf --height 40% \
              --layout=reverse \
              --header-lines=1 \
              --prompt="Select process to kill: " \
              --preview 'echo {}' \
              --preview-window up:3:hidden:wrap \
              --bind 'F2:toggle-preview' | \
          awk '{print $2}' | \
          xargs -r bash -c 'if ! kill "$1" 2>/dev/null; then echo "Regular kill failed. Attempting with sudo..."; sudo kill "$1" || echo "Failed to kill process $1" >&2; fi' --
        '';
      };

      logg = {
        description = "Interactive Git log explorer with previews";
        body = ''
          git log | fzf --ansi --no-sort \
            --preview 'echo {} | grep -o "[a-f0-9]\{7\}" | head -1 | xargs -I % git show % --color=always' \
            --preview-window=right:50%:wrap --height 100% \
            --bind 'enter:execute(echo {} | grep -o "[a-f0-9]\{7\}" | head -1 | xargs -I % sh -c "git show % | $EDITOR -")' \
            --bind 'ctrl-e:execute(echo {} | grep -o "[a-f0-9]\{7\}" | head -1 | xargs -I % sh -c "gh browse %")'
        '';
      };

      mkdd = {
        description = "Create a directory with today's date";
        body = ''
          set -l prefix ""
          if test (count $argv) -gt 0
            set prefix "$argv[1]"
          end
          mkdir -p "$prefix"(date +%F)
        '';
      };

      _fif_common = {
        description = "Internal helper for file searching functions";
        body = ''
          set -l ignore_case_flag $argv[1]
          set -l search_term $argv[2]
          set -l chezmoi_flag ""
          if test (count $argv) -ge 3
            set chezmoi_flag $argv[3]
          end

          if test -z "$search_term"
            echo "Usage: _fif_common <ignore_case_flag> <search_term> [--chezmoi]"
            return 1
          end

          set -l preview_cmd "rg $ignore_case_flag --pretty --context 10 '$search_term' {}"

          set -l files (rg --files-with-matches $ignore_case_flag --no-messages "$search_term" | \
            fzf-tmux +m --preview="$preview_cmd" --multi --select-1 --exit-0)

          if test (count $files) -eq 0
            echo "No files selected."
            return 0
          end

          set -l resolved_files
          for file in $files
            set -a resolved_files (realpath "$file")
          end

          if test "$chezmoi_flag" = "--chezmoi"
            cm edit $resolved_files
          else
            $EDITOR $resolved_files
          end
        '';
      };

      fifs = {
        description = "Case-sensitive search for text in files";
        body = ''
          _fif_common "" $argv
        '';
      };

      fifc = {
        description = "Case-sensitive search in chezmoi-managed files";
        body = ''
          _fif_common "" $argv "--chezmoi"
        '';
      };

      fif = {
        description = "Case-insensitive search for text in files";
        body = ''
          _fif_common "--ignore-case" $argv
        '';
      };

      nix-cleanup = {
        description = "Clean up the Nix store by removing unused packages";
        body = ''
          echo "Collecting garbage from the Nix store..."
          sudo nix-collect-garbage -d
          echo "Garbage collection complete!"
        '';
      };

      note = {
        description = "Search Obsidian vault or create new note";
        body = ''
          set -l selected (fd --type f --extension md . "$OBSIDIAN_VAULT" | \
            fzf --print-query \
                --preview "head -50 {}" \
                --preview-window=right:50%:wrap \
                --height=80% \
                --bind "ctrl-n:print-query+abort")

          set -l search_query $selected[1]
          set -l chosen_file $selected[2]

          # If file was selected, open it
          if test -n "$chosen_file" -a -e "$chosen_file"
            $EDITOR "$chosen_file"
            return 0
          end

          # If we have a query (from typing or ctrl-n), create new note
          if test -n "$search_query"
            set -l filename (string lower -- "$search_query" | string replace -a " " "-")".md"
            set -l filepath "$OBSIDIAN_VAULT/$filename"

            if test -e "$filepath"
              echo "File already exists: $filepath"
              $EDITOR "$filepath"
            else
              echo "# $search_query" > "$filepath"
              echo "Created: $filepath"
              $EDITOR "$filepath"
            end
          end
        '';
      };
    };

    plugins = [
      {
        name = "pure";
        src = pkgs.fishPlugins.pure.src;
      }
    ];
  };
}
