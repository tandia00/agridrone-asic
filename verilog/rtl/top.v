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
// top.v
// AgriDrone Co-Processor ASIC — top-level integration.
`default_nettype none

module top #(
    parameter CLK_HZ = 50_000_000
) (
    input  wire        clk,
    input  wire        rst_n,

    // SPI slave (to host MCU)
    input  wire        spi_sclk,
    input  wire        spi_mosi,
    output wire        spi_miso,
    input  wire        spi_cs_n,

    // 8-channel motor PWM
    output wire [7:0]  pwm_out,

    // Spray + flow meter
    output wire        spray_pwm,
    input  wire        flow_pulse,

    // Safety + status
    output wire        kill_n,
    output wire        armed_led,
    output wire        wdog_trip_led
);

    // --- Register-file <-> SPI ---
    wire        rf_we, rf_re;
    wire [6:0]  rf_addr;
    wire [15:0] rf_wdata, rf_rdata;

    // --- Register-file <-> blocks ---
    wire        ctrl_enable, ctrl_spray_en, ctrl_arm;
    wire        wdog_kick_pulse;
    wire [15:0] wdog_timeout_ms;
    wire [15:0] pwm_period;
    wire [15:0] pwm_duty0, pwm_duty1, pwm_duty2, pwm_duty3;
    wire [15:0] pwm_duty4, pwm_duty5, pwm_duty6, pwm_duty7;
    wire [15:0] spray_duty;
    wire        spray_flow_clear;
    wire [15:0] spray_flow_count;
    wire [15:0] alt_baro_in, alt_sonar_in, alt_alpha_q15, alt_fused;
    wire        alt_update_pulse;

    // --- Status ---
    wire wdog_trip;
    wire armed_status;
    wire spray_active;

    // --- Safety gating ---
    wire safety_ok        = ctrl_enable & ~wdog_trip;
    wire pwm_gate_enable  = safety_ok;
    wire spray_gate_enable = safety_ok & ctrl_spray_en;
    assign spray_active   = spray_gate_enable & (spray_duty != 16'd0);

    // ------------------------------------------------------------------
    spi_slave u_spi (
        .clk      (clk),
        .rst_n    (rst_n),
        .spi_sclk (spi_sclk),
        .spi_mosi (spi_mosi),
        .spi_miso (spi_miso),
        .spi_cs_n (spi_cs_n),
        .rf_we    (rf_we),
        .rf_re    (rf_re),
        .rf_addr  (rf_addr),
        .rf_wdata (rf_wdata),
        .rf_rdata (rf_rdata)
    );

    register_file u_regs (
        .clk                 (clk),
        .rst_n               (rst_n),
        .rf_we               (rf_we),
        .rf_re               (rf_re),
        .rf_addr             (rf_addr),
        .rf_wdata            (rf_wdata),
        .rf_rdata            (rf_rdata),
        .ctrl_enable         (ctrl_enable),
        .ctrl_spray_en       (ctrl_spray_en),
        .ctrl_arm            (ctrl_arm),
        .status_wdog_trip    (wdog_trip),
        .status_armed        (armed_status),
        .status_spray_active (spray_active),
        .wdog_timeout_ms     (wdog_timeout_ms),
        .wdog_kick_pulse     (wdog_kick_pulse),
        .pwm_period          (pwm_period),
        .pwm_duty0           (pwm_duty0),
        .pwm_duty1           (pwm_duty1),
        .pwm_duty2           (pwm_duty2),
        .pwm_duty3           (pwm_duty3),
        .pwm_duty4           (pwm_duty4),
        .pwm_duty5           (pwm_duty5),
        .pwm_duty6           (pwm_duty6),
        .pwm_duty7           (pwm_duty7),
        .spray_duty          (spray_duty),
        .spray_flow_count    (spray_flow_count),
        .spray_flow_clear    (spray_flow_clear),
        .alt_baro_in         (alt_baro_in),
        .alt_sonar_in        (alt_sonar_in),
        .alt_update_pulse    (alt_update_pulse),
        .alt_alpha_q15       (alt_alpha_q15),
        .alt_fused           (alt_fused)
    );

    pwm_multichannel u_pwm (
        .clk     (clk),
        .rst_n   (rst_n),
        .enable  (pwm_gate_enable),
        .period  (pwm_period),
        .duty0   (pwm_duty0),
        .duty1   (pwm_duty1),
        .duty2   (pwm_duty2),
        .duty3   (pwm_duty3),
        .duty4   (pwm_duty4),
        .duty5   (pwm_duty5),
        .duty6   (pwm_duty6),
        .duty7   (pwm_duty7),
        .pwm_out (pwm_out)
    );

    spray_controller u_spray (
        .clk           (clk),
        .rst_n         (rst_n),
        .enable        (spray_gate_enable),
        .period        (pwm_period),
        .duty          (spray_duty),
        .flow_pulse_in (flow_pulse),
        .flow_clear    (spray_flow_clear),
        .spray_pwm     (spray_pwm),
        .flow_count    (spray_flow_count)
    );

    altitude_fusion u_alt (
        .clk        (clk),
        .rst_n      (rst_n),
        .baro_in    (alt_baro_in),
        .sonar_in   (alt_sonar_in),
        .update     (alt_update_pulse),
        .alpha_q15  (alt_alpha_q15),
        .alt_fused  (alt_fused)
    );

    safety_watchdog #(.CLK_HZ(CLK_HZ)) u_wdog (
        .clk          (clk),
        .rst_n        (rst_n),
        .enable       (ctrl_enable),
        .arm          (ctrl_arm),
        .kick         (wdog_kick_pulse),
        .timeout_ms   (wdog_timeout_ms),
        .trip         (wdog_trip),
        .kill_n       (kill_n),
        .armed_status (armed_status)
    );

    assign armed_led     = armed_status;
    assign wdog_trip_led = wdog_trip;

endmodule

`default_nettype wire
