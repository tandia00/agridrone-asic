# Revue de Design / Tape-out Signoff — AgriDrone ASIC

**Date de revue :** Mai 2026  
**Technologie :** SKY130 (130nm)  
**Tension nominale :** 1.8V Core / 3.3V I/O  
**Fréquence cible :** 50 MHz (Période = 20.0 ns)  
**Statut global :** 🟢 **GO POUR FABRICATION**

---

## 1. Vérification Physique (DRC / LVS)

Les vérifications physiques s'assurent que le dessin final respecte les limites de fabrication de la fonderie (espacement minimum, largeurs de fils, chevauchements).

*   **DRC (Design Rule Check) - Magic :** 0 erreur ✅
*   **DRC (Design Rule Check) - KLayout :** 0 erreur ✅
*   **LVS (Layout Versus Schematic) :** 0 erreur ✅
    *   *Explication :* Le circuit logique extrait du dessin physique (GDSII) correspond à 100% au code Verilog simulé. Il n'y a ni courts-circuits, ni circuits ouverts.
*   **Densité / Floorplan :** 
    *   Taille du cœur : 688 × 677 µm (~0.47 mm²)
    *   Utilisation standard des cellules : 12.8% (très aéré, ce qui est excellent pour le refroidissement et le routage sans congestion).

## 2. Vérification Temporelle (STA - Static Timing Analysis)

La puce a été testée numériquement à travers les 3 "Corners" de silicium (Fast/Min, Nominal, Slow/Max). C'est crucial car le silicium physique varie d'une puce à l'autre lors de la fabrication.

*   **Corner Typical (tt) :** WNS = 0.00 ns / TNS = 0.00 ns ✅
*   **Corner Max (ss - Worst Case) :** WNS = 0.00 ns / Marge Setup = +5.04 ns ✅
*   **Corner Min (ff - Best Case) :** Marge Hold = +0.11 ns ✅
    *   *Conclusion :* Le pipelinage du filtre `altitude_fusion` en 4 étages a complètement supprimé le goulot d'étranglement. La puce fonctionnera sans problème à 50 MHz même si la gravure de la fonderie produit des transistors légèrement "lents" (Slow-Slow).
*   **Contraintes SDC :** Les I/O ont été contraints avec un retard externe de 5.0 ns et une charge de 50 fF, assurant une parfaite compatibilité avec les pads Caravel de Efabless.

## 3. Analyse de Puissance et Chute de Tension (IR Drop)

Quand des milliers de transistors commutent en même temps, ils tirent du courant de l'alimentation, ce qui peut créer des chutes de tension locales ("IR Drop") causant des bugs mystérieux.

*   **Consommation estimée :** ~2.5 µW (typique). C'est négligeable grâce à la faible densité (76 flip-flops actifs).
*   **Grille d'Alimentation (PDN) :** Générée avec succès (lignes M4 et M5 pour VPWR/VGND).
*   **IR Drop Report :** La tension minimale calculée aux nœuds de courant ne tombe jamais sous 1.79V (pour 1.80V nominal) ✅. Pas de risque d'effondrement d'alimentation.

## 4. Effets d'Antenne

Lors de la fabrication (gravure plasma), de longues pistes de métal peuvent agir comme des antennes et accumuler de la charge électrique, détruisant les grilles (gates) des transistors sous-jacents.

*   **Violations (Net / Pin) :** 0 / 0 ✅
*   *Explication :* L'outil de routage (TritonRoute) a correctement inséré des "diodes de protection" sur les fils trop longs pour évacuer les charges vers la masse en toute sécurité.

---

## Conclusion et Prochaines Étapes

Le cœur de calcul `agridrone-asic` est **propre à 100%**. Aucune intervention manuelle ou "patch" de layout n'est nécessaire.

Le design est maintenant instancié dans `user_project_wrapper.v` pour correspondre à l'empreinte Efabless Caravel. L'étape suivante, si le financement de la navette (shuttle) chipIgnite (~$9,750) est sécurisé, est de lancer l'outil de `precheck` Efabless sur le dépôt GitHub finalisé pour la soumission.
