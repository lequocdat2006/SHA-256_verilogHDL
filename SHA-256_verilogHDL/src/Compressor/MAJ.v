module MAJ(OutMAJ, A, B, C);
  input [31:0] A, B, C;
  output [31:0] OutMAJ;
  
  assign OutMAJ = (A & B) ^ (~A & C);
endmodule