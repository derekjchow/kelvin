// A simple SRAM model, rewritten for BRAM inference
module Sram
    #(parameter int Width = 32,
      parameter int Depth = 1024)
    (input clk_i,
     input req_i,
     input we_i,
     input [$clog2(Depth) - 1 : 0] addr_i,
     input [Width - 1 : 0] wdata_i,
     input [Width / 8 - 1 : 0] wmask_i,
     output logic [Width - 1 : 0] rdata_o,
     output logic rvalid_o);

  logic [Width - 1 : 0] mem[Depth - 1 : 0];
  logic [$clog2(Depth) - 1 : 0] raddr;

  assign rdata_o = mem[raddr];

  always_ff @(posedge clk_i) begin
    if (req_i) begin
      if (we_i) begin
        for (int i = 0; i < Width / 8; i++) begin
          if (wmask_i[i]) begin
            mem[addr_i][i * 8 +: 8] <= wdata_i[i * 8 +: 8];
          end
        end
      end
      // The read address is registered to ensure a synchronous read.
      raddr <= addr_i;
    end
  end

  // The rvalid signal is simply a delayed version of req_i.
  always_ff @(posedge clk_i) begin
    rvalid_o <= req_i & ~we_i;
  end

  localparam MemInitFile = "";
`include "prim_util_memload.svh"
endmodule
