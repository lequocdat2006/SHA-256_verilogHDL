module sig0(O, I);
  input [31:0] I;
  output [31:0] O;
  
  assign O = {I[6:0], I[31:7]} ^ {I[17:0], I[31:18]} ^ {3'b0, I[31:3]};
endmodule