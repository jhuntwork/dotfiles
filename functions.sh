# Create symlinks in the $HOME directory to elements in .dotfiles
setup_dotfiles() {
    cd "${HOME}/.dotfiles" || return

    case $(uname -o) in
        Darwin) stat_cmd='stat -f %Y' ;;
             *) stat_cmd='stat -c %N' ;;
    esac

    # Create any missing symlinks
    for item in * ; do
        link="${HOME}/.${item%/*}"
        source=".dotfiles/${item}"
        if [ -L "$link" ] ; then
            target=$(${stat_cmd} "$link" | cut -d"'" -f4)
            [ "$target" = "$source" ] && continue
        fi
        # `rm -rf` is used instead of `ln -sf` because $link could be a dir
        rm -rf "${link}"
        ln -s "$source" "$link"
    done

    # Delete any broken symlinks in the homedir
    cd "${HOME}" || return
    find -L . -maxdepth 1 -type l -exec rm -- {} +

    # Add ssh public key, if missing
    [ -d "${HOME}/.ssh" ] || install -m 0700 -d "${HOME}/.ssh"
    if [ -n "$SSH_PUBKEY" ] ; then
        grep -q "$SSH_PUBKEY" "${HOME}/.ssh/authorized_keys" 2>/dev/null || \
            printf "%s\n" "$SSH_PUBKEY" >>"${HOME}/.ssh/authorized_keys"
    fi
}

# - Attempt to syncrhonize .dotfiles from the local host to the remote host.
# - Try to re-use the tcp connection on the subsequent login (only OpenSSH).
# - Bypass the system login defaults and exec a non-login, interactive shell.
ssj() {
    case $(ssh -V 2>&1 | cut -d' ' -f1) in
        OpenSSH*)
            ssh_opts='-q -o ControlMaster=auto'
            ssh_opts="$ssh_opts -o ControlPath=~/.ssh/mux_%h_%p_%r"
            ssh_opts="$ssh_opts -o ControlPersist=2s"
            ;;
    esac

    [ -z "$SSH_PUBKEY" ] && SSH_PUBKEY=$(cat "${HOME}/.ssh/id_rsa.pub")

    # rsync may fail, especially if it's not present on the remote host
    # ignore and proceed to login
    rsync -rltD --delete-after --exclude .git \
          -e "ssh $ssh_opts" "${HOME}/.dotfiles" "$*":~/ 2>/dev/null

    # shellcheck disable=SC2029,SC2086
    ssh -t $ssh_opts "$@" \
        "[ -f \${HOME}/.dotfiles/functions.sh ] &&
         . \${HOME}/.dotfiles/functions.sh ; \
         SSH_PUBKEY=\"${SSH_PUBKEY}\" ; export SSH_PUBKEY ; \
         type setup_dotfiles >/dev/null 2>&1 && setup_dotfiles ; \
         exec env -i SSH_AUTH_SOCK=\"\$SSH_AUTH_SOCK\" \
         SSH_CONNECTION=\"\$SSH_CONNECTION\" SSH_PUBKEY=\"\$SSH_PUBKEY\" \
         SSH_CLIENT=\"\$SSH_CLIENT\" SSH_TTY=\"\$SSH_TTY\" \
         HOME=\"\$HOME\" TERM=\"\$TERM\" \
         SHELL=\"\$SHELL\" USER=\"\$USER\" \$SHELL -i"
}

msg() {
    printf "%s\n" "$*"
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
