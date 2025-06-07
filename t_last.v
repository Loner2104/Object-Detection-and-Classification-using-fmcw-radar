`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.05.2025 23:16:59
// Design Name: 
// Module Name: t_last
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


module tlast_generator (
    input  wire clk,
    input  wire en,
    output reg  tlast
);

    reg [6:0] count;  // 7-bit counter for counting to 128

    always @(posedge clk) begin
        if (en) begin
            if (count == 127) begin
                count <= 0;
                tlast <= 1;
            end else begin
                count <= count + 1;
                tlast <= 0;
            end
        end else begin
            tlast <= 0;
        end
    end

endmodule
