#!/bin/bash

function relink() {
  rm -i $1
  ln -sn $2 $1
}

cd ~
    relink .bash_profile ~/.dotfiles/.bash_profile
    relink .bashrc ~/.dotfiles/.bashrc
    relink .gitconfig ~/.dotfiles/.gitconfig
    relink bin ~/.dotfiles/bin
popd
