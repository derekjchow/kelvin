// description: 
// This is the top module of MUL/MAC wrapper
// Contains instantiation of MUL_ex and MAC_ex
// Contains ex arbiter
//
// feature list:
// 1. Instantiation of MUL ex and MAC ex
// 2. Arbitration to uop0/1 to use MUL or MAC
// 3. Pop MUL_RS 


`include "rvv_backend.svh"
`include "rvv_backend_sva.svh"

module rvv_backend_mulmac (
  //Outputs
  ex2rob_valid, ex2rob_data, rs2ex_fifo_pop,
  //Inputs
  clk, rst_n, rs2ex_uop_data, 
  rs2ex_fifo_empty, rs2ex_fifo_1left_to_empty, 
  ex2rob_ready
);

//global signals
input             clk;
input             rst_n;

//MUL_RS to MUL_EX 
input MUL_RS_t [`NUM_MUL-1:0] rs2ex_uop_data;
input logic                   rs2ex_fifo_empty;
input logic                   rs2ex_fifo_1left_to_empty;
output logic [`NUM_MUL-1:0]   rs2ex_fifo_pop;

//MUL_EX to ROB
output  logic       [`NUM_ALU-1:0] ex2rob_valid;
output  PU2ROB_t    [`NUM_ALU-1:0] ex2rob_data;
input   logic       [`NUM_ALU-1:0] ex2rob_ready;

// Wires & Regs
logic [`FUNCT6_WIDTH-1:0] rs2ex_uop_funct6[`NUM_MUL-1:0];
logic [`NUM_MUL-1:0]      rs2ex_uop_valid;
logic                     uop0_is_mac;
logic                     uop1_is_mac;

logic [`NUM_MUL-1:0]      rs2ex_uop_ready;

logic                     rs2mul_uop_valid;
MUL_RS_t                  rs2mul_uop_data;
logic                     rs2mul_uop_ready;
logic                     rs2mac_uop_valid;
MUL_RS_t                  rs2mac_uop_data;
logic                     rs2mac_uop_ready;

logic                     mul2rob_uop_valid;
PU2ROB_t                  mul2rob_uop_data;
logic                     mac2rob_uop_valid;
PU2ROB_t                  mac2rob_uop_data;

//Decode funct6
assign rs2ex_uop_funct6[0] = rs2ex_uop_data[0].uop_funct6.ari_funct6;
assign rs2ex_uop_funct6[1] = rs2ex_uop_data[1].uop_funct6.ari_funct6;

//Generate uop valid
// empty        0  |  0  |  1  |  1
// 1left2empty  0  |  1  |  0  |  1
// dataLeft     >1 |  1  | N/A |  0
assign rs2ex_uop_valid[0] = !rs2ex_fifo_empty;
assign rs2ex_uop_valid[1] = !(rs2ex_fifo_empty || rs2ex_fifo_1left_to_empty);

//Identify if uop0 it is vmac
//Only check funct6, since no-mul inst cannot be pushed into MUL RS
always@(*) begin
  uop0_is_mac = 1'b0;
  case ({rs2ex_uop_valid[0],rs2ex_uop_funct6[0]}) 
    {1'b1,VMACC},{1'b1,VNMSAC},{1'b1,VMADD},{1'b1,VNMSUB},
    {1'b1,VWMACCU},{1'b1,VWMACC},{1'b1,VWMACCSU},{1'b1,VWMACCUS} : begin
      uop0_is_mac = 1'b1;
    end
    default : begin
      uop0_is_mac = 1'b0;
    end
  endcase
end//end always
      
//Identify if uop1 it is vmac
//Only check funct6, since no-mul inst cannot be pushed into MUL RS
always@(*) begin
  uop1_is_mac = 1'b0;
  case ({rs2ex_uop_valid[1],rs2ex_uop_funct6[1]}) 
    {1'b1,VMACC},{1'b1,VNMSAC},{1'b1,VMADD},{1'b1,VNMSUB},
    {1'b1,VWMACCU},{1'b1,VWMACC},{1'b1,VWMACCSU},{1'b1,VWMACCUS} : begin
      uop1_is_mac = 1'b1;
    end
    default : begin
      uop1_is_mac = 1'b0;
    end
  endcase
end//end always

//Arbiter of using MAC or MUL
//uop0 | mul | mul | mac | mac
//uop1 | mul | mac | mul | mac
//Ex   |     |     |     | stalluop1
always@(*) begin
  case ({uop1_is_mac,uop0_is_mac})
  2'b00 : begin
    rs2mul_uop_valid = rs2ex_uop_valid[0];
    rs2mul_uop_data = rs2ex_uop_data[0];
    rs2ex_uop_ready[0] = rs2mul_uop_ready;
    rs2mac_uop_valid = rs2ex_uop_valid[1];
    rs2mac_uop_data = rs2ex_uop_data[1];
    rs2ex_uop_ready[1] = rs2mac_uop_ready;
  end
  2'b01 : begin
    rs2mul_uop_valid = rs2ex_uop_valid[1];
    rs2mul_uop_data = rs2ex_uop_data[1];
    rs2ex_uop_ready[1] = rs2mul_uop_ready;
    rs2mac_uop_valid = rs2ex_uop_valid[0];
    rs2mac_uop_data = rs2ex_uop_data[0];
    rs2ex_uop_ready[0] = rs2mac_uop_ready;
  end
  2'b10 : begin
    rs2mul_uop_valid = rs2ex_uop_valid[0];
    rs2mul_uop_data = rs2ex_uop_data[0];
    rs2ex_uop_ready[0] = rs2mul_uop_ready;
    rs2mac_uop_valid = rs2ex_uop_valid[1];
    rs2mac_uop_data = rs2ex_uop_data[1];
    rs2ex_uop_ready[1] = rs2mac_uop_ready;
  end
  2'b11 : begin
    rs2mul_uop_valid = 1'b0;
    rs2mul_uop_data = 'b0;
    rs2ex_uop_ready[1] = 1'b0;
    rs2mac_uop_valid = rs2ex_uop_valid[0];
    rs2mac_uop_data = rs2ex_uop_data[0];
    rs2ex_uop_ready[0] = rs2mac_uop_ready;
  end
  default : begin
    rs2mul_uop_valid = rs2ex_uop_valid[0];
    rs2mul_uop_data = rs2ex_uop_data[0];
    rs2ex_uop_ready[0] = rs2mul_uop_ready;
    rs2mac_uop_valid = rs2ex_uop_valid[1];
    rs2mac_uop_data = rs2ex_uop_data[1];
    rs2ex_uop_ready[1] = rs2mac_uop_ready;
  end
  endcase
end

// Inst of MUL-ex and MAC-ex
//MUL
rvv_backend_mul_unit u_mul (
  // Outputs
  .mul2rob_uop_valid(mul2rob_uop_valid),
  .mul2rob_uop_data(mul2rob_uop_data),
  // Inputs
  .clk(clk), 
  .rst_n(rst_n), 
  .rs2mul_uop_valid(rs2mul_uop_valid), 
  .rs2mul_uop_data(rs2mul_uop_data));

//MAC
rvv_backend_mac_unit u_mac (
  // Outputs
  .mac2rob_uop_valid(mac2rob_uop_valid),
  .mac2rob_uop_data(mac2rob_uop_data),
  // Inputs
  .clk(clk), 
  .rst_n(rst_n), 
  .rs2mac_uop_valid(rs2mac_uop_valid), 
  .rs2mac_uop_data(rs2mac_uop_data));

// Pop RS fifo generation
assign rs2ex_fifo_pop[0] = rs2ex_uop_valid[0] && rs2ex_uop_ready[0];
assign rs2ex_fifo_pop[1] = rs2ex_uop_valid[1] && rs2ex_uop_ready[1] && rs2ex_fifo_pop[0];//forbid pop1=1 while pop0=0

//Pack output to ROB
//high pack MAC; low pack MUL
assign ex2rob_valid[0] = mul2rob_uop_valid; 
assign ex2rob_data[0] = mul2rob_uop_data;
assign rs2mul_uop_ready = !mul2rob_uop_valid | ex2rob_ready[0];

assign ex2rob_valid[1] = mac2rob_uop_valid;
assign ex2rob_data[1] = mac2rob_uop_data;
assign rs2mac_uop_ready = !mac2rob_uop_valid | ex2rob_ready[1];

endmodule
