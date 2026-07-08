function mkdd --description="Create a directory with today's date"
    set -l prefix ""
    if test (count $argv) -gt 0
        set prefix "$argv[1]"
    end
    mkdir -p "$prefix"(date +%F)
end
