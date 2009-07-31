#!/bin/bash

function relink() {
  rm -i $1
  ln -sn $2 $1
}

pushd ..
    relink .bash_profile ~/.bash_profile
    relink .bashrc ~/.bashrc
    relink .gitconfig ~/.gitconfig
    relink bin ~/bin
popd
