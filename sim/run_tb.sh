# SPDX-FileCopyrightText: 2024 AgriDrone Team
# SPDX-License-Identifier: Apache-2.0
#!/usr/bin/env bash
# Usage: ./run_tb.sh <tb_name_without_prefix>
#   ./run_tb.sh pwm_multichannel
#   ./run_tb.sh safety_watchdog
#   ./run_tb.sh top
set -euo pipefail

TB=${1:-top}
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
RTL="$ROOT/rtl"
TBF="$ROOT/tb/tb_${TB}.v"
OUT="$ROOT/sim/build"
mkdir -p "$OUT"

if [[ ! -f "$TBF" ]]; then
    echo "Testbench not found: $TBF" >&2
    exit 1
fi

echo "[sim] compiling tb_${TB}..."
iverilog -g2012 -o "$OUT/tb_${TB}.vvp" \
    "$RTL"/*.v \
    "$TBF"

echo "[sim] running..."
( cd "$OUT" && vvp "tb_${TB}.vvp" )

echo
echo "[sim] VCD: $OUT/tb_${TB}.vcd  (open with: gtkwave $OUT/tb_${TB}.vcd)"
