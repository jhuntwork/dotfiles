# Setup the dotfiles repo locally, or pull latest version from github.
# Create symlinks in the $HOME directory to elements in the repo
jpull() {
    local REPO='git@github.com:jhuntwork/dotfiles.git'
    local SGITURL='https://raw.github.com/jhuntwork/dotfiles/e374d0dbc1754b21a3d36b9df5742d351d7fe460/git-static-x86_64-linux-musl.tar.xz'
    local SGITPATH="${HOME}/.git-static"
    SGIT=git
    if ! ${SGIT} --version >/dev/null 2>&1 ; then
        SGIT="${SGITPATH}/git --exec-path=${SGITPATH}/git-core"
        if ! ${SGIT} --version >/dev/null 2>&1 ; then
            cd ${HOME}
            curl -sL ${SGITURL} | tar -xJf -
        fi
    fi
    if [ -d "${HOME}/.dotfiles" ] ; then
        cd "${HOME}/.dotfiles"
        ${SGIT} reset --hard HEAD
        ${SGIT} pull
    else
        cd ${HOME}
        ${SGIT} clone --depth 1 ${REPO} .dotfiles
    fi
    cd "${HOME}/.dotfiles" &&
    for f in * ; do
        rm -rf "${HOME}/.${f}"
        ln -s ".dotfiles/${f}" "../.${f}"
    done
    cd ${HOME}
    # Delete broken symlinks
    find -L . -maxdepth 1 -type l -delete
    exec ${SHELL} -l
}

# Simple wrapper for ssh which makes jpull() available in the remote session
# regardless of whether .dotfiles is present remotely or not
function jssh() {
ssh -A -t "$@" '(type jpull >/dev/null 2>&1 || eval "$(curl -sL --connect-timeout 1 \
    https://raw.github.com/jhuntwork/dotfiles/master/functions.sh)") ;
    [ -r /etc/motd ] && cat /etc/motd ;
    exec ${SHELL} -l'
}
