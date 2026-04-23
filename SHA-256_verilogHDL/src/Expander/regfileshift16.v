module regfileshift16(OW, Osig0, Osig1, OCSkA1, OCSkA2, I, CLK);
  input [31:0] I;
  input CLK;
  output [31:0] OW, Osig0, Osig1, OCSkA1, OCSkA2;
  
  wire [31:0] oR0, oR1, oR2, oR3, oR4, oR5, oR6, oR7, oR8, oR9, oR10, oR11, oR12, oR13, oR14, oR15;
  
  reg32bit R0(oR0, I, CLK);
  reg32bit R1(oR1, oR0, CLK);
  reg32bit R2(oR2, oR1, CLK);
  reg32bit R3(oR3, oR2, CLK);
  reg32bit R4(oR4, oR3, CLK);
  reg32bit R5(oR5, oR4, CLK);
  reg32bit R6(oR6, oR5, CLK);
  reg32bit R7(oR7, oR6, CLK);
  reg32bit R8(oR8, oR7, CLK);
  reg32bit R9(oR9, oR8, CLK);
  reg32bit R10(oR10, oR9, CLK);
  reg32bit R11(oR11, oR10, CLK);
  reg32bit R12(oR12, oR11, CLK);
  reg32bit R13(oR13, oR12, CLK);
  reg32bit R14(oR14, oR13, CLK);
  reg32bit R15(oR15, oR14, CLK);
  
  assign OW = oR0;
  assign Osig1 = oR0;
  assign Osig0 = oR13;
  assign OCSkA1 = oR5;
  assign OCSkA2 = oR14;
endmodule