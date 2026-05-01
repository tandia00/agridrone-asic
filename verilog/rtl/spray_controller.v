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
// spray_controller.v
// Drives the spray valve with a PWM and counts flow-meter pulses.
// Flow counter is latched/cleared on read via the register file.
`default_nettype none

module spray_controller (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        enable,        // CTRL.enable & CTRL.spray_en & !wdog_trip
    input  wire [15:0] period,        // shared PWM period
    input  wire [15:0] duty,          // SPRAY_DUTY register
    input  wire        flow_pulse_in, // async input from flow meter
    input  wire        flow_clear,    // pulse to clear flow counter (read-ack)
    output reg         spray_pwm,
    output reg  [15:0] flow_count
);

    // --- PWM ---
    reg [15:0] counter;
    wire       wrap = (counter >= period - 16'd1) || (period == 16'd0);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)        counter <= 16'd0;
        else if (wrap)     counter <= 16'd0;
        else               counter <= counter + 16'd1;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)        spray_pwm <= 1'b0;
        else if (!enable)  spray_pwm <= 1'b0;
        else               spray_pwm <= (counter < duty);
    end

    // --- Flow pulse sync + edge detect ---
    reg [2:0] flow_sync;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) flow_sync <= 3'b000;
        else        flow_sync <= {flow_sync[1:0], flow_pulse_in};
    end
    wire flow_edge = flow_sync[1] & ~flow_sync[2];

    // --- Counter ---
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)            flow_count <= 16'd0;
        else if (flow_clear)   flow_count <= flow_edge ? 16'd1 : 16'd0;
        else if (flow_edge && flow_count != 16'hFFFF)
                               flow_count <= flow_count + 16'd1;
    end

endmodule

`default_nettype wire
