
`include 'rvv.svh'

module rvv_decode_unit_lsu
(
  inst_valid,
  inst,
  uop_index_remain,
  uop_valid,
  uop
)
//
// interface signals
//
  input   logic                                   inst_valid;
  input   INST_t                                  inst;
  input   logic [`UOP_INDEX_WIDTH-1:0]            uop_index_remain;
  
  output  logic       [`NUM_DE_UOP-1:0]           uop_valid;
  output  UOP_QUEUE_t [`NUM_DE_UOP-1:0]           uop;

//
// internal signals
//
  // split INST_t struct signals
  logic   [`PC_WIDTH-1:0]                         inst_pc;
  logic   [`FUNCT6_WIDTH-1:0]                     inst_funct6;     // inst original encoding[31:26]           
  logic   [`VM_WIDTH-1:0]                         inst_vm;         // inst original encoding[25]      
  logic   [`VS2_WIDTH-1:0]                        inst_vs2;        // inst original encoding[24:20]
  logic   [`UMOP_WIDTH-1:0]                       inst_umop;       // inst original encoding[24:20]
  logic   [`VS1_WIDTH-1:0]                        inst_vs1;        // inst original encoding[19:15]
  logic   [`IMM_WIDTH-1:0]                        inst_imm;        // inst original encoding[19:15]
  logic   [`FUNCT3_WIDTH-1:0]                     inst_funct3;     // inst original encoding[14:12]
  logic   [`VD_WIDTH-1:0]                         inst_vd;         // inst original encoding[11:7]
  logic   [`RD_WIDTH-1:0]                         inst_rd;         // inst original encoding[11:7]
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
  logic                                           inst_encoding_correct;
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
  assign inst_pc              = inst.inst_pc;
  assign inst_funct6          = inst.inst[26:21];
  assign inst_vm              = inst.inst[20];
  assign inst_vs2             = inst.inst[19:15];
  assign inst_umop            = inst.inst[19:15];
  assign inst_vs1             = inst.inst[14:10];
  assign inst_imm             = inst.inst[14:10];
  assign inst_funct3          = inst.inst[9:7];
  assign inst_vd              = inst.inst[6:2];
  assign inst_rd              = inst.inst[6:2];
  assign vector_csr_lsu       = inst.vector_csr;
  assign vill                 = vector_csr_lsu.vtype.vill;
  assign vsew                 = vector_csr_lsu.vtype.vsew;
  assign vlmul                = vector_csr_lsu.vtype.vlmul;
  assign vstart               = vector_csr_lsu.vstart;
  assign rs1_data             = inst.rs1_data;
 
  // decode funct3
  assign funct3_lsu           = inst_funct3; 



endmodule
