function _is_gnu_date --description="Test whether date is GNU coreutils (vs BSD)"
    date -d "1 day ago" +%Y-%m-%d &>/dev/null
end
