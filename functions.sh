# Create symlinks in the $HOME directory to elements in .dotfiles
setup_dotfiles() {
    [ "$1" = "true" ] || return
    cd "${HOME}/.dotfiles" &&
    for f in * ; do
        # A quick check on the files can prevent unnecessary forks
        lf="${HOME}/.${f%/*}"
        sf=".dotfiles/${f}"
        if [ ! "${f}" -ef "${lf}" ] ; then
            rm -rf "${lf}"
            printf "Creating %s -> %s\n" $lf $sf
            ln -s "$sf" "$lf"
        fi
    done
    cd "${HOME}"
    # Delete any broken symlinks in the homedir
    find -L . -maxdepth 1 -type l -exec rm -- {} +
    [ -d "${HOME}/.ssh" ] || install -m 0700 -d "${HOME}/.ssh"
    identity=$(ssh-add -L)
    rc=$?
    if [ $rc -eq 0 ] ; then
        grep -q "$identity" "${HOME}/.ssh/authorized_keys" 2>/dev/null || \
            echo "$identity" >>"${HOME}/.ssh/authorized_keys"
    fi
}

# 1. Attempt to efficiently syncrhonize .dotfiles from the local
# machine to the remote host first.
# 2. Re-use the ssh tcp connection on the subsequent login
# 3. Bypass the system shell login defaults and just exec a non-login,
# interactive shell.
ssj() {
    local func=$(typeset -f setup_dotfiles)
    local ssh_opts='-q -o ControlMaster=auto -o ControlPath=~/.ssh/mux_%h_%p_%r -o ControlPersist=2s'
    local sync="false"
    if [ "$1" = "sync" ] ; then
        sync="true"
        shift
        rsync -av --delete-after --exclude .git \
            -e "ssh $ssh_opts" "${HOME}/.dotfiles" "$@":~/
    fi
    ssh -t $ssh_opts "$@" \
        "${func} ; setup_dotfiles ${sync} ; \
         exec env -i SSH_AUTH_SOCK=\"\$SSH_AUTH_SOCK\" \
         SSH_CONNECTION=\"\$SSH_CONNECTION\" \
         SSH_CLIENT=\"\$SSH_CLIENT\" SSH_TTY=\"\$SSH_TTY\" \
         HOME=\"\$HOME\" TERM=\"\$TERM\" \
         SHELL=\"\$SHELL\" USER=\"\$USER\" \$SHELL -i"
}

msg() {
    printf "%s\n" "$@"
}

info() {
    msg "INF: $@"
}

error() {
    msg "ERR: $@"
    exit 1
}

warn() {
    msg "WRN: $@"
}
