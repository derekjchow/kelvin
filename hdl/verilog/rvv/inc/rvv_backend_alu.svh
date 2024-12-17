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

`endif // ALU_DEFINE_SVH
