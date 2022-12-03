#!/usr/bin/env python3

import argparse
from collections.abc import Iterator
from contextlib import ExitStack, suppress
import json
import logging
from pathlib import Path
import re
import subprocess
import sys
from tempfile import NamedTemporaryFile
from typing import NamedTuple, Self, TextIO

from derivation import DrvFile, find_drv_path
from diff import diff_strings


logger = logging.getLogger(__file__)

DIFF_CMD = ["git", "--no-pager", "diff", "--no-index"]
STORE_PATTERN = re.compile(r"/nix/store/(?P<hash>[0-9a-z]{32}-(?P<name>.*))")

def closure(store_path: Path) -> Iterator[Path]:
    proc = subprocess.Popen(
        ["nix-store", "--query", "--requisites", store_path],
        stdin=subprocess.DEVNULL,
        stdout=subprocess.PIPE,
        text=True,
    )
    for line in proc.stdout:
        yield Path(line.strip())


def nix_store_sort_key(store_path: Path):
    match = STORE_PATTERN.fullmatch(str(store_path))
    return f"{match['name']}|{match['hash']}"


def write_closure(store_path: Path, f: TextIO):
    for p in sorted(closure(store_path), key=nix_store_sort_key):
        f.write(f"{p}\n")


def display_diff(old: Path, new: Path, extra_args: list[str]) -> None:
    proc = subprocess.run(DIFF_CMD + extra_args + [old, new])
    return proc.returncode


###


class RawDiff(NamedTuple):
    mode_old: int
    mode_new: int
    sha1_old: str
    sha1_new: str
    status: str  # first letter of raw diff status code
    paths: list[Path]

    def __str__(self):
        return (
            f"{self.__class__.__name__}({self.mode_old:o} -> {self.mode_new:o},"
            f" {self.sha1_old} -> {self.sha1_new}, {self.status},"
            f" {self.paths})"
        )

    @classmethod
    def parse_one(cls, line: str) -> Self:
        preamble, *paths = line.split("\t")
        mode_old, mode_new, sha1_old, sha1_new, status = preamble.split(" ")
        assert mode_old.startswith(":"), line
        assert status[0] in {"M", "D", "A", "R"}, line
        if status[0] in {"M", "D", "A"}:
            assert len(paths) == 1, line
        elif status[0] in {"R"}:
            assert len(paths) == 2, line
        return cls(
            int(mode_old[1:], 8),
            int(mode_new, 8),
            sha1_old,
            sha1_new,
            status[0],
            [Path(p) for p in paths],
        )

    @classmethod
    def parse_many(cls, data: str) -> Iterator[Self]:
        for line in data.split("\n"):
            if line:
                yield cls.parse_one(line)

    @classmethod
    def run(cls, old: Path, new: Path) -> Iterator[Self]:
        proc = subprocess.run(
            DIFF_CMD + ["--raw", "--find-renames", old, new],
            stdout=subprocess.PIPE,
            text=True,
        )
        yield from cls.parse_many(proc.stdout)


class DiffEntry:
    def __init__(self, old_base: Path, new_base: Path, raw: RawDiff):
        self.is_symlink = raw.mode_old == 0o120000 and raw.mode_new == 0o120000
        self.is_modification = raw.status in {"M", "R"}
        if raw.status == "M":
            assert raw.paths[0].is_relative_to(old_base)
            self.path_old = raw.paths[0]
            self.path_new = new_base / self.path_old.relative_to(old_base)
        elif raw.status == "D":
            assert raw.paths[0].is_relative_to(old_base)
            self.path_old = raw.paths[0]
            self.path_new = Path("/dev/null")
        elif raw.status == "A":
            assert raw.paths[0].is_relative_to(new_base)
            self.path_old = Path("/dev/null")
            self.path_new = raw.paths[0]
        elif raw.status == "R":
            assert raw.paths[0].is_relative_to(old_base)
            assert raw.paths[1].is_relative_to(new_base)
            self.path_old = raw.paths[0]
            self.path_new = raw.paths[1]
        else:
            raise ValueError(raw.status)

    def __str__(self):
        return f"{self.__class__.__name__}({self.path_old} -> {self.path_new})"

    @classmethod
    def run(cls, old: Path, new: Path) -> Iterator[Self]:
        for raw in RawDiff.run(old, new):
            yield cls(old, new, raw)

    def display(self, extra_display_args: list[str]) -> None:
        subprocess.run(
            DIFF_CMD + extra_display_args + [self.path_old, self.path_new]
        )


def diff(old: Path, new: Path, extra_display_args: list[str]):
    for item in DiffEntry.run(old, new):
        if item.is_symlink and item.is_modification:
            print(f"*** Recursing into {item.path_old} vs. {item.path_new}")
            diff(
                item.path_old.readlink(),
                item.path_new.readlink(),
                extra_display_args,
            )
        else:
            item.display(extra_display_args)


def write_diffable_drv(drv_path: Path, f: TextIO):
    proc = subprocess.run(
        ["nix", "show-derivation", drv_path],
        stdout=subprocess.PIPE,
        text=True,
        check=True,
    )
    drv = json.loads(proc.stdout)
    json.dump(drv, f, indent=2, sort_keys=True)


def find_store_path(p: Path) -> Path:
    """Convert (symlink to) store path to actual store path.

    Follow symlinks recursively, and return the ultimate Nix store path (a path
    that starts with "/nix/store/") or raise ValueError, if no such path was
    found.
    """
    with suppress(OSError):
        while p:
            p = p.readlink()

    if p.is_relative_to("/nix/store/"):
        return p
    else:
        raise ValueError(p)


def main(*args):
    parser = argparse.ArgumentParser()
    parser.add_argument("old", type=Path)
    parser.add_argument("new", type=Path)

    args, extra = parser.parse_known_args(args)
    extra += ["--color", "--word-diff"]

    logging.basicConfig(level=logging.INFO)

    with ExitStack() as stack:
        try:
            drv_old = DrvFile.parse(find_drv_path(args.old))
            drv_new = DrvFile.parse(find_drv_path(args.new))

            logging.info(f"Diffing derivers: {drv_old.path} vs. {drv_new.path}")
            view_old = drv_old.human_readable(mask_hashes=True)
            view_new = drv_new.human_readable(mask_hashes=True)
            if diff_strings(view_old, view_new) == 0:
                logging.info(f" -> No salient changes found in the .drv files!")
        except ValueError:
            logging.warning(f"Could not find derivers for both store paths")
            # fall through

        # TODO:
        # - Run `nix-store --query --deriver <path>`` to see if we have .drv
        # - If so, run `nix show-derivation <drv>` to pretty-print drv as JSON
        # - Diff these JSONs?

        # Look at other alternatives:
        # - nix-diff

        # TODO:
        logging.info(f"Diffing packages included in closure: {args.old} vs. {args.new}")
        store_old = find_store_path(args.old)
        store_new = find_store_path(args.new)
        subprocess.run(["nix", "store", "diff-closures", store_old, store_new])

        # Emerging philosophy:
        # - Want to see differences in a _growing_ amount of detail. Encourage
        #   exiting early...
        # - Start with diff of derivations. This is diffing the build instructions,
        #   and should hopefully correspond more directly to the changes that were
        #   made by the end user in their Nix expressions
        # - Next diff the list/tree of packages included in the closure. This gives
        #   birds-eye view of added/removed packages and versions, without drilling
        #   into the contents of each.
        # - Finally, diff the contents of the closure itself. This can get very ugly
        #   very fast, so might want to hide this behind an option.
        # - Always - by default - hide Nix store hashes. These contribute mostly noise
        #   to the diffs, as the hashes themselves are meaningless, and only refer to
        #   other stuff inside the same closure.
        # - If we're lucky (and sort things smartly) we should get diffs that only
        #   show the salient differences between corresponding packages in the two
        #   closures.

        logging.info(f"Diffing output closures: {args.old} vs. {args.new}")
        old_f = stack.enter_context(NamedTemporaryFile(mode="w"))
        write_closure(args.old, old_f)
        old_f.flush()

        new_f = stack.enter_context(NamedTemporaryFile(mode="w"))
        write_closure(args.new, new_f)
        new_f.flush()

        extra += ['--ignore-matching-lines=/nix/store/\w{32}-']
        display_diff(old_f.name, new_f.name, extra)


if __name__ == "__main__":
    sys.exit(main(*sys.argv[1:]))
