`include "rvv_define.svh"

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
