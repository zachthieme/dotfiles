function _require_notes_dir --description="Check NOTES env var is set and directory exists"
    _require_notes; or return 1
    if not test -d "$NOTES"
        echo -e "\033[31mError:\033[0m NOTES directory does not exist: $NOTES"
        return 1
    end
end
