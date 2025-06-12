`ifndef INST_DESCRIPTION__SVH
`define INST_DESCRIPTION__SVH

`include "rvv_backend_define.svh"
`include "rvv_backend.svh"

// TB status description ------------------------------------
package vrf_mon_pkg;
  typedef enum {IDLE, BUSY, ALL_ZERO, UNKNOW} vrf_state_e;
endpackage: vrf_mon_pkg
package rvv_state_pkg;
  typedef enum {IDLE, BUSY, UNKNOW} rvv_state_e;
endpackage: rvv_state_pkg
package delay_mode_pkg;
typedef enum {FAST, NORMAL, SLOW} delay_mode_e;
endpackage: delay_mode_pkg

package rvv_tb_pkg;
import vrf_mon_pkg::*;
import rvv_state_pkg::*;
import delay_mode_pkg::*;
typedef logic [`REGFILE_INDEX_WIDTH-1:0] reg_idx_t;
typedef logic [`XLEN-1:0] xrf_t;
typedef logic [`VLEN-1:0] vrf_t;
typedef logic [`VLENB-1:0] vrf_byte_t;


// typedef RVVSEW sew_e;
typedef enum logic [2:0] {
  SEW8  = 3'b000, 
  SEW16 = 3'b001,
  SEW32 = 3'b010,
  SEW_LAST = 3'b111
} sew_e;

typedef enum int {
  EEW_NONE = 0,
  EEW1  = 1, 
  EEW8  = 8, 
  EEW16 = 16,
  EEW32 = 32,
  EEW64 = 64
} eew_e;

typedef enum logic {
  UNDISTURB = 0,
  AGNOSTIC  = 1
} agnostic_e;

// typedef RVVLMUL lmul_e;
typedef enum logic [2:0] {
  LMUL1_4   = 3'b110,
  LMUL1_2   = 3'b111,
  LMUL1     = 3'b000,
  LMUL2     = 3'b001,
  LMUL4     = 3'b010,
  LMUL8     = 3'b011,
  LMUL_LAST = 3'b100
} lmul_e;
parameter real EMUL_NONE = 0.00;
parameter real EMUL1_4   = 0.25;
parameter real EMUL1_2   = 0.50;
parameter real EMUL1     = 1.00;
parameter real EMUL2     = 2.00;
parameter real EMUL4     = 4.00;
parameter real EMUL8     = 8.00;

typedef struct packed {
  logic [31] vill;
  logic [30:8] rsv;
  agnostic_e vma;
  agnostic_e vta;
  sew_e vsew; 
  lmul_e vlmul;
} vtype_t;

typedef enum logic [1:0] {
  RNU = 0,
  RNE = 1,
  RDN = 2,
  ROD = 3
} vxrm_e;

typedef enum logic [6:0] {
  LD  = 7'b000_0111, 
  ST  = 7'b010_0111, 
  ALU = 7'b101_0111
} inst_type_e;

typedef enum logic [2:0] {
  OPIVV=3'b000,      // vs2,      vs1, vd.
  OPFVV=3'b001,      // vs2,      vs1, vd/rd. float, not support
  OPMVV=3'b010,      // vs2,      vs1, vd/rd.
  OPIVI=3'b011,      // vs2, imm[4:0], vd.
  OPIVX=3'b100,      // vs2,      rs1, vd.
  OPFVF=3'b101,      // vs2,      rs1, vd. float, not support
  OPMVX=3'b110,      // vs2,      rs1, vd/rd.
  OPCFG=3'b111       // vset* instructions    
} alu_type_e;

typedef enum logic [7:0] {
  // OPI
  VADD            =   8'b00_000_000,
  VSUB            =   8'b00_000_010,
  VRSUB           =   8'b00_000_011,
  
  VADC            =   8'b00_010_000,
  VMADC           =   8'b00_010_001,
  VSBC            =   8'b00_010_010,
  VMSBC           =   8'b00_010_011,

  VAND            =   8'b00_001_001,
  VOR             =   8'b00_001_010,
  VXOR            =   8'b00_001_011,

  VSLL            =   8'b00_100_101,
  VSRL            =   8'b00_101_000,
  VSRA            =   8'b00_101_001,
  VNSRL           =   8'b00_101_100,
  VNSRA           =   8'b00_101_101,

  VMSEQ           =   8'b00_011_000,
  VMSNE           =   8'b00_011_001,
  VMSLTU          =   8'b00_011_010,
  VMSLT           =   8'b00_011_011,
  VMSLEU          =   8'b00_011_100,
  VMSLE           =   8'b00_011_101,
  VMSGTU          =   8'b00_011_110,
  VMSGT           =   8'b00_011_111,

  VMINU           =   8'b00_000_100,
  VMIN            =   8'b00_000_101,
  VMAXU           =   8'b00_000_110,
  VMAX            =   8'b00_000_111,

  VMERGE_VMVV     =   8'b00_010_111, // vm=0: vmerge; vm=1: vmv.v

  VSADDU          =   8'b00_100_000,
  VSADD           =   8'b00_100_001,
  VSSUBU          =   8'b00_100_010,
  VSSUB           =   8'b00_100_011,

  VSMUL_VMVNRR    =   8'b00_100_111, // .vv,.vx: vsmul; .vi: vmvnrr 

  VSSRL           =   8'b00_101_010,
  VSSRA           =   8'b00_101_011,

  VNCLIPU         =   8'b00_101_110,
  VNCLIP          =   8'b00_101_111,

// Vector Reduction Operations in OPI
  VWREDSUMU       =   8'b00_110_000,
  VWREDSUM        =   8'b00_110_001,
// Vector Permutation Operations in OPI
  VSLIDEUP_RGATHEREI16 =   8'b00_001_110,
  VSLIDEDOWN      =   8'b00_001_111,
  VRGATHER        =   8'b00_001_100,


  // OPM
  VWADDU          =   8'b01_110_000,
  VWADD           =   8'b01_110_001,
  VWADDU_W        =   8'b01_110_100,
  VWADD_W         =   8'b01_110_101,
  VWSUBU          =   8'b01_110_010,
  VWSUB           =   8'b01_110_011,
  VWSUBU_W        =   8'b01_110_110,
  VWSUB_W         =   8'b01_110_111,

  VXUNARY0        =   8'b01_010_010,  // VZEXT/VSEXT 

  VMUL            =   8'b01_100_101,
  VMULH           =   8'b01_100_111,
  VMULHU          =   8'b01_100_100,
  VMULHSU         =   8'b01_100_110,

  VDIVU           =   8'b01_100_000,
  VDIV            =   8'b01_100_001,
  VREMU           =   8'b01_100_010,
  VREM            =   8'b01_100_011,

  VWMUL           =   8'b01_111_011,
  VWMULU          =   8'b01_111_000,
  VWMULSU         =   8'b01_111_010,

  VMACC           =   8'b01_101_101,
  VNMSAC          =   8'b01_101_111,
  VMADD           =   8'b01_101_001,
  VNMSUB          =   8'b01_101_011,

  VWMACCU         =   8'b01_111_100,
  VWMACC          =   8'b01_111_101,
  VWMACCUS        =   8'b01_111_110,
  VWMACCSU        =   8'b01_111_111,  

  VAADDU          =   8'b01_001_000,
  VAADD           =   8'b01_001_001,
  VASUBU          =   8'b01_001_010,
  VASUB           =   8'b01_001_011,

  VREDSUM         =   8'b01_000_000,
  VREDAND         =   8'b01_000_001,
  VREDOR          =   8'b01_000_010,
  VREDXOR         =   8'b01_000_011,
  VREDMINU        =   8'b01_000_100,
  VREDMIN         =   8'b01_000_101,
  VREDMAXU        =   8'b01_000_110,
  VREDMAX         =   8'b01_000_111,

  VMAND           =   8'b01_011_001,
  VMOR            =   8'b01_011_010,
  VMXOR           =   8'b01_011_011,
  VMORN           =   8'b01_011_100,
  VMNAND          =   8'b01_011_101,
  VMNOR           =   8'b01_011_110,
  VMANDN          =   8'b01_011_000,
  VMXNOR          =   8'b01_011_111,


  VMUNARY0        =   8'b01_010_100,     // it could be vmsbf, vmsof, vmsif, viota, vid. They can be distinguished by vs1 field(inst_encoding[19:15]).
// Vector Permutation Operations in OPM 
  //VMV             =   8'b01_010_000,
  VSLIDE1UP       =   8'b01_001_110,
  VSLIDE1DOWN     =   8'b01_001_111,
  VCOMPRESS       =   8'b01_010_111,

  VWXUNARY0       =   8'b01_010_000,     // it could be vcpop.m, vfirst.m and vmv. They can be distinguished by vs1 field(inst_encoding[19:15]).

  ALU_UNUSE_INST  =   8'b11_111_111
} alu_inst_e;

/* VZEXT/VSEXT vs1 */
typedef enum logic [4:0] {
  VZEXT_VF4       =   5'b00100,
  VSEXT_VF4       =   5'b00101,
  VZEXT_VF2       =   5'b00110,
  VSEXT_VF2       =   5'b00111,  
  VXUNARY0_NONE   =   5'b11111
} vxunary0_e;

// vwxunary0, the uop could be vcpop.m, vfirst.m and vmv. They can be distinguished by vs1 field(inst_encoding[19:15]).
typedef enum logic [4:0] {
  VMV_X_S         =   5'b00000,
  VCPOP           =   5'b10000,
  VFIRST          =   5'b10001,
  VWXUNARY0_NONE  =   5'b11111
} vwxunary0_e;
parameter logic [4:0] VMV_S_X = 5'b00000;

// vmunary0, the uop could be vmsbf, vmsof, vmsif, viota, vid. They can be distinguished by vs1 field(inst_encoding[19:15]).
typedef enum logic [4:0] {
  VMSBF           =   5'b00001,
  VMSOF           =   5'b00010,
  VMSIF           =   5'b00011,
  VIOTA           =   5'b10000,
  VID             =   5'b10001,
  VMUNARY0_NONE   =   5'b11111
} vmunary0_e;

typedef enum logic [1:0] {
  LSU_US = 2'b00, // unit-stride
  LSU_UI = 2'b01, // indexed-unordered
  LSU_CS = 2'b10, // strided
  LSU_OI = 2'b11  // indexed-ordered
} lsu_mop_e;

typedef enum logic [4:0] {
  NORMAL    = 5'b0_0000, // unit-stride load/store
  WHOLE_REG = 5'b0_1000, // unit-stride, whole register load/store
  MASK      = 5'b0_1011, // unit-stride, mask load/store, EEW=8
  FOF       = 5'b1_0000, // unit-stride fault-only-first load
  LSU_UMOP_NONE = 5'b1_1111
} lsu_umop_e;

typedef enum logic [2:0] {
  NF1,  NF2,  NF3,  NF4,  NF5,  NF6,  NF7,  NF8
} lsu_nf_e;

typedef enum logic [2:0] {
  NR1 = 3'b000,  
  NR2 = 3'b001,  
  NR3 = 3'b010,  
  NR4 = 3'b011,
  NR5 = 3'b100,  
  NR6 = 3'b101,  
  NR7 = 3'b110,  
  NR8 = 3'b111
} lsu_nr_e;

typedef enum logic [2:0]{
  LSU_8BIT  = 3'b000,
  LSU_16BIT = 3'b101,
  LSU_32BIT = 3'b110,
  LSU_64BIT = 3'b111
} lsu_width_e;

typedef enum int {
  VL,
  VS,
  VLM,
  VSM,
  VLS,
  VSS,
  VLUX,
  VLOX,
  VSUX,
  VSOX,
  VLFF,
  VLSEG,
  VSSEG,
  VLSEGFF,
  VLSSEG,
  VSSSEG,
  VLUXSEG,
  VLOXSEG,
  VSUXSEG,
  VSOXSEG,
  VLR,
  VSR,
  LSU_UNUSE_INST
} lsu_inst_e;

typedef enum {
  XRF, VRF, IMM, UIMM, FUNC, SCALAR, UNUSE
} operand_type_e;

// Test description -----------------------------------------
typedef enum { ITER, RAND, RAND_SET } test_rand_type_e;
endpackage: rvv_tb_pkg
`endif // INST_DESCRIPTION__SVH
