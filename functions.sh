# Create symlinks in the $HOME directory to elements in .dotfiles
setup_dotfiles() {
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

# 1. Attempt to efficiently syncrhonize .dotfiles from the local
# machine to the remote host first.
# 2. Re-use the ssh tcp connection on the subsequent login
# 3. Bypass the system shell login defaults and just exec a non-login,
# interactive shell.
jssh() {
    local curdir=$(pwd)
    local func=$(typeset -f setup_dotfiles)
    local ssh_opts='-o ControlMaster=auto -o ControlPath=~/.ssh/mux_%h_%p_%r -o ControlPersist=5s'
    cd "$HOME"
    rsync -av --delete-after \
        --exclude .git .dotfiles -e "ssh $ssh_opts" "$@":~/
    ssh -A -t $ssh_opts "$@" \
        "${func} ;
         [ -r /etc/motd ] && cat /etc/motd ;
         [ -r \"\$HOME/.profile\" ] && . \"\$HOME/.profile\" ;
         type jssh >/dev/null 2>&1 || setup_dotfiles ;
         exec env -i SSH_AUTH_SOCK=\"\$SSH_AUTH_SOCK\" \
         SSH_CONNECTION=\"\$SSH_CONNECTION\" \
         SSH_CLIENT=\"\$SSH_CLIENT\" SSH_TTY=\"\$SSH_TTY\" \
         HOME=\"\$HOME\" TERM=\"\$TERM\" \
         PATH=\"\$PATH\" SHELL=\"\$SHELL\" \
         USER=\"\$USER\" \$SHELL -i"
}
alias ssj="jssh"
