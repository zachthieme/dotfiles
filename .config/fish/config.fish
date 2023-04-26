set -x STARSHIP_CONFIG $HOME/.config/starship.toml
set -x EDITOR nvim

fish_add_path ~/.cargo/bin
fish_add_path ~/snap/bin
fish_add_path /opt/homebrew/bin

set -g fish_term24bit 1
set -g theme_nerd_fonts yes

# setup any fish plugins
fish_vi_key_bindings
set fish_greeting

# setup starship 
starship init fish | source

# setup zoxide
zoxide init fish | source

# ALIASES
# used to manage dotfiles
alias dot='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
alias vi='nvim'
alias vim='nvim'

# find files changed in the .config directory in the last day 
alias nf='fd . /Users/zthieme/.config -H --changed-within 1d -E Code -E google-chrome -x /usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME ls-files --others {} | sort | uniq'

# git add files that changed in last day in .config
alias nfa='fd . /Users/zthieme/.config -H --changed-within 1d -E chromium -x /usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME ls-files --others {} | uniq | rargs /usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME add {0}'

# make exa less typing
alias exa='exa --group-directories-first'
alias l='exa'
alias la='exa -la'
alias a='exa -a'
#alias ssh='kitty +kitten ssh'
alias j='z'
