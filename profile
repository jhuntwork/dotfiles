# Personal profile settings
hn=$(hostname -s)
R="\033[00m"
M="\033[32m"
P='$'

[ "${USER}" = "root" ] && M="\033[31m" && P='#'

set_ps1() {
    printf "${hn} ${M}|\033[36m ${PWD}${R}\n${P} "
}

IFS=':'
FOUND=''
for path in $(printf "$PATH") ; do
    if ! printf "$FOUND" | grep -q "|-|${path}|-|" ; then
        FOUND="${FOUND}|-|${path}|-|"
        case "${path}" in
            /bin|/sbin|/usr/bin|/usr/sbin|/usr/local/bin|/usr/local/sbin)
                continue ;;
            *)
                NEWPATH="${NEWPATH}:${path}" ;;
        esac
    fi
done
PATH="/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin${NEWPATH}"
export PATH
IFS=' '

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
    shopt -s expand_aliases
    shopt -s checkwinsize
    HISTFILESIZE=2000
    HISTCONTROL=ignoredups:ignorespace
    export HISTFILESIZE HISTCONTROL
fi

[ "$(uname -s)" = "Linux" ] && alias ls='ls --color'
alias ll='ls -l'

[ -r "${HOME}/.functions.sh" ] && . "${HOME}/.functions.sh"

type -p rbenv >/dev/null 2>&1 && eval "$(rbenv init - | sed '/rbenv.bash/d')"
