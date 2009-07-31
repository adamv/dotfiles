#!/bin/bash

function relink() {
  rm -i $1
  ln -sn $2 $1
}

pushd ..
    root=`pwd`
    relink $root/.bash_profile ~/.bash_profile
    relink $root/.bashrc ~/.bashrc
    relink $root/.gitconfig ~/.gitconfig
    relink $root/bin ~/bin
popd
