`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.05.2025 21:52:18
// Design Name: 
// Module Name: doppler_fft
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


`timescale 1ns / 1ps

module doppler_output_logger #(
    parameter DATA_WIDTH = 32
)(
    input  wire                    clk,
    input  wire                    rst,
    input  wire                    tvalid,   // AXI-Stream valid
    input  wire [DATA_WIDTH-1:0]  tdata     // AXI-Stream data
);

`ifndef SYNTHESIS
    integer fd;

    initial begin
        fd = $fopen("doppler_output.txt", "w");
        if (fd == 0) begin
            $display("ERROR: Could not open doppler_output.txt");
            $finish;
        end
    end

    always @(posedge clk) begin
        if (tvalid) begin
            $fwrite(fd, "%08x\n", tdata);
        end
    end
`endif

endmodule
