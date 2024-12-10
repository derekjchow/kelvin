// a mux with 8 inputs and 1 output

module mux8_1
(
  sel,
  indata0,
  indata1,
  indata2,
  indata3,
  indata4,
  indata5,
  indata6,
  indata7,
  outdata 
);

  parameter             WIDTH = 1;
  
  input   [2:0]         sel;
  input   [WIDTH-1:0]   indata0;
  input   [WIDTH-1:0]   indata1;
  input   [WIDTH-1:0]   indata2;
  input   [WIDTH-1:0]   indata3;
  input   [WIDTH-1:0]   indata4;
  input   [WIDTH-1:0]   indata5;
  input   [WIDTH-1:0]   indata6;
  input   [WIDTH-1:0]   indata7;
  output  [WIDTH-1:0]   outdata;

  always_comb begin
    case(sel)
      3'd0: 
        outdata = indata0;
      3'd1: 
        outdata = indata1;
      3'd2: 
        outdata = indata2;
      3'd3: 
        outdata = indata3;
      3'd4: 
        outdata = indata4;
      3'd5: 
        outdata = indata5;
      3'd6: 
        outdata = indata6;
      3'd7: 
        outdata = indata7;
      default: 
        outdata = 'b0;
    endcase
  end

endmodule
