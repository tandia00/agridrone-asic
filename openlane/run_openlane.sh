#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2024 AgriDrone Team
# SPDX-License-Identifier: Apache-2.0
#
# run_openlane.sh – Caravel 2-step hardening for AgriDrone ASIC.
#
# Stage 1: harden 'top' (the AgriDrone core)         → top.lef + top.gds
# Stage 2: harden 'user_project_wrapper' with top    → user_project_wrapper.lef + .gds
#                                                       (SYNTH_ELABORATE_ONLY = 1)
#
# Usage:
#   bash openlane/run_openlane.sh           # both stages
#   bash openlane/run_openlane.sh top       # stage 1 only
#   bash openlane/run_openlane.sh wrapper   # stage 2 only (needs stage 1 done)

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IMAGE="${OPENLANE_IMAGE:-efabless/openlane:latest}"
PDK_ROOT="${PDK_ROOT:-$HOME/.volare}"
TAG="${TAG:-tape-out}"
STAGE="${1:-all}"

mkdir -p "$PDK_ROOT" "$ROOT/lef" "$ROOT/gds"

run_flow() {
    local design_dir="$1"
    local design_name="$2"
    echo "============================================================"
    echo "[openlane] Stage: $design_name  ($design_dir)"
    echo "============================================================"
    docker run --rm \
        --platform linux/amd64 \
        -v "$ROOT:/work" \
        -v "$PDK_ROOT:/root/.volare" \
        -e PDK_ROOT=/root/.volare \
        -e PDK=sky130A \
        "$IMAGE" \
        bash -c "flow.tcl \
            -design /work/openlane/$design_dir \
            -run_path /work/openlane/runs \
            -tag ${TAG}_${design_name} \
            -overwrite"
}

stage_top() {
    run_flow "top" "top"
    # Promote results so the wrapper run can find them.
    local final="$ROOT/openlane/runs/${TAG}_top/results/final"
    cp "$final/lef/top.lef"          "$ROOT/lef/top.lef"
    cp "$final/gds/top.gds"          "$ROOT/gds/top.gds"
    cp "$final/verilog/gl/top.nl.v"  "$ROOT/verilog/gl/top.v"
    echo "[openlane] Stage 'top' artifacts copied to lef/, gds/, verilog/gl/."
}

stage_wrapper() {
    if [ ! -f "$ROOT/lef/top.lef" ] || [ ! -f "$ROOT/gds/top.gds" ]; then
        echo "ERROR: Stage 1 artifacts missing. Run: bash $0 top"
        exit 1
    fi
    run_flow "user_project_wrapper" "user_project_wrapper"
    local final="$ROOT/openlane/runs/${TAG}_user_project_wrapper/results/final"
    echo "[openlane] Wrapper artifacts in $final"
}

case "$STAGE" in
    top)     stage_top ;;
    wrapper) stage_wrapper ;;
    all)     stage_top && stage_wrapper ;;
    *) echo "Usage: $0 [top|wrapper|all]"; exit 2 ;;
esac

echo "[openlane] DONE. Next: make finalize && make precheck"
