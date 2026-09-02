#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source_dir="${MEO_UI_SOURCE_DIR:-$script_dir/..}"
output_root="${MEO_OUTPUT_ROOT:-/home/shekong/Projects/outputs}"
build_dir="${MEO_UI_BUILD_DIR:-}"
validation_dir="${MEOUI_VALIDATION_DIR:-}"
run_id="${MEOUI_RUN_ID:-}"
qt_prefix="${MEO_UI_QT_PREFIX:-}"
config="${MEO_UI_BUILD_CONFIG:-Release}"
app_args=()
run_id_explicit=0
validation_dir_explicit=0
if [[ -n "$run_id" ]]; then
  run_id_explicit=1
fi
if [[ -n "$validation_dir" ]]; then
  validation_dir_explicit=1
fi

usage() {
  cat <<'EOF'
Usage: tools/run-showcase-linux.sh [options] [-- <MeoShowcaseDemo arguments>]

  --source-dir DIR         MeoUI source directory
  --output-root DIR        Outputs root (default: $MEO_OUTPUT_ROOT or /home/shekong/Projects/outputs)
  --build-dir DIR          Explicit CMake binary directory
  --validation-dir DIR     Explicit evidence directory for this run
  --run-id ID              UTC run identifier: YYYY-MM-DDTHHMMSSZ-short-label
  --qt-prefix DIR          CMAKE_PREFIX_PATH override
  --config CONFIG          CMake build type (default: Release)

Arguments after -- are passed to MeoShowcaseDemo. A relative --screenshot path
is placed in the selected validation directory by the application.

Useful Showcase arguments include `--page=N`, `--component=PublicExport`,
`--light`/`--dark`, and `--screenshot=name.png`.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --source-dir)
      source_dir="$2"
      shift 2
      ;;
    --output-root)
      output_root="$2"
      shift 2
      ;;
    --build-dir)
      build_dir="$2"
      shift 2
      ;;
    --validation-dir)
      validation_dir="$2"
      validation_dir_explicit=1
      shift 2
      ;;
    --run-id)
      run_id="$2"
      run_id_explicit=1
      shift 2
      ;;
    --qt-prefix)
      qt_prefix="$2"
      shift 2
      ;;
    --config)
      config="$2"
      shift 2
      ;;
    --)
      shift
      app_args=("$@")
      break
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1. Pass application arguments after --." >&2
      exit 2
      ;;
  esac
done

absolute_path() {
  local path="$1"
  local base_dir="${2:-$source_dir}"
  if [[ "$path" == /* || "$path" =~ ^[A-Za-z]:[\\/].* ]]; then
    printf '%s\n' "$path"
  else
    printf '%s\n' "$base_dir/$path"
  fi
}

source_dir="$(absolute_path "$source_dir" "$PWD")"
if [[ ! -f "$source_dir/CMakeLists.txt" ]]; then
  echo "error: MeoUI CMakeLists.txt was not found in $source_dir" >&2
  exit 2
fi

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "error: this launcher only supports Linux" >&2
  exit 1
fi

if ! command -v cmake >/dev/null 2>&1; then
  echo "error: cmake was not found. Install CMake and Qt 6 first." >&2
  exit 127
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "error: python3 was not found; it is required to verify Showcase coverage." >&2
  exit 127
fi

output_root="$(absolute_path "$output_root")"
if [[ -z "$build_dir" ]]; then
  build_dir="$output_root/meo-ui/build/showcase-linux"
fi
if [[ -z "$run_id" ]]; then
  run_id="$(date -u +%Y-%m-%dT%H%M%SZ)-showcase-run"
fi
if [[ ! "$run_id" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{6}Z-[A-Za-z0-9][A-Za-z0-9._-]*$ ]]; then
  echo "error: invalid --run-id '$run_id'. Expected YYYY-MM-DDTHHMMSSZ-short-label." >&2
  exit 2
fi
if [[ -z "$validation_dir" ]]; then
  if [[ "$run_id_explicit" -eq 0 && "$validation_dir_explicit" -eq 0 ]]; then
    initial_run_id="$run_id"
    suffix=2
    while [[ -e "$output_root/meo-ui/validation/$run_id" ]]; do
      run_id="$initial_run_id-$suffix"
      ((suffix += 1))
    done
  fi
  validation_dir="$output_root/meo-ui/validation/$run_id"
fi

build_dir="$(absolute_path "$build_dir")"
validation_dir="$(absolute_path "$validation_dir")"
mkdir -p "$validation_dir"
if [[ ! -e "$validation_dir/README.md" ]]; then
  printf '%s\n' \
    '# MeoUI Showcase validation run' \
    '' \
    "- Run ID: \`$run_id\`" \
    "- Build directory: \`$build_dir\`" \
    '- Launcher: `tools/run-showcase-linux.sh`' \
    '' \
    'This directory contains one reviewable Linux Showcase run. Coverage, configure, build, and runtime logs are written here.' \
    > "$validation_dir/README.md"
fi
if [[ ! -e "$validation_dir/delivery-checklist.md" ]]; then
  printf '%s\n' \
    '# MeoUI Showcase delivery checklist' \
    '' \
    'Status: complete this checklist before claiming delivery acceptance.' \
    '' \
    '- Public QML exports: see `coverage.log` for the automated qmldir-to-sample gate.' \
    '- Changed tokens and theme behavior:' \
    '- Changed C++ runtime/API surface:' \
    '- Changed assets or packaging:' \
    '- Changed visible behavior and its Showcase sample:' \
    '- Visual/manual review scope and result:' \
    '- Intentional non-visual items and rationale:' \
    > "$validation_dir/delivery-checklist.md"
fi

run_logged() {
  local log_file="$1"
  shift
  "$@" 2>&1 | tee "$log_file"
}

run_logged "$validation_dir/coverage.log" \
  python3 "$source_dir/tools/verify-showcase-coverage.py"

configure_args=(-S "$source_dir" -B "$build_dir" "-DCMAKE_BUILD_TYPE=$config")
if [[ -n "$qt_prefix" ]]; then
  configure_args+=("-DCMAKE_PREFIX_PATH=$qt_prefix")
fi
run_logged "$validation_dir/configure.log" cmake "${configure_args[@]}"
run_logged "$validation_dir/build.log" cmake --build "$build_dir" \
  --config "$config" --target MeoShowcaseDemo

if [[ -x "$build_dir/MeoShowcaseDemo" ]]; then
  showcase_binary="$build_dir/MeoShowcaseDemo"
elif [[ -x "$build_dir/$config/MeoShowcaseDemo" ]]; then
  showcase_binary="$build_dir/$config/MeoShowcaseDemo"
else
  echo "error: build finished but MeoShowcaseDemo was not found in $build_dir" >&2
  exit 1
fi

run_logged "$validation_dir/run.stdout.log" \
  env "MEOUI_VALIDATION_DIR=$validation_dir" "MEOUI_RUN_ID=$run_id" \
  "$showcase_binary" "${app_args[@]}"
