module SIG1(OutSIG1, E);
  input [31:0] E;
  output [31:0] OutSIG1;
  
  assign OutSIG1 = {E[5:0], E[31:6]} ^ {E[10:0], E[31:11]} ^ {E[24:0], E[31:25]};
endmodule
