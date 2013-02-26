# The path_ functions are modified from http://stackoverflow.com/questions/370047

# Removes one directory from the PATH env. variable
# Accepts one path argument
path_remove () {
    export PATH=$(printf ${PATH} | awk -v RS=: -v ORS=: '$0 != "'$1'"' | sed 's/:$//')
}

# Appends one directory to the PATH env. variable
# Accepts one path argument
path_append () {
    path_remove "${1}"
    export PATH="${PATH}:${1}"
}

# Prepends one directory to the PATH env. variable
# Accepts one path argument
path_prepend () {
    path_remove "${1}"
    export PATH="${1}:${PATH}"
}

# Discovers if git is installed.
# If not available, download a small, static version from github and make it available via
# an alias as well as an exported env. variable: SGIT (required for use in jpull())
set_git () {
    export SGITPATH="${HOME}/.git-static"
    local SGITURL="https://raw.github.com/jhuntwork/dotfiles/master/git-static-x86_64-linux-musl.tar.xz"
    path_append "${SGITPATH}"
    if ! type git >/dev/null 2>&1 ; then
        cd ${HOME}
        printf "No local git. Downloading static version from GitHub...\n" >&2
        curl --progress-bar ${SGITURL} | tar -xJf -
        cd ${OLDPWD}
    fi
    if [[ "$(type -p git)" = "${SGITPATH}/git" ]] ; then
        export SGIT="${SGITPATH}/git --exec-path=${SGITPATH}/git-core"
        alias git="${SGIT}"
    else
        export SGIT="git"
    fi
    path_remove "${SGITPATH}"
}

# Setup the dotfiles repo locally, or pull latest version from github.
# Create symlinks in the $HOME directory to elements in the repo
jpull() {
    local REPO="git@github.com:jhuntwork/dotfiles.git"
    set_git
    CURDIR=$(pwd)
    if [[ -d "${HOME}/.dotfiles" ]] ; then
        cd "${HOME}/.dotfiles"
        ${SGIT} reset --hard HEAD
        ${SGIT} pull
    else
        cd
        ${SGIT} clone --depth 1 ${REPO} .dotfiles
    fi
    cd "${HOME}/.dotfiles" &&
    for f in * ; do
        rm -rf "${HOME}/.${f}"
        ln -s ".dotfiles/${f}" "../.${f}"
    done
    chmod -R go= .
    cd "${CURDIR}"
    exec /bin/bash --login
}

# Simple wrapper for ssh which makes jpull() available in the remote session
# regardless of whether .dotfiles is present remotely or not
function jssh() {
    local FUNC_NAMES='jpull path_remove path_append set_git'
    local FUNCS=$(declare -f ${FUNC_NAMES})
    ssh -t "$@" "${FUNCS} ; export -f ${FUNC_NAMES} ; exec /bin/bash --login"
}
