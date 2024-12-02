#!/bin/sh
# hostname
ps1_h=$(hostname -s | tr '[:upper:]' '[:lower:]')
# directory
ps1_d='\033[38;5;74m'
# git branch
ps1_g='\033[38;5;214m'
# clear
ps1_c='\033[00m'
# fail
ps1_f='\033[38;5;202m'
# prompt
ps1_p='$'
[ "$(id -u)" -eq 0 ] && { ps1_d="$ps1_f"; ps1_p='#'; }

set_ps1() {
    ret="$?"
    # status color
    ps1_s=""
    [ "$ret" -eq 0 ] || ps1_s="$ps1_f"
    winsize=$(stty size)
    export COLUMNS="${winsize##* }"
    printf '%s %b%s %b%s%b\n%s %-3d %b%s%b ' \
        "$ps1_h" "$ps1_d" "${PWD##*/}" \
        "$ps1_g" "$(git bn 2>/dev/null)" "$ps1_c" \
        "$(date +%T)" "$ret" "$ps1_s" "$ps1_p" "$ps1_c"
}

# shellcheck source=/dev/null
[ -r "${HOME}/.functions.sh" ] && . "${HOME}/.functions.sh"

PS1='$(set_ps1)'
PS2=' > '

CLICOLOR=1
EDITOR='vim'
LANG='en_US.UTF-8'
HISTFILE="${HOME}/.history"
PAGER='more'
PATH="${HOME}/.local/bin:${PATH}"
export CLICOLOR EDITOR LANG HISTFILE PAGER PATH

ls --color >/dev/null 2>&1 && alias ls='ls --color'
alias ll='ls -l'
alias sui='sudo -E $SHELL'
alias init='exec $SHELL -l'

# Source machine-specific profile files, but prevent sourcing them twice
# shellcheck source=/dev/null
if [ -z "${__PROFILED:-}" ] && [ -d "${HOME}/.profile.d" ]; then
    for file in "$HOME"/.profile.d/*.sh; do
        . "$file"
    done
    export __PROFILED=1
fi

# Remove duplicates from PATH, without sorting
PATH=$(printf '%s' "$PATH" | tr ':' "\n" | awk '!x[$0]++' | tr "\n" ':')
# PATH ends up with a final ':', just remove it
export PATH="${PATH%*:}"
