// 
// description: 
// 1. It will get instruction from Command Queue and decode it to uops.
// 
// feature list:
// 1. One instruction can be decoded to 8 uops at most.
// 2. Decoder will push 4 uops at most into Uops Queue, so this module only decode to 4 uops at most every time.  
// 3. If the instruction is in wrong encoding, it will be discarded directly without applying a trap, but take assertion in simulation.
// 4. The vstart of the instruction will be calculated to a new value for every decoded uops.
// 5. vmv<nr>r.v instruction will be split to <nr> vmv.v.v uops, which means funct6 and some fields will be modified in new uop. 

`include 'rvv.svh'

module rvv_decode_unit
(
  insts_valid_cq2de,
  insts_cq2de,
  uop_index_remain,
  uop_valid_de2uq,
  uop_de2uq
)
//
// interface signals
//
  // CQ to Decoder unit signals
  input   logic                         insts_valid_cq2de;
  input   INST_t                        insts_cq2de;
  input   logic [`UOP_INDEX_WIDTH-1:0]  uop_index_remain;
  
  // Decoder unit to Uops Queue signals
  output  logic       [`NUM_DE_UOP-1:0] uop_valid_de2uq;
  output  UOP_QUEUE_t [`NUM_DE_UOP-1:0] uop_de2uq;

//
// internal signals
//
  logic   [`OPCODE_WIDTH-1:0]           insts_opcode;     // inst original encoding[6:0]
  logic   [`VTYPE_VILL_WIDTH-1:0]       vill;             // 0:not illegal, 1:illegal
  logic                                 valid_ari;
  logic                                 valid_lsu;

  // decoded arithmetic uops
  logic       [`NUM_DE_UOP-1:0]         uop_valid_ari;
  UOP_QUEUE_t [`NUM_DE_UOP-1:0]         uop_ari;

  // decoded LSU uops
  logic       [`NUM_DE_UOP-1:0]         uop_valid_lsu;
  UOP_QUEUE_t [`NUM_DE_UOP-1:0]         uop_lsu;

//
// decode
//
  assign insts_opcode = insts_cq2de.insts[1:0];
  assign vill         = insts_cq2de.vector_csr.vtype.vill;
 
  // decode opcode
  always_comb begin 
    // initial the data
    valid_lsu           = 'b0;
    valid_ari           = 'b0;

    case(insts_valid_cq2de,vill,insts_opcode)
      {1'b1,1'b0,OPCODE_LOAD},
      {1'b1,1'b0,OPCODE_STORE}: begin
        valid_lsu       = 1'b1;    
      end
    
      {1'b1,1'b0,OPCODE_ARI_CFG}: begin
        valid_ari      = 1'b1;
      end  

      default: begin
        `ifdef ASSERT_ON
        `rvv_forbid((insts_valid_cq2de==1'b1)&(vill==1'b1))
        else $error("Illegal vtype.vill=%d.\n",vill);
        
        `rvv_expect((insts_valid_cq2de==1'b0)&(vill==1'b0))
        else $error("Unsupported insts_opcode=%d.\n",insts_opcode);
        `endif
      end
    endcase
  end
  
  // decode LSU instruction 
  rvv_decode_unit_lsu u_lsu_decode
  (
    insts_valid       (valid_lsu),
    insts             (insts_cq2de),
    uop_index_remain  (uop_index_remain),
    uop_valid         (uop_valid_lsu),
    uop               (uop_lsu)
  );

  // decode arithmetic instruction
  rvv_decode_unit_ari u_ari_decode
  (
    insts_valid       (valid_ari),
    insts             (insts_cq2de),
    uop_index_remain  (uop_index_remain),
    uop_valid         (uop_valid_ari),
    uop               (uop_ari)
  );

  // output
  always_comb begin 
    uop_valid_de2uq     = 'b0;
    uop_de2uq           = 'b0;
    
    case(1'b1)
      valid_lsu: begin
        uop_valid_de2uq = uop_valid_lsu;
        uop_de2uq       = uop_lsu;
      end
  
      valid_ari: begin
        uop_valid_de2uq = uop_valid_ari;
        uop_de2uq       = uop_ari;
      end
    endcase
  end
  
endmodule
