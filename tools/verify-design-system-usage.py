#!/usr/bin/env python3
"""Reject motion, color, and control implementations that bypass MeoUI."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


ANIMATION = re.compile(
    r"\b(NumberAnimation|ColorAnimation|PropertyAnimation|RotationAnimation|"
    r"Vector3dAnimation|XAnimator|YAnimator|OpacityAnimator|ScaleAnimator|"
    r"RotationAnimator)\s*(?:on\s+[\w.]+\s*)?\{"
)
RAW_CONTROL = re.compile(
    r"\b(?:QQC2\.|Controls\.)?"
    r"(Button|ToolButton|Popup|Dialog|Slider|RangeSlider|Switch|CheckBox|"
    r"RadioButton|ComboBox|TextField|TextArea|SpinBox|ProgressBar|TabBar|"
    r"TabButton|Menu|MenuItem|MenuSeparator|ToolTip)\s*\{"
)
HARDCODED_COLOR = re.compile(
    r"\b(?:property\s+color\s+\w+|color|border\.color|strokeColor|"
    r"shadowColor|colorizationColor)\s*:\s*['\"]#[0-9a-fA-F]{3,8}['\"]"
)
NUMERIC_RGBA = re.compile(r"Qt\.rgba\s*\(\s*[0-9.]+\s*,")
MOTION_TIMING_PROPERTY = re.compile(
    r"\bproperty[ \t]+(?:int|real)[ \t]+"
    r"(\w*(?:duration|delay|interval))[ \t]*:[ \t]*([^\n]+)",
    re.IGNORECASE,
)


def block_end(source: str, opening: int) -> int | None:
    depth = 0
    quote: str | None = None
    escaped = False
    for index in range(opening, len(source)):
        char = source[index]
        if quote is not None:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == quote:
                quote = None
            continue
        if char in ('"', "'"):
            quote = char
        elif char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
            if depth == 0:
                return index + 1
    return None


def line_number(source: str, offset: int) -> int:
    return source.count("\n", 0, offset) + 1


def qml_files(paths: list[Path]) -> list[Path]:
    files: set[Path] = set()
    excluded = {"build", "out", "artifacts", "third_party", "vendor", "pkg", "airootfs"}
    for path in paths:
        candidates = [path] if path.is_file() else path.rglob("*.qml")
        for candidate in candidates:
            if candidate.suffix == ".qml" and not excluded.intersection(candidate.parts):
                files.add(candidate.resolve())
    return sorted(files)


def audit(path: Path, mode: str) -> list[str]:
    source = path.read_text(encoding="utf-8")
    issues: list[str] = []

    if path.name != "MeoTheme.qml" and "motionDurationFor(" in source:
        for match in re.finditer(r"motionDurationFor\s*\(", source):
            issues.append(f"{path}:{line_number(source, match.start())}: ad-hoc motion duration")

    if path.name != "MeoTheme.qml":
        for match in MOTION_TIMING_PROPERTY.finditer(source):
            timing_name = match.group(1).lower()
            if not any(keyword in timing_name for keyword in
                       ("animation", "motion", "hover", "ripple", "submenu")):
                continue
            numeric_literals = re.findall(r"(?<![\w.])(\d+(?:\.\d+)?)(?![\w.])", match.group(2))
            if any(float(value) > 0 for value in numeric_literals):
                issues.append(
                    f"{path}:{line_number(source, match.start())}: "
                    "motion timing property contains a numeric fallback"
                )

    for match in ANIMATION.finditer(source):
        end = block_end(source, match.end() - 1)
        if end is None:
            issues.append(f"{path}:{line_number(source, match.start())}: unterminated animation block")
            continue
        block = source[match.start():end]
        line = line_number(source, match.start())
        if not re.search(r"\bduration\s*:", block):
            issues.append(f"{path}:{line}: animation has no semantic duration")
        if not re.search(r"easing\.type\s*:\s*Easing\.BezierSpline", block):
            issues.append(f"{path}:{line}: animation bypasses MeoUI bezier easing")
        if not re.search(r"easing\.bezierCurve\s*:[^;}\n]*(?:MeoTheme|Meo\.MeoTheme)\.motionEasing", block):
            issues.append(f"{path}:{line}: animation has no MeoUI easing token")
        duration = re.search(r"\bduration\s*:\s*([^;}\n]+)", block)
        if duration and re.fullmatch(r"\s*\d+(?:\.\d+)?\s*", duration.group(1)):
            issues.append(f"{path}:{line}: animation uses a numeric duration")

    # Slider input semantics and gesture handling have exactly two owners.
    # Composites such as Quick Control must compose these public primitives
    # instead of hiding a second native slider behind custom-painted rails.
    if mode == "library" and path.name not in {"MeoSlider.qml", "MeoRangeSlider.qml"}:
        for match in RAW_CONTROL.finditer(source):
            if match.group(1) in {"Slider", "RangeSlider"}:
                issues.append(
                    f"{path}:{line_number(source, match.start())}: "
                    f"duplicate native slider: {match.group(0)}"
                )

    if mode == "consumer":
        for pattern, label in ((HARDCODED_COLOR, "hard-coded UI color"),
                               (NUMERIC_RGBA, "numeric UI color"),
                               (RAW_CONTROL, "raw Qt control")):
            for match in pattern.finditer(source):
                issues.append(f"{path}:{line_number(source, match.start())}: {label}: {match.group(0)}")

    return issues


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--mode", choices=("library", "consumer"), default="consumer")
    parser.add_argument("paths", nargs="+", type=Path)
    args = parser.parse_args()

    issues: list[str] = []
    files = qml_files(args.paths)
    for path in files:
        issues.extend(audit(path, args.mode))
    if issues:
        print("\n".join(issues), file=sys.stderr)
        print(f"design-system audit failed: {len(issues)} issue(s) in {len(files)} QML file(s)", file=sys.stderr)
        return 1
    print(f"design-system audit passed: {len(files)} QML file(s)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
