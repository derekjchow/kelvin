// several mux

module mux7_1
(
  sel,
  indata0,
  indata1,
  indata2,
  indata3,
  indata4,
  indata5,
  indata6,
  outdata 
);
  parameter WIDTH = 1;
  
  input  logic [2:0]         sel;
  input  logic [WIDTH-1:0]   indata0;
  input  logic [WIDTH-1:0]   indata1;
  input  logic [WIDTH-1:0]   indata2;
  input  logic [WIDTH-1:0]   indata3;
  input  logic [WIDTH-1:0]   indata4;
  input  logic [WIDTH-1:0]   indata5;
  input  logic [WIDTH-1:0]   indata6;
  output logic [WIDTH-1:0]   outdata;
  

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
      default: 
        outdata = 'b0;
    endcase
  end
endmodule

module mux5_1
(
  sel,
  indata0,
  indata1,
  indata2,
  indata3,
  indata4,
  outdata 
);
  parameter WIDTH = 1;
  
  input  logic [2:0]         sel;
  input  logic [WIDTH-1:0]   indata0;
  input  logic [WIDTH-1:0]   indata1;
  input  logic [WIDTH-1:0]   indata2;
  input  logic [WIDTH-1:0]   indata3;
  input  logic [WIDTH-1:0]   indata4;
  output logic [WIDTH-1:0]   outdata;
  

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
      default: 
        outdata = 'b0;
    endcase
  end
endmodule
