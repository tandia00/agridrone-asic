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
// System-level testbench: drives the ASIC via an SPI master model and checks
// that functional paths respond correctly.
module tb_top;
    // Use a small CLK_HZ override so watchdog timing is fast in simulation.
    localparam CLK_HZ = 100_000;

    reg         clk = 0, rst_n = 0;
    reg         spi_sclk = 0, spi_mosi = 0, spi_cs_n = 1;
    wire        spi_miso;
    wire [7:0]  pwm_out;
    wire        spray_pwm;
    reg         flow_pulse = 0;
    wire        kill_n, armed_led, wdog_trip_led;

    always #10 clk = ~clk;   // 50 MHz

    `ifdef WITH_SDF
    top dut (
    `else
    top #(.CLK_HZ(CLK_HZ)) dut (
    `endif
        .clk(clk), .rst_n(rst_n),
        .spi_sclk(spi_sclk), .spi_mosi(spi_mosi),
        .spi_miso(spi_miso), .spi_cs_n(spi_cs_n),
        .pwm_out(pwm_out),
        .spray_pwm(spray_pwm), .flow_pulse(flow_pulse),
        .kill_n(kill_n),
        .armed_led(armed_led), .wdog_trip_led(wdog_trip_led)
    );

    // --- SDF annotation for Gate-Level Simulation ---
    `ifdef WITH_SDF
    initial begin
        $display("[GLS] Annotating SDF...");
        // This is a dynamic parameter passed via +sdf_file="path/to/file.sdf"
        $sdf_annotate("top.sdf", dut);
    end
    `endif

    integer errors = 0;

    // --- SPI master tasks (mode 0, MSB first) ---
    localparam integer SCLK_HALF = 500; // 1 MHz SPI (half period in ns)

    task spi_xfer(input [23:0] tx, output [15:0] rx);
        integer i; reg [15:0] sh;
        begin
            sh = 16'd0;
            spi_cs_n = 0; #SCLK_HALF;
            for (i = 23; i >= 0; i = i - 1) begin
                spi_mosi = tx[i];
                #SCLK_HALF; spi_sclk = 1;
                // Host samples MISO on rising edge; we accumulate only bits 15..0
                if (i < 16) sh = {sh[14:0], spi_miso};
                #SCLK_HALF; spi_sclk = 0;
            end
            #SCLK_HALF; spi_cs_n = 1;
            #(SCLK_HALF*4);
            rx = sh;
        end
    endtask

    task spi_write(input [6:0] addr, input [15:0] data);
        reg [15:0] dummy;
        begin spi_xfer({1'b1, addr, data}, dummy); end
    endtask

    task spi_read(input [6:0] addr, output [15:0] data);
        begin spi_xfer({1'b0, addr, 16'h0000}, data); end
    endtask

    reg [15:0] rd;

    initial begin
        $dumpfile("tb_top.vcd");
        $dumpvars(0, tb_top);

        #200 rst_n = 1;
        #1000;

        // ---- 1) Read CHIP_ID
        spi_read(7'h7F, rd);
        $display("[TOP] CHIP_ID = 0x%04h (expect 0xA6D1)", rd);
        if (rd !== 16'hA6D1) errors = errors + 1;

        // ---- 2) Configure PWM
        spi_write(7'h04, 16'd100);   // PWM_PERIOD = 100
        spi_write(7'h08, 16'd50);    // duty0 = 50 (50%)
        spi_write(7'h0A, 16'd25);    // duty2 = 25 (25%)

        // ---- 3) Enable + arm + kick watchdog
        spi_write(7'h02, 16'd100);                 // WDOG_TIMEOUT = 100 ms
        spi_write(7'h00, 16'h0005);                // CTRL: enable=1, arm=1
        spi_write(7'h03, 16'h0000);                // WDOG_KICK
        #5000;

        // ---- 4) Check STATUS.armed
        spi_read(7'h01, rd);
        $display("[TOP] STATUS = 0x%04h", rd);
        if (!rd[1]) begin $display("[TOP] expected armed=1"); errors=errors+1; end

        // ---- 5) Watch PWM toggle
        begin : watch_pwm
            integer j, hi;
            hi = 0;
            for (j = 0; j < 1000; j = j + 1) begin
                @(posedge clk);
                if (pwm_out[0]) hi = hi + 1;
            end
            $display("[TOP] pwm_out[0] high fraction over 1000 cycles: %0d (expect ~500)", hi);
            if (hi < 400 || hi > 600) errors = errors + 1;
        end

        // ---- 6) Spray + flow meter
        spi_write(7'h00, 16'h0007);                // enable + spray_en + arm
        spi_write(7'h10, 16'd50);                  // SPRAY_DUTY = 50%
        spi_write(7'h03, 16'h0000);                // kick

        // Inject 5 flow pulses
        begin : flow_stim
            integer k;
            for (k = 0; k < 5; k = k + 1) begin
                #3000 flow_pulse = 1; #3000 flow_pulse = 0;
            end
        end

        spi_read(7'h11, rd);
        $display("[TOP] flow_count = %0d (expect ~5)", rd);
        if (rd < 3 || rd > 7) errors = errors + 1;

        // Read again must be ~0 (cleared on read)
        #2000;
        spi_read(7'h11, rd);
        $display("[TOP] flow_count after clear = %0d", rd);
        if (rd > 1) errors = errors + 1;

        // ---- 7) Altitude fusion
        spi_write(7'h23, 16'h7FFF);                // alpha ~= 1.0 => follow input
        spi_write(7'h20, 16'd1000);                // baro  = 1000
        spi_write(7'h21, 16'd1000);                // sonar = 1000 -> fused -> 1000
        #2000;
        spi_read(7'h22, rd);
        $display("[TOP] alt_fused = %0d (expect ~1000)", rd);
        if (rd < 900 || rd > 1100) errors = errors + 1;

        // ---- 8) Watchdog trip: stop kicking
        `ifndef WITH_SDF
        // En RTL on simule le délai court. En GLS c'est compilé pour 50MHz, l'attente prendrait des plombes.
        spi_write(7'h02, 16'd5);                   // short timeout 5 ms
        spi_write(7'h03, 16'h0000);                // kick once
        // Wait > 5 ms of sim time
        #200_000;
        spi_read(7'h01, rd);
        $display("[TOP] STATUS after timeout = 0x%04h (expect wdog_trip=1)", rd);
        if (!rd[0]) errors = errors + 1;
        if (pwm_out !== 8'h00) begin
            $display("[TOP] PWMs must be 0 on wdog trip, got %h", pwm_out);
            errors = errors + 1;
        end
        if (kill_n) begin $display("[TOP] kill_n must be 0 on trip"); errors = errors + 1; end
        `endif

        if (errors == 0) $display("TEST PASSED");
        else             $display("TEST FAILED: %0d errors", errors);
        $finish;
    end

    initial begin
        #50_000_000 $display("TIMEOUT"); $finish;
    end
endmodule
