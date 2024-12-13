//
// Template for Top module
//

`ifndef RVV_FIFO_TOP__SV
`define RVV_FIFO_TOP__SV

   `include "rvv_fifo_param.sv"
   `include "mstr_slv_intfs.incl"
   `include "rvv_fifo_tb_mod.sv"
module rvv_fifo_top();

   logic clk;
   logic rst_n;

   // Clock Generation
   parameter sim_cycle = 10;
   
   // Reset Delay Parameter
   parameter rst_delay = 50;

   always 
      begin
         #(sim_cycle/2) clk = ~clk;
      end

      push_interface mst_if();
      pop_interface slv_if();
   
   rvv_fifo_tb_mod test(); 

   //clk
   assign mst_if.clk = clk;
   assign mst_if.rst_n = rst_n;
   assign slv_if.rst_n = rst_n;
   assign slv_if.clk = clk;
   
   // ToDo: Include Dut instance here
   `ifdef FIFO_2W2R
      fifo_flopped_2w2r #(.DWIDTH(DWIDTH), .DEPTH(DEPTH)) fifo(
         .outData0            (slv_if.pop_data0),
         .outData1            (slv_if.pop_data1),
         .fifo_full           (mst_if.full),
         .fifo_1left_to_full  (mst_if.almost_full),
         .fifo_empty          (slv_if.empty),
         .fifo_1left_to_empty (slv_if.almost_empty),
         .fifo_idle           (slv_if.idle),
         .inData0             (mst_if.push_data0),
         .inData1             (mst_if.push_data1),
         .push0               (mst_if.push0),
         .push1               (mst_if.push1),
         .pop0                (slv_if.pop0),
         .pop1                (slv_if.pop1),
         .clk                 (clk),
         .rst_n               (rst_n)
      );
      assign mst_if.almost_full2 = 1'b0;
      assign mst_if.almost_full3 = 1'b0;
   `elsif FIFO_4W2R
      fifo_flopped_4w2r #(.DWIDTH(DWIDTH), .DEPTH(DEPTH)) fifo(
         .outData0            (slv_if.pop_data0),
         .outData1            (slv_if.pop_data1),
         .fifo_full           (mst_if.full),
         .fifo_1left_to_full  (mst_if.almost_full),
         .fifo_2left_to_full  (mst_if.almost_full2),
         .fifo_3left_to_full  (mst_if.almost_full3),
         .fifo_empty          (slv_if.empty),
         .fifo_1left_to_empty (slv_if.almost_empty),
         .fifo_idle           (slv_if.idle),
         .inData0             (mst_if.push_data0),
         .inData1             (mst_if.push_data1),
         .inData2             (mst_if.push_data2),
         .inData3             (mst_if.push_data3),
         .push0               (mst_if.push0),
         .push1               (mst_if.push1),
         .push2               (mst_if.push2),
         .push3               (mst_if.push3),
         .pop0                (slv_if.pop0),
         .pop1                (slv_if.pop1),
         .clk                 (clk),
         .rst_n               (rst_n)
      );
   `else
      fifo_flopped #(.DWIDTH(DWIDTH), .DEPTH(DEPTH), .HALF_FULL(HALF_FULL)) fifo(
         .fifo_outData  (slv_if.pop_data),
         .fifo_full     (mst_if.full),
         .fifo_empty    (slv_if.empty),
         .fifo_idle     (slv_if.idle),
         .fifo_inData   (mst_if.push_data),
         .single_push   (mst_if.push),
         .single_pop    (slv_if.pop),
         .clk           (clk),
         .rst_n         (rst_n)
      );
      assign mst_if.almost_full = 1'b0;
      assign mst_if.almost_full2 = 1'b0;
      assign mst_if.almost_full3 = 1'b0;
   `endif
  
   //Driver reset depending on rst_delay
   initial
      begin
         clk = 0;
         rst_n = 1;
      #1 rst_n = 0;
         repeat (rst_delay) @(clk);
         rst_n = 1'b1;
         @(clk);
   end

   initial begin
      if($test$plusargs("dump"))begin
         $display("dump all var");
         $fsdbDumpfile("verilog.fsdb");
         $fsdbDumpMDA();             // dump memory files
         $fsdbDumpvars("+functions","+mda","+packedmda","+trace_process");            // to be able to see things inside a task or function
		  $fsdbDumpSVA();
         $fsdbDumpvars("+all");
      end
   end
endmodule: rvv_fifo_top

`endif // RVV_FIFO_TOP__SV
