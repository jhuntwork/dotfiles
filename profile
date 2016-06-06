# Personal profile settings
hn=$(hostname -s)
R="\033[00m"
M="\033[32m"
P='$'

[ "${USER}" = "root" ] && M="\033[31m" && P='#'

set_ps1() {
    printf "${hn} ${M}|\033[36m ${PWD}${R}\n${P} "
}

PATH="${HOME}/bin:${HOME}/.rbenv/bin${NEWPATH}:/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin"
export PATH

PS1='$(set_ps1)'
PS2=" > "
EDITOR=vim
TZ=America/New_York
LANG=en_US.UTF-8
HISTFILE="${HOME}/.history"
HISTSIZE=1000
# Darwinism
CLICOLOR=1

export EDITOR TZ LANG HISTFILE HISTSIZE CLICOLOR

# Used by bash, unused by mksh
if [ "${0##*/}" = "bash" ] || [ "${0}" = "-bash" ] ; then
    is_bash=1
    shopt -s expand_aliases
    shopt -s checkwinsize
    HISTFILESIZE=2000
    HISTCONTROL=ignoredups:ignorespace
    export HISTFILESIZE HISTCONTROL
else
    is_bash=0
fi

[ "$(uname -s)" = "Linux" ] && alias ls='ls --color'
alias ll='ls -l'

[ -r "${HOME}/.functions.sh" ] && . "${HOME}/.functions.sh"
if [ -d "${HOME}/.profile.d" ] ; then
    for file in ${HOME}/.profile.d/*.sh ; do
        . "$file"
    done
fi
