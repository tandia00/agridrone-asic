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
`timescale 1ns/1ps
module tb_safety_watchdog;
    // Use a reduced CLK_HZ so 1ms = 100 cycles -> fast simulation
    localparam CLK_HZ = 100_000;

    reg         clk = 0, rst_n = 0, enable = 0, arm = 0, kick = 0;
    reg  [15:0] timeout_ms;
    wire        trip, kill_n, armed;

    always #10 clk = ~clk; // 50 MHz sim clock regardless; CLK_HZ param defines ms tick

    // 1 simulated "ms" = TICKS_PER_MS * clk_period = (CLK_HZ/1000) * 20 ns.
    localparam integer SIM_MS_NS = (CLK_HZ/1000) * 20;

    safety_watchdog #(.CLK_HZ(CLK_HZ)) dut (
        .clk(clk), .rst_n(rst_n),
        .enable(enable), .arm(arm), .kick(kick),
        .timeout_ms(timeout_ms),
        .trip(trip), .kill_n(kill_n), .armed_status(armed)
    );

    integer errors = 0;

    task pulse_kick; begin @(posedge clk); kick = 1; @(posedge clk); kick = 0; end endtask

    initial begin
        $dumpfile("tb_safety_watchdog.vcd");
        $dumpvars(0, tb_safety_watchdog);

        timeout_ms = 16'd5; // 5 ms
        #50 rst_n = 1;
        enable = 1;

        // Arm + initial kick
        @(posedge clk); arm = 1; pulse_kick(); @(posedge clk);
        if (!armed) begin $display("[WDOG] should be armed"); errors=errors+1; end
        if (trip)   begin $display("[WDOG] should not be tripped"); errors=errors+1; end

        // Kick every 2 ms for 20 ms -> must not trip
        repeat (10) begin
            #(SIM_MS_NS * 2);
            pulse_kick();
        end
        if (trip) begin $display("[WDOG] false trip while kicking"); errors=errors+1; end

        // Stop kicking -> expect trip after ~5 ms
        #(SIM_MS_NS * 10);
        if (!trip)   begin $display("[WDOG] should have tripped"); errors=errors+1; end
        if (kill_n)  begin $display("[WDOG] kill_n should be 0 on trip"); errors=errors+1; end

        // Recovery: arm rising edge + kick
        arm = 0; @(posedge clk); @(posedge clk);
        arm = 1; kick = 1; @(posedge clk); kick = 0;
        @(posedge clk); @(posedge clk);
        if (trip)   begin $display("[WDOG] should be recovered"); errors=errors+1; end
        if (!armed) begin $display("[WDOG] should be re-armed"); errors=errors+1; end

        if (errors == 0) $display("TEST PASSED"); else $display("TEST FAILED: %0d errors", errors);
        $finish;
    end
endmodule
