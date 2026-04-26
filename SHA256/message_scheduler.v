module message_scheduler (
    input  wire         clk,
    input  wire         rst_n,
    input  wire         load,
    input  wire         advance,
    input  wire [511:0] in_block,
    output reg  [31:0]  Wt
);

    reg [31:0] w [0:15];
    reg [5:0]  t;
    integer k;

    wire [31:0] s0;
    wire [31:0] s1;
    wire [31:0] w_new;

    sigma0 u_sigma0 (
        .in0(w[1]),
        .out0(s0)
    );

    sigma1 u_sigma1 (
        .in1(w[14]),
        .out1(s1)
    );

    assign w_new = s1 + w[9] + s0 + w[0];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            t  <= 6'd0;
            Wt <= 32'd0;
            for (k = 0; k < 16; k = k + 1) begin
                w[k] <= 32'd0;
            end
        end else if (load) begin
            w[0]  <= in_block[511:480];
            w[1]  <= in_block[479:448];
            w[2]  <= in_block[447:416];
            w[3]  <= in_block[415:384];
            w[4]  <= in_block[383:352];
            w[5]  <= in_block[351:320];
            w[6]  <= in_block[319:288];
            w[7]  <= in_block[287:256];
            w[8]  <= in_block[255:224];
            w[9]  <= in_block[223:192];
            w[10] <= in_block[191:160];
            w[11] <= in_block[159:128];
            w[12] <= in_block[127:96];
            w[13] <= in_block[95:64];
            w[14] <= in_block[63:32];
            w[15] <= in_block[31:0];
            t     <= 6'd0;
            Wt    <= in_block[511:480]; // W0
        end else if (advance) begin
            if (t < 6'd15) begin
                t  <= t + 6'd1;
                Wt <= w[t + 6'd1];
            end else if (t < 6'd63) begin
                w[0]  <= w[1];
                w[1]  <= w[2];
                w[2]  <= w[3];
                w[3]  <= w[4];
                w[4]  <= w[5];
                w[5]  <= w[6];
                w[6]  <= w[7];
                w[7]  <= w[8];
                w[8]  <= w[9];
                w[9]  <= w[10];
                w[10] <= w[11];
                w[11] <= w[12];
                w[12] <= w[13];
                w[13] <= w[14];
                w[14] <= w[15];
                w[15] <= w_new;
                t     <= t + 6'd1;
                Wt    <= w_new;
            end
        end
    end

endmodule


module sigma0 (
    input [31:0] in0,
    output [31:0] out0
);

wire [31:0] rotr7 = (in0 >> 7) | (in0 << (32 - 7));
wire [31:0] rotr18 = (in0 >> 18) | (in0 << (32 - 18));
wire [31:0] shr3 = (in0 >> 3);

assign out0 = rotr7 ^ rotr18 ^ shr3;  //σ0(x) = ROTR7(x) ^ ROTR18(x) ^ SHR3(x)
endmodule 


module sigma1(
    input [31:0] in1,
    output [31:0] out1
);

wire [31:0] rotr17 = (in1 >> 17) | (in1 << (32 - 17));
wire [31:0] rotr19 = (in1 >> 19) | (in1 << (32 - 19));
wire [31:0] shr10 = in1 >> 10;

assign out1 = rotr17 ^ rotr19 ^ shr10; //σ1(x) = ROTR17(x) ^ ROTR19(x) ^ SHR10(x)

endmodule 