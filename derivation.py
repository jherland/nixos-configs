#!/usr/bin/env python3
"""Parse Nix derivations (.drv files) and present their contents."""

import argparse
from pathlib import Path
from pprint import pformat
import re
import rich
import subprocess
import sys

from pydantic import BaseModel, validator
from pydantic.dataclasses import dataclass


@dataclass
class DrvOutput:
    """Encapsulate each output object in a derivation."""
    name: str
    path: Path
    hashAlgo: str | None = None
    hash: str | None = None

    @validator("hashAlgo", "hash")
    def empty_str_is_None(cls, v):
        """Convert empty strings to None when validating relevant fields."""
        if isinstance(v, str) and len(v) == 0:
            return None
        return v

    def jsonable(self):
        d = {"path": str(self.path)}
        if self.hashAlgo is not None or self.hash is not None:
            d.update({"hashAlgo": self.hashAlgo, "hash": self.hash})
        return (self.name, d)


@dataclass
class DeriveArgs:
    """The contents of the 'Derive(...)' expression in the .drv file."""
    outputs: list[DrvOutput]
    input_drvs: dict[Path, list[str]]
    input_srcs: list[Path]
    system: str
    builder: Path
    args: list[str]
    env: dict[str, str]

    def jsonable(self):
        return {
            "outputs": dict(o.jsonable() for o in self.outputs),
            "inputSrcs": [str(p) for p in self.input_srcs],
            "inputDrvs": {str(p): outs for p, outs in self.input_drvs.items()},
            "system": self.system,
            "builder": str(self.builder),
            "args": self.args,
            "env": self.env,
        }


class DrvFile(BaseModel):
    """Encapsulate the name and contents of a .drv file in the Nix store."""
    data: DeriveArgs
    path: Path

    @classmethod
    def parse(cls, drv_path: Path) -> "DrvFile":
        def _collect(*args):
            return args

        return cls(
            data=eval(drv_path.read_text(), {"Derive": _collect}),
            path=drv_path
        )

    def jsonable(self):
        """Return a JSON-serializable representation of this .drv."""
        # TODO: Replace .jsonable() with Pydantic-idiomatic customization of
        # .dict() and/or .json()/
        return {str(self.path): self.data.jsonable()}

    def human_readable(self, mask_hashes=True):
        """Present a human-readable (and diffable) representation of this .drv.

        By "diffable" we mean a representation that lends itself to presenting
        salient and readable diffs when two derivations are compared (by passing
        their respective outputs from here to `git diff --no-index ...`).
        """
        ret = self.jsonable()
        if mask_hashes:
            ret = mask_nix_hashes(ret)
        # Several concerns to take into account here:
        # - Each piece of information should have its own line, within reason.
        # - Produce a format which allows Git to choose good hunk headers
        # - Multi-line strings embedded in the data structure should be
        #   presented on multiple lines, to allow diffs across embedded scripts
        #   to look nice.
        # - Does not have to be machine-readable(???)
        # Alternatives that have been considered:
        # - print(ret): Obviously too compact.
        # - pprint(ret): Very good.
        # - rich.print(): Does not handling multi-line strings well, by default.
        return pformat(ret)


def find_drv_path(p: Path) -> Path:
    """Convert (symlink to) store path into the .drv file and generated it.

    This leans on `nix-store --query --deriver`, but raises ValueError instead
    of returning "unknown-deriver" when the deriver cannot be found.
    """
    if p.suffix == ".drv":
        return p
    proc = subprocess.run(
        ["nix-store", "--query", "--deriver", p],
        stdout=subprocess.PIPE,
        text=True,
        check=True,
    )
    drv_path = proc.stdout.rstrip()
    if drv_path == "unknown-deriver":
        raise ValueError("Could not find the .drv that generated {p}")
    return Path(drv_path)


def mask_nix_hashes(data):
    """Mask all Nix store path hashes in the given (JSON-able) data structure.

    Traverse the given data structure and replace all Nix store paths with ones
    where the hash has been replaced with XXX...
    """
    pattern = r"/nix/store/(?P<hash>[a-z0-9]{32})-(?P<name>[a-zA-Z0-9-]+)"
    replace = "/nix/store/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX-\g<name>"

    if isinstance(data, str):
        return re.sub(pattern, replace, data)
    if isinstance(data, list):
        return [mask_nix_hashes(v) for v in data]
    if isinstance(data, dict):
        return {mask_nix_hashes(k): mask_nix_hashes(v) for k, v in data.items()}
    else:
        raise ValueError(f"Don't know how to handle {type(data)}: {data!r}")


def main(*args):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "drv", type=Path, help=".drv file, or (symlink to) its Nix store path")
    parser.add_argument("--json", action="store_true", help="JSON output")
    parser.add_argument("--mask", action="store_true", help="Mask nix hashes")

    args = parser.parse_args(args)

    drv = DrvFile.parse(find_drv_path(args.drv))
    out = drv.jsonable() if args.json else drv.human_readable()
    if args.mask:
        out = mask_nix_hashes(out)
    if args.json:
        rich.print_json(data=out, indent=2)
    else:
        rich.print(out)


if __name__ == "__main__":
    sys.exit(main(*sys.argv[1:]))
