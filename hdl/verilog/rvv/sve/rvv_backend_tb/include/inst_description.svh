`ifndef INST_DESCRIPTION__SVH
`define INST_DESCRIPTION__SVH

`include "rvv_backend_define.svh"
`include "rvv_backend.svh"
typedef logic [`XLEN-1:0] xrf_t;
typedef logic [`VLEN-1:0] vrf_t;


typedef RVVSEW sew_e;

typedef enum int {
    EEW1  = 1, 
    EEW8  = 8, 
    EEW16 = 16,
    EEW32 = 32
} eew_e;

typedef enum logic {
  UNDISTURB = 0,
  AGNOSTIC  = 1
} agnostic_e;

typedef RVVLMUL lmul_e;

typedef struct packed {
  logic [31] vill;
  logic [30:8] rsv;
  agnostic_e vma;
  agnostic_e vta;
  sew_e vsew; 
  lmul_e vlmul;
} vtype_t;

typedef enum logic [6:0] {
  LD  = 7'b000_0111, 
  ST  = 7'b010_0111, 
  ALU = 7'b101_0111
} inst_type_e;

typedef enum logic [2:0] {
    OPI,
    OPM
} alu_type_e;

typedef enum logic [5:0] {
    VADD            =   6'b000_000,
    VWREDSUM        =   6'b110_001   
} opi_type_e;

typedef enum logic [5:0] {
    VWADD           =   6'b110_001,
    VWADD_W         =   6'b110_101,
    
    VNSRL           =   6'b101_100, 

    VMANDN          =   6'b011_000,
    VMAND           =   6'b011_001,
    VMOR            =   6'b011_010,
    VMXOR           =   6'b011_011,
    VMORN           =   6'b011_100,
    VMNAND          =   6'b011_101,
    VMNOR           =   6'b011_110,
    VMXNOR          =   6'b011_111
} opm_type_e;

typedef enum logic [1:0] {
  LSU_E     = 2'b00, // unit-stride
  LSU_UXEI  = 2'b01, // indexed-unordered
  LSU_SE    = 2'b10, // strided
  LSU_OXEI  = 2'b11  // indexed-ordered
} lsu_mop_e;

typedef enum logic [4:0] {
  NORMAL    = 5'b0_0000, // unit-stride load/store
  WHOLE_REG = 5'b0_1000, // unit-stride, whole register load/store
  MASK      = 5'b0_1011, // unit-stride, mask load/store, EEW=8
  FOF       = 5'b1_0000  // unit-stride fault-only-first load
} lsu_umop_e;

typedef enum logic [2:0] {
  NF1,  NF2,  NF3,  NF4,  NF5,  NF6,  NF7,  NF8
} lsu_nf_e;

typedef enum int {
  VLE,
  VSE,
  VLM,
  VSM,
  VLSE,
  VSSE,
  VLUXEI,
  VLOXEI,
  VSUXEI,
  VSOXEI,
  VLEFF,
  VLSEG,
  VSSEG,
  VLSEGFF,
  VLSSEG,
  VSSSEG,
  VLUXSEG,
  VLOXSEG,
  VSUXSEG,
  VSOXSEG,
  VL,
  VSR
} lsu_inst_e;

typedef enum {
  XRF, VRF, IMM, FUNC, UNUSE
} oprand_type_e;

typedef struct packed {
  logic   [`REGFILE_INDEX_WIDTH-1:0]  rt_index; 
  logic   [`XLEN-1:0]                 rt_data; 
} rt_xrf_t;

`endif // INST_DESCRIPTION__SVH
