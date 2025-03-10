`ifndef HDL_VERILOG_RVV_DESIGN_RVV_DEFINE_SVH
`define HDL_VERILOG_RVV_DESIGN_RVV_DEFINE_SVH

// number of scalar core issue lane
`define ISSUE_LANE              4

// the max number of instructions are decoded per cycle in DE stage
`define NUM_DE_INST             2

// the max number of uops are written to Uops Queue per cycle in DE stage
`define NUM_DE_UOP              4
`define NUM_DE_UOP_WIDTH        $clog2(`NUM_DE_UOP)+1

// the max number of uops are dispated per cycle in DP stage
`define NUM_DP_UOP              2
`define NUM_DP_VRF              `NUM_DP_UOP*2

// the max number of processor unit in EX stage
`define NUM_ALU                 2
`define NUM_PMTRDT              2
`define NUM_MUL                 2
`define NUM_DIV                 1
`define NUM_LSU                 2
`define NUM_PU                  `NUM_ALU+`NUM_PMTRDT+`NUM_MUL+`NUM_DIV+`NUM_LSU

// the max number of uops are retired per cycle in RT stage
`define NUM_RT_UOP              4

// the depth of queue/station/buffer
`define CQ_DEPTH                8
`define UQ_DEPTH                16
`define ALU_RS_DEPTH            4
`define PMTRDT_RS_DEPTH         8
`define MUL_RS_DEPTH            4
`define DIV_RS_DEPTH            4
`define LSU_RS_DEPTH            4
`define ROB_DEPTH               8
`define ROB_DEPTH_WIDTH         $clog2(`ROB_DEPTH)

`define PC_WIDTH                32
`define XLEN                    32
`define BYTE_WIDTH              8
`define HWORD_WIDTH             16
`define WORD_WIDTH              32

// an instruction will be split to EMUL_max=8 uops at most
`define EMUL_MAX                8
`define UOP_INDEX_WIDTH         $clog2(`EMUL_MAX)

// Vector CSR
`define VLEN                    128
`define VLENB                   `VLEN/8
// vstart < VLMAX_max and vl <= VLMAX_max, VLMAX_max=VLEN*LMUL_max/SEW_min=128
`define VLMAX                   `VLEN
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
`define NFIELD_WIDTH            3
`define VM_WIDTH                1
`define REGFILE_INDEX_WIDTH     5
`define UMOP_WIDTH              5
`define NREG_WIDTH              3
`define IMM_WIDTH               5
`define FUNCT3_WIDTH            3
`define OPCODE_WIDTH            7

// Uops Queue data width
`define UQ_WIDTH                $bits(UOP_QUEUE_t)

// Reservation Station data width
`define ALU_RS_WIDTH            $bits(ALU_RS_t)

// V0 mask regsiter index^M
`define V0_INDEX                5'b00000

`endif  // HDL_VERILOG_RVV_DESIGN_RVV_DEFINE_SVH
