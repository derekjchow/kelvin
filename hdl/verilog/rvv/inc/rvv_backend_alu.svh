`ifndef ALU_DEFINE_SVH
`define ALU_DEFINE_SVH

typedef enum logic [0:0]{
  ADDSUB_VADD, 
  ADDSUB_VSUB
} ADDSUB_e;   

typedef enum logic [1:0]{
  SHIFT_SLL, 
  SHIFT_SRL,
  SHIFT_SRA
} SHIFT_e;   

typedef enum logic [0:0]{
  GET_MIN, 
  GET_MAX
} GET_MIN_MAX_e;  

typedef struct packed {
  logic                                      result_valid_viota;
  logic   [`VLEN/64-1:0][63:0][$clog2(64):0] result_data_viota_per64;
}PKG_VIOTA_t;

`endif // ALU_DEFINE_SVH
