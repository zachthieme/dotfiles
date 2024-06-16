set -x STARSHIP_CONFIG $HOME/.config/starship.toml
set -x EDITOR nvim

set -x GOPATH $HOME/Code/ 


fish_add_path /usr/local/go/bin
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
alias lvim='XDG_CONFIG_HOME=~/.config/nvim.lazy nvim'

# find files changed in the .config directory in the last day 
alias nf='fdfind . /home/zach/.config -H --changed-within 1d -E Code -E google-chrome -x /usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME ls-files --others {} | sort | uniq'

# git add files that changed in last day in .config
alias nfa='fd . /Users/zthieme/.config -H --changed-within 1d -E chromium -x /usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME ls-files --others {} | uniq | rargs /usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME add {0}'

# make exa less typing
alias exa='exa --group-directories-first'
alias l='exa'
alias la='exa -la'
alias a='exa -a'
#alias ssh='kitty +kitten ssh'
alias j='z'

alias nvim-lazy="env NVIM_APPNAME=LazyVim nvim"
alias nvim-chad="env NVIM_APPNAME=NvChad nvim"
alias nvim-astro="env NVIM_APPNAME=AstroNvim nvim"

function nvims
  set items "default" "LazyVim" "NvChad" "AstroNvim"
  set config (printf "%s\n" $items | fzf --prompt=" Neovim Config  " --height=50% --layout=reverse --border --exit-0)
  if test -z "$config"
    echo "Nothing selected"
    return 0
  else if test "$config" = "default"
    set config ""
  end
  env NVIM_APPNAME=$config nvim $argv
end

