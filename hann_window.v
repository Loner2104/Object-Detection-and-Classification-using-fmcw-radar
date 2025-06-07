`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.05.2025 00:51:42
// Design Name: 
// Module Name: hann_window
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

module hann_window (
    input  wire        clk,
    input  wire        rst,
    input  wire        in_valid,         // 1 clock per valid input sample
    output reg  signed [15:0] hann_coeff,
    output reg         out_valid         // asserted with every new hann_coeff
);

    reg [6:0] addr;
    reg signed [15:0] rom [0:127];       // BRAM-based ROM

    // Load ROM contents from .mem file
    initial $readmemh("hann_window.mem", rom);

    always @(posedge clk) begin
        if (rst) begin
            addr <= 0;
            hann_coeff <= 0;
            out_valid <= 0;
        end else if (in_valid) begin
            hann_coeff <= rom[addr];
            out_valid <= 1;
            addr <= (addr == 127) ? 0 : addr + 1;
        end else begin
            out_valid <= 0;
        end
    end

endmodule

