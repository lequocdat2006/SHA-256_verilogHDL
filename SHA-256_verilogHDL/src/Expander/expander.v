module expander(W, M, Sel, CLK);
  input [31:0] M;
  input Sel, CLK;
  output [31:0] W;
  
  wire [31:0] oR1, sum, osig0, osig1, oCSkA1, oCSkA2, oCSkA3, oCSkA4, sum1, sum2;
  
  mux2to132bit muxexpander(oR1, M, sum, Sel);
  regfileshift16 regfileexpander(W, osig0, osig1, oCSkA1, oCSkA2, oR1, CLK);
  sig0 s0(oCSkA3, osig0);
  sig1 s1(oCSkA4, osig1);
  cska adder12(sum1, oCSkA1, oCSkA2, 1'b0);
  reg32bit Reg1(oCSkA5, sum1, CLK);
  cska adder34(sum2, oCSkA3, oCSkA4, 1'b0);
  reg32bit Reg2(oCSkA6, sum2, CLK);
  cska adder3(sum, oCSkA5, oCSkA6, 1'b0);
endmodule
  