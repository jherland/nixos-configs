#!/usr/bin/env python3

import argparse
from collections.abc import Iterator
from pathlib import Path
import subprocess
import sys
from typing import NamedTuple, Self, TextIO

DIFF_CMD = ["git", "diff", "--no-index"]


class RawDiff(NamedTuple):
    mode_old: int
    mode_new: int
    sha1_old: str
    sha1_new: str
    status: str
    path_old: Path

    def __str__(self):
        return (
            f"{self.__class__.__name__}({self.mode_old:o} -> {self.mode_new:o},"
            f" {self.sha1_old} -> {self.sha1_new}, {self.status},"
            f" {self.path_old})"
        )

    @classmethod
    def parse_one(cls, line: str) -> Self:
        preamble, *paths = line.split("\t")
        mode_old, mode_new, sha1_old, sha1_new, status = preamble.split(" ")
        assert mode_old.startswith(":")
        assert status in {"M"}
        assert len(paths) == 1
        return cls(
            int(mode_old[1:], 8),
            int(mode_new, 8),
            sha1_old,
            sha1_new,
            status,
            Path(paths[0]),
        )

    @classmethod
    def parse_many(cls, data: str) -> Iterator[Self]:
        for line in data.split("\n"):
            if line:
                yield cls.parse_one(line)

    @classmethod
    def run(cls, old: Path, new: Path) -> Iterator[Self]:
        proc = subprocess.run(
            DIFF_CMD + ["--raw", old, new],
            stdout=subprocess.PIPE,
            text=True,
        )
        yield from cls.parse_many(proc.stdout)


class DiffEntry:
    def __init__(self, old_base: Path, new_base: Path, raw: RawDiff):
        self.is_symlink = raw.mode_old == 0o120000 and raw.mode_new == 0o120000
        self.path_old = raw.path_old
        self.path_new = new_base / self.path_old.relative_to(old_base)

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
        if item.is_symlink:
            print(f"*** Recursing into {item.path_old} vs. {item.path_new}")
            diff(
                item.path_old.readlink(),
                item.path_new.readlink(),
                extra_display_args,
            )
        else:
            item.display(extra_display_args)


def main(*args):
    parser = argparse.ArgumentParser()
    parser.add_argument("old", type=Path)
    parser.add_argument("new", type=Path)

    args, extra = parser.parse_known_args(args)
    if not extra:
        extra = ["--color", "--word-diff-regex=\w+"]

    return diff(args.old, args.new, extra_display_args=extra)


if __name__ == "__main__":
    sys.exit(main(*sys.argv[1:]))
