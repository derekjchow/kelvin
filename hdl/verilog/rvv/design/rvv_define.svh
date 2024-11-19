// number of scalar core issue lane
`define ISSUE_LANE              4
// the max number of instructions are decoded per cycle in ID stage
`define NUM_DE_INST             2
// the max number of uops are dispated per cycle in DP stage
`define NUM_DP_UOP              2
//
`define NUM_DP_RS
// the max number of uops are retired per cycle in WB stage
`define NUM_WB_UOP              4

`define CQ_DEPTH
`define UQ_DEPTH
`define ROB_DEPTH               8
`define ROB_DEPTH_WIDTH         $clog2(`ROB_DEPTH)

`define PC_WIDTH                32
`define INST_WIDTH              27
`define XLEN                    32
`define REGFILE_INDEX_WIDTH     5
// an instruction will be split to EMUL_max=8 uops at most, so UOP_INDEX_WITH is log2(8).
`define UOP_INDEX_WIDTH         3

// Vector CSR
`define VLEN                    128
`define VLENB                   `VLEN/8
// vstart <= VLMAX_max and vl <= VLMAX_max, VLMAX_max=VLEN*LMUL_max/SEW_min=128
`define VSTART_WIDTH            $clog2(`VLEN)+1
`define VL_WIDTH                $clog2(`VLEN)+1
`define VTYPE_VILL              1
`define VTYPE_VMA               1
`define VTYPE_VTA               1
`define VTYPE_VSEW              3
`define VTYPE_VLMUL             3
`define VCSR_VXRM               2
`define VCSR_VXSAT              1
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

// Reservation Station data width
`define ALU_RS_WIDTH            $bits(ALU_RS_t)



















