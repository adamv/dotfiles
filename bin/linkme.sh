#!/bin/bash

function relink() {
  if [-e $1] ; then rm -i $1; fi
  ln -sn $2 $1
}

cd ~
relink .bash_profile ~/.dotfiles/.bash_profile
relink .bashrc ~/.dotfiles/.bashrc
relink .gitconfig ~/.dotfiles/.gitconfig
relink bin ~/.dotfiles/bin
