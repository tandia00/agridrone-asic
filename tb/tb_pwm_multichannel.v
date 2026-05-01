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
module tb_pwm_multichannel;
    reg         clk = 0, rst_n = 0, enable = 0;
    reg  [15:0] period;
    reg  [15:0] d0,d1,d2,d3,d4,d5,d6,d7;
    wire [7:0]  pwm_out;

    always #10 clk = ~clk; // 50 MHz

    pwm_multichannel dut (
        .clk(clk), .rst_n(rst_n), .enable(enable), .period(period),
        .duty0(d0), .duty1(d1), .duty2(d2), .duty3(d3),
        .duty4(d4), .duty5(d5), .duty6(d6), .duty7(d7),
        .pwm_out(pwm_out)
    );

    integer errors = 0;
    integer high_count, i;

    initial begin
        $dumpfile("tb_pwm_multichannel.vcd");
        $dumpvars(0, tb_pwm_multichannel);

        period = 16'd100;
        d0 = 16'd25; d1 = 16'd50; d2 = 16'd75; d3 = 16'd0;
        d4 = 16'd100; d5 = 16'd10; d6 = 16'd90; d7 = 16'd50;
        enable = 1'b0;

        #50 rst_n = 1'b1;
        #40 enable = 1'b1;

        // Wait one period for alignment, then measure one full period on ch1 (duty=50/100)
        @(posedge clk);
        while (pwm_out[1] == 1'b0) @(posedge clk);    // wait high
        while (pwm_out[1] == 1'b1) @(posedge clk);    // wait low => start of new period
        // now at rising edge of a new period. Count high cycles of ch1 over `period`
        high_count = 0;
        for (i = 0; i < 100; i = i + 1) begin
            if (pwm_out[1]) high_count = high_count + 1;
            @(posedge clk);
        end
        $display("[PWM] ch1 high=%0d / 100 (expected ~50)", high_count);
        if (high_count < 45 || high_count > 55) errors = errors + 1;

        // ch3 duty=0 must stay low
        for (i = 0; i < 200; i = i + 1) begin
            if (pwm_out[3] !== 1'b0) begin
                $display("[PWM] ch3 duty=0 should stay low"); errors = errors + 1;
            end
            @(posedge clk);
        end

        // ch4 duty>=period must stay high
        for (i = 0; i < 200; i = i + 1) begin
            if (pwm_out[4] !== 1'b1) begin
                $display("[PWM] ch4 duty>=period should stay high"); errors = errors + 1;
            end
            @(posedge clk);
        end

        // Disable => all low
        enable = 0;
        @(posedge clk); @(posedge clk);
        if (pwm_out !== 8'h00) begin
            $display("[PWM] enable=0 must zero outputs, got %h", pwm_out);
            errors = errors + 1;
        end

        if (errors == 0) $display("TEST PASSED"); else $display("TEST FAILED: %0d errors", errors);
        $finish;
    end
endmodule
