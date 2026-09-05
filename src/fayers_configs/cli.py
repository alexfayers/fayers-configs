"""Install configs into the given python project."""

from __future__ import annotations

from argparse import ArgumentParser, Namespace
from pathlib import Path
import sys
from sys import argv
from typing import TYPE_CHECKING

import tomli_w
import tomllib

if TYPE_CHECKING:
    from collections.abc import Iterable


def build_parser() -> ArgumentParser:
    """Build a parser for parsing args.

    Returns:
        The built parser
    """
    parser = ArgumentParser()
    parser.add_argument("install_dir", type=Path, nargs="?")
    return parser


def parse_args(parser: ArgumentParser, args: Iterable[str]) -> Namespace:
    """Parse args using the given parser.

    Args:
        parser: Parser to parse with
        args: Args to parse

    Returns:
        Parsed args
    """
    return parser.parse_args(args)


def validate_install_dir(install_dir: Path) -> bool:
    """Validate the install dir is a valid python dir.

    Args:
        install_dir: The install dir to check

    Returns:
        If the dir is valid
    """
    if not install_dir.is_dir():
        print("Not a directory")
        return False

    return True


def handle_pyproject(pyproject_path: Path) -> bool:
    """Handle pyproject config.

    Args:
        pyproject_path: Pyproject to process

    Returns:
        If anything was processed
    """
    if not pyproject_path.is_file():
        return False

    with pyproject_path.open("rb") as f:
        pyproject = tomllib.load(f)

    tool = pyproject.get("tool")
    if (tool := pyproject.get("tool")) is None:
        tool = pyproject["tool"] = {}

    # ruff install

    if (ruff := tool.get("ruff")) is None:
        ruff = tool["ruff"] = {}

    if (ruff_extend := ruff.get("extend")) is None:
        ruff["extend"] = ".venv/.fayers-configs/ruff/pyproject.toml"
        print("pyproject.toml: registered ruff config")
    else:
        print(
            f"pyproject.toml: [tool.ruff.extend] is already set to '{ruff_extend}'. Won't override."
        )
        return False

    with pyproject_path.open("wb") as f:
        tomli_w.dump(pyproject, f)

    return True


def main() -> None:
    """Main entry."""
    parser = build_parser()
    args = parse_args(parser, argv[1:])

    install_dir: Path = args.install_dir or Path()

    if not validate_install_dir(install_dir):
        sys.exit(1)

    did_updates = False
    did_updates = did_updates or handle_pyproject(Path(install_dir, "pyproject.toml"))
