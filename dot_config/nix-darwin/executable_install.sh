#!/bin/bash

# figure out in nix
# add address bar in finder
# add path bar in finder
# add dropbox to the favorites in finder

# install doom-emacs
if ! command -v "$HOME/.config/emacs/bin/doom" &>/dev/null; then
  git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
  ~/.config/emacs/bin/doom install
fi
