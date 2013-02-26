# Personal Bash Profile settings
shopt -s expand_aliases
shopt -s checkwinsize

case $(uname -s) in
    "Darwin")
        export CLICOLOR=1
        ;;
    "Linux")
        alias ls="ls --color"
        ;;
esac

alias ll='ls -l'

if [[ "$(locale charmap 2>/dev/null)" = "UTF-8" ]] ; then
    stty iutf8
fi

# Set the titlebar text for X terminals.
if [    "$TERM" = "xterm" -o \
        "$TERM" = "xterm-color" -o \
        "$TERM" = "xterm-256color" -o \
        "$TERM" = "xterm-xfree86" -o \
        "$TERM" = "rxvt" -o \
        "$TERM" = "rxvt-unicode" ] ; then
    export PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"'
fi

NORMAL=$(tput sgr0)
CYAN=$(tput setaf 6)
if [[ $EUID = 0 ]] ; then
    MYCOLOR=$(tput setaf 1)
else
    MYCOLOR=$(tput setaf 2)
fi
PS1="\H \[$CYAN\]\W \[$MYCOLOR\]\\$\[$NORMAL\] "
PS2=" \[$MYCOLOR\]>\[$NORMAL\] "
export HISTSIZE=1000
export HISTFILESIZE=2000
export HISTTIMEFORMAT="%F %T :: "
export HISTCONTROL=ignoredups:ignorespace
export EDITOR=vim

path_remove () {
    export PATH=$(printf ${PATH} | awk -v RS=: -v ORS=: '$0 != "'$1'"' | sed 's/:$//')
}

path_append () {
    path_remove "{$1}"
    export PATH="${PATH}:${1}"
}

path_prepend () {
    path_remove "${1}"
    export PATH="${1}:${PATH}"
}

set_git () {
    local SGITPATH="${HOME}/.git-static"
    local SGITURL="https://raw.github.com/jhuntwork/dotfiles/master/git-static-x86_64-linux-musl.tar.xz"
    path_append "${SGITPATH}"
    case $(type -p git) in
        "$HOME/.git-static/git")
            alias git="${SGITPATH}/git --exec-path=${SGITPATH}/git-core"
            ;;
        "")
            cd ${HOME}
            echo "No local git. Downloading static version from GitHub..."
            curl --progress-bar ${SGITURL} | tar -xJf -
            cd ${OLDPWD}
            alias git="${SGITPATH}/git --exec-path=${SGITPATH}/git-core"
            ;;
    esac
    path_remove "${SGITPATH}"
}

jpull() {
    local REPO="git@github.com:jhuntwork/dotfiles.git"
    CURDIR=$(pwd)
    set_git
    if [[ -d "${HOME}/.dotfiles" ]] ; then
        cd "${HOME}/.dotfiles"
        git reset --hard HEAD
        git pull
    else
        cd
        git clone --depth 1 ${REPO} .dotfiles
    fi
    cd ${HOME}/.dotfiles &&
    for f in * ; do
        rm -rf $HOME/.$f
        ln -s .dotfiles/$f ../.$f
    done
    chmod -R go= .
    cd ${CURDIR}
    exec /bin/bash --login
}

function jssh() {
    local FUNC_NAMES='jpull path_remove path_append set_git'
    local FUNCS=$(declare -f ${FUNC_NAMES})
    ssh -t "$@" "${FUNCS} ; export -f ${FUNC_NAMES} ; exec /bin/bash"
}
