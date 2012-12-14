alias ll='ls -l'

# Setup a red prompt for root and a green one for users. 
NORMAL="\[\e[0m\]"
RED="\[\e[1;31m\]"
GREEN="\[\e[1;32m\]"
if [[ $EUID == 0 ]] ; then
        PS1="$RED\u$NORMAL@\h \w$RED \\$ $NORMAL"
else
        PS1="$GREEN\u$NORMAL@\h \w$GREEN \\$ $NORMAL"
fi
PS2=' '

if [ "`locale charmap 2>/dev/null`" = "UTF-8" ]
then
        stty iutf8
fi

shopt -s checkwinsize

# Set the titlebar text for X terminals.
if [    "$TERM" = "xterm" -o \
        "$TERM" = "xterm-color" -o \
        "$TERM" = "xterm-256color" -o \
        "$TERM" = "xterm-xfree86" -o \
        "$TERM" = "rxvt" -o \
        "$TERM" = "rxvt-unicode" ]; then
        export PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"'
fi

export HISTSIZE=1000
export HISTFILESIZE=2000
export HISTTIMEFORMAT="%F %T :: "
export HISTCONTROL=ignoredups:ignorespace
unset TMOUT
