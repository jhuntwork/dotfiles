# Setup the dotfiles repo locally, or pull latest version from github.
# Create symlinks in the $HOME directory to elements in the repo
jpull() {
    local REPO='https://github.com/jhuntwork/dotfiles'
    local SGITURL="${REPO}/raw/e374d0dbc1754b21a3d36b9df5742d351d7fe460/git-static-x86_64-linux-musl.tar.xz"
    local SGITPATH="${HOME}/.git-static"
    local SGIT=git
    if ! ${SGIT} --version >/dev/null 2>&1 ; then
        SGIT="${SGITPATH}/git --exec-path=${SGITPATH}/git-core"
        if ! ${SGIT} --version >/dev/null 2>&1 ; then
            cd ${HOME}
            curl -sL ${SGITURL} | tar -xJf -
        fi
    fi
    if [ -d "${HOME}/.dotfiles" ] ; then
        cd "${HOME}/.dotfiles"
        ${SGIT} reset --hard HEAD >/dev/null 2>&1
        ${SGIT} pull
        ${SGIT} submodule init
        ${SGIT} submodule update
    else
        cd "${HOME}"
        ${SGIT} clone --depth 1 ${REPO} .dotfiles
        ${SGIT} submodule init
        ${SGIT} submodule update
    fi
    cd "${HOME}/.dotfiles" &&
    for f in * ; do
        # A quick check on the files can prevent unnecessary forks
        lf="${HOME}/.${f%/*}"
        if [ ! "${f}" -ef "${lf}" ] ; then
            rm -rf "${lf}"
            ln -s ".dotfiles/${f}" "${lf}"
        fi
    done
    cd "${HOME}"
    # Delete any broken symlinks in the homedir
    find -L . -maxdepth 1 -type l -exec rm -- {} +
    . "${HOME}/.profile"
}

# Simple wrapper for ssh which makes jpull() available in the remote session
# regardless of whether .dotfiles is present remotely or not
jssh() {
    local func=$(typeset -f jpull)
    ssh -A -t "$@" \
    "${func} ;
    [ -r /etc/motd ] && cat /etc/motd ;
    [ -r \"\$HOME/.profile\" ] && . \"\$HOME/.profile\" ;
    type jssh >/dev/null 2>&1 || jpull ;
    exec env -i SSH_AUTH_SOCK=\"\$SSH_AUTH_SOCK\" \
      SSH_CONNECTION=\"\$SSH_CONNECTION\" \
      SSH_CLIENT=\"\$SSH_CLIENT\" SSH_TTY=\"\$SSH_TTY\" \
      HOME=\"\$HOME\" TERM=\"\$TERM\" \
      PATH=\"\$PATH\" SHELL=\"\$SHELL\" \
      USER=\"\$USER\" \$SHELL -i"
}    
alias ssj="jssh"
