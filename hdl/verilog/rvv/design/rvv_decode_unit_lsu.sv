
`include 'rvv.svh'

module rvv_decode_unit_lsu
(
  insts_valid,
  insts,
  uop_index_remain,
  uop_valid,
  uop
)
//
// interface signals
//
  input   logic                                   insts_valid;
  input   INST_t                                  insts;
  input   logic [`UOP_INDEX_WIDTH-1:0]            uop_index_remain;
  
  output  logic       [`NUM_DE_UOP-1:0]           uop_valid;
  output  UOP_QUEUE_t [`NUM_DE_UOP-1:0]           uop;

//
// internal signals
//
  // split INST_t struct signals
  logic   [`PC_WIDTH-1:0]                         insts_pc;
  logic   [`FUNCT6_WIDTH-1:0]                     insts_funct6;     // inst original encoding[31:26]           
  logic   [`VM_WIDTH-1:0]                         insts_vm;         // inst original encoding[25]      
  logic   [`VS2_WIDTH-1:0]                        insts_vs2;        // inst original encoding[24:20]
  logic   [`UMOP_WIDTH-1:0]                       insts_umop;       // inst original encoding[24:20]
  logic   [`VS1_WIDTH-1:0]                        insts_vs1;        // inst original encoding[19:15]
  logic   [`IMM_WIDTH-1:0]                        insts_imm;        // inst original encoding[19:15]
  logic   [`FUNCT3_WIDTH-1:0]                     insts_funct3;     // inst original encoding[14:12]
  logic   [`VD_WIDTH-1:0]                         insts_vd;         // inst original encoding[11:7]
  logic   [`RD_WIDTH-1:0]                         insts_rd;         // inst original encoding[11:7]
  VECTOR_CSR_t                                    vector_csr_lsu;
  logic   [`VTYPE_VILL_WIDTH-1:0]                 vill;             // 0:not illegal, 1:illegal
  logic   [`VTYPE_VSEW_WIDTH-1:0]                 vsew;             // support: 000:SEW8, 001:SEW16, 010:SEW32
  logic   [`VTYPE_VLMUL_WIDTH-1:0]                vlmul;            // support: 110:LMUL1/4, 111:LMUL1/2, 000:LMUL1, 001:LMUL2, 010:LMUL4, 011:LMUL8  
  logic   [`VSTART_WIDTH-1:0]                     vstart;
  logic   [`XLEN-1:0] 	                          rs1_data;
  
  logic   [`VTYPE_VLMUL_WIDTH:0]                  emul_max;         // 0000:emul=0, 0001:emul=1, 0010:emul=2,...  
  EEW_e                                           eew_vd;          
  EEW_e                                           eew_vs1;          
  EEW_e                                           eew_vs2;
  logic                                           insts_encoding_correct;
  logic   [`UOP_INDEX_WIDTH-1:0]                  uop_vstart;         
  logic   [`UOP_INDEX_WIDTH-1:0]                  uop_index_start;         
  logic   [`NUM_DE_UOP-1:0][`UOP_INDEX_WIDTH:0]   uop_index_current;         
   
  // convert to enum/union
  logic   [`FUNCT3_WIDTH-1:0]                     funct3_lsu;                
  FUNCT6_u                                        funct6_lsu;

  // use for for-loop 
  integer                                         i;

//
// decode
//
  assign insts_pc             = insts.insts_pc;
  assign insts_funct6         = insts.insts[26:21];
  assign insts_vm             = insts.insts[20];
  assign insts_vs2            = insts.insts[19:15];
  assign insts_umop           = insts.insts[19:15];
  assign insts_vs1            = insts.insts[14:10];
  assign insts_imm            = insts.insts[14:10];
  assign insts_funct3         = insts.insts[9:7];
  assign insts_vd             = insts.insts[6:2];
  assign insts_rd             = insts.insts[6:2];
  assign vector_csr_lsu       = insts.vector_csr;
  assign vill                 = vector_csr_lsu.vtype.vill;
  assign vsew                 = vector_csr_lsu.vtype.vsew;
  assign vlmul                = vector_csr_lsu.vtype.vlmul;
  assign vstart               = vector_csr_lsu.vstart;
  assign rs1_data             = insts.rs1_data;
 
  // decode funct3
  assign funct3_lsu = ((insts_valid==1'b1)&(vill==1'b0)) ? 
                      insts_funct3 :
                      'b0;
  `ifdef ASSERT_ON
    `rvv_forbid((insts_valid==1'b1)&(vill==1'b1))
    else $error("Unsupported vtype.vill=%d.\n",vill);
  `endif



endmodule
