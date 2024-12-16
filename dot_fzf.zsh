# Setup fzf
# ---------
if [[ ! "$PATH" == */home/test/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/test/.fzf/bin"
fi

source <(fzf --zsh)
