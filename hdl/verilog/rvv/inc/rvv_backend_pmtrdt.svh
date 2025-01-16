`ifndef PMTRDT_DEFINE_SVH
`define PMTRDT_DEFINE_SVH

typedef enum logic [1:0] {
  PERMUTATION,
  REDUCTION,
  COMPARE
} PMTRDT_UOP_TYPE_e;

typedef enum logic [2:0] {
  NOT_EQUAL,
  EQUAL,
  LESS_THAN,
  LESS_THAN_OR_EQUAL,
  GREAT_THAN,
  GREAT_THAN_OR_EQUAL
} CMP_TYPE_e;

typedef enum logic [2:0] {
  SUM,
  MAX,
  MIN,
  AND,
  OR,
  XOR
} RDT_OPERATION_e;

typedef enum logic [1:0] {
  SLIDE_DOWN,
  SLIDE_UP,
  GATHER
} PMT_OPERATION_e;

typedef struct packed {
  PMTRDT_UOP_TYPE_e         uop_type;
  logic                     sign_opr;   // set if signed value, clear if unsigned value
  CMP_TYPE_e                gt_lt_eq;
  logic                     widen;      // set if vd EEW is 2*SEW
  RDT_OPERATION_e           rdt_opr;
  PMT_OPERATION_e           pmt_opr;
  logic                     compress;   // set if the uop is compress instruction

  // signals from uop
`ifdef TB_SUPPORT
  logic [`PC_WIDTH-1:0]     uop_pc;
`endif
  logic [`ROB_DEPTH-1:0]    rob_entry;
  logic [`VSTART_WIDTH-1:0] vstart;
  logic [`VL_WIDTH-1:0]     vl;
  logic                     vm;
  EEW_e                     vs1_eew;
  logic [`VLEN-1:0]         v0_data;
  logic [`VLEN-1:0]         vs3_data;
  logic                     last_uop_valid;
} PMTRDT_CTRL_t;

`endif
