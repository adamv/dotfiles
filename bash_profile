if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi

## Source any local additions
if [ -f ~/.bash_local ]; then
  . ~/.bash_local
fi
