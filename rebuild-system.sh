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

copy_symlink "$new" "$old" || true
copy_symlink ./result "$new"

if [ -h "$old" ]; then
    echo "old result: $(readlink "$old")"
fi
echo "new result: $(readlink "$new")"

if [ "${host}" = "$(hostname)" ]; then
    preamble="sudo "
else
    extra_args=" --target-host \"root@${host}\""
fi
echo "To deploy:"
echo "    ${preamble}nixos-rebuild --flake \"./#${host}\"${extra_args} switch"
