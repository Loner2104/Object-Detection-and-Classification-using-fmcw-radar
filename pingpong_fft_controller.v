`timescale 1ns / 1ps

module pingpong_fft_controller (
    input  wire        clk,
    input  wire        rst,

    input  wire [31:0] fft_data_in,
    input  wire        fft_data_valid,

    // BRAM A ports
    output reg  [14:0] bram_addra,
    output reg  [31:0] bram_dina,
    output reg         bram_wea,
    output reg         bram_ena,
    input  wire [31:0] bram_douta,

    // BRAM B ports
    output reg  [14:0] bram_addrb,
    output reg  [31:0] bram_dinb,
    output reg         bram_web,
    output reg         bram_enb,
    input  wire [31:0] bram_doutb,

    // Doppler FFT output
    output reg  [31:0] fft_doppler_input,
    output reg         fft_doppler_valid,
    output reg         fft_doppler_last     // <-- ADDED tlast
);

    localparam RESET       = 2'd0;
    localparam FILL_FIRST  = 2'd1;
    localparam ACTIVE      = 2'd2;

    reg [1:0]  state;
    reg        active_write_buf;  // 0 = write A, 1 = write B
    reg        active_read_buf;   // 0 = read A, 1 = read B

    reg [15:0] wr_counter;
    reg [6:0]  col;
    reg [7:0]  row;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state             <= RESET;
            active_write_buf  <= 0;
            active_read_buf   <= 1;
            wr_counter        <= 0;
            col               <= 0;
            row               <= 0;
            fft_doppler_valid <= 0;
            fft_doppler_last  <= 0;

            bram_wea <= 0; bram_ena <= 0; bram_addra <= 0; bram_dina <= 0;
            bram_web <= 0; bram_enb <= 0; bram_addrb <= 0; bram_dinb <= 0;
        end else begin
            fft_doppler_valid <= 0;
            fft_doppler_last  <= 0;

            case (state)
                RESET: begin
                    if (fft_data_valid) begin
                        state      <= FILL_FIRST;
                        wr_counter <= 0;
                    end
                end

                FILL_FIRST: begin
                    if (fft_data_valid) begin
                        bram_addra <= wr_counter;
                        bram_dina  <= fft_data_in;
                        bram_wea   <= 1;
                        bram_ena   <= 1;

                        wr_counter <= wr_counter + 1;

                        if (wr_counter == 32767) begin
                            wr_counter        <= 0;
                            active_write_buf  <= 1;
                            active_read_buf   <= 0;
                            state             <= ACTIVE;
                            col               <= 0;
                            row               <= 0;
                        end
                    end else begin
                        bram_wea <= 0;
                        bram_ena <= 0;
                    end
                end

                ACTIVE: begin
                    // ---------------- Write Logic ----------------
                    if (fft_data_valid) begin
                        wr_counter <= wr_counter + 1;
                        if (active_write_buf == 0) begin
                            bram_addra <= wr_counter;
                            bram_dina  <= fft_data_in;
                            bram_wea   <= 1;
                            bram_ena   <= 1;
                            bram_web   <= 0;
                            bram_enb   <= 0;
                        end else begin
                            bram_addrb <= wr_counter;
                            bram_dinb  <= fft_data_in;
                            bram_web   <= 1;
                            bram_enb   <= 1;
                            bram_wea   <= 0;
                            bram_ena   <= 0;
                        end

                        if (wr_counter == 32767) begin
                            wr_counter       <= 0;
                            active_write_buf <= ~active_write_buf;
                            active_read_buf  <= ~active_read_buf;
                            col              <= 0;
                            row              <= 0;
                        end
                    end else begin
                        bram_wea <= 0; bram_web <= 0;
                        bram_ena <= 0; bram_enb <= 0;
                    end

                    // ---------------- Read Logic ----------------
                    fft_doppler_valid <= 1;
                    fft_doppler_last  <= (row == 8'd255);  // <-- tlast when row = 255

                    if (active_read_buf == 0) begin
                        bram_addra <= col + row * 128;
                        bram_ena   <= 1;
                        fft_doppler_input <= bram_douta;
                    end else begin
                        bram_addrb <= col + row * 128;
                        bram_enb   <= 1;
                        fft_doppler_input <= bram_doutb;
                    end

                    if (row == 8'd255 && col == 7'd127) begin
                        row <= 0;
                        col <= 0;
                        fft_doppler_valid <= 0;
                        fft_doppler_last  <= 0;
                    end else if (row == 8'd255) begin
                        row <= 0;
                        col <= col + 1;
                    end else begin
                        row <= row + 1;
                    end
                end
            endcase
        end
    end

endmodule
