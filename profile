#!/bin/sh
ps1_h=$(hostname -s)
ps1_c='\033[38;5;74m'
ps1_p='$'
[ "$(id -u)" -eq 0 ] && { ps1_c='\033[38;5;202m'; ps1_p='#'; }

set_ps1() {
    winsize=$(stty size)
    export COLUMNS=${winsize##* }
    printf '%d %s %s %b%s%b\n%s ' \
        "$?" "$ps1_h" "$(date +%T)" "$ps1_c" "$PWD" '\033[00m' "$ps1_p"
}

# shellcheck source=/dev/null
[ -r "${HOME}/.functions.sh" ] && . "${HOME}/.functions.sh"

PS1='$(set_ps1)'
PS2=' > '

EDITOR='vim'
LANG='en_US.UTF-8'
HISTFILE="${HOME}/.history"
PATH="${HOME}/bin:/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin"
CLICOLOR=1

ls --color >/dev/null 2>&1 && alias ls='ls --color'
alias ll='ls -l'
alias sui='sudo -E $SHELL'
alias init='exec $SHELL -l'

# shellcheck source=/dev/null
[ -d "${HOME}/.profile.d" ] &&
    for file in "$HOME"/.profile.d/*.sh; do . "$file" ; done

# PATH has probably been updated from .profile.d files, so export it here
export PATH EDITOR LANG HISTFILE CLICOLOR
