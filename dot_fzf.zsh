# Setup fzf
# ---------
if [[ ! "$PATH" == *"$HOME/.fzf/bin"* ]]; then
  PATH="${PATH:+${PATH}:}$HOME/.fzf/bin"
fi

# if [[ ! "$PATH" == */home/test/.fzf/bin* ]]; then
#   PATH="${PATH:+${PATH}:}/home/test/.fzf/bin"
# fi

source <(fzf --zsh)
