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
// pwm_multichannel.v
// 8-channel PWM generator with shared period.
// All channels are phase-aligned on counter wrap (=> all ESCs start together).
`default_nettype none

module pwm_multichannel (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        enable,           // global enable; if 0, all outputs low
    input  wire [15:0] period,           // PWM period in clock ticks (e.g. 40000 @ 50MHz => 1.25 kHz)
    input  wire [15:0] duty0, duty1, duty2, duty3,
    input  wire [15:0] duty4, duty5, duty6, duty7,
    output reg  [7:0]  pwm_out
);

    reg [15:0] counter;
    wire       wrap = (counter >= period - 16'd1) || (period == 16'd0);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 16'd0;
        end else if (wrap) begin
            counter <= 16'd0;
        end else begin
            counter <= counter + 16'd1;
        end
    end

    // Compare: output high while counter < duty (duty=0 => always low; duty>=period => always high)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pwm_out <= 8'h00;
        end else if (!enable) begin
            pwm_out <= 8'h00;
        end else begin
            pwm_out[0] <= (counter < duty0);
            pwm_out[1] <= (counter < duty1);
            pwm_out[2] <= (counter < duty2);
            pwm_out[3] <= (counter < duty3);
            pwm_out[4] <= (counter < duty4);
            pwm_out[5] <= (counter < duty5);
            pwm_out[6] <= (counter < duty6);
            pwm_out[7] <= (counter < duty7);
        end
    end

endmodule

`default_nettype wire
