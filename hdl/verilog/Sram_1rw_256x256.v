module Sram_1rw_256x256(
  input          clock,
  input          valid,
  input          write,
  input  [7:0]   addr,
  input  [255:0] wdata,
  output [255:0] rdata
);

  reg [255:0] mem [0:255];
  reg [7:0] raddr;

  assign rdata = mem[raddr];

  always @(posedge clock) begin
    if (valid & write) begin
      mem[addr] <= wdata;
    end
    if (valid & ~write) begin
      raddr <= addr;
    end
  end
endmodule
