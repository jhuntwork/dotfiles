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

function jssh() {
    local REPO="git@github.com:jhuntwork/dotfiles.git"
    local GITPATH="\$HOME/.git-static"
    local RMTCMD="
    OLDPATH=\$PATH
    PATH=\"$GITPATH:\$PATH\"
    if ! type -p git >/dev/null
    then
        echo Remote host missing git
        exit 133
    fi
    if [ \"\$(type -p git)\" = \"$GITPATH/git\" ]
    then
        shopt -s expand_aliases
        alias git=\"$GITPATH/git --exec-path=$GITPATH/git-core\"
    fi
    if [ -d ~/.dotfiles ]
    then
        cd ~/.dotfiles
        git stash
        git pull
    else
        git clone $REPO .dotfiles
    fi
    cd ~/.dotfiles &&
    for f in *
    do
        rm -rf \$HOME/.\$f
        ln -s .dotfiles/\$f ../.\$f
    done
    cd &&
    chmod -R go= .
    PATH=\$OLDPATH
    unset OLDPATH
    exec /bin/bash --login"
    
    if [ -z $1 ]
    then
        echo Missing hostname
    else
        echo "Updating .dotfiles and logging in..."
        ssh -A -t "$@" "$RMTCMD"
        if [ $? -eq 133 ]
        then
            echo "Transferring git-static..."
            ssh "$@" 'tar -xJf -' < ~/.git-static-x86_64-linux-musl.tar.xz
            echo "Reattempting to update .dotfiles and log in..."
            ssh -A -t "$@" "$RMTCMD"
        fi
    fi
}

# Setup a red prompt for root and a green one for users. 
NORMAL=$(tput sgr0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
CYAN=$(tput setaf 6)
if [[ $EUID == 0 ]] ; then
        PS1="\[$RED\]\u\[$NORMAL\]@\H \w\[$RED\] \\$ \[$NORMAL\]"
else
	if [[ `hostname` = 'krikkit.local' ]] ; then
            PS1="\[$CYAN\]\u\[$NORMAL\]@\H \w\[$CYAN\] \\$ \[$NORMAL\]"
	else
            PS1="\[$GREEN\]\u\[$NORMAL\]@\H \w\[$GREEN\] \\$ \[$NORMAL\]"
	fi
fi
PS2=' '

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
        "$TERM" = "rxvt-unicode" ]; then
        export PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"'
fi

export HISTSIZE=1000
export HISTFILESIZE=2000
export HISTTIMEFORMAT="%F %T :: "
export HISTCONTROL=ignoredups:ignorespace
unset TMOUT
