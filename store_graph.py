#!/usr/bin/env python3
"""Parse graphs of Nix store closures and present their contents."""

import argparse
from dataclasses import dataclass
from pathlib import Path
from pprint import pformat
import re
import rich
import subprocess
import sys
from typing import Self

DOT_NODE_PATTERN = re.compile(r'"(?P<path>\w{32}-[^"])" \[[^]]\];')
DOT_EDGE_PATTERN = re.compile(
    r'"(?P<src>\w{32}-[^"])" -> "(?P<dst>\w{32}-[^"])" \[[^]]\];')


@dataclass
class Graph:
    root: str
    nodes: dict[str, set[str]]

    @classmethod
    def from_dot_graph(dot_data: str) -> Self:
        root = None
        nodes = {}
        for line in dot_data.splitlines():
            if line == "digraph G {":
                assert root is None  # beginning
            elif match := DOT_NODE_PATTERN.fullmatch(line):
                node = match["path"]
                assert node not in nodes  # nodes come before their edges
                nodes[node] = set()
                if root is None:
                    root = node  # first node in graph is root node
            elif match := DOT_EDGE_PATTERN.fullmatch(line):
                dependency, depender = match["src"], match["dst"]
                assert depender in nodes  # dependers come before dependencies
                nodes[depender].add(dependency)
            elif line == "}":
                break  # end
            else:
                raise ValueError(f"Could not parse {line!r}!")
        return cls(root, nodes)

    @classmethod
    def from_store_path(cls, store_path: Path) -> Self:
        proc = subprocess.run(
            ["nix-store", "--query", "--graph", store_path],
            stdout=subprocess.PIPE,
            text=True,
            check=True,
        )
        return cls.from_dot_graph(proc.stdout)


# class DrvFile(BaseModel):
#     """Encapsulate the name and contents of a .drv file in the Nix store."""
#     data: DeriveArgs
#     path: Path

#     @classmethod
#     def parse(cls, drv_path: Path) -> "DrvFile":
#         def _collect(*args):
#             return args

#         return cls(
#             data=eval(drv_path.read_text(), {"Derive": _collect}),
#             path=drv_path
#         )

#     def jsonable(self):
#         """Return a JSON-serializable representation of this .drv."""
#         # TODO: Replace .jsonable() with Pydantic-idiomatic customization of
#         # .dict() and/or .json()/
#         return {str(self.path): self.data.jsonable()}

#     def human_readable(self, mask_hashes=True):
#         """Present a human-readable (and diffable) representation of this .drv.

#         By "diffable" we mean a representation that lends itself to presenting
#         salient and readable diffs when two derivations are compared (by passing
#         their respective outputs from here to `git diff --no-index ...`).
#         """
#         ret = self.jsonable()
#         if mask_hashes:
#             ret = mask_nix_hashes(ret)
#         # Several concerns to take into account here:
#         # - Each piece of information should have its own line, within reason.
#         # - Produce a format which allows Git to choose good hunk headers
#         # - Multi-line strings embedded in the data structure should be
#         #   presented on multiple lines, to allow diffs across embedded scripts
#         #   to look nice.
#         # - Does not have to be machine-readable(???)
#         # Alternatives that have been considered:
#         # - print(ret): Obviously too compact.
#         # - pprint(ret): Very good.
#         # - rich.print(): Does not handling multi-line strings well, by default.
#         return pformat(ret)


# def mask_nix_hashes(data):
#     """Mask all Nix store path hashes in the given (JSON-able) data structure.

#     Traverse the given data structure and replace all Nix store paths with ones
#     where the hash has been replaced with XXX...
#     """
#     pattern = r"/nix/store/(?P<hash>[a-z0-9]{32})-(?P<name>[a-zA-Z0-9-]+)"
#     replace = "/nix/store/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX-\g<name>"

#     if isinstance(data, str):
#         return re.sub(pattern, replace, data)
#     if isinstance(data, list):
#         return [mask_nix_hashes(v) for v in data]
#     if isinstance(data, dict):
#         return {mask_nix_hashes(k): mask_nix_hashes(v) for k, v in data.items()}
#     else:
#         raise ValueError(f"Don't know how to handle {type(data)}: {data!r}")


# def main(*args):
#     parser = argparse.ArgumentParser(description=__doc__)
#     parser.add_argument(
#         "drv", type=Path, help=".drv file, or (symlink to) its Nix store path")
#     parser.add_argument("--json", action="store_true", help="JSON output")
#     parser.add_argument("--mask", action="store_true", help="Mask nix hashes")

#     args = parser.parse_args(args)

#     drv = DrvFile.parse(find_drv_path(args.drv))
#     out = drv.jsonable() if args.json else drv.human_readable()
#     if args.mask:
#         out = mask_nix_hashes(out)
#     if args.json:
#         rich.print_json(data=out, indent=2)
#     else:
#         rich.print(out)


# if __name__ == "__main__":
#     sys.exit(main(*sys.argv[1:]))
