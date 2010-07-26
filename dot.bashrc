# Adam Vandenberg's bashrc
# Cobbled together from the Internet

export EDITOR='mate'
export GIT_EDITOR='mate -wl1'


## History control
export HISTCONTROL=ignoreboth
shopt -s histappend


## PATH
# Put /usr/local/{sbin,bin} first
export PATH=/usr/local/bin:/usr/local/sbin:$PATH

# bin folders from ~, gems, and Homebrew examples
for another_bin in \
    $HOME/bin \
    $HOME/bin/extras \
    $HOME/.gem/ruby/1.8/bin \
    $HOME/homebrew/Cellar/python/2.6.5/bin \
    $HOME/homebrew/Library/Contributions/examples
do
    [[ -e $another_bin ]] && export PATH=$another_bin:$PATH
done


# If not running interactively, don't do anything
[ -z "$PS1" ] && return


## Python stuff
export VIRTUALENV_USE_DISTRIBUTE

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
alias edit='mate'
alias mkdir="mkdir -vp"
alias delpyc="find . -name '*.pyc' -delete"
alias tree='tree -Ca -I ".git|.svn|*.pyc|*.swp"'
alias sizes='du -h -d1'

alias go-bundles="cd ~/Library/Application\ Support/TextMate/Bundles/"
alias firefox-dev="~/Applications/Minefield.app/Contents/MacOS/firefox-bin -no-remote -P dev &"


## Tab Completions
set completion-ignore-case On

for comp in \
    /usr/local/etc/bash_completion.d/git-completion.bash \
    $HOME/homebrew/Library/Contributions/brew_bash_completion.sh \
    $HOME/source/custom-django/extras/django_bash_completion
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
     BROWN="\[\033[0;33m\]"
COLOR_NONE="\[\033[0m\]"

LIGHTNING_BOLT="⚡"
      UP_ARROW="↑"
    DOWN_ARROW="↓"
      UD_ARROW="↕"
      FF_ARROW="→"
       RECYCLE="♺"
        MIDDOT="•"
     PLUSMINUS="±"


function parse_git_branch {
  branch_pattern="^# On branch ([^${IFS}]*)"
  remote_pattern_ahead="# Your branch is ahead of"
  remote_pattern_behind="# Your branch is behind"
  remote_pattern_ff="# Your branch (.*) can be fast-forwarded."
  diverge_pattern="# Your branch and (.*) have diverged"

  git_status="$(git status 2> /dev/null)"
  if [[ ! ${git_status} =~ ${branch_pattern} ]]; then
    # Rebasing?
    toplevel=$(git rev-parse --show-toplevel 2> /dev/null)
    [[ -z "$toplevel" ]] && return

    [[ -d "$toplevel/.git/rebase-merge" || -d "$toplevel/.git/rebase-apply" ]] && {
      sha_file="$toplevel/.git/rebase-merge/stopped-sha"
      [[ -e "$sha_file" ]] && {
        sha=`cat ${sha_file}`
      }
      echo "${PINK}(rebase in progress)${COLOR_NONE} ${sha}"
    }
    return
  fi

  branch=${BASH_REMATCH[1]}

  # Dirty?
  if [[ ! ${git_status} =~ "working directory clean" ]]; then
    [[ ${git_status} =~ "modified:" ]] && {
      git_is_dirty="${RED}${LIGHTNING_BOLT}"
    }

    [[ ${git_status} =~ "Untracked files" ]] && {
      git_is_dirty="${git_is_dirty}${WHITE}${MIDDOT}"
    }

    [[ ${git_status} =~ "new file:" ]] && {
      git_is_dirty="${git_is_dirty}${LT_GREEN}+"
    }

    [[ ${git_status} =~ "deleted:" ]] && {
      git_is_dirty="${git_is_dirty}${RED}-"
    }

    [[ ${git_status} =~ "renamed:" ]] && {
      git_is_dirty="${git_is_dirty}${YELLOW}→"
    }
  fi

  # Are we ahead of, beind, or diverged from the remote?
  if [[ ${git_status} =~ ${remote_pattern_ahead} ]]; then
    remote="${YELLOW}${UP_ARROW}"
  elif [[ ${git_status} =~ ${remote_pattern_ff} ]]; then
    remote_ff="${WHITE}${FF_ARROW}"
  elif [[ ${git_status} =~ ${remote_pattern_behind} ]]; then
    remote="${YELLOW}${DOWN_ARROW}"
  elif [[ ${git_status} =~ ${diverge_pattern} ]]; then
    remote="${YELLOW}${UD_ARROW}"
  fi

  echo "${remote}${remote_ff}${GREEN}(${branch})${COLOR_NONE}${git_is_dirty}${COLOR_NONE}"
}

function set_prompt() {
  [[ -n $HOMEBREW_DEBUG_INSTALL ]] && \
    homebrew_prompt="${BROWN}Homebrew:${COLOR_NONE} debugging ${HOMEBREW_DEBUG_INSTALL}\n"
  git_prompt="$(parse_git_branch)"
  export PS1="[\w] ${git_prompt}${COLOR_NONE}\n${homebrew_prompt}\$ "
}

export PROMPT_COMMAND=set_prompt


## Functions

git-root()
{
  root=$(git rev-parse --git-dir 2> /dev/null)
  if [[ "$root" == "" ]]; then root="."; fi
  dirname $root
}


# Reveal current or provided dir in Path Finder
pf()
{
  target_path=$(cd ${1:-$PWD} && PWD)
  osascript<<END
tell app "Path Finder"
  reveal POSIX file("$target_path")
  activate
end tell
END
}

# Open a manpage in Preview, which can be saved to PDF
pman()
{
   man -t "${1}" | open -f -a /Applications/Preview.app
}

function pgrep() {
  local exclude="\.svn|\.git|\.swp|\.coverage|\.pyc|_build"
  find . -maxdepth 1 -mindepth 1| egrep -v "$exclude" | xargs egrep -lir "$1" | egrep -v "$exclude" | xargs egrep -Hin --color "$1"
}


## Source any local additions
## (To keep work & home separate.)
[[ -f ~/.bash_local ]] && . ~/.bash_local
