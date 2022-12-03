#!/usr/bin/env python3

import argparse
from collections.abc import Iterator
import json
import logging
from pathlib import Path
import rich
import sys
import subprocess
from typing import NamedTuple, Self, TextIO

from pydantic import BaseModel, constr, root_validator, validator
from pydantic.dataclasses import dataclass


logger = logging.getLogger(__name__)


# The following mirrors the JSON objects produced by `nix show-derivation`
class Output(BaseModel):
    path: str
    hash_algo: str | None
    hash: str | None

    # class Config:
    #     json_encoders = {Path: str}


class Derivation(BaseModel):
    outputs: dict[str, Output]
    inputDrvs: dict[str, list[str]]
    inputSrcs: list[str]
    system: str
    builder: str
    args: list[str]
    env: dict[str, str]

    @root_validator(pre=True)
    def args2dict(cls, values):
        logger.warning(f"{cls=!r}, {values=!r}")
        raise NotImplementedError
    # class Config:
    #     json_encoders = {Path: str}


def parse_drv(drv_path: Path) -> Derivation:
    proc = subprocess.run(
        ["nix", "show-derivation", drv_path],
        stdout = subprocess.PIPE,
        text=True,
        check=True,
    )
    data = json.loads(proc.stdout)
    return data
    # assert len(data) == 1
    # key, value = data.popitem()
    # assert Path(key) == drv_path
    # return Derivation.parse_obj(value)


def custom_encoder(obj):
    logger.warning(f"foo({obj!r})")
    if isinstance(obj, Path):
        logger.warning(f"<<< {obj}")
        return str(obj)
    raise RuntimeError(type(obj))


# class Config:
#     json_encoders = {
#         Output: lambda o: "BLARG",
#         Path: lambda p: f"<<<{p}>>>",
#     }

@dataclass
class Output:
    name: str
    path: Path
    hashAlgo: str | None = None
    hash: str | None = None

    @validator("hashAlgo", "hash")
    def empty_str_is_None(cls, v):
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
    outputs: list[Output]
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

    # TODO: Replace .jsonable() with Pydantic-idiomatic customization of
    # ,dict() and/or .json()/
    def jsonable(self):
        return {str(self.path): self.data.jsonable()}

# def build_old(
#     outputs: list[tuple[str, str, str, str]],
#     input_drvs: list[tuple[str, list[str]]],
#     input_srcs: list[str],
#     platform: str,
#     builder: str,
#     args: list[str],
#     env: list[tuple[str, str]],
# ):
#     return Derivation.parse_obj(**{
#         "outputs": outputs,
#         "input_drvs": input_drvs,
#         "input_srcs": input_srcs,
#         "platform": platform,
#         "builder": builder,
#         "args": args,
#         "env": env,
#     })


from contextlib import ExitStack
import pprint
from tempfile import NamedTemporaryFile


def diff_objs(obj1, obj2, **kwargs):
    with ExitStack() as stack:
        f1 = stack.enter_context(NamedTemporaryFile(mode="w"))
        pprint(obj1, stream=f1, **kwargs)
        f1.flush()

        f2 = stack.enter_context(NamedTemporaryFile(mode="w"))
        pprint(obj2, stream=f2, **kwargs)
        f2.flush()

        proc = subprocess.run(
            ["git", "--no-pager", "diff", "--no-index", f1.name, f2.name],
        )
        return proc.returncode


def diff_json_to_drv(other, drv, **kwargs):
    with ExitStack() as stack:
        f1 = stack.enter_context(NamedTemporaryFile(mode="w"))
        json.dump(other, f1, **kwargs)
        f1.flush()

        f2 = stack.enter_context(NamedTemporaryFile(mode="w"))
        f2.write(drv.json(exclude_none=True, **kwargs))
        f2.flush()

        proc = subprocess.run(
            ["git", "--no-pager", "diff", "--no-index", f1.name, f2.name],
        )
        return proc.returncode


DIFF_CMD = ["git", "--no-pager", "diff", "--no-index"]

def diff_strings(s1, s2, *args):
    with ExitStack() as stack:
        f1 = stack.enter_context(NamedTemporaryFile(mode="w"))
        f1.write(s1)
        f1.flush()

        f2 = stack.enter_context(NamedTemporaryFile(mode="w"))
        f2.write(s2)
        f2.flush()

        return subprocess.run(DIFF_CMD + [*args, f1.name, f2.name]).returncode


def diff_objs_as_json(obj1, obj2, *args, **kwargs):
    return diff_strings(
        json.dumps(obj1, **kwargs),
        json.dumps(obj2, **kwargs),
        *args,
    )


def diff_objs_as_pprint(obj1, obj2, *args, **kwargs):
    return diff_strings(
        pprint.pformat(obj1, **kwargs),
        pprint.pformat(obj2, **kwargs),
        *args,
    )


def main(*args):
    parser = argparse.ArgumentParser()
    parser.add_argument("drv", type=Path)
    args = parser.parse_args(args)

    drv = DrvFile.parse(args.drv)
    rich.print(drv)
    rich.print(drv.jsonable())

    drv_json = parse_drv(args.drv)
    print(">>> JSON")
    diff_objs_as_json(drv_json, drv.jsonable(), indent=2)
    print(">>> PPRINT")
    diff_objs_as_pprint(drv_json, drv.jsonable(), indent=2)

    proc = subprocess.run(
        ["nix", "show-derivation", args.drv],
        stdout = subprocess.PIPE,
        text=True,
        check=True,
    )
    print(">>> STRING")
    diff_strings(proc.stdout, json.dumps(drv.jsonable(), indent=2) + "\n")

#     rich.print(drv)
# #    print(drv.dict())


if __name__ == "__main__":
    sys.exit(main(*sys.argv[1:]))
