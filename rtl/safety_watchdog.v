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
// safety_watchdog.v
// Millisecond-resolution watchdog. Hosts must "kick" within `timeout_ms`.
// On expiration: trip is latched (sticky), requires explicit arm+kick to recover.
`default_nettype none

module safety_watchdog #(
    parameter CLK_HZ = 50_000_000
) (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        enable,        // CTRL.enable
    input  wire        arm,           // CTRL.arm (level)
    input  wire        kick,          // 1-cycle pulse on WDOG_KICK write
    input  wire [15:0] timeout_ms,    // timeout in ms
    output reg         trip,          // 1 = watchdog fired
    output wire        kill_n,        // active-low kill: 0 = kill everything
    output reg         armed_status
);

    localparam integer TICKS_PER_MS = CLK_HZ / 1000;

    // 1 ms tick generator
    reg [$clog2(TICKS_PER_MS)-1:0] tick_cnt;
    reg                            ms_tick;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tick_cnt <= 0;
            ms_tick  <= 1'b0;
        end else if (tick_cnt == TICKS_PER_MS - 1) begin
            tick_cnt <= 0;
            ms_tick  <= 1'b1;
        end else begin
            tick_cnt <= tick_cnt + 1'b1;
            ms_tick  <= 1'b0;
        end
    end

    // ms-elapsed counter since last kick
    reg [15:0] elapsed;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)                          elapsed <= 16'd0;
        else if (!enable || !armed_status)   elapsed <= 16'd0;
        else if (kick)                       elapsed <= 16'd0;
        else if (ms_tick && elapsed != 16'hFFFF)
                                             elapsed <= elapsed + 16'd1;
    end

    // Arming logic: `arm` edge re-arms, `trip` sticks until user re-arms and kicks.
    reg arm_d;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            trip         <= 1'b0;
            armed_status <= 1'b0;
            arm_d        <= 1'b0;
        end else begin
            arm_d <= arm;
            if (!enable) begin
                armed_status <= 1'b0;
            end else if (arm && !arm_d && kick) begin
                // Rising edge of arm combined with a kick recovers from trip.
                trip         <= 1'b0;
                armed_status <= 1'b1;
            end else if (arm && !arm_d) begin
                armed_status <= 1'b1;
            end else if (armed_status && elapsed >= timeout_ms && timeout_ms != 16'd0) begin
                trip         <= 1'b1;
                armed_status <= 1'b0;
            end
        end
    end

    assign kill_n = ~trip & enable;

endmodule

`default_nettype wire
