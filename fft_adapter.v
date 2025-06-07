`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.05.2025 22:32:50
// Design Name: 
// Module Name: fft_adapter
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


module axi_stream_adapter #(
    parameter FRAME_LENGTH = 128,
    parameter PIPELINE_LATENCY = 4
)(
    input  wire clk,
    input  wire rst,

    input  wire in_tvalid,  // from streamer
    output reg  out_tvalid, // to FFT
    output reg  out_tlast   // to FFT
);

    reg [7:0] valid_count = 0;
    reg [PIPELINE_LATENCY:0] valid_shift;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            valid_count   <= 0;
            valid_shift   <= 0;
            out_tvalid    <= 0;
            out_tlast     <= 0;
        end else begin
            // shift register to delay tvalid
            valid_shift <= {valid_shift[PIPELINE_LATENCY-1:0], in_tvalid};

            // delayed tvalid output
            out_tvalid <= valid_shift[PIPELINE_LATENCY-1];

            // count incoming valid samples
            if (in_tvalid) begin
                valid_count <= valid_count + 1;
            end

            // assert tlast after 128 valid inputs (delayed)
            if (valid_count == FRAME_LENGTH) begin
                out_tlast <= 1;
                valid_count <= 0;  // reset for next frame
            end else begin
                out_tlast <= 0;
            end
        end
    end

endmodule
