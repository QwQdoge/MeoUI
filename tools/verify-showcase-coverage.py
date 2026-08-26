#!/usr/bin/env python3
"""Verify that every public MeoUI export is represented by the Showcase.

The Showcase catalog deliberately also contains a few non-exported comparison
entries (for example, "Expressive buttons").  They are allowed, but every
catalog entry must have a direct ``sampleFor()`` branch that returns a real
``Component`` rather than the generic fallback.  Keep component names as
literal strings in ``ShowcaseCatalog.qml`` and ``ShowcaseSampleDelegate.qml``
so this check can catch omissions before the Showcase is configured or built.
"""

from __future__ import annotations

import argparse
import re
import sys
from collections import Counter, defaultdict
from pathlib import Path


VERSION_RE = re.compile(r"^\d+(?:\.\d+)+$")
IDENTIFIER_RE = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")
CATALOG_ENTRY_RE = re.compile(r'\bcomponent\s*\(\s*"([^"\n]+)"')
SAMPLE_BRANCH_RE = re.compile(
    r"\bif\s*\(\s*(.*?)\s*\)\s*return\s+([A-Za-z_][A-Za-z0-9_]*)\s*;?",
    re.DOTALL,
)
NAME_COMPARISON_RE = re.compile(r'\bname\s*===\s*"([^"\n]+)"')


def fail(message: str) -> None:
    print(f"verify-showcase-coverage.py: {message}", file=sys.stderr)
    raise SystemExit(2)


def read_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except OSError as error:
        fail(f"cannot read {path}: {error}")
    raise AssertionError("unreachable")


def strip_qml_comments(text: str) -> str:
    """Remove QML comments without treating comment markers inside strings as comments."""

    output: list[str] = []
    index = 0
    quote = ""
    while index < len(text):
        character = text[index]
        next_character = text[index + 1] if index + 1 < len(text) else ""

        if quote:
            output.append(character)
            if character == "\\" and index + 1 < len(text):
                output.append(text[index + 1])
                index += 2
                continue
            if character == quote:
                quote = ""
            index += 1
            continue

        if character in ("'", '"'):
            quote = character
            output.append(character)
            index += 1
            continue

        if character == "/" and next_character == "/":
            newline = text.find("\n", index)
            if newline == -1:
                break
            output.append("\n")
            index = newline + 1
            continue

        if character == "/" and next_character == "*":
            end_comment = text.find("*/", index + 2)
            if end_comment == -1:
                fail("unterminated block comment in QML input")
            output.extend("\n" for item in text[index:end_comment + 2] if item == "\n")
            index = end_comment + 2
            continue

        output.append(character)
        index += 1

    if quote:
        fail("unterminated string literal in QML input")
    return "".join(output)


def find_matching_brace(text: str, opening_index: int) -> int:
    """Return the index of the brace matching ``opening_index`` in QML text."""

    if opening_index >= len(text) or text[opening_index] != "{":
        fail("internal parser error: expected an opening brace")

    depth = 0
    quote = ""
    index = opening_index
    while index < len(text):
        character = text[index]
        if quote:
            if character == "\\":
                index += 2
                continue
            if character == quote:
                quote = ""
            index += 1
            continue
        if character in ("'", '"'):
            quote = character
        elif character == "{":
            depth += 1
        elif character == "}":
            depth -= 1
            if depth == 0:
                return index
        index += 1

    fail("unclosed brace in QML input")
    raise AssertionError("unreachable")


def parse_qmldir(path: Path) -> set[str]:
    exports: set[str] = set()
    for line_number, original_line in enumerate(read_text(path).splitlines(), start=1):
        line = original_line.split("#", maxsplit=1)[0].strip()
        if not line:
            continue
        fields = line.split()
        if fields[0] == "singleton":
            if len(fields) < 4 or not IDENTIFIER_RE.fullmatch(fields[1]) or not VERSION_RE.fullmatch(fields[2]):
                continue
            exports.add(fields[1])
            continue
        if len(fields) >= 3 and IDENTIFIER_RE.fullmatch(fields[0]) and VERSION_RE.fullmatch(fields[1]):
            exports.add(fields[0])
        elif fields[0].startswith("Meo") and len(fields) >= 2:
            fail(f"could not parse public export on {path}:{line_number}: {original_line}")
    if not exports:
        fail(f"no public exports found in {path}")
    return exports


def parse_catalog_entries(path: Path) -> list[str]:
    entries = CATALOG_ENTRY_RE.findall(strip_qml_comments(read_text(path)))
    if not entries:
        fail(f"no component(...) entries found in {path}")
    return entries


def extract_sample_function(delegate: str, path: Path) -> str:
    match = re.search(r"\bfunction\s+sampleFor\s*\(\s*name\s*\)", delegate)
    if not match:
        fail(f"could not find function sampleFor(name) in {path}")
    opening_brace = delegate.find("{", match.end())
    if opening_brace == -1:
        fail(f"could not find the body of sampleFor(name) in {path}")
    return delegate[opening_brace + 1:find_matching_brace(delegate, opening_brace)]


def parse_component_ids(delegate: str) -> set[str]:
    """Return IDs declared directly inside ``Component`` blocks."""

    component_ids: set[str] = set()
    component_re = re.compile(r"\bComponent\s*\{")
    for match in component_re.finditer(delegate):
        closing_brace = find_matching_brace(delegate, delegate.find("{", match.start()))
        body = delegate[match.end():closing_brace]
        id_match = re.search(r"\bid\s*:\s*([A-Za-z_][A-Za-z0-9_]*)", body)
        if id_match:
            component_ids.add(id_match.group(1))
    return component_ids


def parse_sample_branches(path: Path) -> tuple[dict[str, list[str]], set[str]]:
    delegate = strip_qml_comments(read_text(path))
    function_body = extract_sample_function(delegate, path)
    branches: dict[str, list[str]] = defaultdict(list)
    for condition, target in SAMPLE_BRANCH_RE.findall(function_body):
        for name in NAME_COMPARISON_RE.findall(condition):
            branches[name].append(target)
    if not branches:
        fail(f"no literal sampleFor(name) branches found in {path}")
    return branches, parse_component_ids(delegate)


def format_group(title: str, entries: list[str]) -> list[str]:
    if not entries:
        return []
    return [f"  {title} ({len(entries)}):", *(f"    - {entry}" for entry in entries)]


def main() -> int:
    root = Path(__file__).resolve().parent.parent
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--qmldir", type=Path, default=root / "qmldir", help="public MeoUI qmldir")
    parser.add_argument("--catalog", type=Path, default=root / "showcase" / "ShowcaseCatalog.qml", help="Showcase catalog QML")
    parser.add_argument("--delegate", type=Path, default=root / "showcase" / "ShowcaseSampleDelegate.qml", help="Showcase sample delegate QML")
    parser.add_argument("--verbose", action="store_true", help="also print catalog-only comparison entries")
    arguments = parser.parse_args()

    exports = parse_qmldir(arguments.qmldir)
    catalog_entries = parse_catalog_entries(arguments.catalog)
    catalog_counts = Counter(catalog_entries)
    catalog_names = set(catalog_entries)
    sample_branches, component_ids = parse_sample_branches(arguments.delegate)

    missing_catalog = sorted(exports - catalog_names)
    duplicate_catalog = sorted(name for name, count in catalog_counts.items() if count > 1)
    missing_samples = sorted(name for name in catalog_names if name not in sample_branches)
    ambiguous_samples = sorted(
        name for name in catalog_names if len(set(sample_branches.get(name, []))) > 1
    )
    fallback_samples = sorted(
        name
        for name in catalog_names
        if any(target.lower().startswith("fallback") for target in sample_branches.get(name, []))
    )
    undefined_samples = sorted(
        name
        for name in catalog_names
        if any(target not in component_ids for target in sample_branches.get(name, []))
    )

    problems: list[str] = []
    problems.extend(format_group("public qmldir exports missing from ShowcaseCatalog", missing_catalog))
    problems.extend(format_group("duplicate ShowcaseCatalog entries", duplicate_catalog))
    problems.extend(format_group("catalog entries without a direct sampleFor() branch", missing_samples))
    problems.extend(format_group("catalog entries with ambiguous sampleFor() branches", ambiguous_samples))
    problems.extend(format_group("catalog entries mapped to a fallback sample", fallback_samples))
    problems.extend(format_group("catalog entries mapped to an undefined Component ID", undefined_samples))

    if problems:
        print("Showcase coverage check failed:", file=sys.stderr)
        print("\n".join(problems), file=sys.stderr)
        return 1

    supplemental_entries = sorted(catalog_names - exports)
    print(
        "Showcase coverage OK: "
        f"{len(exports)} public exports, {len(catalog_entries)} catalog entries, "
        f"{len(catalog_entries)} entries with explicit non-fallback samples."
    )
    if arguments.verbose and supplemental_entries:
        print("Supplemental catalog entries (intentional non-export comparison demos):")
        for entry in supplemental_entries:
            print(f"  - {entry}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
