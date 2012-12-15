# Personal Bash Profile settings
alias ll='ls -l'

function jssh() {
	if [ -z $1 ]
	then
		echo Missing hostname
	else
		ssh -t "$@" "if [ -d ~/.dotfiles ] ; then cd .dotfiles ; git pull ; else git clone git@github.com:jhuntwork/dotfiles.git .dotfiles ; cd .dotfiles && for f in * ; do ln -sf ./.dotfiles/\$f ../.\$f ; done ; fi ; cd ; exec /bin/bash --login"
	fi
}

# Setup a red prompt for root and a green one for users. 
NORMAL="\[\e[0m\]"
RED="\[\e[1;31m\]"
GREEN="\[\e[1;32m\]"
CYAN="\[\e[1;36m\]"
if [[ $EUID == 0 ]] ; then
        PS1="$RED\u$NORMAL@\H \w$RED \\$ $NORMAL"
else
	if [[ `hostname` = 'krikkit.local' ]] ; then
        	PS1="$CYAN\u$NORMAL@\H \w$CYAN \\$ $NORMAL"
	else
        	PS1="$GREEN\u$NORMAL@\H \w$GREEN \\$ $NORMAL"
	fi
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
