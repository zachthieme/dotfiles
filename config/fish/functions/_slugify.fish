function _slugify --description="Convert string to lowercase slug"
    string lower -- $argv | string replace -a ' ' -
end
