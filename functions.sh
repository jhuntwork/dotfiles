#!/bin/sh -e
setup_dotfiles() {
    # Create symlinks in the $HOME directory to elements in .dotfiles
    cd "${HOME}/.dotfiles" || return

    # Create any missing symlinks
    for item in * ; do
        link="${HOME}/.${item%/*}"
        source=".dotfiles/${item}"
        if [ -L "$link" ] ; then
            [ "$(readlink "$link")" = "$source" ] && continue
        fi
        # `rm -rf` is used instead of `ln -sf` because $link could be a dir
        rm -rf "${link}"
        ln -s "$source" "$link"
    done

    # Delete any broken symlinks in the homedir
    cd "${HOME}" || return
    find -L . -maxdepth 1 -type l -exec rm -- {} +
}

add_public_key() {
    # Add ssh public key, if missing
    [ -d "${HOME}/.ssh" ] || install -m 0700 -d "${HOME}/.ssh"
    if [ -n "$SSH_PUBKEY" ] ; then
        grep -q "$SSH_PUBKEY" "${HOME}/.ssh/authorized_keys" 2>/dev/null || \
            printf '%s\n' "$SSH_PUBKEY" >>"${HOME}/.ssh/authorized_keys"
    fi
}

ssj() {
    # - Bypass the system login defaults and exec a non-login, interactive shell.
    [ $# -eq 0 ] && return 1
    ssh_ver=$(ssh -V 2>&1)
    case ${ssh_ver%,*} in
        OpenSSH*)
            ssh_opts='-q -o ControlMaster=auto'
            ssh_opts="$ssh_opts -o ControlPath=~/.ssh/mux_%h_%p_%r"
            ssh_opts="$ssh_opts -o ControlPersist=2s"
            ;;
    esac

    [ -z "$SSH_PUBKEY" ] && \
        SSH_PUBKEY=$(cat "${HOME}/.ssh/id_rsa.pub" 2>/dev/null)

    if [ ! -f "${HOME}/.dotfiles.base64" ] ; then
        tar -c -C "$HOME" --exclude .gitmodules --exclude .git --exclude vim/bundle \
            --exclude README.md .dotfiles 2>/dev/null | gzip -9 | base64 >.dotfiles.base64
    fi
    DOTFILES=$(cat "${HOME}/.dotfiles.base64")

    # shellcheck disable=SC2029,SC2086
    ssh -t $ssh_opts "$@" \
        "export THOME=/dev/shm/\$USER; \
         install -d -m 0700 \"\$THOME\" && cd \"\$THOME\"; \
         printf '%s' \"$DOTFILES\" | base64 -d | zcat | tar -x ; \
         . .dotfiles/functions.sh ; \
         printf '%s\\n' 'trap cleanup_home EXIT' >>.dotfiles/functions.sh ; \
         SSH_PUBKEY=\"${SSH_PUBKEY}\" ; export SSH_PUBKEY ; \
         type add_public_key >/dev/null 2>&1 && add_public_key ; \
         export HOME=\"\$THOME\" ; \
         type setup_dotfiles >/dev/null 2>&1 && setup_dotfiles ; \
         exec env -i SSH_AUTH_SOCK=\"\$SSH_AUTH_SOCK\" \
         SSH_CONNECTION=\"\$SSH_CONNECTION\" SSH_PUBKEY=\"\$SSH_PUBKEY\" \
         SSH_CLIENT=\"\$SSH_CLIENT\" SSH_TTY=\"\$SSH_TTY\" \
         HOME=\"\$HOME\" TERM=\"\$TERM\" \
         SHELL=\"\$SHELL\" USER=\"\$USER\" \$SHELL -i"
}

syntastic() {
    repodir="${HOME}/.vim/bundle/syntastic"
    if [ -d "$repodir" ] ; then
        cd "$repodir"
        git pull
    else
        install -d "${repodir%/*}"
        cd "${repodir%/*}"
        git clone --depth=1 https://github.com/vim-syntastic/syntastic.git
        cd "$OLDPWD"
    fi
}

cleanup_home() {
    if [ "${HOME%/*}" = '/dev/shm' ] ; then
        cd /
        rm -rf "${HOME}"
    fi
}

msg() {
    printf '%s\n' "$*"
}

info() {
    msg "INF: $*"
}

error() {
    msg "ERR: $*"
    exit 1
}

warn() {
    msg "WRN: $*"
}
