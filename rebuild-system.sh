#!/bin/sh

set -e

host=$1
shift

if [ -h ./result ]; then
  rm -f ./old-result
  ln -s "$(readlink ./result)" ./old-result
fi

nixos-rebuild --flake "./systems/${host}#${host}" --target-host "root@${host}" $@

if [ -h old-result ]; then
  echo "old result: $(readlink old-result)"
fi
echo "new result: $(readlink result)"
