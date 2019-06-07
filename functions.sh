#!/bin/sh -e
setup_dotfiles() {
    cd "${HOME}/.dotfiles" || return
    for i in * ; do
        l="${HOME}/.${i%/*}"
        s=".dotfiles/${i}"
        [ -L "$l" ] && [ "$(readlink "$l")" = "$s" ] && continue
        rm -rf "$l"
        ln -s "$s" "$l"
    done
    cd "$HOME"
    find -L . -maxdepth 1 -type l -exec rm -- {} +
}

add_public_key() {
    [ -d "${HOME}/.ssh" ] || install -m 0700 -d "${HOME}/.ssh"
    if [ -n "$*" ] ; then
        grep -q "$*" "${HOME}/.ssh/authorized_keys" 2>/dev/null || \
          printf '%s\n' "$*" >>"${HOME}/.ssh/authorized_keys"
    fi
}

ssj() {
    [ $# -eq 0 ] && return 1
    k="$(cat "${HOME}/.ssh/id_rsa.pub" 2>/dev/null)"
    k="${k% *}"
    ssh-add -L | grep -q "$k" || ssh-add "${HOME}/.ssh/id_rsa"
    [ -f "${HOME}/.d64" ] || tar -cf - -C "$HOME" --exclude .git \
        --exclude vim/bundle/syntastic --exclude README.md .dotfiles|\
        gzip -9 | base64 >"${HOME}/.d64"
    DOTFILES="$(cat "${HOME}/.d64")"
    ssh -tq -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null "$@" \
        "cd \"\$HOME\";\
        printf '%s' '$DOTFILES'|base64 -d |tar -xz;\
        . .dotfiles/functions.sh;\
        add_public_key $k;\
        setup_dotfiles;\
        SHELL=\$SHELL;
        MKSH=\$(command -v mksh);\
        [ -n \"\$MKSH\" ] && SHELL=\"\$MKSH\";\
        exec env -i HOME=\"\$HOME\" TERM=\"\$TERM\" \
            SHELL=\"\$SHELL\" USER=\"\$USER\" \$SHELL -i"
}

syntastic() {
    r="${HOME}/.vim/bundle"
    if [ ! -d "${r}/syntastic" ] ; then
        install -d "$r"
        git clone --depth=1 https://github.com/vim-syntastic/syntastic.git \
            "${r}/syntastic"
    fi
}

extra_profile() {
    # shellcheck source=/dev/null
    if [ -d "${HOME}/.extra_profile.d" ] ; then
        for file in "${HOME}"/.extra_profile.d/*.sh ; do
            . "$file"
        done
    fi
}
