module sha256_top_fpga (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       in_valid,
    input  wire [7:0] in_data,
    input  wire       msg_start,
    input  wire       msg_end,
    output wire       in_ready,

    output wire [7:0] hash_data,
    output wire       hash_valid,
    output wire       hash_last,
    input  wire       hash_ready,

    output wire       done
);

    wire [31:0] H0;
    wire [31:0] H1;
    wire [31:0] H2;
    wire [31:0] H3;
    wire [31:0] H4;
    wire [31:0] H5;
    wire [31:0] H6;
    wire [31:0] H7;
    wire        core_done;

    reg  [255:0] digest_shift_reg;
    reg  [5:0]   digest_byte_cnt;
    reg          digest_streaming;

    sha256_top u_core (
        .clk(clk),
        .rst_n(rst_n),
        .in_valid(in_valid),
        .in_data(in_data),
        .msg_start(msg_start),
        .msg_end(msg_end),
        .in_ready(in_ready),
        .H0(H0),
        .H1(H1),
        .H2(H2),
        .H3(H3),
        .H4(H4),
        .H5(H5),
        .H6(H6),
        .H7(H7),
        .done(core_done)
    );

    assign hash_data  = digest_shift_reg[255:248];
    assign hash_valid = digest_streaming;
    assign hash_last  = digest_streaming && (digest_byte_cnt == 6'd31);
    assign done       = core_done;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            digest_shift_reg <= 256'd0;
            digest_byte_cnt  <= 6'd0;
            digest_streaming <= 1'b0;
        end else begin
            if (core_done) begin
                digest_shift_reg <= {H0, H1, H2, H3, H4, H5, H6, H7};
                digest_byte_cnt  <= 6'd0;
                digest_streaming <= 1'b1;
            end else if (digest_streaming && hash_ready) begin
                if (digest_byte_cnt == 6'd31) begin
                    digest_streaming <= 1'b0;
                end else begin
                    digest_shift_reg <= {digest_shift_reg[247:0], 8'h00};
                    digest_byte_cnt  <= digest_byte_cnt + 6'd1;
                end
            end
        end
    end

endmodule
