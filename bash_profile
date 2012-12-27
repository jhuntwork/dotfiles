# Personal Bash Profile settings
shopt -s expand_aliases
shopt -s checkwinsize

case `uname -s` in
    "Darwin")
        export CLICOLOR=1
        ;;
    "Linux")
        alias ls="ls --color"
        ;;
esac

alias ll='ls -l'

if [ "`locale charmap 2>/dev/null`" = "UTF-8" ]
then
    stty iutf8
fi

# Set the titlebar text for X terminals.
if [    "$TERM" = "xterm" -o \
        "$TERM" = "xterm-color" -o \
        "$TERM" = "xterm-256color" -o \
        "$TERM" = "xterm-xfree86" -o \
        "$TERM" = "rxvt" -o \
        "$TERM" = "rxvt-unicode" ]
then
    export PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"'
fi

NORMAL=$(tput sgr0)
CYAN=$(tput setaf 6)
if [ $EUID = 0 ]
then
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

test -f $HOME/.jssh && source $HOME/.jssh
