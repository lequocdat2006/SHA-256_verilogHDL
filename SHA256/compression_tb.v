module tb_compression;

reg  [31:0] A, B, C, D, E, F, G, H, Kt, Wt;
wire [31:0] A_next, B_next, C_next, D_next, E_next, F_next, G_next, H_next;
wire [31:0] sig0_out, sig1_out, maj_out, ch_out, Sum1, Sum2, Sum3, U_t, V_t, T1, T2;

compression dut (
    .A(A), .B(B), .C(C), .D(D),
    .E(E), .F(F), .G(G), .H(H),
    .Kt(Kt), .Wt(Wt),
    .A_next(A_next), .B_next(B_next), .C_next(C_next), .D_next(D_next),
    .E_next(E_next), .F_next(F_next), .G_next(G_next), .H_next(H_next),
    .sig0_out(sig0_out), .sig1_out(sig1_out), .maj_out(maj_out), .ch_out(ch_out),
    .Sum1(Sum1), .Sum2(Sum2), .Sum3(Sum3), .U_t(U_t), .V_t(V_t), .T1(T1), .T2(T2)
);

function [31:0] ROTR;
    input [31:0] x;
    input integer n;
    begin
        ROTR = (x >> n) | (x << (32 - n));
    end
endfunction

function [31:0] SIG0_REF;
    input [31:0] x;
    begin
        SIG0_REF = ROTR(x,2) ^ ROTR(x,13) ^ ROTR(x,22);
    end
endfunction

function [31:0] SIG1_REF;
    input [31:0] x;
    begin
        SIG1_REF = ROTR(x,6) ^ ROTR(x,11) ^ ROTR(x,25);
    end
endfunction

function [31:0] CH_REF;
    input [31:0] x, y, z;
    begin
        CH_REF = (x & y) ^ (~x & z);
    end
endfunction

function [31:0] MAJ_REF;
    input [31:0] x, y, z;
    begin
        MAJ_REF = (x & y) ^ (x & z) ^ (y & z);
    end
endfunction

reg [31:0] ref_T1, ref_T2;

initial begin
    A  = 32'h6a09e667;
    B  = 32'hbb67ae85;
    C  = 32'h3c6ef372;
    D  = 32'ha54ff53a;
    E  = 32'h510e527f;
    F  = 32'h9b05688c;
    G  = 32'h1f83d9ab;
    H  = 32'h5be0cd19;
    Kt = 32'h428a2f98;
    Wt = 32'h61626380;

    #1;

    ref_T1 = H + SIG1_REF(E) + CH_REF(E,F,G) + Kt + Wt;
    ref_T2 = SIG0_REF(A) + MAJ_REF(A,B,C);

    if (T1 !== ref_T1) $fatal(1, "T1 sai");
    if (T2 !== ref_T2) $fatal(1, "T2 sai");
    if (A_next !== (ref_T1 + ref_T2)) $fatal(1, "A_next sai");
    if (E_next !== (D + ref_T1)) $fatal(1, "E_next sai");
    if (B_next !== A) $fatal(1, "B_next sai");
    if (C_next !== B) $fatal(1, "C_next sai");
    if (D_next !== C) $fatal(1, "D_next sai");
    if (F_next !== E) $fatal(1, "F_next sai");
    if (G_next !== F) $fatal(1, "G_next sai");
    if (H_next !== G) $fatal(1, "H_next sai");

    $display("compression round OK");
    $finish;
end

endmodule
