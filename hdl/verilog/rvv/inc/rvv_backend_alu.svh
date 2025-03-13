`ifndef ALU_DEFINE_SVH
`define ALU_DEFINE_SVH

typedef enum logic [0:0]{
  ADDSUB_VADD, 
  ADDSUB_VSUB
} ADDSUB_e;   

typedef enum logic [1:0]{
  SHIFT_SLL, 
  SHIFT_SRL,
  SHIFT_SRA
} SHIFT_e;   

typedef enum logic [1:0]{
  OP_NONE,
  OP_VCPOP, 
  OP_VIOTA,
  OP_OTHER
} ALU_SUB_OPCODE_e; 

typedef struct packed {
`ifdef TB_SUPPORT
  logic   [`PC_WIDTH-1:0]                   uop_pc;
`endif
  logic [`ROB_DEPTH_WIDTH-1:0]              rob_entry;
  EEW_e                                     vd_eew;
  logic [`UOP_INDEX_WIDTH-1:0]              uop_index;          
  ALU_SUB_OPCODE_e                          alu_sub_opcode; 
  logic [`VLEN-1:0]                         result_data;
  logic [`VLEN/64-1:0][63:0][$clog2(64):0]  data_viota_per64;
  logic [`VLENB-1:0]                        vsaturate;
} PIPE_DATA_t;

`endif // ALU_DEFINE_SVH
