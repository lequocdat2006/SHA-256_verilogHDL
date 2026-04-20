module regfileshift16(OW, Osig0, Osig1, OCSkA1, OCSkA2, I, CLK);
  input [31:0] I;
  input CLK;
  output [31:0] OW, Osig0, Osig1, OCSkA1, OCSkA2;
  
  reg [31:0] R [0:15];
  
  always @(posedge CLK) begin
    R[0] = I;
    R[1] = R[0];
    R[2] = R[1];
    R[3] = R[2];
    R[4] = R[3];
    R[5] = R[4];
    R[6] = R[5];
    R[7] = R[6];
    R[8] = R[7];
    R[9] = R[8];
    R[10] = R[9];
    R[11] = R[10];
    R[12] = R[11];
    R[13] = R[12];
    R[14] = R[13];
    R[15] = R[14];
  end
  
  assign OW = R[0];
  assign Osig1 = R[0];
  assign Osig0 = R[13];
  assign OCSkA1 = R[5];
  assign OCSkA2 = R[14];
endmodule
    