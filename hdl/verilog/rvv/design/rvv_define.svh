`ifndef HDL_VERILOG_RVV_DESIGN_RVV_DEFINE_SVH
`define HDL_VERILOG_RVV_DESIGN_RVV_DEFINE_SVH

// number of scalar core issue lane
`define ISSUE_LANE              4

// the max number of instructions are decoded per cycle in DE stage
`define NUM_DE_INST             2

// the max number of uops are written to Uops Queue per cycle in DE stage
`define NUM_DE_UOP              4

// the max number of uops are dispated per cycle in DP stage
`define NUM_DP_UOP              2

// the max number of uops are retired per cycle in WB stage
`define NUM_RT_UOP              4

`define CQ_DEPTH
`define UQ_DEPTH
`define ROB_DEPTH               8
`define ROB_DEPTH_WIDTH         $clog2(`ROB_DEPTH)

`define PC_WIDTH                32
`define INST_WIDTH              27
`define XLEN                    32
`define REGFILE_INDEX_WIDTH     5

// an instruction will be split to EMUL_max=8 uops at most
`define EMUL_MAX                8
`define UOP_INDEX_WIDTH         $clog2(`EMUL_MAX)

// Vector CSR
`define VLEN                    128
`define VLENB                   `VLEN/8

// vstart < VLMAX_max and vl <= VLMAX_max, VLMAX_max=VLEN*LMUL_max/SEW_min=12
`define VSTART_WIDTH            $clog2(`VLEN)
`define VL_WIDTH                $clog2(`VLEN)+1
`define VTYPE_VILL_WIDTH        1
`define VTYPE_VMA_WIDTH         1
`define VTYPE_VTA_WIDTH         1
`define VTYPE_VSEW_WIDTH        3
`define VTYPE_VLMUL_WIDTH       3
`define VCSR_VXRM_WIDTH         2
`define VCSR_VXSAT_WIDTH        1

// Instruction encoding
`define FUNCT6_WIDTH            6
`define VM_WIDTH                1
`define VS2_WIDTH               5
`define UMOP_WIDTH              5
`define VS1_WIDTH               5
`define IMM_WIDTH               5
`define FUNCT3_WIDTH            3
`define VD_WIDTH                5
`define RD_WIDTH                5
`define OPCODE_WIDTH            7
  
// vtype.vlmul
`define LMUL1_4                 3'b110
`define LMUL1_2                 3'b111
`define LMUL1                   3'b000
`define LMUL2                   3'b001
`define LMUL4                   3'b010
`define LMUL8                   3'b011

// vtype.vsew
`define SEW8                    3'b000
`define SEW16                   3'b001
`define SEW32                   3'b010

// <nr> field used in vmv<nr>.v instruction
`define NREG1                   3'b000
`define NREG2                   3'b001
`define NREG4                   3'b011
`define NREG8                   3'b111

// instruction opcode
`define OPCODE_LOAD             2'b00
`define OPCODE_STORE            2'b01
// configuration(vset*) and arithmetic instructions
`define OPCODE_ARI_CFG          2'b10

// Reservation Station data width
`define ALU_RS_WIDTH            $bits(ALU_RS_t)

`endif  // HDL_VERILOG_RVV_DESIGN_RVV_DEFINE_SVH
