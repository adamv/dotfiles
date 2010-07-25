#!/bin/bash

function relink() {
  if [[ -h "$1" ]]; then
    # Symbolic link? Then recreate.
    rm "$1"
    ln -sn "$2" "$1"
  elif [[ ! -e "$1" ]]; then
    ln -sn "$2" "$1"
  else
    echo "$1 exists as a real file, skipping."
  fi
}

cd ~
relink .bash_profile ~/.dotfiles/dot.bash_profile
relink .bashrc ~/.dotfiles/dot.bashrc
relink .gitconfig ~/.dotfiles/.gitconfig
relink bin ~/.dotfiles/bin
