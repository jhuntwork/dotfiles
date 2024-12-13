#!/bin/sh
ps1_h=$(hostname -s | tr '[:upper:]' '[:lower:]')
ps1_d='\033[38;5;74m'
ps1_g='\033[38;5;214m'
ps1_c='\033[0m'
ps1_f='\033[38;5;202m'
ps1_p='$'
[ "$(id -u)" -eq 0 ] && { ps1_d="$ps1_f"; ps1_p='#'; }

set_ps1() {
    ret="$?"
    ps1_s="$ps1_c"
    [ "$ret" -eq 0 ] || ps1_s="$ps1_f"
    winsize=$(stty size)
    export COLUMNS="${winsize##* }"
    printf '%b%-3d%b %s %b%s %b%s%b\n%s %s ' \
         "$ps1_s" "$ret" "$ps1_c" \
         "$ps1_h" "$ps1_d" "${PWD##*/}" \
         "$ps1_g" "$(git bn 2>/dev/null)" "$ps1_c" \
         "$(date +%T)" "$ps1_p"
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

# Setup an ssh-agent if it is present
if command -v ssh-add >/dev/null 2>&1 && command -v ssh-agent >/dev/null 2>&1; then
    sockets=$(find /tmp/ssh-* -type s -name 'agent.*' -user "$(id -u)" 2>/dev/null)
    for socket in $sockets; do
        SSH_AUTH_SOCK="$socket" ssh-add -l >/dev/null 2>&1
        case "$?" in
            2)   rm -f "$socket"                ;; # Dead socket
            0|1) export SSH_AUTH_SOCK="$socket" ;; # Active socket
        esac
    done
    [ -n "$SSH_AUTH_SOCK" ] || eval "$(ssh-agent)" >/dev/null
    ssh-add -l
fi

# Source machine-specific profile files
# shellcheck source=/dev/null
if [ -d "${HOME}/.profile.d" ]; then
    for file in "$HOME"/.profile.d/*.sh; do
        . "$file"
    done
fi

# Remove duplicates from PATH, without sorting
PATH=$(printf '%s' "$PATH" | tr ':' "\n" | awk '!x[$0]++' | tr "\n" ':')
# PATH ends up with a final ':', just remove it
export PATH="${PATH%*:}"
