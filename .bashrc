# Adam Vandenberg's bashrc
# Cobbled together from the Internet

export EDITOR='mate'
export GIT_EDITOR='mate -wl1'



## History control
export HISTCONTROL=ignoredups
export HISTCONTROL=ignoreboth
shopt -s histappend



## PATH
local_path=/usr/local/bin:/usr/local/sbin
export PATH=$local_path:$PATH

# prepend $HOME/bin & $HOME/bin/extra to the path if they exist
if [[ -e $HOME/bin ]] ; then
  export PATH=$HOME/bin:$PATH
fi

if [[ -e $HOME/bin/extras ]] ; then
  export PATH=$HOME/bin/extras:$PATH
fi

# Todo: Is this really needed?
# If not running interactively, don't do anything
[ -z "$PS1" ] && return



## Colors and ls
export LSCOLORS=hxfxcxdxbxegedabagHxHx

# -G = enable colors
alias ls="ls -G"
alias ll="ls -l -h"
alias la="ls -a"
alias l="ls"
alias lla="ls -a -l"
alias lm='ls -la | less'



## Aliases
alias cls='clear'
alias gist='git status'
alias mkdir="mkdir -vp"
alias delpyc="find . -name '*.pyc' -delete"
alias tree='tree -Ca -I ".git|.svn|*.pyc|*.swp"'

alias go-bundles="cd ~/Library/Application\ Support/TextMate/Bundles/"
alias firefox-dev="~/Applications/Minefield.app/Contents/MacOS/firefox-bin -no-remote -P dev &"

alias debrew='brew install --debug --verbose'


## Tab Completions
set completion-ignore-case On

for comp in \
    ~/bin/git-completion.bash \
    ~/homebrew/Library/Contributions/brew_bash_completion.sh \
    ~/source/django/extras/django_bash_completion
do
    [[ -e $comp ]] && source $comp
done


## Custom prompt
# Colors
       RED="\[\033[0;31m\]"
      PINK="\[\033[1;31m\]"
    YELLOW="\[\033[1;33m\]"
     GREEN="\[\033[0;32m\]"
  LT_GREEN="\[\033[1;32m\]"
      BLUE="\[\033[0;34m\]"
     WHITE="\[\033[1;37m\]"
    PURPLE="\[\033[1;35m\]"
      CYAN="\[\033[1;36m\]"      
COLOR_NONE="\[\033[0m\]"

LIGHTNING_BOLT="⚡"
      UP_ARROW="↑"
    DOWN_ARROW="↓"
      UD_ARROW="↕"
       RECYCLE="♺"


function parse_git_branch {
  branch_pattern="^# On branch ([^${IFS}]*)"
  remote_pattern="# Your branch is (.*) of"
  diverge_pattern="# Your branch and (.*) have diverged"

  git_status="$(git status 2> /dev/null)"
  if [[ ! ${git_status} =~ ${branch_pattern} ]]; then
    return
  fi
  branch=${BASH_REMATCH[1]}

  # Dirty?
  if [[ ! ${git_status} =~ "working directory clean" ]]; then
    git_is_dirty="${RED}${LIGHTNING_BOLT}"
  else
    git_is_dirty=
  fi

  # Do we need to push to origin?
  git_log_linecount="$(git log --pretty=oneline origin/${branch}..${branch} 2> /dev/null | wc -l)"
  if [[ ! ${git_log_linecount}} =~ " 0" ]]; then
      needs_push="${WHITE}${RECYCLE}"
  fi
  
  # Are we ahead of, beind, or diverged from the remote?
  if [[ ${git_status} =~ ${remote_pattern} ]]; then
    if [[ ${BASH_REMATCH[1]} == "ahead" ]]; then
      remote="${YELLOW}${UP_ARROW}"
    else
      remote="${YELLOW}${DOWN_ARROW}"
    fi
  fi

  if [[ ${git_status} =~ ${diverge_pattern} ]]; then
    remote="${YELLOW}${UD_ARROW}"
  fi
  
  echo "(${branch})${remote}${git_is_dirty}${needs_push}"
}
 
function set_prompt() {
  git_prompt="${GREEN}$(parse_git_branch)${COLOR_NONE}"
  export PS1="[\w]  ${git_prompt}\n${COLOR_NONE}\$ "
}
 
export PROMPT_COMMAND=set_prompt


## Functions

git-root() 
{
  root=$(git rev-parse --git-dir 2> /dev/null)
  if [[ "$root" == "" ]]; then root="."; fi
  dirname $root
}


# Reveal current dir in Path Finder
pf()
{
  osascript<<END
tell app "Path Finder"
  reveal POSIX file("$PWD")
  activate
end tell
END
}

# Open a manpage in Preview, which can be saved to PDF
pman()
{
   man -t "${1}" | open -f -a /Applications/Preview.app
}

exclude="\.svn|\.git|\.swp|\.coverage|\.pyc|_build"
function pgrep() {
    find . -maxdepth 1 -mindepth 1| egrep -v "$exclude" | xargs egrep -lir "$1" | egrep -v "$exclude" | xargs egrep -Hin --color "$1"
}


## Source any local additions
## (To keep work & home separate.)
[[ -f ~/.bash_local ]] && . ~/.bash_local
