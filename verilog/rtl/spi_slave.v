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
// spi_slave.v
// SPI slave, mode 0 (CPOL=0, CPHA=0), MSB-first.
// 24-bit frame: [RW, addr[6:0], data[15:0]]
//   RW = 1 -> write: data is written into register file at `addr`.
//   RW = 0 -> read : register file returns data at `addr`, shifted out on MISO
//                    during bits 8..23.
// CS_N must stay low for the full 24 bits.
`default_nettype none

module spi_slave (
    input  wire        clk,
    input  wire        rst_n,

    // SPI pins
    input  wire        spi_sclk,
    input  wire        spi_mosi,
    output reg         spi_miso,
    input  wire        spi_cs_n,

    // Register-file interface (synchronous to clk)
    output reg         rf_we,
    output reg         rf_re,
    output reg  [6:0]  rf_addr,
    output reg  [15:0] rf_wdata,
    input  wire [15:0] rf_rdata
);

    // --- 2-FF synchronizers ---
    reg [2:0] sclk_s, mosi_s, cs_s;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sclk_s <= 3'b000;
            mosi_s <= 3'b000;
            cs_s   <= 3'b111;
        end else begin
            sclk_s <= {sclk_s[1:0], spi_sclk};
            mosi_s <= {mosi_s[1:0], spi_mosi};
            cs_s   <= {cs_s[1:0],   spi_cs_n};
        end
    end
    wire sclk_rise = (sclk_s[2:1] == 2'b01);
    wire sclk_fall = (sclk_s[2:1] == 2'b10);
    wire cs_active = ~cs_s[1];
    wire cs_fall   = (cs_s[2:1] == 2'b10);

    // --- Shift in / bit counter ---
    // bit_cnt counts how many bits have been captured so far (0..24).
    reg [5:0]  bit_cnt;
    reg [23:0] shreg_in;   // full frame as it comes in
    reg [15:0] shreg_out;  // data to shift out on MISO

    // Single always block drives bit_cnt, shreg_in, rf_re, rf_we, rf_addr, rf_wdata.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bit_cnt  <= 6'd0;
            shreg_in <= 24'd0;
            rf_re    <= 1'b0;
            rf_we    <= 1'b0;
            rf_addr  <= 7'd0;
            rf_wdata <= 16'd0;
        end else begin
            rf_re <= 1'b0;
            rf_we <= 1'b0;

            if (cs_fall) begin
                bit_cnt  <= 6'd0;
                shreg_in <= 24'd0;
            end else if (cs_active && sclk_rise) begin
                shreg_in <= {shreg_in[22:0], mosi_s[1]};

                // After bit 7 is captured: decode RW/addr for reads.
                if (bit_cnt == 6'd7) begin
                    if (shreg_in[6] == 1'b0) begin // RW == 0 (read)
                        rf_re   <= 1'b1;
                        rf_addr <= {shreg_in[5:0], mosi_s[1]};
                    end
                end

                // After bit 23 is captured: issue write if RW == 1.
                if (bit_cnt == 6'd23) begin
                    if (shreg_in[22] == 1'b1) begin // RW == 1 (write)
                        rf_we    <= 1'b1;
                        rf_addr  <= shreg_in[21:15];
                        rf_wdata <= {shreg_in[14:0], mosi_s[1]};
                    end
                end

                if (bit_cnt != 6'd63) bit_cnt <= bit_cnt + 6'd1;
            end
        end
    end

    // Latch register-file data one cycle after rf_re.
    reg rf_re_d;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rf_re_d   <= 1'b0;
            shreg_out <= 16'd0;
        end else begin
            rf_re_d <= rf_re;
            if (rf_re_d) shreg_out <= rf_rdata;
        end
    end

    // MISO update on falling edge (mode 0). Index directly into shreg_out
    // so that bit_cnt == 8 presents bit 15, bit_cnt == 23 presents bit 0.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            spi_miso <= 1'b0;
        end else if (!cs_active) begin
            spi_miso <= 1'b0;
        end else if (sclk_fall && bit_cnt >= 6'd8 && bit_cnt <= 6'd23) begin
            spi_miso <= shreg_out[6'd23 - bit_cnt];
        end
    end

endmodule

`default_nettype wire
