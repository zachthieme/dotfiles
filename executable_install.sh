#!/bin/bash
# install nix-darwin
# nix run nix-darwin -- switch --flake

# rebuild nix-darwin
# sudo darwin-rebuild switch --flake ~/Code/dotfiles/flake.nix

# mk dir if it doesn't exist
# ~/Pictures/screenshots/

# install doom-emacs
if ! command -v "$HOME/.config/emacs/bin/doom" &>/dev/null; then
  git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
  ~/.config/emacs/bin/doom install
fi

# install homebrew
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
