module CH(OutCH, E, F, G);
  input [31:0] E, F, G;
  output [31:0] OutCH;
  
  assign OutCH = (E & F) ^ (E & G) ^ (F & G);
endmodule