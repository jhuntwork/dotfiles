#!/bin/sh -e
# Personal profile settings
hn=$(hostname -s)

# PS settings
set_ps1() {
    printf '%s %b%s%b\n$ ' "$hn" '\033[38;5;202m' "$PWD" '\033[00m'
}

PS1='$(set_ps1)'
PS2=' > '

# Default ENVVARS
EDITOR='vim'
LANG='en_US.UTF-8'
HISTFILE="${HOME}/.history"
HISTSIZE=1000
HISTFILESIZE=$HISTSIZE
PATH="${HOME}/bin:/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin"
CLICOLOR=1
export EDITOR LANG HISTFILE HISTSIZE HISTFILESIZE PATH CLICOLOR

[ "$(uname -s)" = "Linux" ] && alias ls='ls --color'
alias ll='ls -l'

# shellcheck source=/dev/null
if [ -d "${HOME}/.profile.d" ] ; then
    for file in "$HOME"/.profile.d/*.sh ; do
        . "$file"
    done
fi

# shellcheck source=/dev/null
[ -r "${HOME}/.functions.sh" ] && . "${HOME}/.functions.sh"
