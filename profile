#!/bin/sh -e
# Personal profile settings
hn=$(hostname -s)
R="\033[00m"
M="\033[38;5;045m"
P='$'

[ "$USER" = 'root' ] && M="\033[38;5;167m" && P='#'

set_ps1() {
    # shellcheck disable=SC2059
    printf "${hn} ${M}${PWD}${R}\\n${P} "
}

PS1='$(set_ps1)'
PS2=" > "
EDITOR=vim
PAGER=less
TZ=America/New_York
LANG=en_US.UTF-8
HISTFILE="${HOME}/.history"
HISTSIZE=1000
HISTFILESIZE=$HISTSIZE
PATH="${HOME}/bin:/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin"

export EDITOR PAGER TZ LANG HISTFILE HISTSIZE HISTFILESIZE HISTCONTROL CLICOLOR PATH

[ "$(uname -s)" = "Linux" ] && alias ls='ls --color'
alias ll='ls -l'

# shellcheck source=/dev/null
if [ -d "${HOME}/.profile.d" ] ; then
    for file in "${HOME}"/.profile.d/*.sh ; do
        . "$file"
    done
fi

# shellcheck source=/dev/null
[ -r "${HOME}/.functions.sh" ] && . "${HOME}/.functions.sh"
