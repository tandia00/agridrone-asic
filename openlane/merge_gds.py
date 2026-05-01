#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2024 AgriDrone Team
# SPDX-License-Identifier: Apache-2.0
"""
Fusionne le GDS du user_project_wrapper avec le GDS de la macro 'top'
afin que toutes les cellules référencées (std cells sky130) aient
leur layout complet dans un seul fichier auto-suffisant.

Le streamout Magic du wrapper produit volontairement un GDS où 'top'
et les std cells apparaissent comme des cellules vides (le merge final
se fait au niveau Caravel). Pour que le precheck Efabless local accepte
le GDS, on fait ce merge ici.

Usage : klayout -b -r openlane/merge_gds.py
"""
import os
import sys
import pya  # type: ignore  (fourni par klayout)

ROOT = os.environ.get("PROJECT_ROOT", os.getcwd())
WRAPPER_GDS = os.path.join(ROOT, "gds", "user_project_wrapper.gds")
TOP_GDS     = os.path.join(ROOT, "gds", "top.gds")
OUT_GDS     = os.path.join(ROOT, "gds", "user_project_wrapper.gds")

print(f"[merge_gds] Wrapper : {WRAPPER_GDS}")
print(f"[merge_gds] Macro   : {TOP_GDS}")

if not os.path.isfile(WRAPPER_GDS):
    print(f"ERREUR : {WRAPPER_GDS} introuvable", file=sys.stderr)
    sys.exit(1)
if not os.path.isfile(TOP_GDS):
    print(f"ERREUR : {TOP_GDS} introuvable", file=sys.stderr)
    sys.exit(1)

# Charge le wrapper.
ly = pya.Layout()
ly.read(WRAPPER_GDS)
print(f"[merge_gds] Wrapper : {ly.cells()} cells, top = {ly.top_cell().name}")

# Identifie les cellules vides (geometry-less) du wrapper.
empty_before = []
for c in ly.each_cell():
    if c.is_empty() and not c.is_top():
        empty_before.append(c.name)
print(f"[merge_gds] Cellules vides avant merge : {len(empty_before)}")

# Charge le top.gds dans le même Layout (merge des cellules par nom).
ly.read(TOP_GDS)
print(f"[merge_gds] Après lecture top.gds : {ly.cells()} cells")

# Re-vérifie les cellules vides.
empty_after = []
for c in ly.each_cell():
    if c.is_empty() and not c.is_top():
        empty_after.append(c.name)
print(f"[merge_gds] Cellules vides après merge : {len(empty_after)}")
if empty_after:
    print(f"  → encore vides : {empty_after[:10]}{'...' if len(empty_after) > 10 else ''}")

# Réécrit le wrapper unifié.
opts = pya.SaveLayoutOptions()
opts.format = "GDS2"
opts.write_context_info = False
ly.write(OUT_GDS, opts)
print(f"[merge_gds] Sauvegardé : {OUT_GDS}")
print(f"[merge_gds] Cellules récupérées : {len(empty_before) - len(empty_after)}")
