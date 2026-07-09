function notes-sync --description="Commit and push notes via jj"
    if not set -q NOTES; or test -z "$NOTES"
        return 1
    end

    set -l prev_dir $PWD
    cd $NOTES
    or begin
        echo "notes-sync: cannot cd to NOTES ($NOTES)" >&2
        return 1
    end

    set -l sync_failed 0
    if jj root &>/dev/null
        set -l changes (jj diff --summary 2>/dev/null)
        if test -n "$changes"
            set -l today (date "+%Y-%m-%d %H:%M")
            # Guard the commit: if it fails, do NOT move main to @- (that would
            # point the bookmark at an unrelated/parent commit).
            if not jj commit -m "notes: auto-save $today"
                echo -e "\033[31mCommit FAILED — leaving main where it is.\033[0m" >&2
                cd $prev_dir
                return 1
            end
            echo -e "\033[32mCommitted notes changes.\033[0m"
            jj bookmark move main --to @-
            set -l remotes (jj git remote list 2>/dev/null)
            if test (count $remotes) -gt 0
                jj git push 2>/dev/null
                and echo -e "\033[32mPushed to remote.\033[0m"
                or begin
                    echo -e "\033[31mPush FAILED.\033[0m" >&2
                    set sync_failed 1
                end
            else
                echo -e "\033[33mPush skipped (no remote).\033[0m"
            end
        else
            echo "No changes to commit."
        end
    else
        echo -e "\033[33mNotes directory is not a jj repository, skipping commit/push.\033[0m"
    end

    cd $prev_dir
    return $sync_failed
end
