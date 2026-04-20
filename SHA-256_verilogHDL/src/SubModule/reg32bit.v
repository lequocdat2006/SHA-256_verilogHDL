module reg32bit(O, I, CLK);
  input [31:0] I;
  input CLK;
  output reg [31:0] O;
  
  always @(posedge CLK) begin
    O = I;
  end
endmodule