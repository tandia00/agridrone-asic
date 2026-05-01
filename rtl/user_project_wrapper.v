// SPDX-FileCopyrightText: 2024 AgriDrone Team
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0
// user_project_wrapper.v
// Wrapper officiel pour Efabless Caravel (chipIgnite).
// Instancie l'AgriDrone Co-Processor et mappe les ports sur les GPIO de Caravel.

`default_nettype none

module user_project_wrapper #(
    parameter BITS = 32
)(
    // Power pins (toujours déclarés pour conformité stricte avec le wrapper Efabless)
    inout vdda1,    // User area 1 3.3V supply
    inout vdda2,    // User area 2 3.3V supply
    inout vssa1,    // User area 1 analog ground
    inout vssa2,    // User area 2 analog ground
    inout vccd1,    // User area 1 1.8V supply
    inout vccd2,    // User area 2 1.8v supply
    inout vssd1,    // User area 1 digital ground
    inout vssd2,    // User area 2 digital ground

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [37:0] io_in,
    output [37:0] io_out,
    output [37:0] io_oeb,

    // Analog (direct connection to GPIO pad---use with caution)
    // Note that analog I/O is not available on the 7 lowest-numbered
    // pins based on the Caravel top-level module.
    inout [28:0] analog_io,

    // Independent clock (on independent integer divider)
    input   user_clock2,

    // User maskable interrupt signals
    output [2:0] user_irq
);

    // -----------------------------------------------------------
    // Non-used interface tie-offs
    // -----------------------------------------------------------
    assign wbs_ack_o = 1'b0;
    assign wbs_dat_o = 32'b0;  // 32-bit comme le golden wrapper
    assign la_data_out = 128'b0;
    assign user_irq = 3'b0;

    // -----------------------------------------------------------
    // Mapping AgriDrone I/O -> Caravel IO Pads
    // -----------------------------------------------------------
    // io_in : entrées depuis l'extérieur
    // io_out : sorties vers l'extérieur
    // io_oeb : Output Enable Bar (0 = sortie active, 1 = haute impédance/entrée)
    
    // Tie-off par bit pour les io_out non utilisés.
    // Bits utilisés comme sorties : 10, 12-20, 22-24
    // Bits non utilisés (0-9, 11, 21, 25-37) → 0
    assign io_out[9:0]   = 10'b0;
    assign io_out[11]    = 1'b0;
    assign io_out[21]    = 1'b0;
    assign io_out[37:25] = 13'b0;

    // io_oeb : 1 = entrée, 0 = sortie
    // Sorties activées : 10, 12-20, 22-24
    assign io_oeb[9:0]   = 10'h3FF;          // entrées (8-9-11 SPI in, autres N/C)
    assign io_oeb[11]    = 1'b1;             // SPI CS_n (entrée)
    assign io_oeb[21]    = 1'b1;             // flow_pulse (entrée)
    assign io_oeb[37:25] = 13'h1FFF;         // entrées par défaut

    // --- HORLOGE ET RESET ---
    // On utilise l'horloge Wishbone principale (générée par le PLL de Caravel)
    wire clk = wb_clk_i;

    // Inverseur wb_rst_i (actif haut) -> rst_n (actif bas).
    // En synth OpenLane, on instancie une cellule sky130 explicite
    // pour éviter un $not non mappé (SYNTH_ELABORATE_ONLY).
    // En simulation comportementale, on utilise un simple ~.
    wire rst_n;
`ifdef SIM_BEHAVIORAL
    assign rst_n = ~wb_rst_i;
`else
    // Power pins (VPWR/VGND/VPB/VNB) sont ajoutés automatiquement par OpenLane
    // (PDN step). Yosys lit .lib qui ne déclare pas ces ports.
    sky130_fd_sc_hd__inv_2 rst_inv_inst (
        .A(wb_rst_i),
        .Y(rst_n)
    );
`endif

    // --- SPI SLAVE INTERFACE (Pins 8-11) ---
    wire spi_sclk = io_in[8];
    wire spi_mosi = io_in[9];
    wire spi_miso;
    wire spi_cs_n = io_in[11];
    
    assign io_out[10] = spi_miso;
    assign io_oeb[10] = 1'b0; // MISO en sortie

    // --- PWM MOTEURS (Pins 12-19) ---
    wire [7:0] pwm_out;
    assign io_out[19:12] = pwm_out;
    assign io_oeb[19:12] = 8'h00; // 8 canaux en sortie

    // --- SPRAY & FLOW (Pins 20-21) ---
    wire spray_pwm;
    wire flow_pulse = io_in[21];
    assign io_out[20] = spray_pwm;
    assign io_oeb[20] = 1'b0; // PWM spray en sortie

    // --- SAFETY & STATUS (Pins 22-24) ---
    wire kill_n;
    wire armed_led;
    wire wdog_trip_led;
    
    assign io_out[22] = kill_n;
    assign io_out[23] = armed_led;
    assign io_out[24] = wdog_trip_led;
    assign io_oeb[24:22] = 3'b000; // Statuts en sortie

    // -----------------------------------------------------------
    // Instanciation de l'AgriDrone Top
    // -----------------------------------------------------------
    top agridrone_inst (
        .clk(clk),
        .rst_n(rst_n),
        .spi_sclk(spi_sclk),
        .spi_mosi(spi_mosi),
        .spi_miso(spi_miso),
        .spi_cs_n(spi_cs_n),
        .pwm_out(pwm_out),
        .spray_pwm(spray_pwm),
        .flow_pulse(flow_pulse),
        .kill_n(kill_n),
        .armed_led(armed_led),
        .wdog_trip_led(wdog_trip_led)
    );

endmodule
`default_nettype wire
