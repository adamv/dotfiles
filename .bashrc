export PATH=/opt/local/bin:$PATH

# prepend $HOME/bin to the path if it exists
if [ -e $HOME/bin ] ; then
  export PATH=$HOME/bin:$PATH
fi


# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
export HISTCONTROL=ignoredups
# ... and ignore same sucessive entries.
export HISTCONTROL=ignoreboth

shopt -s histappend


# auto-completion is not case sensitive anymore
set completion-ignore-case On

export EDITOR='mate -w'


alias cls='clear'
alias gush='git push origin master'
alias mkdir="mkdir -vp"


###################################
# ls
###################################
export CLICOLOR=1
export LSCOLORS=hxfxcxdxbxegedabagHxHx

alias ll="ls -l -h"
alias la="ls -a"
alias l="ls"
alias lla="ls -a -l"
alias lm='ls -la | more'

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


###################################
# PROMPT
###################################
        RED="\[\033[0;31m\]"
     YELLOW="\[\033[0;33m\]"
      GREEN="\[\033[0;32m\]"
       BLUE="\[\033[0;34m\]"
      WHITE="\[\033[1;37m\]"
 COLOR_NONE="\[\e[0m\]"

function parse_git_branch {
  # If we're not in our home, but that's where the .git dir is,
  # then don't show the git status.
  #
  # We track .dotfiles, but pretend that subdirectories
  # aren't in the repo (since they are all ignored anyway.)
  
  git_dir="$(git rev-parse --git-dir 2> /dev/null)"

  if [[ ${git_dir} = ~/".git" ]]; then
    return
  fi
  
  git_status="$(git status 2> /dev/null)"
  branch_pattern="^# On branch ([^${IFS}]*)"
  remote_pattern="# Your branch is (.*) of"
  diverge_pattern="# Your branch and (.*) have diverged"
  
  if [[ ! ${git_status} =~ "working directory clean" ]]; then
    state="${RED}⚡"
  fi
  
  # add an else if or two here if you want to get more specific
  if [[ ${git_status} =~ ${remote_pattern} ]]; then
    if [[ ${BASH_REMATCH[1]} == "ahead" ]]; then
        remote="${YELLOW}↑"
    else
        remote="${YELLOW}↓"
    fi
  fi

  if [[ ${git_status} =~ ${diverge_pattern} ]]; then
    remote="${YELLOW}↕"
  fi

  if [[ ${git_status} =~ ${branch_pattern} ]]; then
    branch=${BASH_REMATCH[1]}
    echo "(${branch})${remote}${state}"
  fi
}
 
function prompt_func() {
    previous_return_value=$?;
    prompt="${TITLEBAR} [\w]  ${GREEN}$(parse_git_branch)${COLOR_NONE}"
    PS1="${prompt}\n${COLOR_NONE}$ "
}
 
PROMPT_COMMAND=prompt_func
