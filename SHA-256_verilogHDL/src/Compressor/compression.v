module compression (
    input  [31:0] A,
    input  [31:0] B,
    input  [31:0] C,
    input  [31:0] D,
    input  [31:0] E,
    input  [31:0] F,
    input  [31:0] G,
    input  [31:0] H,
    input  [31:0] Kt,
    input  [31:0] Wt,
    output [31:0] A_next,
    output [31:0] B_next,
    output [31:0] C_next,
    output [31:0] D_next,
    output [31:0] E_next,
    output [31:0] F_next,
    output [31:0] G_next,
    output [31:0] H_next,
    output [31:0] sig0_out,
    output [31:0] sig1_out,
    output [31:0] maj_out,
    output [31:0] ch_out,
    output [31:0] Sum1,
    output [31:0] Sum2,
    output [31:0] Sum3,
    output [31:0] U_t,
    output [31:0] V_t,
    output [31:0] T1,
    output [31:0] T2
);

wire [31:0] m1_out;
wire [31:0] m2_out;
wire [31:0] m3_out;
wire [31:0] sum_h_sig1;
wire [31:0] sum_ch_kt;
wire [31:0] sum_u_w;
wire [31:0] sum_d_t1;

Sig0 u_sig0 (
    .A(A),
    .out_sig0(sig0_out)
);

Sig1 u_sig1 (
    .A(E),
    .out_sig1(sig1_out)
);

Maj u_maj (
    .A(A),
    .B(B),
    .C(C),
    .out_maj(maj_out)
);

Ch u_ch (
    .E(E),
    .F(F),
    .G(G),
    .out_ch(ch_out)
);

/*
 * The paper figure does not expose the control of M1/M2/M3.
 * Here they are modeled as fixed routing points to keep the
 * datapath close to the block diagram while preserving the
 * standard SHA-256 round equations.
 */
M1 u_m1 (
    .A(H),
    .B(sig1_out),
    .sel(1'b1),
    .out_m1(m1_out)
);

M2 u_m2 (
    .A(ch_out),
    .B(Kt),
    .sel(1'b1),
    .out_m2(m2_out)
);

CSkA u_add_sum1 (
    .A(m1_out),
    .B(sig1_out),
    .SUM(sum_h_sig1)
);

CSkA u_add_sum2 (
    .A(m2_out),
    .B(Kt),
    .SUM(sum_ch_kt)
);

assign Sum1 = sum_h_sig1;
assign Sum2 = sum_ch_kt;

M3 u_m3 (
    .A(Sum1),
    .B(Sum2),
    .sel(1'b1),
    .out_m3(m3_out)
);

CSkA u_add_u (
    .A(m3_out),
    .B(Sum2),
    .SUM(U_t)
);

CSkA u_add_t1 (
    .A(U_t),
    .B(Wt),
    .SUM(sum_u_w)
);

assign T1 = sum_u_w;
assign V_t = T1;

CSkA u_add_t2 (
    .A(sig0_out),
    .B(maj_out),
    .SUM(T2)
);

CSkA u_add_a_next (
    .A(T1),
    .B(T2),
    .SUM(Sum3)
);

assign A_next = Sum3;

CSkA u_add_e_next (
    .A(D),
    .B(T1),
    .SUM(sum_d_t1)
);

assign E_next = sum_d_t1;

assign B_next = A;
assign C_next = B;
assign D_next = C;
assign F_next = E;
assign G_next = F;
assign H_next = G;

endmodule


module CSkA (
    input  [31:0] A,
    input  [31:0] B,
    output [31:0] SUM
);

assign SUM = A + B;

endmodule


module Sig0 (
    input  [31:0] A,
    output [31:0] out_sig0
);

wire [31:0] rotr2;
wire [31:0] rotr13;
wire [31:0] rotr22;

assign rotr2  = (A >> 2)  | (A << (32 - 2));
assign rotr13 = (A >> 13) | (A << (32 - 13));
assign rotr22 = (A >> 22) | (A << (32 - 22));

assign out_sig0 = rotr2 ^ rotr13 ^ rotr22;

endmodule


module Sig1 (
    input  [31:0] A,
    output [31:0] out_sig1
);

wire [31:0] rotr6;
wire [31:0] rotr11;
wire [31:0] rotr25;

assign rotr6  = (A >> 6)  | (A << (32 - 6));
assign rotr11 = (A >> 11) | (A << (32 - 11));
assign rotr25 = (A >> 25) | (A << (32 - 25));

assign out_sig1 = rotr6 ^ rotr11 ^ rotr25;

endmodule


module Maj (
    input  [31:0] A,
    input  [31:0] B,
    input  [31:0] C,
    output [31:0] out_maj
);

assign out_maj = (A & B) ^ (A & C) ^ (B & C);

endmodule


module Ch (
    input  [31:0] E,
    input  [31:0] F,
    input  [31:0] G,
    output [31:0] out_ch
);

assign out_ch = (E & F) ^ (~E & G);

endmodule


module M1 (
    input  [31:0] A,
    input  [31:0] B,
    input         sel,
    output [31:0] out_m1
);

assign out_m1 = sel ? A : B;

endmodule


module M2 (
    input  [31:0] A,
    input  [31:0] B,
    input         sel,
    output [31:0] out_m2
);

assign out_m2 = sel ? A : B;

endmodule


module M3 (
    input  [31:0] A,
    input  [31:0] B,
    input         sel,
    output [31:0] out_m3
);

assign out_m3 = sel ? A : B;

endmodule