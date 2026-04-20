module SIG0(OutSIG0, A);
  input [31:0] A;
  output [31:0] OutSIG0;
  
  assign OutSIG0 = {A[1:0], A[31:2]} ^ {A[12:0], A[31:13]} ^ {A[21:0], A[31:22]};
endmodule