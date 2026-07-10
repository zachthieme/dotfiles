function notes-sync --description="Sync notes via jj: fetch, merge (rebase) remote, commit, push"
    if not set -q NOTES; or test -z "$NOTES"
        return 1
    end

    set -l prev_dir $PWD
    cd $NOTES
    or begin
        echo "notes-sync: cannot cd to NOTES ($NOTES)" >&2
        return 1
    end

    # Not a jj repo → nothing to sync.
    if not jj root &>/dev/null
        echo -e "\033[33mNotes directory is not a jj repository, skipping.\033[0m"
        cd $prev_dir
        return 0
    end

    # This runs unattended (hourly, from `nw`). If we're already sitting on
    # unresolved conflict markers from a previous bailed sync, do NOT commit —
    # that would bake `<<<<<<<` markers into a note. Bail until a human resolves.
    set -l pre_conflict (jj log -r '@ | @-' --no-graph -T 'if(conflict, "x", "")' 2>/dev/null)
    if test -n "$pre_conflict"
        echo -e "\033[31mnotes-sync: unresolved conflict from a previous sync — not touching anything.\033[0m" >&2
        echo "  Resolve:  cd \$NOTES; jj resolve --list; <edit the file>; jj squash --into @-" >&2
        cd $prev_dir
        return 1
    end

    set -l has_remote 0
    test (count (jj git remote list 2>/dev/null)) -gt 0; and set has_remote 1

    # 1. Fetch first, so we reconcile before pushing. Offline is not fatal — we
    #    can still commit locally; the push at the end will just report failure.
    if test $has_remote -eq 1
        jj git fetch 2>/dev/null
        or echo -e "\033[33mnotes-sync: fetch failed (offline?) — continuing locally.\033[0m" >&2
    end

    # 2. Commit local working-copy edits, if any.
    set -l changes (jj diff --summary 2>/dev/null)
    if test -n "$changes"
        set -l today (date "+%Y-%m-%d %H:%M")
        if not jj commit -m "notes: auto-save $today"
            echo -e "\033[31mCommit FAILED — leaving main where it is.\033[0m" >&2
            cd $prev_dir
            return 1
        end
        echo -e "\033[32mCommitted notes changes.\033[0m"
    end

    # 3. Reconcile: if the remote has commits we don't, rebase our work onto it.
    #    jj 3-way merges — non-overlapping edits (even within one file) combine
    #    automatically; only truly overlapping edits produce a conflict.
    if test $has_remote -eq 1; and jj log -r 'main@origin' &>/dev/null
        set -l remote_ahead (jj log -r 'main@origin ~ ::@' --no-graph -T '"x"' 2>/dev/null)
        if test -n "$remote_ahead"
            jj rebase -d 'main@origin' 2>/dev/null
            set -l post_conflict (jj log -r '@ | @-' --no-graph -T 'if(conflict, "x", "")' 2>/dev/null)
            if test -n "$post_conflict"
                echo -e "\033[31mnotes-sync: merge conflict with remote — NOT pushing.\033[0m" >&2
                echo "  Your change was rebased onto the remote and left with conflict markers." >&2
                echo "  Resolve:  cd \$NOTES; jj resolve --list; <edit the file>; jj squash --into @-" >&2
                echo "  Then re-run notes-sync." >&2
                cd $prev_dir
                return 1
            end
            echo -e "\033[32mMerged remote changes.\033[0m"
        end
    end

    # 4. Point main at the reconciled tip and push.
    jj bookmark move main --to @- 2>/dev/null

    set -l sync_failed 0
    if test $has_remote -eq 1
        set -l push_out (jj git push 2>&1)
        if test $status -eq 0
            echo -e "\033[32mPushed to remote.\033[0m"
        else
            echo -e "\033[31mPush FAILED:\033[0m $push_out" >&2
            set sync_failed 1
        end
    else
        echo -e "\033[33mPush skipped (no remote).\033[0m"
    end

    cd $prev_dir
    return $sync_failed
end
