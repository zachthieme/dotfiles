function _titlecase --description="Convert string to Title Case"
    set -l result
    for word in (string split ' ' -- $argv)
        set -l first (string sub -l 1 -- $word | string upper)
        set -l rest (string sub -s 2 -- $word | string lower)
        set result $result "$first$rest"
    end
    string join ' ' -- $result
end
