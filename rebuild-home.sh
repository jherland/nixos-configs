#!/bin/sh

set -e

user_at_host=$1
default_user_at_host="${USER}@$(hostname)"
if [ -z "$user_at_host" ]; then
    user_at_host="$default_user_at_host"
fi

new="./result.${user_at_host}.new"
old="./result.${user_at_host}.old"

copy_symlink() {
    src=$1
    dst=$2
    if [ -h "$src" ]; then
        rm -f "$dst"
        ln -s "$(readlink "$src")" "$dst"
    else
        echo "${src} is not a symlink!"
        false
    fi
}

home-manager build --flake ".#${user_at_host}"

copy_symlink "$new" "$old" || true
copy_symlink ./result "$new"

if [ -h "$old" ]; then
    echo "Old result: $(readlink "$old")"
    echo "New result: $(readlink "$new")"
    echo "To view diff:"
    echo "    ./diff_results.py \"$old\" \"$new\" | less -RX"
fi

if [ "${user_at_host}" = "$default_user_at_host" ]; then
    echo "To deploy:"
    echo "    home-manager switch --flake \".#${user_at_host}\""
else
    echo "*** Don't know how to switch home-manager remotely yet!"
fi
