# SPDX-FileCopyrightText: 2024 AgriDrone Team
# SPDX-License-Identifier: Apache-2.0
# AgriDrone ASIC – Top-level Makefile
# Compatible with Efabless mpw-precheck and chipIgnite submission workflow.

OPENLANE_ROOT  ?= $(HOME)/openlane
PDK_ROOT       ?= $(HOME)/pdk
PDK            ?= sky130A
CARAVEL_ROOT   ?= $(HOME)/caravel
DESIGN         := user_project_wrapper
RUN_NAME       ?= tape-out
OPENLANE_TAG   ?= 2023.11.23

FINAL_RESULTS  := openlane/runs/$(RUN_NAME)/results/final

# ── Help ───────────────────────────────────────────────────────────────────
.PHONY: help
help:
	@echo "AgriDrone ASIC – Efabless chipIgnite submission"
	@echo ""
	@echo "Simulation:   make sim-all | sim-gls"
	@echo "Hardening:    make openlane"
	@echo "Finalize:     make finalize"
	@echo "Precheck:     make precheck"
	@echo "Verify:       make verify"
	@echo "Install:      make install"

# ── Install / Uninstall (Caravel submodule) ────────────────────────────────
.PHONY: install
install:
	@echo "Installing Caravel dependencies..."
	@if [ ! -d "$(CARAVEL_ROOT)" ]; then \
		git clone https://github.com/efabless/caravel.git $(CARAVEL_ROOT); \
	fi

.PHONY: uninstall
uninstall:
	@echo "Removing Caravel installation at $(CARAVEL_ROOT)..."
	rm -rf $(CARAVEL_ROOT)

.PHONY: update_caravel
update_caravel:
	cd $(CARAVEL_ROOT) && git pull

# ── Caravel / PDK checks ───────────────────────────────────────────────────
.PHONY: check-caravel
check-caravel:
	@test -d $(CARAVEL_ROOT) || (echo "ERROR: CARAVEL_ROOT=$(CARAVEL_ROOT) not found. Run: make install" && exit 1)
	@echo "Caravel found at $(CARAVEL_ROOT)"

.PHONY: check-pdk
check-pdk:
	@test -d $(PDK_ROOT)/$(PDK) || (echo "ERROR: PDK not found at $(PDK_ROOT)/$(PDK). Run: python3 -m volare enable --pdk sky130 --pdk-root $(PDK_ROOT) <hash>" && exit 1)
	@echo "PDK found at $(PDK_ROOT)/$(PDK)"

.PHONY: check-precheck
check-precheck:
	@test -d $(PRECHECK_ROOT) || (echo "ERROR: PRECHECK_ROOT=$(PRECHECK_ROOT) not found. Run: make precheck-clone" && exit 1)
	@echo "mpw_precheck found at $(PRECHECK_ROOT)"

# ── Simulation environment ─────────────────────────────────────────────────
.PHONY: simenv
simenv:
	@which iverilog || (echo "ERROR: iverilog not found. Install: brew install icarus-verilog" && exit 1)
	@echo "Simulation environment ready."

.PHONY: simlink
simlink:
	@echo "Symlinking simulation dependencies (no-op for this project)."

# ── RTL simulation ─────────────────────────────────────────────────────────
.PHONY: sim-rtl
sim-rtl:
	bash sim/run_tb.sh top

.PHONY: sim-pwm
sim-pwm:
	bash sim/run_tb.sh pwm_multichannel

.PHONY: sim-wdog
sim-wdog:
	bash sim/run_tb.sh safety_watchdog

.PHONY: sim-all
sim-all: sim-rtl sim-pwm sim-wdog

# ── Gate-level simulation ──────────────────────────────────────────────────
.PHONY: sim-gls
sim-gls:
	bash sim/run_gls.sh

# ── Verify (RTL + GLS) ─────────────────────────────────────────────────────
.PHONY: verify
verify: sim-all sim-gls

# ── OpenLane flow ──────────────────────────────────────────────────────────
.PHONY: openlane
openlane:
	bash openlane/run_openlane.sh

# ── Finalize Efabless submission artifacts ─────────────────────────────────
.PHONY: finalize
finalize:
	bash sim/setup_caravel_repo.sh

# ── Efabless mpw-precheck (Docker) ────────────────────────────────────────
# The efabless/mpw_precheck image contains only EDA tools (magic, netgen).
# The precheck Python scripts must be cloned separately and mounted.
# Note: image is linux/amd64 – on Apple Silicon Docker runs it via Rosetta.
PRECHECK_ROOT ?= $(HOME)/mpw_precheck

.PHONY: precheck-clone
precheck-clone:
	@if [ ! -d "$(PRECHECK_ROOT)" ]; then \
		echo "Cloning mpw_precheck scripts..."; \
		git clone https://github.com/efabless/mpw_precheck.git $(PRECHECK_ROOT); \
	else \
		echo "mpw_precheck already at $(PRECHECK_ROOT)"; \
	fi

.PHONY: run-precheck
run-precheck: precheck

.PHONY: precheck
precheck: precheck-clone
	mkdir -p precheck_output
	docker run --rm --platform linux/amd64 \
		-v $(PWD):/project \
		-v $(PRECHECK_ROOT):/precheck \
		-v $(PDK_ROOT):/pdk \
		-e INPUT_DIRECTORY=/project \
		-e PDK_PATH=/pdk/$(PDK) \
		-w /precheck \
		efabless/mpw_precheck:latest \
		bash run_precheck.sh \
			--output_directory /project/precheck_output

# ── Clean ──────────────────────────────────────────────────────────────────
.PHONY: clean
clean:
	rm -rf sim/build sim/build_gls precheck_output
