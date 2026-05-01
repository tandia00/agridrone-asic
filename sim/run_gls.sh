# SPDX-FileCopyrightText: 2024 AgriDrone Team
# SPDX-License-Identifier: Apache-2.0
#!/usr/bin/env bash
# run_gls.sh: Run Gate-Level Simulation (post-routing)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TB="tb_top"
TBF="$ROOT/tb/tb_top.v"
NL="$ROOT/openlane/runs/pipelined4/results/routing/top.nl.v"
SDF="$ROOT/openlane/runs/pipelined4/results/routing/top.sdf"
OUT="$ROOT/sim/build_gls"
PDK_LIB="${PDK_ROOT:-$HOME/.volare}/sky130A/libs.ref/sky130_fd_sc_hd/verilog"

mkdir -p "$OUT"

if [[ ! -f "$NL" ]]; then
    echo "Netlist non trouvée: $NL" >&2
    exit 1
fi

echo "[gls] Compilation de la netlist gate-level..."
# Compiler avec les primitives PDK SKY130 (NAND, DFF...)
iverilog -g2012 -DFUNCTIONAL -DUNIT_DELAY=#1 -DWITH_SDF \
    -I "$PDK_LIB" \
    -o "$OUT/tb_top_gls.vvp" \
    "$PDK_LIB/primitives.v" \
    "$PDK_LIB/sky130_fd_sc_hd.v" \
    "$NL" \
    "$TBF"

echo "[gls] Exécution..."
( cd "$OUT" && vvp "tb_top_gls.vvp" +sdf_file="$SDF" )

echo "[gls] VCD: $OUT/tb_top.vcd"
