#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${LC_ALL:-}" ]]; then
  export LC_ALL=C.UTF-8
  export LANG=C.UTF-8
fi

config="Release"
output_root="${MEO_OUTPUT_ROOT:-/home/shekong/Projects/outputs}"
build_dir="${MEO_UI_BUILD_DIR:-}"
install_dir="${MEO_UI_INSTALL_DIR:-}"
validation_dir="${MEOUI_VALIDATION_DIR:-}"
run_id="${MEOUI_RUN_ID:-}"
qt_prefix=""
screenshot_path="${MEOUI_SCREENSHOT_PATH:-}"
do_install=0
do_run=0
run_id_explicit=0
validation_dir_explicit=0
if [[ -n "$run_id" ]]; then
  run_id_explicit=1
fi
if [[ -n "$validation_dir" ]]; then
  validation_dir_explicit=1
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --config)
      config="$2"
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
    --install-dir)
      install_dir="$2"
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
    --screenshot)
      screenshot_path="$2"
      shift 2
      ;;
    --qt-prefix)
      qt_prefix="$2"
      shift 2
      ;;
    --install)
      do_install=1
      shift
      ;;
    --run)
      do_run=1
      shift
      ;;
    -h|--help)
      cat <<'EOF'
Usage: tools/build-showcase.sh [options]

  --config CONFIG          CMake build type (default: Release)
  --output-root DIR        Outputs root (default: $MEO_OUTPUT_ROOT or /home/shekong/Projects/outputs)
  --build-dir DIR          Explicit CMake binary directory
  --install-dir DIR        Explicit staging-install directory
  --validation-dir DIR     Explicit evidence directory for this invocation
  --run-id ID              UTC run identifier: YYYY-MM-DDTHHMMSSZ-short-label
  --screenshot PATH        Capture into PATH when used with --run; relative paths stay in the validation run
  --qt-prefix DIR          CMAKE_PREFIX_PATH override
  --install                Stage an install tree
  --run                    Launch MeoShowcaseDemo after building

Environment equivalents, with lower priority than command-line options:
MEO_OUTPUT_ROOT, MEO_UI_BUILD_DIR, MEO_UI_INSTALL_DIR, MEOUI_VALIDATION_DIR,
MEOUI_RUN_ID, and MEOUI_SCREENSHOT_PATH.
EOF
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 2
      ;;
  esac
done

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source_dir="$(cd -- "$script_dir/.." && pwd)"

absolute_path() {
  local path="$1"
  local base_dir="${2:-$source_dir}"
  if [[ "$path" == /* || "$path" =~ ^[A-Za-z]:[\\/].* ]]; then
    printf '%s\n' "$path"
  else
    printf '%s\n' "$base_dir/$path"
  fi
}

if ! command -v cmake >/dev/null 2>&1; then
  echo "cmake was not found on PATH. Install CMake and Qt, or source the Qt environment first." >&2
  exit 127
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 was not found on PATH; it is required to verify Showcase coverage." >&2
  exit 127
fi

output_root="$(absolute_path "$output_root")"
if [[ -z "$build_dir" ]]; then
  build_dir="$output_root/meo-ui/build/showcase"
fi
if [[ -z "$install_dir" ]]; then
  install_dir="$output_root/meo-ui/install/showcase"
fi

if [[ -z "$run_id" ]]; then
  if [[ "$do_run" -eq 1 ]]; then
    run_id="$(date -u +%Y-%m-%dT%H%M%SZ)-showcase-run"
  else
    run_id="$(date -u +%Y-%m-%dT%H%M%SZ)-showcase-build"
  fi
fi
if [[ ! "$run_id" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{6}Z-[A-Za-z0-9][A-Za-z0-9._-]*$ ]]; then
  echo "Invalid --run-id '$run_id'. Expected YYYY-MM-DDTHHMMSSZ-short-label." >&2
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
install_dir="$(absolute_path "$install_dir")"
validation_dir="$(absolute_path "$validation_dir")"
if [[ -n "$screenshot_path" ]]; then
  screenshot_path="$(absolute_path "$screenshot_path" "$validation_dir")"
fi

mkdir -p "$validation_dir"
if [[ ! -e "$validation_dir/README.md" ]]; then
  printf '%s\n' \
    '# MeoUI Showcase validation run' \
    '' \
    "- Run ID: \`$run_id\`" \
    "- Build directory: \`$build_dir\`" \
    "- Install directory: \`$install_dir\`" \
    "- Run requested: \`$([[ "$do_run" -eq 1 ]] && echo yes || echo no)\`" \
    '' \
    'Files in this directory are the evidence for one Showcase invocation. The build launcher writes coverage, configure, build, install, and runtime logs here as applicable.' \
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
run_logged "$validation_dir/build.log" \
  cmake --build "$build_dir" --config "$config" --target MeoShowcaseDemo

if [[ "$do_install" -eq 1 ]]; then
  run_logged "$validation_dir/install.log" \
    cmake --install "$build_dir" --config "$config" --prefix "$install_dir"
fi

if [[ "$do_run" -eq 1 ]]; then
  if [[ -x "$build_dir/MeoShowcaseDemo" ]]; then
    showcase_binary="$build_dir/MeoShowcaseDemo"
  elif [[ -x "$build_dir/$config/MeoShowcaseDemo" ]]; then
    showcase_binary="$build_dir/$config/MeoShowcaseDemo"
  else
    echo "Could not find MeoShowcaseDemo in $build_dir" >&2
    exit 1
  fi

  showcase_args=("--validation-dir=$validation_dir" "--run-id=$run_id")
  if [[ -n "$screenshot_path" ]]; then
    mkdir -p "$(dirname -- "$screenshot_path")"
    showcase_args+=("--screenshot=$screenshot_path")
  fi
  run_logged "$validation_dir/run.stdout.log" \
    env "MEOUI_VALIDATION_DIR=$validation_dir" "MEOUI_RUN_ID=$run_id" \
    "$showcase_binary" "${showcase_args[@]}"
fi
