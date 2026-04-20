module mux2to132bit(O, I0, I1, Sel);
  input [31:0] I0, I1;
  input Sel;
  output [31:0] O;
  
  assign O = (Sel == 0)? I0 : I1;
endmodule
