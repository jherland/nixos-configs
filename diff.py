#!/usr/bin/env python3
"""Utils for generating diffs."""

import argparse
from contextlib import ExitStack
import json
from pathlib import Path
import pprint
import sys
import subprocess
from tempfile import NamedTemporaryFile


DIFF_CMD = ["git", "--no-pager", "diff", "--no-index"]


def diff_files(old: Path, new: Path, *args: str) -> int:
    """Print a diff between two files."""
    return subprocess.run(DIFF_CMD + [*args, old, new]).returncode


def diff_strings(s1, s2, *args):
    """Print a diff between two strings."""
    with ExitStack() as stack:
        f1 = stack.enter_context(NamedTemporaryFile(mode="w"))
        f1.write(s1)
        f1.flush()

        f2 = stack.enter_context(NamedTemporaryFile(mode="w"))
        f2.write(s2)
        f2.flush()

        return diff_files(f1.name, f2.name, *args)


def diff_objs_as_json(obj1, obj2, *args, **kwargs):
    """Print a diff between the JSON serialization of two objects."""
    return diff_strings(
        json.dumps(obj1, **kwargs) + "\n",
        json.dumps(obj2, **kwargs) + "\n",
        *args,
    )


def diff_objs_as_pprint(obj1, obj2, *args, **kwargs):
    """Print a diff between the pprint() representation of two objects."""
    return diff_strings(
        pprint.pformat(obj1, **kwargs),
        pprint.pformat(obj2, **kwargs),
        *args,
    )


def main(*args):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("old", type=Path)
    parser.add_argument("new", type=Path)
    parser.add_argument("--json", action='store_true')
    args, extra = parser.parse_known_args(args)

    if args.json:
        with args.old.open() as f:
            old = json.load(f)
        with args.new.open() as f:
            new = json.load(f)
        return diff_objs_as_json(old, new, *extra, indent=2)
    else:
        return diff_files(args.old, args.new, *extra)


if __name__ == "__main__":
    sys.exit(main(*sys.argv[1:]))
