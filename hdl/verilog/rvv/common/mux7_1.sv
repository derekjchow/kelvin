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
      3'd0: begin 
        outdata = indata0;
      end
      3'd1: begin 
        outdata = indata1;
      end
      3'd2: begin
        outdata = indata2;
      end
      3'd3: begin
        outdata = indata3;
      end
      3'd4: begin
        outdata = indata4;
      end
      3'd5: begin
        outdata = indata5;
      end
      3'd6: begin
        outdata = indata6;
      end
      default: begin
        outdata = 'b0;
      end
    endcase
  end

endmodule
