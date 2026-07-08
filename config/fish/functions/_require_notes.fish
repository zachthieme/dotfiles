function _require_notes --description="Check NOTES env var is set and non-empty"
    if not set -q NOTES; or test -z "$NOTES"
        echo -e "\033[31mError:\033[0m NOTES environment variable not set"
        return 1
    end
end
