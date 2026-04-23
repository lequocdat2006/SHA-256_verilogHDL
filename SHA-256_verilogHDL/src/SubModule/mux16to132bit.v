module mux4to132bit(O, I0, I1, I2, I3, Sel);
  input [31:0] I0, I1, I2, I3;
  input [1:0] Sel;
  output [31:0] O;
  
  wire [31:0] Om0, Om1;
  
  mux2to132bit m0(Om0, I0, I1, Sel[0]);
  mux2to132bit m1(Om1, I2, I3, Sel[0]);
  mux2to132bit m2(O, Om0, Om1, Sel[1]);
endmodule

module mux8to132bit(O, I0, I1, I2, I3, I4, I5, I6, I7, Sel);
  input [31:0] I0, I1, I2, I3, I4, I5, I6, I7;
  input [2:0] Sel;
  output [31:0] O;
  
  wire [31:0] Om0, Om1;
  
  mux4to132bit m0(Om0, I0, I1, I2, I3, Sel[1:0]);
  mux4to132bit m1(Om1, I4, I5, I6, I7, Sel[1:0]);
  mux2to132bit m2(O, Om0, Om1, Sel[2]);
endmodule

module mux16to132bit(O, I0, I1, I2, I3, I4, I5, I6, I7, I8, I9, I10, I11, I12, I13, I14, I15, Sel);
  input [31:0] I0, I1, I2, I3, I4, I5, I6, I7, I8, I9, I10, I11, I12, I13, I14, I15;
  input [3:0] Sel;
  output [31:0] O;
  
  wire [31:0] Om0, Om1;
  
  mux8to132bit m0(Om0, I0, I1, I2, I3, I4, I5, I6, I7, Sel[2:0]);
  mux8to132bit m1(Om1, I8, I9, I10, I11, I12, I13, I14, I15, Sel[2:0]);
  mux2to132bit m2(O, Om0, Om1, Sel[3]);
endmodule