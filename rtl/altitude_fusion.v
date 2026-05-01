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
// altitude_fusion.v
// First-order IIR fusing barometer + sonar measurements, pipelined in 3 stages
// to keep the 17x17 multiplier off the critical path.
//
//   measurement = (baro + sonar) >> 1
//   alt_fused  += (alpha * (measurement - alt_fused)) >>> 15
//
// alpha is Q1.15 unsigned (0x0000..0x7FFF). Default 0x2000 ~= 0.25.
// Update is triggered on any write to ALT_BARO_IN or ALT_SONAR_IN; a new result
// appears 3 cycles later. Updates arrive far apart in practice (SPI writes),
// so 3-cycle latency is irrelevant.
//
// Stage 1: register measurement, current alt, alpha
// Stage 2: register err = meas - alt
// Stage 3: register product = err * alpha
// Stage 4: register alt_fused <- alt + (product >>> 15), saturated
`default_nettype none

module altitude_fusion (
    input  wire         clk,
    input  wire         rst_n,
    input  wire [15:0]  baro_in,
    input  wire [15:0]  sonar_in,
    input  wire         update,
    input  wire [15:0]  alpha_q15,
    output reg  [15:0]  alt_fused
);

    // --- Stage 1: latch operands when update pulses ---
    reg signed [15:0] s1_meas;
    reg signed [15:0] s1_alt;
    reg        [15:0] s1_alpha;
    reg               s1_valid;

    wire signed [16:0] baro_ext  = {baro_in[15],  baro_in};
    wire signed [16:0] sonar_ext = {sonar_in[15], sonar_in};
    wire signed [16:0] sum_ext   = baro_ext + sonar_ext;
    wire signed [15:0] meas_avg  = sum_ext[16:1];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s1_valid <= 1'b0;
            s1_meas  <= 16'd0;
            s1_alt   <= 16'd0;
            s1_alpha <= 16'd0;
        end else begin
            s1_valid <= update;
            if (update) begin
                s1_meas  <= meas_avg;
                s1_alt   <= alt_fused;
                s1_alpha <= alpha_q15;
            end
        end
    end

    // --- Stage 2: subtract (err = meas - alt) ---
    reg signed [16:0] s2_err;
    reg        [15:0] s2_alpha;
    reg signed [15:0] s2_alt;
    reg               s2_valid;

    wire signed [16:0] err_ext = {s1_meas[15], s1_meas} - {s1_alt[15], s1_alt};

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s2_valid <= 1'b0;
            s2_err   <= 17'sd0;
            s2_alpha <= 16'd0;
            s2_alt   <= 16'd0;
        end else begin
            s2_valid <= s1_valid;
            if (s1_valid) begin
                s2_err   <= err_ext;
                s2_alpha <= s1_alpha;
                s2_alt   <= s1_alt;
            end
        end
    end

    // --- Stage 3: multiply ---
    reg signed [33:0] s3_prod;    // 17 x 17 -> 34
    reg signed [15:0] s3_alt;
    reg               s3_valid;

    wire signed [16:0] alpha_ext = {1'b0, s2_alpha};

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s3_valid <= 1'b0;
            s3_prod  <= 34'sd0;
            s3_alt   <= 16'd0;
        end else begin
            s3_valid <= s2_valid;
            if (s2_valid) begin
                s3_prod <= s2_err * alpha_ext;
                s3_alt  <= s2_alt;
            end
        end
    end

    // --- Stage 4: shift, add, saturate, write back ---
    wire signed [33:0] prod_shft = s3_prod >>> 15;
    wire signed [16:0] delta     = prod_shft[16:0];
    wire signed [17:0] next_sum  = {{2{s3_alt[15]}}, s3_alt} + {{1{delta[16]}}, delta};

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            alt_fused <= 16'd0;
        end else if (s3_valid) begin
            if      (next_sum >  $signed(18'sd32767))  alt_fused <= 16'h7FFF;
            else if (next_sum < -$signed(18'sd32768))  alt_fused <= 16'h8000;
            else                                       alt_fused <= next_sum[15:0];
        end
    end

endmodule

`default_nettype wire
