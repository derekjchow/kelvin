`include "rvv_define.svh"

/*
IF stage, RVS to Command Queue
*/
typedef struct packed {
    logic   [`VTYPE_VILL-1:0]       vill,       // 0:not illegal, 1:illegal
    logic   [`VTYPE_VMA-1:0]        vma,        // 0:inactive element undisturbed, 1:inactive element agnostic
    logic   [`VTYPE_VTA-1:0]        vta,        // 0:tail undisturbed, 1:tail agnostic
    logic   [`VTYPE_VSEW-1:0]       vsew,       // support: 000:SEW8, 001:SEW16, 010:SEW32
    logic   [`VTYPE_VLMUL-1:0]      vlmul       // support: 110:LMUL1/4, 111:LMUL1/2, 000:LMUL1, 001:LMUL2, 010:LMUL4, 011:LMUL8  
} VTYPE_t;

typedef struct packed {
    logic   [`VCSR_VXRM-1:0]        vxrm,       
    logic   [`VCSR_VXSAT-1:0]       vxsat            
} VCSR_t;

typedef struct packed {
    logic   [`VSTART_WIDTH-1:0]     vstart,
    logic   [`VL_WIDTH-1:0]         vl,
    VTYPE_t                         vtype,
    VCSR_t                          vcsr
} VECTOR_CSR_t;

typedef struct packed {
    logic   [`PC_WIDTH-1:0]         insts_pc,
    logic   [`INST_WIDTH-1:0]       insts, 	
    VECTOR_CSR_t                    vector_csr,
    logic   [`XLEN-1:0] 	        rs1_data
} INST_t; 

/*
ID stage, Uops Queue to Dispatch unit
*/
// It is used to distinguish which execute units that VVV/VVX/VX uop is dispatch to, based on inst_encoding[6:0]
typedef enum logic [2:0] {
    ALU,
    PMT,
    RDT,
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
} EXE_OPCODE_e;

// when EXE_UNIT_e is not LSU, it identifys what instruction, vadd or vmacc or ..? based on inst_encoding[31:26]
typedef enum logic [5:0] {
    vadd            =   6'b000_000,
    vsub            =   6'b000_010,
    vrsub           =   6'b000_011,
    vminu           =   6'b000_100,
    vmin            =   6'b000_101,
    vmaxu           =   6'b000_110,
    vmaxu           =   6'b000_111,
    vand            =   6'b001_001,
    vor             =   6'b001_010,
    vxor            =   6'b001_011,
    vrgather        =   6'b001_100,
    vslideup        =   6'b001_110,
    vrgatherei16    =   6'b001_110,
    vslidedown      =   6'b001_111,
    vadc            =   6'b010_000,
    vmadc           =   6'b010_001,
    vsbc            =   6'b010_010,
    vmsbc           =   6'b010_011,
    vmerge_vmv      =   6'b010_111,     // it could be vmerge or vmv, based on vm field
    vmseq           =   6'b011_000,
    vmsne           =   6'b011_001,
    vmsltu          =   6'b011_010,
    vmslt           =   6'b011_011,
    vmsleu          =   6'b011_100,
    vmsle           =   6'b011_101,
    vmsgtu          =   6'b011_110,
    vmsgt           =   6'b011_111,
    vsaddu          =   6'b100_000,
    vsadd           =   6'b100_001,
    vssubu          =   6'b100_010,
    vssub           =   6'b100_011,
    vsll            =   6'b100_101,
    vsmul_vmvnrr    =   6'b100_111,     // it could be vsmul or vmv<nr>r, based on vm field
    vsrl            =   6'b101_000,
    vsra            =   6'b101_001,
    vssrl           =   6'b101_010,
    vssra           =   6'b101_011,
    vnsrl           =   6'b101_100,
    vnsra           =   6'b101_101,
    vnclipu         =   6'b101_110,
    vnclip          =   6'b101_111,
    vwredsumu       =   6'b110_000,
    vwredsum        =   6'b110_001   
} OPI_TYPE_e;

typedef enum logic [5:0] {
    vredsum         =   6'b000_000,
    vredand         =   6'b000_001,
    vredor          =   6'b000_010,
    vredxor         =   6'b000_011,
    vredminu        =   6'b000_100,
    vredmin         =   6'b000_101,
    vredmaxu        =   6'b000_110,
    vredmax         =   6'b000_111,
    vaaddu          =   6'b001_000,
    vaadd           =   6'b001_001,
    vasubu          =   6'b001_010,
    vasub           =   6'b001_011,
    vslide1up       =   6'b001_110,
    vslide1down     =   6'b001_111,
    vwxunary0       =   6'b010_000,     // it could be vcpop.m, vfirst.m and vmv. They can be distinguished by vs1 field(inst_encoding[19:15]).
    vxunary0        =   6'b010_010,     // it could be vzext.vf2, vzext.vf4, vsext.vf2, vsext.vf4. They can be distinguished by vs1 field(inst_encoding[19:15]).
    vmunary0        =   6'b010_100,     // it could be vmsbf, vmsof, vmsif, viota, vid. They can be distinguished by vs1 field(inst_encoding[19:15]).
    vcompress       =   6'b010_111,
    vmandn          =   6'b011_000,
    vmand           =   6'b011_001,
    vmor            =   6'b011_010,
    vmxor           =   6'b011_011,
    vmorn           =   6'b011_100,
    vmnand          =   6'b011_101,
    vmnor           =   6'b011_110,
    vmxnor          =   6'b011_111,
    vdivu           =   6'b100_000,
    vdiv            =   6'b100_001,
    vremu           =   6'b100_010,
    vrem            =   6'b100_011,
    vmulhu          =   6'b100_100,
    vmul            =   6'b100_101,
    vmulhsu         =   6'b100_110,
    vmulh           =   6'b100_111,
    vmadd           =   6'b101_001,
    vnmsub          =   6'b101_011,
    vmacc           =   6'b101_101,
    vnmsac          =   6'b101_111,
    vwaddu          =   6'b110_000,
    vwadd           =   6'b110_001,
    vwsubu          =   6'b110_010,
    vwsub           =   6'b110_011,
    vwaddu          =   6'b110_100,
    vwadd           =   6'b110_101,
    vwsubu          =   6'b110_110,
    vwsub           =   6'b110_111,
    vwmulu          =   6'b111_000,
    vwmulsu         =   6'b111_010,
    vwmul           =   6'b111_011,
    vwmaccu         =   6'b111_100,
    vwmacc          =   6'b111_101,
    vwmaccus        =   6'b111_110,
    vwmaccsu        =   6'b111_111      
} OPM_TYPE_e;

// when OPM_TYPE_e=vwxunary0, the uop could be vcpop.m, vfirst.m and vmv. They can be distinguished by vs1 field(inst_encoding[19:15]).
typedef enum logic [4:0] {
    vmv_x_s         =   5'b00000,
    vcpop           =   5'b10000,
    vfirst          =   5'b10001
} OPM_VWXUNARY0_e;

// when OPM_TYPE_e=vxunary0, the uop could be vzext.vf2, vzext.vf4, vsext.vf2, vsext.vf4. They can be distinguished by vs1 field(inst_encoding[19:15]).
typedef enum logic [4:0] {
    vzext_vf4       =   5'b00100,
    vsext_vf4       =   5'b00101,
    vzext_vf2       =   5'b00110,
    vsext_vf2       =   5'b00111
} OPM_VXUNARY0_e;

// when OPM_TYPE_e=vmxunary0, the uop could be vmsbf, vmsof, vmsif, viota, vid. They can be distinguished by vs1 field(inst_encoding[19:15]).
typedef enum logic [4:0] {
    vmsbf           =   5'b00001,
    vmsof           =   5'b00010,
    vmsif           =   5'b00011,
    viota           =   5'b10000,
    vid             =   5'b10001
} OPM_VMXUNARY0_e;

// when EXE_UNIT_e is LSU, it identifys what LSU instruction, unit-stride load or indexed store or ..? based on inst_encoding[31:26]
typedef enum logic [1:0] {
    US,         // Unit-Stride
    IU,         // Indexed Unordered
    CS,         // Constant Stride
    IO          // Indexed Ordered
} LSU_MOP_e;

// It identifys what unit-stride instruction when LSU_MOP_e=US, based on inst_encoding[24:20]
typedef enum logic [1:0] {
    US,         // Unit-Stride load/store
    WR,         // Whole Register load/store
    MK,         // MasK load/store, EEW=8(inst_encoding[14:12]=3'b000)
    FF          // Faul-only-First load
} LSU_UMOP_e;

// It identifys what inst_encoding[11:7] is used for when LSU instruction, based on inst_encoding[5]
typedef enum logic [0] {
    LOAD,       // when load, inst_encoding[11:7] is seen as vs3
    STORE       // when load, inst_encoding[11:7] is seen as vd
} LSU_IS_STORE_e;

// combine those signals to LSU_TYPE
typedef struct packed {
    logic               rsv,        // reserved
    LSU_MOP_e           lsu_mop,
    LSU_UMOP_e          lsu_umop,
    LSU_IS_STORE_e      lsu_is_store
} LSU_TYPE_t;

// function opcode
typedef union packed {
    OPI_TYPE_e          opi_funct,
    OPM_TYPE_e          opm_funct,
    LSU_TYPE_t          lsu_funct
} FUNCT_u;

// vs1 field
typedef union packed {
    OPM_VWXUNARY0_e                     vwxunary0_funct,
    OPM_VXUNARY0_e                      vxunary0_funct,
    OPM_VMXUNARY0_e                     vmxunary0_funct,
    logic   [`REGFILE_INDEX_WIDTH-1:0]  vs1_index,
} VS1_u;

// uop classification used for dispatch rule
typedef enum logic [1:0] {
    VVV,        // this uop will use 2 read ports of VRF
    VVX,        // this uop will use 1 read ports of VRF
    VX,         // this uop will use 0 read ports of VRF
    MACV        // this uop will use 3 read ports of VRF
} UOP_CLASS_e;

// Effective Element Width
typedef enum logic [1:0] {
    EEW8, 
    EEW16,
    EEW32
} EEW_e;

// the uop struct stored in Uops Queue
typedef struct packed {
    logic   [`PC_WIDTH-1:0]             uop_pc,
    EXE_UNIT_e                          uop_exe_unit, 
    EXE_OPCODE_e                        uop_opcode, 
    FUNCT_u                             uop_funct,
    UOP_CLASS_e                         uop_class,   
    VECTOR_CSR_t                        vector_csr,     

    logic                               vm,                 // Original 32bit instruction encoding: insts[25]
    logic   [`REGFILE_INDEX_WIDTH-1:0]  vd_index,           // Original 32bit instruction encoding: insts[11:7].this index is also used as vs3 in some uops 
    EEW_e                               vd_eew,  
    logic                               vd_valid,
    VS1_u                               vs1,                // when vs1_valid=1, vs1 field is used as vs1_index to address VRF
    EEW_e                               vs1_eew,            // when vs1_valid=0, vs1 field is used to decode some OPMVV uops 
    logic                               vs1_valid,
    logic   [`REGFILE_INDEX_WIDTH-1:0]  vs2_index, 	        // Original 32bit instruction encoding: insts[24:20]
    EEW_e                               vs2_eew,
    logic                               vs2_valid,
    logic   [`REGFILE_INDEX_WIDTH-1:0]  rd_index, 	        // Original 32bit instruction encoding: insts[11:7].
    logic                               rd_index_valid, 
    logic   [`XLEN-1:0] 	            rs1_data,           // rs1_data could be from X[rs1] and imm(insts[19:15]). If it is imm, the 5-bit imm(insts[19:15]) will be sign-extend or zero-extend(shift instructions...) to XLEN-bit. 
    logic        	                    rs1_data_valid,                                
            
    logic   [`UOP_INDEX_WIDTH-1:0]      uop_index,          // used for calculate v0_start in DP stage
    logic                               last_uop_valid      // one instruction may be split to many uops, this signal is used to specify the last uop in those uops of one instruction.
} UOP_QUEUE_t;    

/*
DP stage, 
*/
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
typedef struct packed {
    logic   [`ROB_DEPTH_WIDTH-1:0]      rob_entry,
    FUNCT6_e                            uop_funct,  
    EXE_OPCODE_e                        uop_opcode,
    logic                               vm,                 // Identify vmadc.v?m and vmadc.v? in the same uop_funct(6'b010000).
                                                            // Identify vmsbc.v?m and vmsbc.v? in the same uop_funct(6'b010011).    
    logic   [`VCSR_VXRM-1:0]            vxrm,               // rounding mode and saturate mode
    
    logic   [`VLENB-1:0]                v0_data,            // when the uop is vmadc.v?m or vmsbc.v?m, it will use v0 as the third vector operand
    VS1_u                               vs1,                // when vs1_data_valid=0, vs1 field is valid and used to decode some OPMVV uops
    logic   [`VLEN-1:0]                 vs1_data,           // when vs1_data_valid=1, vs1_data is valid as a vector operand
    EEW_e                               vs1_eew,
    logic                               vs1_data_valid, 
    ELE_TYPE_t                          vs1_type, 
    logic   [`VLEN-1:0]                 vs2_data,	        
    EEW_e                               vs2_eew,
    logic                               vs2_data_valid,  
    ELE_TYPE_t                          vs2_type, 
    logic   [`XLEN-1:0] 	            rs1_data,           // rs1_data could be from X[rs1] and imm(insts[19:15]). If it is imm, the 5-bit imm(insts[19:15]) will be sign-extend to XLEN-bit. 
    logic        	                    rs1_data_valid                                   
} ALU_RS_t;    

// DIV reservation station struct
typedef struct packed {
    logic   [`ROB_DEPTH_WIDTH-1:0]      rob_entry,
    FUNCT6_e                            uop_funct,  
    EXE_OPCODE_e                        uop_opcode,
    
    logic   [`VLEN-1:0]                 vs1_data,           // when vs1_data_valid=1, vs1_data is valid as a vector operand
    EEW_e                               vs1_eew,
    logic                               vs1_data_valid, 
    ELE_TYPE_t                          vs1_type, 
    logic   [`VLEN-1:0]                 vs2_data,	        
    EEW_e                               vs2_eew,
    logic                               vs2_data_valid,  
    ELE_TYPE_t                          vs2_type, 
    logic   [`XLEN-1:0] 	            rs1_data,           // rs1_data could be from X[rs1] and imm(insts[19:15]). If it is imm, the 5-bit imm(insts[19:15]) will be sign-extend to XLEN-bit. 
    logic        	                    rs1_data_valid                                   
} DIV_RS_t; 

// MUL and MAC reservation station struct
typedef struct packed {   
    logic   [`ROB_DEPTH_WIDTH-1:0]      rob_entry,
    FUNCT6_e                            uop_func,
    EXE_OPCODE_e                        uop_opcode,
    logic   [`VCSR_VXRM-1:0]            vxrm,               // rounding mode and saturate mode
 
    logic   [`VLEN-1:0]                 vs1_data,           
    EEW_e                               vs1_eew,
    logic                               vs1_data_valid, 
    ELE_TYPE_t                          vs1_type, 
    logic   [`VLEN-1:0]                 vs2_data,	        
    EEW_e                               vs2_eew,
    logic                               vs2_data_valid, 
    ELE_TYPE_t                          vs2_type, 
    logic   [`VLEN-1:0]                 vs3_data,	        
    EEW_e                               vs3_eew,
    logic                               vs3_data_valid, 
    ELE_TYPE_t                          vs3_type, 
    logic   [`XLEN-1:0] 	            rs1_data,           // rs1_data could be from X[rs1] and imm(insts[19:15]). If it is imm, the 5-bit imm(insts[19:15]) will be sign-extend to XLEN-bit. 
    logic        	                    rs1_data_valid   
} MUL_RS_t;    

// PMT and RDT reservation station struct
typedef struct packed {   
    logic   [`ROB_DEPTH_WIDTH-1:0]      rob_entry,
    FUNCT6_e                            uop_func,
    EXE_OPCODE_e                        uop_opcode,

    logic                               vm,                 // Identify vmerge and vmv in the same uop_funct(6'b010111).
    VS1_u                               vs1,                // when vs1_data_valid=0, vs1 field is valid and used to decode some OPMVV uops
    logic   [`VLEN-1:0]                 vs1_data,           // when vs1_data_valid=1, vs1_data is valid as a vector operand
    EEW_e                               vs1_eew,
    logic                               vs1_data_valid, 
    ELE_TYPE_t                          vs1_type, 
    logic   [`VLEN-1:0]                 vs2_data,	        
    EEW_e                               vs2_eew,
    logic                               vs2_data_valid, 
    ELE_TYPE_t                          vs2_type, 
    logic   [`XLEN-1:0] 	            rs1_data,           // rs1_data could be from X[rs1] and imm(insts[19:15]). If it is imm, the 5-bit imm(insts[19:15]) will be sign-extend to XLEN-bit. 
    logic        	                    rs1_data_valid   
} PMT_RDT_RS_t;    

// LSU reservation station struct
typedef struct packed {   
    logic   [`PC_WIDTH-1:0]             uop_pc,
    logic   [`ROB_DEPTH_WIDTH-1:0]      uop_id,
    LSU_TYPE_t                          uop_funct,  

    logic                               vidx_valid, 
    logic   [`REGFILE_INDEX_WIDTH-1:0]  vidx_addr,
    logic   [`VLEN-1:0]                 vidx_data,                  // vs2        
    ELE_TYPE_t                          vs2_type,        
    logic                               vregfile_read_valid, 
    logic   [`REGFILE_INDEX_WIDTH-1:0]  vregfile_read_addr,
    logic   [`VLEN-1:0]                 vregfile_read_data          // vs3       
    ELE_TYPE_t                          vs3_type, 
} LSU_RS_t;    

/*
EX stage, 
*/
// send uop to LSU
typedef struct packed {   
    // RVV send to uop_pc to help LSU match the vld/vst uop
    logic   [`PC_WIDTH-1:0]             uop_pc,     
    // When LSU submit the result to RVV, LSU need to attend uop_id to help RVV retire the uop in ROB  
    logic   [`ROB_DEPTH_WIDTH-1:0]      uop_id,     
    // Vector regfile index interface for indexed vld/vst
	logic 								vidx_valid,
	logic	[`REGFILE_INDEX_WIDTH-1:0]	vidx_addr,
  	logic	[`VLEN-1:0]					vidx_data,              // vs2
    ELE_TYPE_t                          vs2_type,               // mask for vs2
    // Vector regfile read interface for vst
	logic 								vregfile_read_valid,
  	logic	[`REGFILE_INDEX_WIDTH-1:0]	vregfile_read_addr,
  	logic	[`VLEN-1:0] 				vregfile_read_data,		// vs3     
    ELE_TYPE_t                          vs3_type                // mask for vs3
} UOP_LSU_RVV2RVS_t;  

// LSU feedback to RVV
typedef struct packed {   
    // When LSU submit the result to RVV, LSU need to attend uop_id to help RVV retire the uop in ROB
    logic   [`ROB_DEPTH_WIDTH-1:0]      uop_id,   
    // LSU uop type
    // When LSU complete the vstore uop, it need to tell RVV done signal and attend uop_id to help RVV retire the uops
    LSU_IS_STORE_e                      uop_type,               // when load, it means the uop is vld. It enables vregfile_write_addr and vregfile_write_data, and submit the vector data to ROB
                                                                // when store, it means this store uop is done in LSU, ROB can retire this uop.
	// Vector regfile write interface for vld
  	logic	[`REGFILE_INDEX_WIDTH-1:0] 	vregfile_write_addr,
  	logic	[`VLEN-1:0] 				vregfile_write_data, 	// vd   
    ELE_TYPE_t                          vs1_type                // mask for vd
} UOP_LSU_RVS2RVV_t;  

// ReOrder Buffer data struct
typedef enum logic [0] {
    VRF,
    XRF
} W_DATA_TYPE_t;

typedef struct packed {
    logic                               valid,              // Total valid
    logic   [`REGFILE_INDEX_WIDTH-1:0]  w_index,        
    logic   [`VLEN-1:0]                 w_data,             // when w_type=XRF, w_data[`XLEN-1:0] will store the scalar result
    W_DATA_TYPE_t                       w_type,
    logic                               w_valid,                    
    ELE_TYPE_t                          ele_type, 
    VECTOR_CSR_t                        vector_csr,
    logic                               last_uop_valid     
} ROB_t;  

/*
WB stage, bypass and write back to VRF/XRF, trap handler
*/
// write back to XRF
typedef struct packed {
    logic   [`REGFILE_INDEX_WIDTH-1:0]  w_index, 
    logic   [`XLEN-1:0]                 w_data 
} WB_XRF_t;  

// write back to VRF
typedef struct packed {
    logic   [`REGFILE_INDEX_WIDTH-1:0]  w_index, 
    logic   [`VLEN-1:0]                 w_data,
    logic   [`VLENB-1:0]                w_strobe 
} WB_VRF_t;  

// trap handle
typedef enum logic [0] {
    DECODE,             // RVS find some illegal instructions when decoding, 
                        // which means a trap occurs to the instruction that is NOT executing in RVV.
                        // So RVV will stop receiving new instructions from RVS, and complete all instructions in RVV.
    LSU,                // RVS find some illegal instructions when complete LSU transaction, like bus error,
                        // which means a trap occurs to the instruction that is executing in RVV.
                        // So RVV will top CQ to receive new instructions and flush Command Queue and Uops Queue, 
                        // and complete the instructions in EX, ME and WB stage. And RVS need to send rob_entry of that exception instruction.
                        // After RVV retire all uops before that exception instruction, RVV response a ready signal for trap application.
    LSU_FF              // fault only first load, need to confirm whether has TLB or not.
} TRAP_INFO_e;

typedef struct packed {
    logic                               trap_apply,
    TRAP_INFO_e                         trap_info, 
    logic   [`ROB_DEPTH_WIDTH-1:0]      trap_uop_rob_entry
} TRAP_t;  

