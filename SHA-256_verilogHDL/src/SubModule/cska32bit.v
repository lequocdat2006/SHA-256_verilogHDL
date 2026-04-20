module cska4bit(S, Co, A, B, Ci);
  input [3:0] A, B;
  input Ci;
  output [3:0] S;
  output Co;
  
  wire [3:0] P;
  wire [3:0] C;
  wire Skip_condition;
  
  assign P = A ^ B;
  assign Skip_condition = &P;
  
  fulladder FA0(S[0], C[0], A[0], B[0], Ci);
  fulladder FA1(S[1], C[1], A[1], B[1], C[0]);
  fulladder FA2(S[2], C[2], A[2], B[2], C[1]);
  fulladder FA3(S[3], C[3], A[3], B[3], C[2]);
  
  assign Co = (Skip_condition)? Ci : C[3];
endmodule

module cska32bit(Sum, A, B, Cin);
  input[31:0] A, B;
  input Cin;
  output [31:0] Sum;
  
  wire [7:0] C;
  
  cska4bit block0(Sum[3:0], C[0], A[3:0], B[3:0], Cin);
  cska4bit block1(Sum[7:4], C[1], A[7:4], B[7:4], C[0]);
  cska4bit block2(Sum[11:8], C[2], A[11:8], B[11:8], C[1]);
  cska4bit block3(Sum[15:12], C[3], A[15:12], B[15:12], C[2]);
  cska4bit block4(Sum[19:16], C[4], A[19:16], B[19:16], C[3]);
  cska4bit block5(Sum[23:20], C[5], A[23:20], B[23:20], C[4]);
  cska4bit block6(Sum[27:24], C[6], A[27:24], B[27:24], C[5]);
  cska4bit block7(Sum[31:28], C[7], A[31:28], B[31:28], C[6]);
endmodule