
`include 'rvv.svh'

module rvv_decode_unit
(
  inst_valid_cq2de,
  inst_cq2de,
  uop_index_remain,
  uop_valid_de2uq,
  uop_de2uq
)
//
// interface signals
//
  // CQ to Decoder unit signals
  input   logic                         inst_valid_cq2de;
  input   INST_t                        inst_cq2de;
  input   logic [`UOP_INDEX_WIDTH-1:0]  uop_index_remain;
  
  // Decoder unit to Uops Queue signals
  output  logic       [`NUM_DE_UOP-1:0] uop_valid_de2uq;
  output  UOP_QUEUE_t [`NUM_DE_UOP-1:0] uop_de2uq;

//
// internal signals
//
  logic   [`OPCODE_WIDTH-1:0]           inst_opcode;     // inst original encoding[6:0]
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
  assign inst_opcode  = inst_cq2de.inst[1:0];
  assign vill         = inst_cq2de.vector_csr.vtype.vill;
 
  // decode opcode
  always_comb begin 
    // initial the data
    valid_lsu           = 'b0;
    valid_ari           = 'b0;

    case(inst_valid_cq2de,vill,inst_opcode)
      {1'b1,1'b0,OPCODE_LOAD},
      {1'b1,1'b0,OPCODE_STORE}: begin
        valid_lsu       = 1'b1;    
      end
    
      {1'b1,1'b0,OPCODE_ARI_CFG}: begin
        valid_ari      = 1'b1;
      end  

      default: begin
        `ifdef ASSERT_ON
        `rvv_forbid((inst_valid_cq2de==1'b1)&(vill==1'b1))
        else $error("Illegal vtype.vill=%d.\n",vill);
        
        `rvv_expect((inst_valid_cq2de==1'b0)&(vill==1'b0))
        else $error("Unsupported inst_opcode=%d.\n",inst_opcode);
        `endif
      end
    endcase
  end
  
  // decode LSU instruction 
  rvv_decode_unit_lsu u_lsu_decode
  (
    inst_valid        (valid_lsu),
    inst              (inst_cq2de),
    uop_index_remain  (uop_index_remain),
    uop_valid         (uop_valid_lsu),
    uop               (uop_lsu)
  );

  // decode arithmetic instruction
  rvv_decode_unit_ari u_ari_decode
  (
    inst_valid        (valid_ari),
    inst              (inst_cq2de),
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

  // 
  `ifdef ASSERT_ON
    `rvv_forbid((inst_valid_cq2de==1'b1)&((valid_lsu==1'b0)&(valid_ari==1'b0)))
    else $error("Unsupported instruction to decode.\n");
  `endif

endmodule
