#!/bin/sh

set -e

host=$1
if [ -z "$host" ]; then
    host=$(hostname)
fi

new="./result.${host}.new"
old="./result.${host}.old"

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

nixos-rebuild --flake ".#${host}" build

if [ -h "$new" -a "$(readlink $new)" = "$(readlink ./result)" ]; then
    echo "***"
    echo "*** No change since last build! Leaving symlinks as-is."
    echo "***"
else
    copy_symlink "$new" "$old" || true
    copy_symlink ./result "$new"
fi

if [ -h "$old" ]; then
    echo "Old result: $(readlink "$old")"
    echo "New result: $(readlink "$new")"
    echo "To view diff:"
    echo "    ./diff_results.py \"$old\" \"$new\" | less -RX"
fi

if [ "${host}" = "$(hostname)" ]; then
    preamble="sudo "
else
    extra_args=" --target-host \"root@${host}\""
fi
echo "To deploy:"
echo "    ${preamble}nixos-rebuild --flake \"./#${host}\"${extra_args} switch"