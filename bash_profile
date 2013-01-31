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
export EDITOR=vim
unset TMOUT

function jssh() {
    local GITPATH="\$HOME/.git-static"
    local RMTCMD="
    PATH=\"\$PATH:$GITPATH\"
    if ! type -p git >/dev/null
    then
        echo Remote host missing git
        exit 133
    fi
    exec /bin/bash --login"

    if [ -z $1 ]
    then
        echo Missing hostname
    else
        ssh "$@" 'cat >~/.bash_profile -' < ~/.bash_profile
        ssh -A -t "$@" "$RMTCMD"
        if [ $? -eq 133 ]
        then
            echo "Transferring git-static..."
            ssh "$@" 'tar -xJf -' < ~/.git-static-x86_64-linux-musl.tar.xz
            ssh -A -t "$@"
        fi
    fi
}

function jpull() {
    local GITPATH="$HOME/.git-static"
    local REPO="git@github.com:jhuntwork/dotfiles.git"
    PATH="$PATH:$GITPATH"
    if [ "$(type -p git)" = "$GITPATH/git" ]
    then
        shopt -s expand_aliases
        alias git="$GITPATH/git --exec-path=$GITPATH/git-core"
    fi
    if [ -d ~/.dotfiles ]
    then
        cd ~/.dotfiles
        git reset --hard HEAD
        git pull
    else
        cd
        git clone $REPO .dotfiles
    fi
    cd ~/.dotfiles &&
    for f in *
    do
        rm -rf $HOME/.$f
        ln -s .dotfiles/$f ../.$f
    done
    cd &&
    chmod -R go= .
}
