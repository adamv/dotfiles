# If not running interactively, don't do anything
[ -z "$PS1" ] && return

source_if() { [ -f $1 ] && source $1 1> /dev/null ; }

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


## Java
source_if $HOME/dotfiles/java-helpers.sh


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
     GREEN="\[\033[0;32m\]"
  LT_GREEN="\[\033[1;32m\]"
     BROWN="\[\033[0;33m\]"
    YELLOW="\[\033[1;33m\]"
      BLUE="\[\033[0;34m\]"
   LT_BLUE="\[\033[1;34m\]"
    PURPLE="\[\033[1;35m\]"
      CYAN="\[\033[1;36m\]"
     WHITE="\[\033[1;37m\]"
COLOR_NONE="\[\033[0m\]"

LIGHTNING_BOLT="⚡"
UP_ARROW="↑"
DOWN_ARROW="↓"
UD_ARROW="↕"
FF_ARROW="→"
RECYCLE="♺"
MIDDOT="•"
PLUSMINUS="±"
ELLIPSES="…"
CHECKMARK="✔"


function __parse_git_branch {
    declare branch="$1"

    local branch_color=${LT_BLUE}
    local git_branch=${branch}

    if [[ ${branch} = "HEAD (no branch)" ]] ; then
        local g=$(git rev-parse --git-dir)
        if [[ -d "${g}/rebase-merge" ]] ; then
            branch_color=${PINK}
            git_branch=$(cut -f3- -d/ "${g}/rebase-merge/head-name")
        elif [[ -d "${g}/rebase-apply" ]] ; then
            branch_color=${PINK}
            git_branch=$(cut -f3- -d/ "${g}/rebase-apply/head-name")
        else
            branch_color=${PURPLE}
            git_branch=$(git rev-parse --short HEAD)
        fi
    fi

    echo -e "${branch_color}${git_branch}${COLOR_NONE}"
}

function __parse_git_relative {
    declare relation="$1" text="$2"
    local regex="${relation} ([0-9]+)"
    [[ $text =~ $regex ]] && echo "${BASH_REMATCH[1]}"
}

function __parse_git_status {
    status=$(git status --porcelain --branch 2>&1)
    [[ $? == 0 ]] || exit 1

    git_branch=""
    (( mods = 0 ))
    (( adds = 0 ))
    (( dels = 0 ))
    (( news = 0 ))
    (( rens = 0 ))
    (( cons = 0 ))

    # Interpret file states
    # https://git-scm.com/docs/git-status
    while read -r line; do
        _xy=${line:0:2}
        _rest=${line:3}
        case $_xy in
            "##") git_branch=$(__parse_git_branch "${_rest%...*}")
                  # parse ahead/behind
                  # https://github.com/git/git/blob/8c6d1f9807c67532e7fb545a944b064faff0f70b/wt-status.c#L1694
                  _relative=${_rest%%* }
                  git_ahead=$(__parse_git_relative "ahead" "${_relative}")
                  git_behind=$(__parse_git_relative "behind" "${_relative}")
                  ;;
            'DD'|'AU'|'UD'|'UA'|'DU'|'AA'|'UU') (( cons++ )) ;;
            C?|A?)   (( adds++ )) ;;
            M?|R?)   (( mods++ )) ;;
            D?)   (( dels++ )) ;;
            "??") (( news++ )) ;;
        esac
    done <<< "$status"

    git_sigils=""
    (( cons > 0 )) && git_sigils="${git_sigils}${PURPLE}!${cons}${COLOR_NONE}"
    (( adds > 0 )) && git_sigils="${git_sigils}${GREEN}+${adds}${COLOR_NONE}"
    (( mods > 0 )) && git_sigils="${git_sigils}${YELLOW}~${mods}${COLOR_NONE}"
    (( dels > 0 )) && git_sigils="${git_sigils}${RED}-${dels}${COLOR_NONE}"
    (( news > 0 )) && git_sigils="${git_sigils}${WHITE}${ELLIPSES}${news}${COLOR_NONE}"
    [[ -n $git_sigils ]] && git_sigils=" $git_sigils"

    git_tracking=""
    [[ -n $git_behind ]] && git_tracking=" ${WHITE}${DOWN_ARROW}${COLOR_NONE}${git_behind}"
    [[ -n $git_ahead ]] && git_tracking="${git_tracking} ${WHITE}${UP_ARROW}${COLOR_NONE}${git_ahead}"

    echo -e "(${git_branch}${git_tracking}${git_sigils})"
}

function setWindowTitle {
  case $TERM in
    *xterm*|ansi)
      echo -n -e "\033]0;$*\007"
      ;;
  esac
}

function set_prompt {
  export PS1="[\w] $(__parse_git_status)${COLOR_NONE}\n\$ "
  setWindowTitle "${PWD/$HOME/~}"
}

export PROMPT_COMMAND=set_prompt
