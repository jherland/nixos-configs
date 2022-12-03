sh_script = """\
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
"""

d = {
    "first": 123,
    "second": sh_script,
    "third": [
        1,
        2,
        3,
        {
            "another multi-line": sh_script,
            "another key": [1, 2, 3]
        }
    ]
}

# print(d)

from pprint import pprint
pprint(d, sort_dicts=False)

# import rich
# rich.print(d)

# from rich.pretty import pprint as rpprint
# rpprint(d, expand_all=True, indent_guides=False)
