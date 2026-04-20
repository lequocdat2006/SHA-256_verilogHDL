module sig1(O, I);
  input [31:0] I;
  output [31:0] O;
  
  assign O = {I[16:0], I[31:17]} ^ {I[18:0], I[31:19]} ^ {10'b0, I[31:10]};
endmodule