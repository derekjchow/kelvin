`ifndef HDL_VERILOG_RVV_DESIGN_RVV_SVH
`define HDL_VERILOG_RVV_DESIGN_RVV_SVH

`ifndef HDL_VERILOG_RVV_DESIGN_RVV_DEFINE_SVH
`include "rvv_define.svh"
`endif  // not defined HDL_VERILOG_RVV_DESIGN_RVV_DEFINE_SVH

// Enum type for SEW. See Table 2 in:
// https://github.com/riscv/riscv-v-spec/blob/master/v-spec.adoc#341-vector-selected-element-width-vsew20
typedef enum logic [2:0] {
  SEW8=0,
  SEW16=1,
  SEW32=2,
  SEW64=3
} RVVSEW;

// Enum type for LMUL. See:
// https://github.com/riscv/riscv-v-spec/blob/master/v-spec.adoc#vector-instruction-formats
typedef enum logic [2:0] {
  LMUL1=0,
  LMUL2=1,
  LMUL4=2,
  LMUL8=3,
  LMULRESERVED=4,
  LMUL1_8=5, // 1/8
  LMUL1_4=6, // 1/4
  LMUL1_2=7  // 1/2
} RVVLMUL;

// The architectural configuration state of the RVV core.
typedef struct packed {
  logic [7:0] vl;  // Max 128, need one extra bit
  logic ma;
  logic ta;
  RVVSEW sew;
  RVVLMUL lmul;
} RVVConfigState;

// Enum to encode the major opcode of the instruction. See "Section 5. Vector
// Instruction Formats" of the RVV 1.0 spec.
typedef enum logic [1:0] {
  LOAD=0,
  STORE=1,
  RVV=2
} RVVOpCode;

// A decoded instruction forwarded to the RVVCore from the scalar core.
typedef struct packed {
  logic [31:0] pc;
  RVVOpCode opcode; // effectively bits [6:0] from instruction
  logic [24:0] bits;   // bits [31:7] from instruction
} RVVInstruction;

// A command internal to the RVVCore. The immediate value of this command has
// been read from the scalar register file if necessary. It also contains
// additional data to track configuration register state (ie: SEW, LMUL, etc).
typedef struct packed {
  RVVOpCode opcode;
  logic [24:0] bits;
  logic [31:0] rs1;
  RVVConfigState arch_state;
} RVVCmd;

//
// IF stage, RVS to Command Queue
//
typedef struct packed {
    logic   [`VTYPE_VILL_WIDTH-1:0]       vill;       // 0:not illegal, 1:illegal
    logic   [`VTYPE_VMA_WIDTH-1:0]        vma;        // 0:inactive element undisturbed, 1:inactive element agnostic
    logic   [`VTYPE_VTA_WIDTH-1:0]        vta;        // 0:tail undisturbed, 1:tail agnostic
    logic   [`VTYPE_VSEW_WIDTH-1:0]       vsew;       // support: 000:SEW8, 001:SEW16, 010:SEW32
    logic   [`VTYPE_VLMUL_WIDTH-1:0]      vlmul;      // support: 110:LMUL1/4, 111:LMUL1/2, 000:LMUL1, 001:LMUL2, 010:LMUL4, 011:LMUL8
} VTYPE_t;

typedef struct packed {
    logic   [`VCSR_VXRM_WIDTH-1:0]        vxrm;
    logic   [`VCSR_VXSAT_WIDTH-1:0]       vxsat;
} VCSR_t;

typedef struct packed {
    logic   [`VSTART_WIDTH-1:0]     vstart;
    logic   [`VL_WIDTH-1:0]         vl;
    VTYPE_t                         vtype;
    VCSR_t                          vcsr;
} VECTOR_CSR_t;

typedef struct packed {
    logic   [`PC_WIDTH-1:0]         insts_pc;
    RVVOpCode opcode;
    logic [24:0] bits;
    VECTOR_CSR_t                    vector_csr;
    logic   [`XLEN-1:0] 	        rs1_data;
} INST_t;

//
// DE stage, Uops Queue to Dispatch unit
//
// It is used to distinguish which execute units that VVV/VVX/VX uop is dispatch to, based on inst_encoding[6:0]
typedef enum logic [2:0] {
    ALU,
    PMTRDT,
    MUL,
    MAC,
    LSU
} EXE_UNIT_e;

// when EXE_UNIT_e is not LSU, it is used to distinguish arithmetic instructions, based on inst_encoding[14:12]
typedef enum logic [2:0] {
    OPIVV,      // vs2,      vs1, vd.
    OPFVV,      // vs2,      vs1, vd/rd. float, not support
    OPMVV,      // vs2,      vs1, vd/rd.
    OPIVI,      // vs2, imm[4:0], vd.
    OPIVX,      // vs2,      rs1, vd.
    OPFVF,      // vs2,      rs1, vd. float, not support
    OPMVX,      // vs2,      rs1, vd/rd.
    OPCFG       // vset* instructions
} EXE_FUNCT3_e;

// when EXE_UNIT_e is not LSU, it identifys what instruction, vadd or vmacc or ..? based on inst_encoding[31:26]
typedef enum logic [5:0] {
    VADD            =   6'b000_000,
    VSUB            =   6'b000_010,
    VRSUB           =   6'b000_011,
    VMINU           =   6'b000_100,
    VMIN            =   6'b000_101,
    VMAXU           =   6'b000_110,
    VMAX            =   6'b000_111,
    VAND            =   6'b001_001,
    VOR             =   6'b001_010,
    VXOR            =   6'b001_011,
    VRGATHER        =   6'b001_100,
    VSLIDEUP        =   6'b001_110,
    // VRGATHEREI16    =   6'b001_110,  // Overlaps with VSLIDEUP
    VSLIDEDOWN      =   6'b001_111,
    VADC            =   6'b010_000,
    VMADC           =   6'b010_001,
    VSBC            =   6'b010_010,
    VMSBC           =   6'b010_011,
    VMERGE_VMV      =   6'b010_111,     // it could be vmerge or vmv, based on vm field
    VMSEQ           =   6'b011_000,
    VMSNE           =   6'b011_001,
    VMSLTU          =   6'b011_010,
    VMSLT           =   6'b011_011,
    VMSLEU          =   6'b011_100,
    VMSLE           =   6'b011_101,
    VMSGTU          =   6'b011_110,
    VMSGT           =   6'b011_111,
    VSADDU          =   6'b100_000,
    VSADD           =   6'b100_001,
    VSSUBU          =   6'b100_010,
    VSSUB           =   6'b100_011,
    VSLL            =   6'b100_101,
    VSMUL_VMVNRR    =   6'b100_111,     // it could be vsmul or vmv<nr>r, based on vm field
    VSRL            =   6'b101_000,
    VSRA            =   6'b101_001,
    VSSRL           =   6'b101_010,
    VSSRA           =   6'b101_011,
    VNSRL           =   6'b101_100,
    VNSRA           =   6'b101_101,
    VNCLIPU         =   6'b101_110,
    VNCLIP          =   6'b101_111,
    VWREDSUMU       =   6'b110_000,
    VWREDSUM        =   6'b110_001
} OPI_TYPE_e;

typedef enum logic [5:0] {
    VREDSUM         =   6'b000_000,
    VREDAND         =   6'b000_001,
    VREDOR          =   6'b000_010,
    VREDXOR         =   6'b000_011,
    VREDMINU        =   6'b000_100,
    VREDMIN         =   6'b000_101,
    VREDMAXU        =   6'b000_110,
    VREDMAX         =   6'b000_111,
    VAADDU          =   6'b001_000,
    VAADD           =   6'b001_001,
    VASUBU          =   6'b001_010,
    VASUB           =   6'b001_011,
    VSLIDE1UP       =   6'b001_110,
    VSLIDE1DOWN     =   6'b001_111,
    VWXUNARY0       =   6'b010_000,     // it could be vcpop.m, vfirst.m and vmv. They can be distinguished by vs1 field(inst_encoding[19:15]).
    VXUNARY0        =   6'b010_010,     // it could be vzext.vf2, vzext.vf4, vsext.vf2, vsext.vf4. They can be distinguished by vs1 field(inst_encoding[19:15]).
    VMUNARY0        =   6'b010_100,     // it could be vmsbf, vmsof, vmsif, viota, vid. They can be distinguished by vs1 field(inst_encoding[19:15]).
    VCOMPRESS       =   6'b010_111,
    VMANDN          =   6'b011_000,
    VMAND           =   6'b011_001,
    VMOR            =   6'b011_010,
    VMXOR           =   6'b011_011,
    VMORN           =   6'b011_100,
    VMNAND          =   6'b011_101,
    VMNOR           =   6'b011_110,
    VMXNOR          =   6'b011_111,
    VDIVU           =   6'b100_000,
    VDIV            =   6'b100_001,
    VREMU           =   6'b100_010,
    VREM            =   6'b100_011,
    VMULHU          =   6'b100_100,
    VMUL            =   6'b100_101,
    VMULHSU         =   6'b100_110,
    VMULH           =   6'b100_111,
    VMADD           =   6'b101_001,
    VNMSUB          =   6'b101_011,
    VMACC           =   6'b101_101,
    VNMSAC          =   6'b101_111,
    VWADDU          =   6'b110_000,
    VWADD           =   6'b110_001,
    VWSUBU          =   6'b110_010,
    VWSUB           =   6'b110_011,
    VWADDUW         =   6'b110_100,
    VWADDW          =   6'b110_101,
    VWSUBUW         =   6'b110_110,
    VWSUBW          =   6'b110_111,
    VWMULU          =   6'b111_000,
    VWMULSU         =   6'b111_010,
    VWMUL           =   6'b111_011,
    VWMACCU         =   6'b111_100,
    VWMACC          =   6'b111_101,
    VWMACCUS        =   6'b111_110,
    VWMACCSU        =   6'b111_111
} OPM_TYPE_e;

// when OPM_TYPE_e=vwxunary0, the uop could be vcpop.m, vfirst.m and vmv. They can be distinguished by vs1 field(inst_encoding[19:15]).
typedef enum logic [4:0] {
    VMV_X_S         =   5'b00000,
    VCPOP           =   5'b10000,
    VFIRST          =   5'b10001
} OPM_VWXUNARY0_e;

// when OPM_TYPE_e=vxunary0, the uop could be vzext.vf2, vzext.vf4, vsext.vf2, vsext.vf4. They can be distinguished by vs1 field(inst_encoding[19:15]).
typedef enum logic [4:0] {
    VZEXT_VF4       =   5'b00100,
    VSEXT_VF4       =   5'b00101,
    VZEXT_VF2       =   5'b00110,
    VSEXT_VF2       =   5'b00111
} OPM_VXUNARY0_e;

// when OPM_TYPE_e=vmxunary0, the uop could be vmsbf, vmsof, vmsif, viota, vid. They can be distinguished by vs1 field(inst_encoding[19:15]).
typedef enum logic [4:0] {
    VMSBF           =   5'b00001,
    VMSOF           =   5'b00010,
    VMSIF           =   5'b00011,
    VIOTA           =   5'b10000,
    VID             =   5'b10001
} OPM_VMXUNARY0_e;

// when EXE_UNIT_e is LSU, it identifys what LSU instruction, unit-stride load or indexed store or ..? based on inst_encoding[31:26]
typedef enum logic [1:0] {
    LSU_MOP_US,         // Unit-Stride
    LSU_MOP_IU,         // Indexed Unordered
    LSU_MOP_CS,         // Constant Stride
    LSU_MOP_IO          // Indexed Ordered
} LSU_MOP_e;

// It identifys what unit-stride instruction when LSU_MOP_e=US, based on inst_encoding[24:20]
typedef enum logic [1:0] {
    LSU_UMOP_US,         // Unit-Stride load/store
    LSU_UMOP_WR,         // Whole Register load/store
    LSU_UMOP_MK,         // MasK load/store, EEW=8(inst_encoding[14:12]=3'b000)
    LSU_UMOP_FF          // Fault-only-First load
} LSU_UMOP_e;

// It identifys what inst_encoding[11:7] is used for when LSU instruction, based on inst_encoding[5]
typedef enum logic {
    LSU_IS_STORE_LOAD,       // when load, inst_encoding[11:7] is seen as vs3
    LSU_IS_STORE_STORE       // when load, inst_encoding[11:7] is seen as vd
} LSU_IS_STORE_e;

// combine those signals to LSU_TYPE
typedef struct packed {
    logic               rsv;        // reserved
    LSU_MOP_e           lsu_mop;
    LSU_UMOP_e          lsu_umop;
    LSU_IS_STORE_e      lsu_is_store;
} LSU_TYPE_t;

// function opcode
typedef union packed {
    OPI_TYPE_e          opi_funct;
    OPM_TYPE_e          opm_funct;
    LSU_TYPE_t          lsu_funct;
} FUNCT6_u;

// vs1 field
typedef union packed {
    OPM_VWXUNARY0_e                     vwxunary0_funct;
    OPM_VXUNARY0_e                      vxunary0_funct;
    OPM_VMXUNARY0_e                     vmxunary0_funct;
    logic   [`REGFILE_INDEX_WIDTH-1:0]  vs1_index;
} VS1_u;

// uop classification used for dispatch rule
typedef enum logic [1:0] {
    VV,        // this uop will use 2 read ports of VRF
    VX,        // this uop will use 1 read ports of VRF
    X,         // this uop will use 0 read ports of VRF
    VVV        // this uop will use 3 read ports of VRF
} UOP_CLASS_e;

// Effective Element Width
typedef enum logic [1:0] {
    EEW1,
    EEW8, 
    EEW16,
    EEW32
} EEW_e;

// the uop struct stored in Uops Queue
typedef struct packed {
    logic   [`PC_WIDTH-1:0]             uop_pc;
    EXE_UNIT_e                          uop_exe_unit;
    EXE_FUNCT3_e                        uop_funct3;
    FUNCT6_u                            uop_funct6;
    UOP_CLASS_e                         uop_class;
    VECTOR_CSR_t                        vector_csr;

    logic                               vm;                 // Original 32bit instruction encoding: insts[25]
    logic   [`REGFILE_INDEX_WIDTH-1:0]  vd_index;           // Original 32bit instruction encoding: insts[11:7].this index is also used as vs3 in some uops
    EEW_e                               vd_eew;
    logic                               vd_valid;
    VS1_u                               vs1;                // when vs1_valid=1, vs1 field is used as vs1_index to address VRF
    EEW_e                               vs1_eew;            // when vs1_valid=0, vs1 field is used to decode some OPMVV uops
    logic                               vs1_valid;
    logic   [`REGFILE_INDEX_WIDTH-1:0]  vs2_index; 	        // Original 32bit instruction encoding: insts[24:20]
    EEW_e                               vs2_eew;
    logic                               vs2_valid;
    logic   [`REGFILE_INDEX_WIDTH-1:0]  rd_index; 	        // Original 32bit instruction encoding: insts[11:7].
    logic                               rd_index_valid;
    logic   [`XLEN-1:0] 	            rs1_data;           // rs1_data could be from X[rs1] and imm(insts[19:15]). If it is imm, the 5-bit imm(insts[19:15]) will be sign-extend or zero-extend(shift instructions...) to XLEN-bit.
    logic        	                    rs1_data_valid;

    logic   [`UOP_INDEX_WIDTH-1:0]      uop_index;          // used for calculate v0_start in DP stage
    logic                               last_uop_valid;     // one instruction may be split to many uops, this signal is used to specify the last uop in those uops of one instruction.
} UOP_QUEUE_t;

//
// DP stage,
//
// VRF struct
typedef struct packed {
    logic                               dp2vrf_vr0_valid;
    logic [`REGFILE_INDEX_WIDTH-1:0]    dp2vrf_vr0_addr;
    logic                               dp2vrf_vr1_valid;
    logic [`REGFILE_INDEX_WIDTH-1:0]    dp2vrf_vr1_addr;
    logic                               dp2vrf_vr2_valid;
    logic [`REGFILE_INDEX_WIDTH-1:0]    dp2vrf_vr2_addr;
    logic                               dp2vrf_vr3_valid;
    logic [`REGFILE_INDEX_WIDTH-1:0]    dp2vrf_vr3_addr;
}DP2VRF_t;

typedef struct packed {
    logic                               vrf2dp_rd0_valid;
    logic [`VLEN-1:0]                   vrf2dp_rd0_data;
    logic                               vrf2dp_rd1_valid;
    logic [`VLEN-1:0]                   vrf2dp_rd1_data;
    logic                               vrf2dp_rd2_valid;
    logic [`VLEN-1:0]                   vrf2dp_rd2_data;
    logic                               vrf2dp_rd3_valid;
    logic [`VLEN-1:0]                   vrf2dp_rd3_data;
    logic                               vrf2dp_v0_valid;
    logic [`VLEN-1:0]                   vrf2dp_v0_data;
}VRF2DP_t;

// specify whether the current byte belongs to 'prestart' or 'body-inactive' or 'body-active' or 'tail'
typedef enum logic [1:0] {
    NOT_CHANGE,         // the byte is not changed, which may belong to 'prestart' or superfluous element in widening/narrowing uop
    BODY_INACTIVE,      // body-inactive byte
    BODY_ACTIVE,        // body-active byte
    TAIL                // tail byte
} ELE_TYPE_e;

// the max number of byte in a vector register is VLENB
typedef ELE_TYPE_e [`VLENB-1:0]         ELE_TYPE_t;

// ALU reservation station struct
typedef union packed {
    logic [`VLEN-1:0]   v0_data;
    logic [`VLEN-1:0]   vd_data;
}VS3_u;

typedef struct packed {
    logic   [`ROB_DEPTH_WIDTH-1:0]      rob_entry;
    FUNCT6_u                            uop_funct6;
    EXE_FUNCT3_e                        uop_funct3;
    logic   [`VSTART_WIDTH-1:0]         vstart;
    // vm field can be used to identify vmadc.v?m/vmadc.v? uop in the same uop_funct6(6'b010000).
    // vm field can be used to identify vmsbc.v?m/vmsbc.v? uop in the same uop_funct6(6'b010011).
    logic                               vm;
    // rounding mode
    logic   [`VCSR_VXRM_WIDTH-1:0]            vxrm;
    // when the uop is vmadc.v?m/vmsbc.v?m, the uop will use v0_data as the third vector operand.
    // when the uop is mask uop(vmandn,vmand,...), the uop will use vd_data as the third vector operand.
    VS3_u                               vs3_data;
    // when vs1_data_valid=0, vs1_data is used to decode some OPMVV uops
    // when vs1_data_valid=1, vs1_data is valid as a vector operand
    VS1_u                               vs1;
    logic   [`VLEN-1:0]                 vs1_data;
    EEW_e                               vs1_eew;
    logic                               vs1_data_valid;
    ELE_TYPE_t                          vs1_type;
    logic   [`VLEN-1:0]                 vs2_data;
    EEW_e                               vs2_eew;
    logic                               vs2_data_valid;
    ELE_TYPE_t                          vs2_type;
    // rs1_data could be from X[rs1] and imm(insts[19:15]). If it is imm, the 5-bit imm(insts[19:15]) will be sign-extend to XLEN-bit. 
    logic   [`XLEN-1:0] 	              rs1_data;
    logic        	                      rs1_data_valid;
} ALU_RS_t;

// DIV reservation station struct
typedef struct packed {
    logic   [`ROB_DEPTH_WIDTH-1:0]      rob_entry;
    FUNCT6_u                            uop_funct6;
    EXE_FUNCT3_e                        uop_funct3;
    // when vs1_data_valid=1, vs1_data is valid as a vector operand
    logic   [`VLEN-1:0]                 vs1_data;
    EEW_e                               vs1_eew;
    logic                               vs1_data_valid;
    ELE_TYPE_t                          vs1_type;
    logic   [`VLEN-1:0]                 vs2_data;
    EEW_e                               vs2_eew;
    logic                               vs2_data_valid;
    ELE_TYPE_t                          vs2_type;
    // rs1_data could be from X[rs1] and imm(insts[19:15]). If it is imm, the 5-bit imm(insts[19:15]) will be sign-extend to XLEN-bit.
    logic   [`XLEN-1:0] 	              rs1_data;
    logic        	                      rs1_data_valid;
} DIV_RS_t;

// MUL and MAC reservation station struct
typedef struct packed {
    logic   [`ROB_DEPTH_WIDTH-1:0]      rob_entry;
    FUNCT6_u                            uop_funct6;
    EXE_FUNCT3_e                        uop_funct3;
    logic   [`VCSR_VXRM_WIDTH-1:0]            vxrm;             // rounding mode

    logic   [`VLEN-1:0]                 vs1_data;
    EEW_e                               vs1_eew;
    logic                               vs1_data_valid;
    ELE_TYPE_t                          vs1_type;
    logic   [`VLEN-1:0]                 vs2_data;
    EEW_e                               vs2_eew;
    logic                               vs2_data_valid;
    ELE_TYPE_t                          vs2_type;
    logic   [`VLEN-1:0]                 vs3_data;
    EEW_e                               vs3_eew;
    logic                               vs3_data_valid;
    ELE_TYPE_t                          vs3_type;
    // rs1_data could be from X[rs1] and imm(insts[19:15]). If it is imm, the 5-bit imm(insts[19:15]) will be sign-extend to XLEN-bit.
    logic   [`XLEN-1:0] 	              rs1_data;
    logic          	                    rs1_data_valid;
} MUL_RS_t;

// PMT and RDT reservation station struct
typedef struct packed {
    logic   [`ROB_DEPTH_WIDTH-1:0]      rob_entry;
    FUNCT6_u                            uop_funct6;
    EXE_FUNCT3_e                        uop_funct3;
    // Identify vmerge and vmv in the same uop_funct6(6'b010111).
    logic                               vm;
    // when vs1_data_valid=0, vs1 field is valid and used to decode some OPMVV uops
    // when vs1_data_valid=1, vs1_data is valid as a vector operand
    VS1_u                               vs1;
    logic   [`VLEN-1:0]                 vs1_data;
    EEW_e                               vs1_eew;
    logic                               vs1_data_valid;
    ELE_TYPE_t                          vs1_type;
    logic   [`VLEN-1:0]                 vs2_data;        
    EEW_e                               vs2_eew;
    logic                               vs2_data_valid;
    ELE_TYPE_t                          vs2_type;
    // rs1_data could be from X[rs1] and imm(insts[19:15]). If it is imm, the 5-bit imm(insts[19:15]) will be sign-extend to XLEN-bit. 
    logic   [`XLEN-1:0] 	              rs1_data;
    logic        	                      rs1_data_valid;
    logic                               last_uop_valid;
} PMT_RDT_RS_t;    

// LSU reservation station struct
typedef struct packed {
    logic   [`PC_WIDTH-1:0]             uop_pc;
    logic   [`ROB_DEPTH_WIDTH-1:0]      uop_id;
    LSU_TYPE_t                          uop_funct6;

    logic                               vidx_valid;
    logic   [`REGFILE_INDEX_WIDTH-1:0]  vidx_addr;
    logic   [`VLEN-1:0]                 vidx_data;                  // vs2
    ELE_TYPE_t                          vs2_type;
    logic                               vregfile_read_valid;
    logic   [`REGFILE_INDEX_WIDTH-1:0]  vregfile_read_addr;
    logic   [`VLEN-1:0]                 vregfile_read_data;         // vs3
    ELE_TYPE_t                          vs3_type;
} LSU_RS_t;

//
// EX stage,
//
// ReOrder Buffer data struct
typedef enum logic {
    VRF,
    XRF
} W_DATA_TYPE_t;

// send ALU's result to ROB
typedef struct packed {
    logic   [`ROB_DEPTH_WIDTH-1:0]      rob_entry;
    logic   [`VLEN-1:0]                 w_data;             // when w_type=XRF, w_data[`XLEN-1:0] will store the scalar result
    W_DATA_TYPE_t                       w_type;
    logic                               w_valid;
    logic   [`VCSR_VXSAT_WIDTH-1:0]           vxsat;
    logic                               ignore_vta_vma;
} ALU2ROB_t;

// send uop to LSU
typedef struct packed {
    // RVV send to uop_pc to help LSU match the vld/vst uop
    logic   [`PC_WIDTH-1:0]             uop_pc;
    // When LSU submit the result to RVV, LSU need to attend uop_id to help RVV retire the uop in ROB
    logic   [`ROB_DEPTH_WIDTH-1:0]      uop_id;
    // Vector regfile index interface for indexed vld/vst
	logic                               vidx_valid;
    logic   [`REGFILE_INDEX_WIDTH-1:0]  vidx_addr;
    logic   [`VLEN-1:0]                 vidx_data;             // vs2
    ELE_TYPE_t                          vs2_type;              // mask for vs2
    // Vector regfile read interface for vst
    logic                               vregfile_read_valid;
    logic   [`REGFILE_INDEX_WIDTH-1:0]  vregfile_read_addr;
    logic   [`VLEN-1:0]                 vregfile_read_data;    // vs3
    ELE_TYPE_t                          vs3_type;              // mask for vs3
} UOP_LSU_RVV2RVS_t;

// LSU feedback to RVV
typedef struct packed {
    // When LSU submit the result to RVV, LSU need to attend uop_id to help RVV retire the uop in ROB
    logic   [`ROB_DEPTH_WIDTH-1:0]      uop_id;
    // LSU uop type
    // When LSU complete the vstore uop, it need to tell RVV done signal and attend uop_id to help RVV retire the uops
    // when load, it means the uop is vld. It enables vregfile_write_addr and vregfile_write_data, and submit the vector data to ROB
    // when store, it means this store uop is done in LSU, ROB can retire this uop.
    LSU_IS_STORE_e                      uop_type;

	// Vector regfile write interface for vld
  	logic	[`REGFILE_INDEX_WIDTH-1:0] 	  vregfile_write_addr;
  	logic	[`VLEN-1:0] 			          	vregfile_write_data;  	// vd
    ELE_TYPE_t                          vs1_type;                // mask for vd
} UOP_LSU_RVS2RVV_t;

typedef struct packed {
    logic                               valid;              // Total valid
    logic   [`REGFILE_INDEX_WIDTH-1:0]  w_index;
    logic   [`VLEN-1:0]                 w_data;             // when w_type=XRF, w_data[`XLEN-1:0] will store the scalar result
    W_DATA_TYPE_t                       w_type;
    logic                               w_valid;
    ELE_TYPE_t                          vd_type;
    VECTOR_CSR_t                        vector_csr;
    logic                               ignore_vta_vma;
} ROB_t;

//
// WB stage, bypass and write back to VRF/XRF, trap handler
// Retire stage, bypass and write back to VRF/XRF, trap handler
//
// write back to XRF
typedef struct packed {
    logic   [`REGFILE_INDEX_WIDTH-1:0]  rt_index, 
    logic   [`XLEN-1:0]                 rt_data 
} RT2XRF_data_t;  

// write back to VRF
typedef struct packed {
    logic   [`REGFILE_INDEX_WIDTH-1:0]  rt_index, 
    logic   [`VLEN-1:0]                 rt_data,
    logic   [`VLENB-1:0]                rt_strobe 
} RT2VRF_data_t;  

typedef struct packed {
    logic [`NUM_RT_UOP-1:0]             rt2vrf_wr_valid;
    RT2VRF_data_t [`NUM_RT_UOP-1:0]     rt2vrf_wr_data;
}RT2VRF_t;

// trap handle
typedef enum logic [1:0] {
    TRAP_INFO_DECODE,   // RVS find some illegal instructions when decoding,
                        // which means a trap occurs to the instruction that is NOT executing in RVV.
                        // So RVV will stop receiving new instructions from RVS, and complete all instructions in RVV.
    TRAP_INFO_LSU,      // RVS find some illegal instructions when complete LSU transaction, like bus error,
                        // which means a trap occurs to the instruction that is executing in RVV.
                        // So RVV will top CQ to receive new instructions and flush Command Queue and Uops Queue,
                        // and complete the instructions in EX, ME and WB stage. And RVS need to send rob_entry of that exception instruction.
                        // After RVV retire all uops before that exception instruction, RVV response a ready signal for trap application.
    TRAP_INFO_LSU_FF    // fault only first load, need to confirm whether has TLB or not.
} TRAP_INFO_e;

typedef struct packed {
    logic                               trap_apply;
    TRAP_INFO_e                         trap_info;
    logic   [`ROB_DEPTH_WIDTH-1:0]      trap_uop_rob_entry;
} TRAP_t;

`endif  // HDL_VERILOG_RVV_DESIGN_RVV_SVH