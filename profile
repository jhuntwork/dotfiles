# Personal profile settings
hn=$(hostname -s)
R="\033[00m"
M="\033[32m"
P='$'

if [ "${USER}" = "root" ] ; then
        M="\033[31m"
        P='#'
fi

set_ps1() {
    printf "${hn} ${M}|\033[36m ${PWD}${R}\n${P} "
}

PS1='$(set_ps1)'
PS2=" > "
EDITOR=vim
TZ=America/New_York
LANG=en_US.UTF-8
HISTFILE="${HOME}/.history"
HISTSIZE=1000
# Darwinism
CLICOLOR=1

export EDITOR HISTSIZE TZ LANG CLICOLOR

# Used by bash, unused by mksh
if [ "${0##*/}" = "bash" ] || [ "${0}" = "-bash" ] ; then
    shopt -s expand_aliases
    shopt -s checkwinsize
    HISTFILESIZE=2000
    HISTTIMEFORMAT="%F %T :: "
    HISTCONTROL=ignoredups:ignorespace
    export HISTFILESIZE HISTTIMEFORMAT HISTCONTROL
fi

[ "$(uname -s)" = "Linux" ] && alias ls='ls --color'
alias ll='ls -l'

[ -r "${HOME}/.functions.sh" ] && . "${HOME}/.functions.sh"
