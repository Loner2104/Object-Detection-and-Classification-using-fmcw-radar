`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.05.2025 19:26:51
// Design Name: 
// Module Name: Feeder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module frame_streamer #(
    parameter TOTAL_SAMPLES = 128 * 256*2,
    parameter DATA_WIDTH = 32
)(
    input  wire             clk,
    input  wire             rst,
    input  wire             enable,
    output reg  [DATA_WIDTH-1:0] tdata,
    output reg              tvalid
);

    // ROM to hold input data
    reg [DATA_WIDTH-1:0] rom [0:TOTAL_SAMPLES-1];
    reg [$clog2(TOTAL_SAMPLES):0] index;

    // Load input data from hex file at simulation start
    initial begin
        $readmemh("fft_packed_real_imag_hex.txt", rom);  // One 32-bit hex per line
    end

    always @(posedge clk) begin
        if (rst) begin
            index  <= 0;
            tvalid <= 0;
        end else if (enable) begin
            tdata  <= rom[index];
            tvalid <= 1;

            if (index == TOTAL_SAMPLES - 1)
                index <= 0;  // wrap around if needed
            else
                index <= index + 1;
        end else begin
            tvalid <= 0;
        end
    end

endmodule
