module compression_round_core (
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire [31:0] C,
    input  wire [31:0] D,
    input  wire [31:0] E,
    input  wire [31:0] F,
    input  wire [31:0] G,
    input  wire [31:0] H,
    input  wire [31:0] Kt,
    input  wire [31:0] Wt,

    output wire [31:0] A_next,
    output wire [31:0] B_next,
    output wire [31:0] C_next,
    output wire [31:0] D_next,
    output wire [31:0] E_next,
    output wire [31:0] F_next,
    output wire [31:0] G_next,
    output wire [31:0] H_next,

    output wire [31:0] sig0_out,
    output wire [31:0] sig1_out,
    output wire [31:0] maj_out,
    output wire [31:0] ch_out,
    output wire [31:0] Sum1,
    output wire [31:0] Sum2,
    output wire [31:0] Sum3,
    output wire [31:0] U_t,
    output wire [31:0] V_t,
    output wire [31:0] T1,
    output wire [31:0] T2
);

    wire [31:0] rotr2_A;
    wire [31:0] rotr13_A;
    wire [31:0] rotr22_A;
    wire [31:0] rotr6_E;
    wire [31:0] rotr11_E;
    wire [31:0] rotr25_E;

    assign rotr2_A  = {A[1:0],  A[31:2]};
    assign rotr13_A = {A[12:0], A[31:13]};
    assign rotr22_A = {A[21:0], A[31:22]};

    assign rotr6_E  = {E[5:0],  E[31:6]};
    assign rotr11_E = {E[10:0], E[31:11]};
    assign rotr25_E = {E[24:0], E[31:25]};

    assign sig0_out = rotr2_A ^ rotr13_A ^ rotr22_A;                 // Σ0(A)
    assign sig1_out = rotr6_E ^ rotr11_E ^ rotr25_E;                 // Σ1(E)
    assign maj_out  = (A & B) ^ (A & C) ^ (B & C);                   // Maj(A,B,C)
    assign ch_out   = (E & F) ^ (~E & G);                            // Ch(E,F,G)

    assign Sum1 = H + sig1_out;                                      // H + Σ1(E)
    assign Sum2 = ch_out + Kt;                                       // Ch + Kt
    assign U_t  = Sum1 + Sum2;                                       // H + Σ1 + Ch + Kt
    assign T1   = U_t + Wt;                                          // H + Σ1 + Ch + Kt + Wt
    assign V_t  = T1;                                                // debug giữ nguyên tên cũ
    assign T2   = sig0_out + maj_out;                                // Σ0(A) + Maj(A,B,C)
    assign Sum3 = T1 + T2;                                           // A_next

    assign A_next = Sum3;
    assign B_next = A;
    assign C_next = B;
    assign D_next = C;
    assign E_next = D + T1;
    assign F_next = E;
    assign G_next = F;
    assign H_next = G;

endmodule

