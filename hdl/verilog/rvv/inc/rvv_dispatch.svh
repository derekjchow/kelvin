`ifndef RVV_DISPATCH__SVH
`define RVV_DISPATCH__SVH

`include "rvv_define.svh"

// input signals for RAW check
typedef struct packed {
  logic [`REGFILE_INDEX_WIDTH-1:0] vs1_index;
  logic                            vs1_valid; // set if vs1 is a source operand
  logic [`REGFILE_INDEX_WIDTH-1:0] vs2_index;
  logic                            vs2_valid; // set if vs2 is a source operand
  logic [`REGFILE_INDEX_WIDTH-1:0] vd_index;
  logic                            vs3_valid; // set if vd is a source operand
  logic                            vm;
} SUC_UOP_RAW_t;

typedef struct packed {
  logic [`REGFILE_INDEX_WIDTH-1:0] w_index; 
  logic                            w_valid;
  logic                            valid;
} PRE_UOP_RAW_t;

// RAW hazard information
typedef struct packed {
  logic [`ROB_DEPTH-1:0] vs1_hit;
  logic                  vs1_wait;
  logic [`ROB_DEPTH-1:0] vs2_hit;
  logic                  vs2_wait;
  logic [`ROB_DEPTH-1:0] vd_hit;
  logic                  vd_wait;
  logic [`ROB_DEPTH-1:0] v0_hit;
  logic                  v0_wait;
} RAW_UOP_ROB_t;

typedef struct packed {
  logic                  vs1_wait;
  logic                  vs2_wait;
  logic                  vd_wait;
  logic                  v0_wait;
} RAW_UOP_UOP_t;

// Input signals for structure hazard
typedef struct packed {
  logic [`REGFILE_INDEX_WIDTH-1:0] vs1_index;
  logic [`REGFILE_INDEX_WIDTH-1:0] vs2_index;
  logic [`REGFILE_INDEX_WIDTH-1:0] vd_index;
  EXE_UNIT_e                       uop_exe_unit;
  UOP_CLASS_e                      uop_class;
} STRCT_UOP_t;

// Structure hazard information
typedef struct packed {
  logic                  vr_limit; // VRF read port limitation
  logic                  pu_limit; // Processor Unit limitation
} ARCH_HAZARD_t;

// the vector operand of uop
typedef struct packed {
  logic [`VLEN-1:0]      vs1;
  logic [`VLEN-1:0]      vs2;
  logic [`VLEN-1:0]      vd;
  logic [`VLEN-1:0]      v0;
} UOP_OPN_t;

// the vector operand byte type in uop
typedef struct packed {
  BYTE_TYPE_t            vs1;
  BYTE_TYPE_t            vs2;
  BYTE_TYPE_t            vd;
} UOP_OPN_BYTE_TYPE_t;


`endif // RVV_DISPATCH__SVH
