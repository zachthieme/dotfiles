# Setup fzf
# ---------
if [[ ! "$PATH" == */home/zach/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/zach/.fzf/bin"
fi

source <(fzf --zsh)
