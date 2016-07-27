# If not running interactively, don't do anything
[ -z "$PS1" ] && return

source_if() { [ -f $1 ] && source $1 ; }

export EDITOR='emacs'
# No ._ files in archives please
export COPYFILE_DISABLE=1


## History control
export HISTCONTROL=ignoreboth
shopt -s histappend


## Tab Completions
set completion-ignore-case On


# Path
export PATH=$HOME/bin:$HOME/bin-local:$HOME/opt/bin:$HOME/opt/sbin:$HOME/hb/bin:$HOME/hb/sbin:$HOME/.gem/ruby/2.0.0/bin:$PATH


## Completions (on Linux)
source_if "/etc/bash_completion"


## Homebrew
if [[ -n `which brew` ]]; then
  export HOMEBREW_NO_EMOJI='1'
  export HOMEBREW_DEVELOPER='1'
  export HOMEBREW_NO_ANALYTICS='1'

  # Add Homebrew completions and homebrew sourced completions
  source_if "$(brew --prefix)/etc/bash_completion"
fi


## Aliases
alias cls='clear'
alias delpyc="find . -name '*.pyc' -delete"
alias tree='tree -Ca -I ".git|.svn|*.pyc|*.swp"'
alias sizes='du -h -d1'
alias pigs="du | sort -nr | cut -f2- | xargs du -hs"
alias pigs1="du -d1 | sort -nr | cut -f2- | xargs du -hs"


function show-empty-folders {
    find . -depth -type d -empty
}

function kill-empty-folders {
    find . -depth -type d -empty -exec rmdir "{}" \;
}

function git-root {
  root=$(git rev-parse --git-dir 2> /dev/null)
  [[ -z "$root" ]] && root="."
  dirname $root
}

# Reveal current or provided folder in Path Finder
# (For Finder, use `open .`)
function pf {
  target_path="$(cd ${1:-"$PWD"} && PWD)"
  osascript<<END
tell app "Path Finder"
  reveal POSIX file("$target_path")
  activate
end tell
END
}

# Open a manpage in Preview, which can be saved to PDF
function pman {
   man -t "${1}" | open -f -a /Applications/Preview.app
}

# Open a manpage in the browser
function bman {
  man "${1}" | man2html | browser
}

function pgrep {
  local exclude="\.svn|\.git|\.swp|\.coverage|\.pyc|_build"
  find . -maxdepth 1 -mindepth 1 | egrep -v "$exclude" | xargs egrep -lir "$1" | egrep -v "$exclude" | xargs egrep -Hin --color "$1"
}


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
  local branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  [[ -z $branch ]] && return

  local remote_pattern_ahead="Your branch is ahead of"
  local remote_pattern_behind="Your branch is behind"
  local remote_pattern_ff="Your branch (.*) can be fast-forwarded."
  local diverge_pattern="Your branch and (.*) have diverged"

  local git_status="$(git status 2> /dev/null)"
  # if [[ ! ${git_status} =~ ${branch_pattern} ]]; then
  #   # Rebasing?
  #   toplevel=$(git rev-parse --show-toplevel 2> /dev/null)
  #   [[ -z "$toplevel" ]] && return

  #   [[ -d "$toplevel/.git/rebase-merge" || -d "$toplevel/.git/rebase-apply" ]] && {
  #     sha_file="$toplevel/.git/rebase-merge/stopped-sha"
  #     [[ -e "$sha_file" ]] && {
  #       sha=`cat "${sha_file}"`
  #     }
  #     echo "${PINK}(rebase in progress)${COLOR_NONE} ${sha}"
  #   }
  #   return
  # fi

  # Dirty?
  if [[ ! ${git_status} =~ "working directory clean" ]]; then
    [[ ${git_status} =~ "modified:" ]] && {
      local git_is_dirty="${RED}${LIGHTNING_BOLT}"
    }

    [[ ${git_status} =~ "Untracked files" ]] && {
      local git_is_dirty="${git_is_dirty}${WHITE}${MIDDOT}"
    }

    [[ ${git_status} =~ "new file:" ]] && {
      local git_is_dirty="${git_is_dirty}${LT_GREEN}+"
    }

    [[ ${git_status} =~ "deleted:" ]] && {
      local git_is_dirty="${git_is_dirty}${RED}-"
    }

    [[ ${git_status} =~ "renamed:" ]] && {
      local git_is_dirty="${git_is_dirty}${YELLOW}→"
    }
  fi

  # Are we ahead of, beind, or diverged from the remote?
  if [[ ${git_status} =~ ${remote_pattern_ahead} ]]; then
    local remote="${YELLOW}${UP_ARROW}"
  elif [[ ${git_status} =~ ${remote_pattern_ff} ]]; then
    local remote_ff="${WHITE}${FF_ARROW}"
  elif [[ ${git_status} =~ ${remote_pattern_behind} ]]; then
    local remote="${YELLOW}${DOWN_ARROW}"
  elif [[ ${git_status} =~ ${diverge_pattern} ]]; then
    local remote="${YELLOW}${UD_ARROW}"
  fi

  echo "${remote}${remote_ff}${GREEN}(${branch})${COLOR_NONE}${git_is_dirty}${COLOR_NONE}"
}

function setWindowTitle {
  case $TERM in
    *xterm*|ansi)
      echo -n -e "\033]0;$*\007"
      ;;
  esac
}

function set_prompt {
  export PS1="[\w] $(parse_git_branch)${COLOR_NONE}\n\$ "
  setWindowTitle "${PWD/$HOME/~}"
}

export PROMPT_COMMAND=set_prompt

# scmpuff
# https://github.com/mroth/scmpuff/blob/master/README.md
which -s scmpuff && {
    eval "$(scmpuff init -s --aliases=false)"
    alias gs='scmpuff_status'
}
