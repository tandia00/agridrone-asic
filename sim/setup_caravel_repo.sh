# SPDX-FileCopyrightText: 2024 AgriDrone Team
# SPDX-License-Identifier: Apache-2.0
#!/usr/bin/env bash
# setup_caravel_repo.sh – Finalise l'arborescence Efabless chipIgnite.
# Usage: bash sim/setup_caravel_repo.sh [run_name]
#   run_name  (optionnel) – nom du run OpenLane, ex. "pipelined4" ou "tape-out"
#             Si absent, le script choisit le dernier run dont results/final existe.

set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# ── Résolution du répertoire de résultats OpenLane ────────────────────────
RUN_NAME="${1:-}"
if [ -z "$RUN_NAME" ]; then
    # Préférence : run du wrapper user_project_wrapper s'il existe.
    for d in $(ls -dt openlane/runs/*user_project_wrapper*/ 2>/dev/null); do
        if [ -d "${d}results/final/gds" ] && [ "$(ls -A "${d}results/final/gds")" ]; then
            RUN_NAME="$(basename "$d")"
            break
        fi
    done
    # Sinon, prendre n'importe quel run avec final non-vide.
    if [ -z "$RUN_NAME" ]; then
        for d in $(ls -dt openlane/runs/*/); do
            if [ -d "${d}results/final/gds" ] && [ "$(ls -A "${d}results/final/gds")" ]; then
                RUN_NAME="$(basename "$d")"
                break
            fi
        done
    fi
fi

if [ -z "$RUN_NAME" ]; then
    echo "ERREUR : aucun run OpenLane avec résultats finaux trouvé dans openlane/runs/."
    echo "Lancez d'abord : bash openlane/run_openlane.sh"
    exit 1
fi

FINAL="openlane/runs/${RUN_NAME}/results/final"
echo "Run retenu : ${RUN_NAME}"
echo "Répertoire final : ${FINAL}"

# ── Création de l'arborescence ────────────────────────────────────────────
mkdir -p verilog/rtl verilog/gl verilog/dv
mkdir -p gds def lef maglef spi/lvs sdf/nom sdf/min sdf/max spef/nom spef/min spef/max
mkdir -p .github/workflows

# ── RTL ───────────────────────────────────────────────────────────────────
echo "Copie des fichiers RTL..."
cp rtl/*.v verilog/rtl/

# ── Livrables physiques (OpenLane) ────────────────────────────────────────
copy_if_exists() {
    local src="$1" dst="$2"
    if [ -f "$src" ]; then
        cp "$src" "$dst"
        echo "  $(basename "$dst")"
    else
        echo "  MANQUANT : $src  →  $dst"
    fi
}

# Détection du nom du design depuis le GDS produit par OpenLane.
DESIGN="$(ls "$FINAL/gds/" 2>/dev/null | head -1 | sed 's/\.gds$//')"
if [ -z "$DESIGN" ]; then
    echo "ERREUR : aucun .gds dans $FINAL/gds/"
    exit 1
fi
echo "Design détecté : ${DESIGN}"

echo "Copie des livrables physiques..."
copy_if_exists "$FINAL/gds/${DESIGN}.gds"              gds/user_project_wrapper.gds
copy_if_exists "$FINAL/def/${DESIGN}.def"              def/user_project_wrapper.def
copy_if_exists "$FINAL/lef/${DESIGN}.lef"              lef/user_project_wrapper.lef
copy_if_exists "$FINAL/maglef/${DESIGN}.mag"           maglef/user_project_wrapper.mag
copy_if_exists "$FINAL/spi/lvs/${DESIGN}.spice"        spi/lvs/user_project_wrapper.spice
copy_if_exists "$FINAL/verilog/gl/${DESIGN}.nl.v"      verilog/gl/user_project_wrapper.v
copy_if_exists "$FINAL/sdf/nom/${DESIGN}.nom.sdf"      sdf/nom/user_project_wrapper.nom.sdf
copy_if_exists "$FINAL/sdf/min/${DESIGN}.min.sdf"      sdf/min/user_project_wrapper.min.sdf
copy_if_exists "$FINAL/sdf/max/${DESIGN}.max.sdf"      sdf/max/user_project_wrapper.max.sdf
copy_if_exists "$FINAL/spef/nom/${DESIGN}.nom.spef"    spef/nom/user_project_wrapper.nom.spef
copy_if_exists "$FINAL/spef/min/${DESIGN}.min.spef"    spef/min/user_project_wrapper.min.spef
copy_if_exists "$FINAL/spef/max/${DESIGN}.max.spef"    spef/max/user_project_wrapper.max.spef

# Si on vient du run user_project_wrapper, le GDS contient déjà le bon nom
# de cellule top — pas besoin de renommer.
if [ "$DESIGN" != "user_project_wrapper" ]; then
    echo ""
    echo "ATTENTION : run de '$DESIGN' (pas user_project_wrapper) – les checks"
    echo "Consistency / OEB / LVS échoueront. Lancez : bash openlane/run_openlane.sh wrapper"
fi

echo ""
echo "Arborescence Caravel finalisée depuis le run '${RUN_NAME}'."
echo "Prochaine étape : make precheck"
