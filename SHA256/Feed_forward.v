module sha256_feedforward (
    input  wire [31:0] H0_old,
    input  wire [31:0] H1_old,
    input  wire [31:0] H2_old,
    input  wire [31:0] H3_old,
    input  wire [31:0] H4_old,
    input  wire [31:0] H5_old,
    input  wire [31:0] H6_old,
    input  wire [31:0] H7_old,
    input  wire [31:0] A_final,
    input  wire [31:0] B_final,
    input  wire [31:0] C_final,
    input  wire [31:0] D_final,
    input  wire [31:0] E_final,
    input  wire [31:0] F_final,
    input  wire [31:0] G_final,
    input  wire [31:0] H_final,
    output wire [31:0] H0_new,
    output wire [31:0] H1_new,
    output wire [31:0] H2_new,
    output wire [31:0] H3_new,
    output wire [31:0] H4_new,
    output wire [31:0] H5_new,
    output wire [31:0] H6_new,
    output wire [31:0] H7_new
);

    assign H0_new = H0_old + A_final;
    assign H1_new = H1_old + B_final;
    assign H2_new = H2_old + C_final;
    assign H3_new = H3_old + D_final;
    assign H4_new = H4_old + E_final;
    assign H5_new = H5_old + F_final;
    assign H6_new = H6_old + G_final;
    assign H7_new = H7_old + H_final;

endmodule
