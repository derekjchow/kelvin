`ifndef ALU_DEFINE_SVH
`define ALU_DEFINE_SVH

typedef enum logic [0:0]{
  ADDSUB_VADD, 
  ADDSUB_VSUB
} F_ADDSUB_e;   

typedef enum logic [1:0]{
  SHIFT_SLL, 
  SHIFT_SRL,
  SHIFT_SRA
} F_SHIFT_e;   

`endif // ALU_DEFINE_SVH

