#!/bin/sh

set -e

host=$1
if [ -z "$host" ]; then
    host=$(hostname)
fi
test "$host" = "$(hostname)" && is_local=1

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

test -h "$old" && has_old=1

if [ "$is_local" = "1" ]; then
    echo "Current system: $(readlink /run/current-system)"
fi
if [ "$has_old" = "1" ]; then
    echo "    Old result: $(readlink "$old")"
fi
echo "    New result: $(readlink "$new")"
echo "To view diffs:"
if [ "$is_local" = "1" ]; then
    echo "    ./diff_results.py /run/current-system \"$new\" | less -RX"
    echo "    nvd diff /run/current-system \"$new\""
fi
if [ "$has_old" = "1" ]; then
    echo "    ./diff_results.py \"$old\" \"$new\" | less -RX"
    echo "    nvd diff \"$old\" \"$new\""
fi

if [ "$is_local" = "1" ]; then
    preamble="sudo "
else
    extra_args=" --target-host \"root@${host}\""
fi
echo "To deploy:"
echo "    ${preamble}nixos-rebuild --flake \"./#${host}\"${extra_args} switch"

# Suggest making /etc/nixos a symlink to this dir, if not already
here=$(readlink -e .)
if [ "$is_local" = "1" -a "$(readlink -e /etc/nixos)" != "$here" ]; then
    echo
    echo "Suggestion: Make /etc/nixos a symlink to $here, to allow 'sudo nixos-rebuild switch'"
    echo "            ( cd /etc && sudo mv nixos nixos.bak && sudo ln -s $here nixos )"
    echo
fi
