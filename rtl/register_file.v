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
// register_file.v
// Central register file. Maps SPI accesses to/from internal signals.
// See docs/register_map.md for the full map.
`default_nettype none

module register_file (
    input  wire        clk,
    input  wire        rst_n,

    // SPI slave side
    input  wire        rf_we,
    input  wire        rf_re,
    input  wire [6:0]  rf_addr,
    input  wire [15:0] rf_wdata,
    output reg  [15:0] rf_rdata,

    // CTRL / STATUS
    output reg         ctrl_enable,
    output reg         ctrl_spray_en,
    output reg         ctrl_arm,
    input  wire        status_wdog_trip,
    input  wire        status_armed,
    input  wire        status_spray_active,

    // Watchdog
    output reg  [15:0] wdog_timeout_ms,
    output reg         wdog_kick_pulse,

    // PWM
    output reg  [15:0] pwm_period,
    output reg  [15:0] pwm_duty0, pwm_duty1, pwm_duty2, pwm_duty3,
    output reg  [15:0] pwm_duty4, pwm_duty5, pwm_duty6, pwm_duty7,

    // Spray
    output reg  [15:0] spray_duty,
    input  wire [15:0] spray_flow_count,
    output reg         spray_flow_clear,

    // Altitude
    output reg  [15:0] alt_baro_in,
    output reg  [15:0] alt_sonar_in,
    output reg         alt_update_pulse,
    output reg  [15:0] alt_alpha_q15,
    input  wire [15:0] alt_fused
);

    localparam [6:0]
        A_CTRL        = 7'h00,
        A_STATUS      = 7'h01,
        A_WDOG_TO     = 7'h02,
        A_WDOG_KICK   = 7'h03,
        A_PWM_PERIOD  = 7'h04,
        A_PWM_D0      = 7'h08,
        A_PWM_D1      = 7'h09,
        A_PWM_D2      = 7'h0A,
        A_PWM_D3      = 7'h0B,
        A_PWM_D4      = 7'h0C,
        A_PWM_D5      = 7'h0D,
        A_PWM_D6      = 7'h0E,
        A_PWM_D7      = 7'h0F,
        A_SPRAY_DUTY  = 7'h10,
        A_SPRAY_FLOW  = 7'h11,
        A_ALT_BARO    = 7'h20,
        A_ALT_SONAR   = 7'h21,
        A_ALT_FUSED   = 7'h22,
        A_ALT_ALPHA   = 7'h23,
        A_CHIP_ID     = 7'h7F;

    localparam [15:0] CHIP_ID = 16'hA6D1;

    // --- Writes ---
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ctrl_enable     <= 1'b0;
            ctrl_spray_en   <= 1'b0;
            ctrl_arm        <= 1'b0;
            wdog_timeout_ms <= 16'h00C8;  // 200 ms
            wdog_kick_pulse <= 1'b0;
            pwm_period      <= 16'h9C40;  // 40000 -> 1.25 kHz @ 50 MHz
            pwm_duty0 <= 0; pwm_duty1 <= 0; pwm_duty2 <= 0; pwm_duty3 <= 0;
            pwm_duty4 <= 0; pwm_duty5 <= 0; pwm_duty6 <= 0; pwm_duty7 <= 0;
            spray_duty       <= 16'd0;
            spray_flow_clear <= 1'b0;
            alt_baro_in      <= 16'd0;
            alt_sonar_in     <= 16'd0;
            alt_update_pulse <= 1'b0;
            alt_alpha_q15    <= 16'h2000;
        end else begin
            wdog_kick_pulse  <= 1'b0;
            spray_flow_clear <= 1'b0;
            alt_update_pulse <= 1'b0;

            if (rf_we) begin
                case (rf_addr)
                    A_CTRL: begin
                        ctrl_enable   <= rf_wdata[0];
                        ctrl_spray_en <= rf_wdata[1];
                        ctrl_arm      <= rf_wdata[2];
                    end
                    A_WDOG_TO:    wdog_timeout_ms <= rf_wdata;
                    A_WDOG_KICK:  wdog_kick_pulse <= 1'b1;
                    A_PWM_PERIOD: pwm_period      <= rf_wdata;
                    A_PWM_D0:     pwm_duty0       <= rf_wdata;
                    A_PWM_D1:     pwm_duty1       <= rf_wdata;
                    A_PWM_D2:     pwm_duty2       <= rf_wdata;
                    A_PWM_D3:     pwm_duty3       <= rf_wdata;
                    A_PWM_D4:     pwm_duty4       <= rf_wdata;
                    A_PWM_D5:     pwm_duty5       <= rf_wdata;
                    A_PWM_D6:     pwm_duty6       <= rf_wdata;
                    A_PWM_D7:     pwm_duty7       <= rf_wdata;
                    A_SPRAY_DUTY: spray_duty      <= rf_wdata;
                    A_ALT_BARO: begin
                        alt_baro_in      <= rf_wdata;
                        alt_update_pulse <= 1'b1;
                    end
                    A_ALT_SONAR: begin
                        alt_sonar_in     <= rf_wdata;
                        alt_update_pulse <= 1'b1;
                    end
                    A_ALT_ALPHA:  alt_alpha_q15   <= rf_wdata;
                    default: ;
                endcase
            end
            // Reads with side effects
            if (rf_re && rf_addr == A_SPRAY_FLOW) spray_flow_clear <= 1'b1;
        end
    end

    // --- Reads (combinational mux; SPI slave latches one cycle after rf_re) ---
    always @(*) begin
        case (rf_addr)
            A_CTRL:       rf_rdata = {13'd0, ctrl_arm, ctrl_spray_en, ctrl_enable};
            A_STATUS:     rf_rdata = {13'd0, status_spray_active, status_armed, status_wdog_trip};
            A_WDOG_TO:    rf_rdata = wdog_timeout_ms;
            A_PWM_PERIOD: rf_rdata = pwm_period;
            A_PWM_D0:     rf_rdata = pwm_duty0;
            A_PWM_D1:     rf_rdata = pwm_duty1;
            A_PWM_D2:     rf_rdata = pwm_duty2;
            A_PWM_D3:     rf_rdata = pwm_duty3;
            A_PWM_D4:     rf_rdata = pwm_duty4;
            A_PWM_D5:     rf_rdata = pwm_duty5;
            A_PWM_D6:     rf_rdata = pwm_duty6;
            A_PWM_D7:     rf_rdata = pwm_duty7;
            A_SPRAY_DUTY: rf_rdata = spray_duty;
            A_SPRAY_FLOW: rf_rdata = spray_flow_count;
            A_ALT_FUSED:  rf_rdata = alt_fused;
            A_ALT_ALPHA:  rf_rdata = alt_alpha_q15;
            A_CHIP_ID:    rf_rdata = CHIP_ID;
            default:      rf_rdata = 16'h0000;
        endcase
    end

endmodule

`default_nettype wire
