
`ifndef HDL_VERILOG_RVV_DESIGN_RVV_SVH
`include "rvv_backend.svh"
`endif
`ifndef ALU_DEFINE_SVH
`include "rvv_backend_alu.svh"
`endif

module rvv_backend_alu_unit_addsub
(
  alu_uop_valid,
  alu_uop,
  result_valid,
  result
);
//
// interface signals
//
  // ALU RS handshake signals
  input   logic                   alu_uop_valid;
  input   ALU_RS_t                alu_uop;

  // ALU send result signals to ROB
  output  logic                   result_valid;
  output  PU2ROB_t                result;

//
// internal signals
//
  // ALU_RS_t struct signals
  logic   [`ROB_DEPTH_WIDTH-1:0]  rob_entry;
  FUNCT6_u                        uop_funct6;
  logic   [`FUNCT3_WIDTH-1:0]     uop_funct3;
  logic   [`VSTART_WIDTH-1:0]     vstart;
  logic   [`VL_WIDTH-1:0]         vl;       
  logic                           vm;       
  RVVXRM                          vxrm;       
  logic   [`VLEN-1:0]             v0_data;
  logic                           v0_data_valid;
  logic   [`VLEN-1:0]             vd_data;           
  logic                           vd_data_valid;
  logic   [`VLEN-1:0]             vs1_data;           
  logic                           vs1_data_valid; 
  logic   [`VLEN-1:0]             vs2_data;	        
  logic                           vs2_data_valid;  
  EEW_e                           vs2_eew;
  logic   [`XLEN-1:0] 	          rs1_data;        
  logic        	                  rs1_data_valid;
  logic   [`UOP_INDEX_WIDTH-1:0]  uop_index;          

  // execute 
  // add and sub instructions
  logic   [`VLENB-1:0]                                v0_data_in_use;
  logic   [`VLENB-1:0][`BYTE_WIDTH-1:0]               src2_data;
  logic   [`VLENB-1:0][`BYTE_WIDTH-1:0]               src1_data;
  logic   [`VLENB-1:0][`BYTE_WIDTH-1:0]               product8;
  logic   [`VLEN/`HWORD_WIDTH-1:0][`HWORD_WIDTH-1:0]  product16;
  logic   [`VLEN/`WORD_WIDTH-1:0][`WORD_WIDTH-1:0]    product32;
  logic   [`VLENB-1:0][`BYTE_WIDTH-1:0]               round8_src;
  logic   [`VLEN/`HWORD_WIDTH-1:0][`HWORD_WIDTH-1:0]  round16_src;
  logic   [`VLEN/`WORD_WIDTH-1:0][`WORD_WIDTH-1:0]    round32_src;
  logic   [`VLENB-1:0][`BYTE_WIDTH-1:0]               round8;
  logic   [`VLEN/`HWORD_WIDTH-1:0][`HWORD_WIDTH-1:0]  round16;
  logic   [`VLEN/`WORD_WIDTH-1:0][`WORD_WIDTH-1:0]    round32;
  logic   [`VLENB-1:0]                                cin;
  logic   [`VLENB-1:0]                                cout8;
  logic   [`VLEN/`HWORD_WIDTH-1:0]                    cout16;
  logic   [`VLEN/`WORD_WIDTH-1:0]                     cout32;
  logic   [`VLENB-1:0]                                addu_upoverflow;
  logic   [`VLENB-1:0]                                add_upoverflow;
  logic   [`VLENB-1:0]                                add_underoverflow;
  logic   [`VLENB-1:0]                                subu_underoverflow;
  logic   [`VLENB-1:0]                                sub_upoverflow;
  logic   [`VLENB-1:0]                                sub_underoverflow;
  logic   [`VLENB-1:0][`BYTE_WIDTH-1:0]               result_minmax8;
  logic   [`VLEN/`HWORD_WIDTH-1:0][`HWORD_WIDTH-1:0]  result_minmax16;
  logic   [`VLEN/`WORD_WIDTH-1:0][`WORD_WIDTH-1:0]    result_minmax32;
  logic   [`VLEN-1:0]                                 result_data;   // regular data for EEW_vd = 8b,16b,32b
  ADDSUB_e                                            opcode;
  
  // for-loop
  genvar                                              j;

//
// prepare source data to calculate    
//
  // split ALU_RS_t struct
  assign  rob_entry      = alu_uop.rob_entry;
  assign  uop_funct6     = alu_uop.uop_funct6;
  assign  uop_funct3     = alu_uop.uop_funct3;
  assign  vstart         = alu_uop.vstart;
  assign  vl             = alu_uop.vl;
  assign  vm             = alu_uop.vm;
  assign  vxrm           = alu_uop.vxrm;
  assign  v0_data        = alu_uop.v0_data;
  assign  v0_data_valid  = alu_uop.v0_data_valid;
  assign  vd_data        = alu_uop.vd_data;
  assign  vd_data_valid  = alu_uop.vd_data_valid;
  assign  vs1_data       = alu_uop.vs1_data;
  assign  vs1_data_valid = alu_uop.vs1_data_valid;
  assign  vs2_data       = alu_uop.vs2_data;
  assign  vs2_data_valid = alu_uop.vs2_data_valid;
  assign  vs2_eew        = alu_uop.vs2_eew;
  assign  rs1_data       = alu_uop.rs1_data;
  assign  rs1_data_valid = alu_uop.rs1_data_valid;
  assign  uop_index      = alu_uop.uop_index;

//  
// prepare source data 
//
  // prepare valid signal 
  always_comb begin
    // initial the data
    result_valid = 'b0;

    case(uop_funct3) 
      OPIVV: begin
        case(uop_funct6.ari_funct6)
          VADD,
          VSUB,
          VSADD,
          VSSUB,
          VSADDU,
          VSSUBU: begin
            result_valid = alu_uop_valid&vs2_data_valid&vs1_data_valid;
          end

          VADC,
          VSBC: begin
            result_valid = alu_uop_valid&vs2_data_valid&vs1_data_valid&(vm==1'b0)&v0_data_valid;
          end

          VMINU,
          VMIN,
          VMAXU,
          VMAX: begin
            result_valid = alu_uop_valid&vs1_data_valid&vs2_data_valid;
          end
        endcase
      end

      OPIVX: begin
        case(uop_funct6.ari_funct6)
          VADD,
          VSUB,
          VRSUB,
          VSADD,
          VSSUB,
          VSADDU,
          VSSUBU: begin
            result_valid = alu_uop_valid&vs2_data_valid&rs1_data_valid;
          end

          VADC,
          VSBC: begin
            result_valid = alu_uop_valid&vs2_data_valid&rs1_data_valid&(vm==1'b0)&v0_data_valid;
          end

          VMINU,
          VMIN,
          VMAXU,
          VMAX: begin
            result_valid = alu_uop_valid&rs1_data_valid&vs2_data_valid;
          end
        endcase
      end
      OPIVI: begin
        case(uop_funct6.ari_funct6)
          VADD,
          VRSUB,
          VSADD,
          VSADDU: begin
            result_valid = alu_uop_valid&vs2_data_valid&rs1_data_valid;
          end

          VADC: begin
            result_valid = alu_uop_valid&vs2_data_valid&rs1_data_valid&(vm==1'b0)&v0_data_valid;
          end
        endcase
      end

      OPMVV: begin
        case(uop_funct6.ari_funct6)
          VWADDU,
          VWADD,
          VWSUBU,
          VWSUB: begin
            result_valid = alu_uop_valid&vs2_data_valid&vs1_data_valid&((vs2_eew==EEW8)|(vs2_eew==EEW16));
          end

          VWADDU_W,
          VWADD_W,
          VWSUBU_W,
          VWSUB_W: begin
            result_valid = alu_uop_valid&vs2_data_valid&vs1_data_valid&((vs2_eew==EEW16)|(vs2_eew==EEW32));
          end

          VAADDU,
          VAADD,
          VASUBU,
          VASUB: begin
            result_valid = alu_uop_valid&vs2_data_valid&vs1_data_valid;
          end
        endcase
      end
      
      OPMVX: begin
        case(uop_funct6.ari_funct6)
          VWADDU,
          VWADD,
          VWSUBU,
          VWSUB: begin
            result_valid = alu_uop_valid&vs2_data_valid&rs1_data_valid&((vs2_eew==EEW8)|(vs2_eew==EEW16));
          end

          VWADDU_W,
          VWADD_W,
          VWSUBU_W,
          VWSUB_W: begin
            result_valid = alu_uop_valid&vs2_data_valid&rs1_data_valid&((vs2_eew==EEW16)|(vs2_eew==EEW32));
          end

          VAADDU,
          VAADD,
          VASUBU,
          VASUB: begin
            result_valid = alu_uop_valid&vs2_data_valid&rs1_data_valid;
          end
        endcase
      end
    endcase
  end
 
  // prepare source data
  always_comb begin
    // initial the data
    src2_data    = 'b0;
    src1_data    = 'b0;

    case(uop_funct3) 
      OPIVV: begin
        case(uop_funct6.ari_funct6)
          VADD,
          VSUB,
          VADC,
          VSBC,
          VSADDU,
          VSADD,
          VSSUBU,
          VSSUB,
          VMINU,
          VMIN,
          VMAXU,
          VMAX: begin
            src2_data = vs2_data;
            src1_data = vs1_data;
          end
        endcase
      end

      OPIVX: begin
        case(uop_funct6.ari_funct6)
          VADD,
          VSUB,
          VADC,
          VSBC,
          VSADDU,
          VSADD,
          VSSUBU,
          VSSUB,
          VMINU,
          VMIN,
          VMAXU,
          VMAX: begin
            src2_data = vs2_data;

            for(int i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
              case(vs2_eew)
                EEW8: begin
                  src1_data[4*i]   = rs1_data[0 +: `BYTE_WIDTH];
                  src1_data[4*i+1] = rs1_data[0 +: `BYTE_WIDTH];
                  src1_data[4*i+2] = rs1_data[0 +: `BYTE_WIDTH];
                  src1_data[4*i+3] = rs1_data[0 +: `BYTE_WIDTH];
                end
                EEW16: begin  
                  src1_data[4*i]   = rs1_data[0             +: `BYTE_WIDTH];
                  src1_data[4*i+1] = rs1_data[1*`BYTE_WIDTH +: `BYTE_WIDTH];
                  src1_data[4*i+2] = rs1_data[0             +: `BYTE_WIDTH];
                  src1_data[4*i+3] = rs1_data[1*`BYTE_WIDTH +: `BYTE_WIDTH];
                end
                EEW32: begin 
                  src1_data[4*i]   = rs1_data[0             +: `BYTE_WIDTH];
                  src1_data[4*i+1] = rs1_data[1*`BYTE_WIDTH +: `BYTE_WIDTH];
                  src1_data[4*i+2] = rs1_data[2*`BYTE_WIDTH +: `BYTE_WIDTH];
                  src1_data[4*i+3] = rs1_data[3*`BYTE_WIDTH +: `BYTE_WIDTH];
                end
              endcase
            end
          end
          
          VRSUB: begin
            for(int i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
              case(vs2_eew)
                EEW8: begin
                  src2_data[4*i]   = rs1_data[0 +: `BYTE_WIDTH];
                  src2_data[4*i+1] = rs1_data[0 +: `BYTE_WIDTH];
                  src2_data[4*i+2] = rs1_data[0 +: `BYTE_WIDTH];
                  src2_data[4*i+3] = rs1_data[0 +: `BYTE_WIDTH];
                end
                EEW16: begin  
                  src2_data[4*i]   = rs1_data[0             +: `BYTE_WIDTH];
                  src2_data[4*i+1] = rs1_data[1*`BYTE_WIDTH +: `BYTE_WIDTH];
                  src2_data[4*i+2] = rs1_data[0             +: `BYTE_WIDTH];
                  src2_data[4*i+3] = rs1_data[1*`BYTE_WIDTH +: `BYTE_WIDTH];
                end
                EEW32: begin 
                  src2_data[4*i]   = rs1_data[0             +: `BYTE_WIDTH];
                  src2_data[4*i+1] = rs1_data[1*`BYTE_WIDTH +: `BYTE_WIDTH];
                  src2_data[4*i+2] = rs1_data[2*`BYTE_WIDTH +: `BYTE_WIDTH];
                  src2_data[4*i+3] = rs1_data[3*`BYTE_WIDTH +: `BYTE_WIDTH];
                end
              endcase
            end
            
            src1_data = vs2_data;
          end
        endcase
      end

      OPIVI: begin
        case(uop_funct6.ari_funct6)
          VADD,
          VADC,
          VSADDU,
          VSADD: begin
            src2_data = vs2_data;

            for(int i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
              case(vs2_eew)
                EEW8: begin
                  src1_data[4*i]   = rs1_data[0 +: `BYTE_WIDTH];
                  src1_data[4*i+1] = rs1_data[0 +: `BYTE_WIDTH];
                  src1_data[4*i+2] = rs1_data[0 +: `BYTE_WIDTH];
                  src1_data[4*i+3] = rs1_data[0 +: `BYTE_WIDTH];
                end
                EEW16: begin  
                  src1_data[4*i]   = rs1_data[0             +: `BYTE_WIDTH];
                  src1_data[4*i+1] = rs1_data[1*`BYTE_WIDTH +: `BYTE_WIDTH];
                  src1_data[4*i+2] = rs1_data[0             +: `BYTE_WIDTH];
                  src1_data[4*i+3] = rs1_data[1*`BYTE_WIDTH +: `BYTE_WIDTH];
                end
                EEW32: begin 
                  src1_data[4*i]   = rs1_data[0             +: `BYTE_WIDTH];
                  src1_data[4*i+1] = rs1_data[1*`BYTE_WIDTH +: `BYTE_WIDTH];
                  src1_data[4*i+2] = rs1_data[2*`BYTE_WIDTH +: `BYTE_WIDTH];
                  src1_data[4*i+3] = rs1_data[3*`BYTE_WIDTH +: `BYTE_WIDTH];
                end
              endcase
            end
          end
          
          VRSUB: begin
            for(int i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
              case(vs2_eew)
                EEW8: begin
                  src2_data[4*i]   = rs1_data[0 +: `BYTE_WIDTH];
                  src2_data[4*i+1] = rs1_data[0 +: `BYTE_WIDTH];
                  src2_data[4*i+2] = rs1_data[0 +: `BYTE_WIDTH];
                  src2_data[4*i+3] = rs1_data[0 +: `BYTE_WIDTH];
                end
                EEW16: begin  
                  src2_data[4*i]   = rs1_data[0             +: `BYTE_WIDTH];
                  src2_data[4*i+1] = rs1_data[1*`BYTE_WIDTH +: `BYTE_WIDTH];
                  src2_data[4*i+2] = rs1_data[0             +: `BYTE_WIDTH];
                  src2_data[4*i+3] = rs1_data[1*`BYTE_WIDTH +: `BYTE_WIDTH];
                end
                EEW32: begin 
                  src2_data[4*i]   = rs1_data[0             +: `BYTE_WIDTH];
                  src2_data[4*i+1] = rs1_data[1*`BYTE_WIDTH +: `BYTE_WIDTH];
                  src2_data[4*i+2] = rs1_data[2*`BYTE_WIDTH +: `BYTE_WIDTH];
                  src2_data[4*i+3] = rs1_data[3*`BYTE_WIDTH +: `BYTE_WIDTH];
                end
              endcase
            end

            src1_data = vs2_data;
          end
        endcase
      end

      OPMVV: begin
        case(uop_funct6.ari_funct6)
          VWADDU,
          VWSUBU: begin
            for(int i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
              case(vs2_eew)
                EEW8: begin
                  if(uop_index[0]==1'b0) begin
                    src2_data[4*i]   = vs2_data[(2*i)*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src2_data[4*i+1] = 'b0;
                    src2_data[4*i+2] = vs2_data[(2*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src2_data[4*i+3] = 'b0;

                    src1_data[4*i]   = vs1_data[(2*i)*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_data[4*i+1] = 'b0;
                    src1_data[4*i+2] = vs1_data[(2*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_data[4*i+3] = 'b0;
                  end
                  else begin
                    src2_data[4*i]   = vs2_data[`VLEN/2+(2*i  )*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src2_data[4*i+1] = 'b0;
                    src2_data[4*i+2] = vs2_data[`VLEN/2+(2*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src2_data[4*i+3] = 'b0;

                    src1_data[4*i]   = vs1_data[`VLEN/2+(2*i  )*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_data[4*i+1] = 'b0;
                    src1_data[4*i+2] = vs1_data[`VLEN/2+(2*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_data[4*i+3] = 'b0;
                  end
                end
                EEW16: begin
                  if(uop_index[0]==1'b0) begin
                    src2_data[4*i]   = vs2_data[(2*i  )*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src2_data[4*i+1] = vs2_data[(2*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src2_data[4*i+2] = 'b0;
                    src2_data[4*i+3] = 'b0;

                    src1_data[4*i]   = vs1_data[(2*i  )*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_data[4*i+1] = vs1_data[(2*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_data[4*i+2] = 'b0;
                    src1_data[4*i+3] = 'b0;
                  end
                  else begin
                    src2_data[4*i]   = vs2_data[`VLEN/2+(2*i  )*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src2_data[4*i+1] = vs2_data[`VLEN/2+(2*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src2_data[4*i+2] = 'b0;
                    src2_data[4*i+3] = 'b0;

                    src1_data[4*i]   = vs1_data[`VLEN/2+(2*i  )*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_data[4*i+1] = vs1_data[`VLEN/2+(2*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_data[4*i+2] = 'b0;
                    src1_data[4*i+3] = 'b0;
                  end
                end
              endcase
            end
          end

          VWADD,
          VWSUB: begin
            for(int i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
              case(vs2_eew)
                EEW8: begin
                  if(uop_index[0]==1'b0) begin
                    src2_data[4*i]   =              vs2_data[(2*i  )*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src2_data[4*i+1] = {`BYTE_WIDTH{vs2_data[(2*i+1)*`BYTE_WIDTH-1]}};
                    src2_data[4*i+2] =              vs2_data[(2*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src2_data[4*i+3] = {`BYTE_WIDTH{vs2_data[(2*i+2)*`BYTE_WIDTH-1]}};

                    src1_data[4*i]   =              vs1_data[(2*i  )*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_data[4*i+1] = {`BYTE_WIDTH{vs1_data[(2*i+1)*`BYTE_WIDTH-1]}};
                    src1_data[4*i+2] =              vs1_data[(2*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_data[4*i+3] = {`BYTE_WIDTH{vs1_data[(2*i+2)*`BYTE_WIDTH-1]}};
                  end
                  else begin
                    src2_data[4*i]   =              vs2_data[`VLEN/2+(2*i  )*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src2_data[4*i+1] = {`BYTE_WIDTH{vs2_data[`VLEN/2+(2*i+1)*`BYTE_WIDTH-1]}};
                    src2_data[4*i+2] =              vs2_data[`VLEN/2+(2*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src2_data[4*i+3] = {`BYTE_WIDTH{vs2_data[`VLEN/2+(2*i+2)*`BYTE_WIDTH-1]}};

                    src1_data[4*i]   =              vs1_data[`VLEN/2+(2*i  )*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_data[4*i+1] = {`BYTE_WIDTH{vs1_data[`VLEN/2+(2*i+1)*`BYTE_WIDTH-1]}};
                    src1_data[4*i+2] =              vs1_data[`VLEN/2+(2*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_data[4*i+3] = {`BYTE_WIDTH{vs1_data[`VLEN/2+(2*i+2)*`BYTE_WIDTH-1]}};
                  end
                end
                EEW16: begin
                  if(uop_index[0]==1'b0) begin
                    src2_data[4*i]   =              vs2_data[(2*i  )*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src2_data[4*i+1] =              vs2_data[(2*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src2_data[4*i+2] = {`BYTE_WIDTH{vs2_data[(2*i+2)*`BYTE_WIDTH-1]}};
                    src2_data[4*i+3] = {`BYTE_WIDTH{vs2_data[(2*i+2)*`BYTE_WIDTH-1]}};

                    src1_data[4*i]   =              vs1_data[(2*i  )*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_data[4*i+1] =              vs1_data[(2*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_data[4*i+2] = {`BYTE_WIDTH{vs1_data[(2*i+2)*`BYTE_WIDTH-1]}};
                    src1_data[4*i+3] = {`BYTE_WIDTH{vs1_data[(2*i+2)*`BYTE_WIDTH-1]}};
                  end
                  else begin
                    src2_data[4*i]   =              vs2_data[`VLEN/2+(2*i  )*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src2_data[4*i+1] =              vs2_data[`VLEN/2+(2*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src2_data[4*i+2] = {`BYTE_WIDTH{vs2_data[`VLEN/2+(2*i+2)*`BYTE_WIDTH-1]}};
                    src2_data[4*i+3] = {`BYTE_WIDTH{vs2_data[`VLEN/2+(2*i+2)*`BYTE_WIDTH-1]}};

                    src1_data[4*i]   =              vs1_data[`VLEN/2+(2*i  )*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_data[4*i+1] =              vs1_data[`VLEN/2+(2*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_data[4*i+2] = {`BYTE_WIDTH{vs1_data[`VLEN/2+(2*i+2)*`BYTE_WIDTH-1]}};
                    src1_data[4*i+3] = {`BYTE_WIDTH{vs1_data[`VLEN/2+(2*i+2)*`BYTE_WIDTH-1]}};
                  end
                end
              endcase
            end
          end

          VWADDU_W,
          VWSUBU_W: begin
            src2_data = vs2_data;

            for(int i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
              case(vs2_eew)
                EEW16: begin
                  if(uop_index[0]==1'b0) begin
                    src1_data[4*i]   = vs1_data[(2*i  )*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_data[4*i+1] = 'b0;
                    src1_data[4*i+2] = vs1_data[(2*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_data[4*i+3] = 'b0;
                  end
                  else begin
                    src1_data[4*i]   = vs1_data[`VLEN/2+(2*i  )*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_data[4*i+1] = 'b0; 
                    src1_data[4*i+2] = vs1_data[`VLEN/2+(2*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_data[4*i+3] = 'b0;
                  end
                end
                EEW32: begin
                  if(uop_index[0]==1'b0) begin
                    src1_data[4*i]   = vs1_data[(2*i  )*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_data[4*i+1] = vs1_data[(2*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_data[4*i+2] = 'b0;
                    src1_data[4*i+3] = 'b0;
                  end
                  else begin
                    src1_data[4*i]   = vs1_data[`VLEN/2+(2*i  )*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_data[4*i+1] = vs1_data[`VLEN/2+(2*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_data[4*i+2] = 'b0;
                    src1_data[4*i+3] = 'b0;
                  end
                end
              endcase
            end
          end

          VWADD_W,
          VWSUB_W: begin
            src2_data = vs2_data;

            for(int i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
              case(vs2_eew)
                EEW16: begin
                  if(uop_index[0]==1'b0) begin
                    src1_data[4*i]   =              vs1_data[(2*i  )*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_data[4*i+1] = {`BYTE_WIDTH{vs1_data[(2*i+1)*`BYTE_WIDTH-1]}}; 
                    src1_data[4*i+2] =              vs1_data[(2*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_data[4*i+3] = {`BYTE_WIDTH{vs1_data[(2*i+2)*`BYTE_WIDTH-1]}};
                  end
                  else begin
                    src1_data[4*i]   =              vs1_data[`VLEN/2+(2*i  )*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_data[4*i+1] = {`BYTE_WIDTH{vs1_data[`VLEN/2+(2*i+1)*`BYTE_WIDTH-1]}}; 
                    src1_data[4*i+2] =              vs1_data[`VLEN/2+(2*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_data[4*i+3] = {`BYTE_WIDTH{vs1_data[`VLEN/2+(2*i+2)*`BYTE_WIDTH-1]}}; 
                  end
                end
                EEW32: begin
                  if(uop_index[0]==1'b0) begin
                    src1_data[4*i]   =              vs1_data[(2*i  )*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_data[4*i+1] =              vs1_data[(2*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_data[4*i+2] = {`BYTE_WIDTH{vs1_data[(2*i+2)*`BYTE_WIDTH-1]}};
                    src1_data[4*i+3] = {`BYTE_WIDTH{vs1_data[(2*i+2)*`BYTE_WIDTH-1]}};
                  end
                  else begin
                    src1_data[4*i]   =              vs1_data[`VLEN/2+(2*i  )*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_data[4*i+1] =              vs1_data[`VLEN/2+(2*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_data[4*i+2] = {`BYTE_WIDTH{vs1_data[`VLEN/2+(2*i+2)*`BYTE_WIDTH-1]}};
                    src1_data[4*i+3] = {`BYTE_WIDTH{vs1_data[`VLEN/2+(2*i+2)*`BYTE_WIDTH-1]}};
                  end
                end
              endcase
            end
          end

          VAADDU,
          VASUBU,
          VAADD,
          VASUB: begin
            src2_data = vs2_data;
            src1_data = vs1_data;
          end
        endcase
      end
      
      OPMVX: begin
        case(uop_funct6.ari_funct6)
          VWADDU,
          VWSUBU: begin
            for(int i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
              case(vs2_eew)
                EEW8: begin
                  src1_data[4*i]   =  rs1_data[0 +: `BYTE_WIDTH];
                  src1_data[4*i+1] = 'b0;
                  src1_data[4*i+2] = rs1_data[0 +: `BYTE_WIDTH];
                  src1_data[4*i+3] = 'b0;

                  if(uop_index[0]==1'b0) begin
                    src2_data[4*i]   = vs2_data[(2*i  )*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src2_data[4*i+1] = 'b0;
                    src2_data[4*i+2] = vs2_data[(2*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src2_data[4*i+3] = 'b0;
                  end
                  else begin
                    src2_data[4*i]   = vs2_data[`VLEN/2+(2*i  )*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src2_data[4*i+1] = 'b0;
                    src2_data[4*i+2] = vs2_data[`VLEN/2+(2*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src2_data[4*i+3] = 'b0;
                  end
                end
                EEW16: begin
                  src1_data[4*i]   = rs1_data[0 +: `BYTE_WIDTH];
                  src1_data[4*i+1] = rs1_data[`BYTE_WIDTH +: `BYTE_WIDTH];
                  src1_data[4*i+2] = 'b0;
                  src1_data[4*i+3] = 'b0;

                  if(uop_index[0]==1'b0) begin
                    src2_data[4*i]   = vs2_data[(2*i  )*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src2_data[4*i+1] = vs2_data[(2*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src2_data[4*i+2] = 'b0;
                    src2_data[4*i+3] = 'b0;
                  end
                  else begin
                    src2_data[4*i]   = vs2_data[`VLEN/2+(2*i  )*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src2_data[4*i+1] = vs2_data[`VLEN/2+(2*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src2_data[4*i+2] = 'b0;
                    src2_data[4*i+3] = 'b0;
                  end
                end
              endcase
            end
          end

          VWADD,
          VWSUB: begin
            for(int i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
              case(vs2_eew)
                EEW8: begin
                  src1_data[4*i]   =              rs1_data[0 +: `BYTE_WIDTH];
                  src1_data[4*i+1] = {`BYTE_WIDTH{rs1_data[`BYTE_WIDTH-1]}};
                  src1_data[4*i+2] =              rs1_data[0 +: `BYTE_WIDTH];
                  src1_data[4*i+3] = {`BYTE_WIDTH{rs1_data[`BYTE_WIDTH-1]}};

                  if(uop_index[0]==1'b0) begin
                    src2_data[4*i]   =              vs2_data[(2*i  )*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src2_data[4*i+1] = {`BYTE_WIDTH{vs2_data[(2*i+1)*`BYTE_WIDTH-1]}};
                    src2_data[4*i+2] =              vs2_data[(2*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src2_data[4*i+3] = {`BYTE_WIDTH{vs2_data[(2*i+2)*`BYTE_WIDTH-1]}};
                  end
                  else begin
                    src2_data[4*i]   =              vs2_data[`VLEN/2+(2*i  )*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src2_data[4*i+1] = {`BYTE_WIDTH{vs2_data[`VLEN/2+(2*i+1)*`BYTE_WIDTH-1]}};
                    src2_data[4*i+2] =              vs2_data[`VLEN/2+(2*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src2_data[4*i+3] = {`BYTE_WIDTH{vs2_data[`VLEN/2+(2*i+2)*`BYTE_WIDTH-1]}};
                  end
                end
                EEW16: begin
                  src1_data[4*i]   = rs1_data[0 +: `BYTE_WIDTH];
                  src1_data[4*i+1] = rs1_data[`BYTE_WIDTH +: `BYTE_WIDTH];
                  src1_data[4*i+2] = {`BYTE_WIDTH{rs1_data[2*`BYTE_WIDTH-1]}};
                  src1_data[4*i+3] = {`BYTE_WIDTH{rs1_data[2*`BYTE_WIDTH-1]}};

                  if(uop_index[0]==1'b0) begin
                    src2_data[4*i]   =              vs2_data[(2*i  )*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src2_data[4*i+1] =              vs2_data[(2*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src2_data[4*i+2] = {`BYTE_WIDTH{vs2_data[(2*i+2)*`BYTE_WIDTH-1]}};
                    src2_data[4*i+3] = {`BYTE_WIDTH{vs2_data[(2*i+2)*`BYTE_WIDTH-1]}};
                  end
                  else begin
                    src2_data[4*i]   =              vs2_data[`VLEN/2+(2*i  )*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src2_data[4*i+1] =              vs2_data[`VLEN/2+(2*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src2_data[4*i+2] = {`BYTE_WIDTH{vs2_data[`VLEN/2+(2*i+2)*`BYTE_WIDTH-1]}};
                    src2_data[4*i+3] = {`BYTE_WIDTH{vs2_data[`VLEN/2+(2*i+2)*`BYTE_WIDTH-1]}};
                  end
                end
              endcase
            end
          end

          VWADDU_W,
          VWSUBU_W: begin
            src2_data = vs2_data;

            for(int i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
              case(vs2_eew)
                EEW16: begin
                  src1_data[4*i]   = rs1_data[0 +: `BYTE_WIDTH];
                  src1_data[4*i+1] = 'b0;
                  src1_data[4*i+2] = rs1_data[0 +: `BYTE_WIDTH];
                  src1_data[4*i+3] = 'b0;
                end
                EEW32: begin
                  src1_data[4*i]   = rs1_data[0 +: `BYTE_WIDTH];
                  src1_data[4*i+1] = rs1_data[`BYTE_WIDTH +: `BYTE_WIDTH];
                  src1_data[4*i+2] = 'b0;
                  src1_data[4*i+3] = 'b0;
                end
              endcase
            end
          end

          VWADD_W,
          VWSUB_W: begin
            src2_data = vs2_data;

            for(int i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
              case(vs2_eew)
                EEW16: begin
                  src1_data[4*i]   =              rs1_data[0 +: `BYTE_WIDTH];
                  src1_data[4*i+1] = {`BYTE_WIDTH{rs1_data[`BYTE_WIDTH-1]}};
                  src1_data[4*i+2] =              rs1_data[0 +: `BYTE_WIDTH];
                  src1_data[4*i+3] = {`BYTE_WIDTH{rs1_data[`BYTE_WIDTH-1]}};
                end
                EEW32: begin
                  src1_data[4*i]   =              rs1_data[0 +: `BYTE_WIDTH];
                  src1_data[4*i+1] =              rs1_data[`BYTE_WIDTH +: `BYTE_WIDTH];
                  src1_data[4*i+2] = {`BYTE_WIDTH{rs1_data[2*`BYTE_WIDTH-1]}};
                  src1_data[4*i+3] = {`BYTE_WIDTH{rs1_data[2*`BYTE_WIDTH-1]}};
                end
              endcase
            end
          end

          VAADDU,
          VASUBU,
          VAADD,
          VASUB: begin
            src2_data = vs2_data;

            for(int i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
              case(vs2_eew)
                EEW8: begin
                  src1_data[4*i]   = rs1_data[0 +: `BYTE_WIDTH];
                  src1_data[4*i+1] = rs1_data[0 +: `BYTE_WIDTH];
                  src1_data[4*i+2] = rs1_data[0 +: `BYTE_WIDTH];
                  src1_data[4*i+3] = rs1_data[0 +: `BYTE_WIDTH];
                end
                EEW16: begin  
                  src1_data[4*i]   = rs1_data[0             +: `BYTE_WIDTH];
                  src1_data[4*i+1] = rs1_data[1*`BYTE_WIDTH +: `BYTE_WIDTH];
                  src1_data[4*i+2] = rs1_data[0             +: `BYTE_WIDTH];
                  src1_data[4*i+3] = rs1_data[1*`BYTE_WIDTH +: `BYTE_WIDTH];
                end
                EEW32: begin 
                  src1_data[4*i]   = rs1_data[0             +: `BYTE_WIDTH];
                  src1_data[4*i+1] = rs1_data[1*`BYTE_WIDTH +: `BYTE_WIDTH];
                  src1_data[4*i+2] = rs1_data[2*`BYTE_WIDTH +: `BYTE_WIDTH];
                  src1_data[4*i+3] = rs1_data[3*`BYTE_WIDTH +: `BYTE_WIDTH];
                end
              endcase
            end
          end
        endcase
      end
    endcase
  end
 
  // prepare cin
  always_comb begin
    v0_data_in_use = 'b0;

    case(vs2_eew)
      EEW8: begin
        v0_data_in_use = v0_data[{uop_index,{($clog2(`VLENB)){1'b0}}} +: `VLENB];
      end
      EEW16: begin
        v0_data_in_use = {{(`VLENB/2){1'b0}}, v0_data[{uop_index,{($clog2(`VLENB/2)){1'b0}}} +: `VLENB/2]};
      end
      EEW32: begin
        v0_data_in_use = {{(`VLENB*3/4){1'b0}}, v0_data[{uop_index,{($clog2(`VLENB/4)){1'b0}}} +: `VLENB/4]};
      end
    endcase
  end

  generate
    for (j=0;j<`VLEN/`WORD_WIDTH;j=j+1) begin: GET_CIN
      always_comb begin
        // initial the data
        cin[4*j]   = 'b0;
        cin[4*j+1] = 'b0;
        cin[4*j+2] = 'b0;
        cin[4*j+3] = 'b0;

        case(uop_funct3) 
          OPIVV,
          OPIVX,
          OPIVI: begin
            case(uop_funct6.ari_funct6)
              VADC,
              VSBC: begin
                case(vs2_eew)
                  EEW8: begin                    
                    cin[4*j]   = v0_data_in_use[4*j];
                    cin[4*j+1] = v0_data_in_use[4*j+1];
                    cin[4*j+2] = v0_data_in_use[4*j+2];
                    cin[4*j+3] = v0_data_in_use[4*j+3];
                  end
                  EEW16: begin
                    cin[4*j]   = v0_data_in_use[2*j];
                    cin[4*j+1] = 'b0;
                    cin[4*j+2] = v0_data_in_use[2*j+1];
                    cin[4*j+3] = 'b0;
                  end
                  EEW32: begin
                    cin[4*j]   = v0_data_in_use[j];
                    cin[4*j+1] = 'b0;
                    cin[4*j+2] = 'b0;
                    cin[4*j+3] = 'b0;
                  end
                endcase
              end
            endcase
          end
        endcase
      end
    end
  endgenerate

  // get opcode for f_addsub
  always_comb begin
    // initial the data
    opcode = ADDSUB_VADD;

    // prepare source data
    case(uop_funct3) 
      OPIVV,
      OPIVX,
      OPIVI: begin
        case(uop_funct6.ari_funct6)    
          VADD,
          VADC,
          VSADDU,
          VSADD: begin
            opcode = ADDSUB_VADD;
          end
          VSUB,
          VRSUB,
          VSBC,
          VSSUBU,
          VSSUB,
          VMINU,
          VMIN,
          VMAXU,
          VMAX: begin
            opcode = ADDSUB_VSUB;
          end
        endcase
      end
      OPMVV,
      OPMVX: begin
        case(uop_funct6.ari_funct6)    
          VWADDU,
          VWADD,
          VWADDU_W,
          VWADD_W,
          VAADDU,
          VAADD: begin
            opcode = ADDSUB_VADD;
          end
          VWSUBU,
          VWSUB,
          VWSUBU_W,
          VWSUB_W,
          VASUBU,
          VASUB: begin
            opcode = ADDSUB_VSUB;
          end
        endcase
      end
    endcase
  end

//    
// calculate the result
//
  // for add and sub instructions
  generate
    for (j=0;j<`VLENB;j=j+1) begin: EXE_VADDSUB_PROD8
      assign {cout8[j],product8[j]} = f_full_addsub8(opcode, src2_data[j], src1_data[j], cin[j]);
    end
  endgenerate
  
  generate
    for (j=0;j<`VLEN/`HWORD_WIDTH;j=j+1) begin: EXE_VADDSUB_PROD16
      assign {cout16[j],product16[j]} = {f_half_addsub8(opcode, {cout8[2*j+1],product8[2*j+1]}, cout8[2*j]), product8[2*j]};
    end
  endgenerate 

  generate
    for (j=0;j<`VLEN/`WORD_WIDTH;j=j+1) begin: EXE_VADDSUB_PROD32
      assign {cout32[j],product32[j]} = {f_half_addsub16(opcode, {cout16[2*j+1],product16[2*j+1]}, cout16[2*j]), product16[2*j]};
    end
  endgenerate 
  
  // rounding result
  always_comb begin
    round8_src  = 'b0;
    round16_src = 'b0;
    round32_src = 'b0;
    round8  = 'b0;
    round16 = 'b0;
    round32 = 'b0;
    
    case(uop_funct6.ari_funct6)
      VAADDU,
      VASUBU: begin
        case(vxrm)
          RNU: begin
            for(int i=0;i<`VLENB;i=i+1) begin
              round8_src[i] = {cout8[i],product8[i][`BYTE_WIDTH-1:1]};
              round8[i] = product8[i][0] ? round8_src[i]+1'b1 : round8_src[i];
            end

            for(int i=0;i<`VLEN/`HWORD_WIDTH;i=i+1) begin
              round16_src[i] = {cout16[i],product16[i][`HWORD_WIDTH-1:1]};
              round16[i] = product16[i][0] ? round16_src[i]+1'b1 : round16_src[i];
            end

            for(int i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
              round32_src[i] = {cout32[i],product32[i][`WORD_WIDTH-1:1]};
              round32[i] = product32[i][0] ? f_src_plus1(round32_src[i]) : round32_src[i];
            end
          end
          RNE: begin
            for(int i=0;i<`VLENB;i=i+1) begin
              round8_src[i] = {cout8[i],product8[i][`BYTE_WIDTH-1:1]};
              round8[i] = product8[i][0]&product8[i][1] ? round8_src[i]+1'b1 : round8_src[i];
            end
    
            for(int i=0;i<`VLEN/`HWORD_WIDTH;i=i+1) begin
              round16_src[i] = {cout16[i],product16[i][`HWORD_WIDTH-1:1]};
              round16[i] = product16[i][0]&product16[i][1] ? round16_src[i]+1'b1 : round16_src[i];
            end
    
            for(int i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
              round32_src[i] = {cout32[i],product32[i][`WORD_WIDTH-1:1]};
              round32[i] = product32[i][0]&product32[i][1] ? f_src_plus1(round32_src[i]) : round32_src[i];
            end
          end
          RDN: begin
            for(int i=0;i<`VLENB;i=i+1) begin
              round8_src[i] = {cout8[i],product8[i][`BYTE_WIDTH-1:1]}; 
              round8[i] = round8_src[i];
            end
    
            for(int i=0;i<`VLEN/`HWORD_WIDTH;i=i+1) begin
              round16_src[i] = {cout16[i],product16[i][`HWORD_WIDTH-1:1]}; 
              round16[i] = round16_src[i];
            end
    
            for(int i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
              round32_src[i] = {cout32[i],product32[i][`WORD_WIDTH-1:1]}; 
              round32[i] = round32_src[i];
            end
          end
          ROD: begin
            for(int i=0;i<`VLENB;i=i+1) begin
              round8_src[i] = {cout8[i],product8[i][`BYTE_WIDTH-1:1]};
              round8[i] = (!product8[i][1])&product8[i][0] ? round8_src[i]+1'b1 : round8_src[i];
            end
    
            for(int i=0;i<`VLEN/`HWORD_WIDTH;i=i+1) begin
              round16_src[i] = {cout16[i],product16[i][`HWORD_WIDTH-1:1]};
              round16[i] = (!product16[i][1])&product16[i][0] ? round16_src[i]+1'b1 : round16_src[i]; 
            end
    
            for(int i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
              round32_src[i] = {cout32[i],product32[i][`WORD_WIDTH-1:1]}; 
              round32[i] = (!product32[i][1])&product32[i][0] ? f_src_plus1(round32_src[i]) : round32_src[i]; 
            end
          end
        endcase
      end
      VAADD,
      VASUB: begin
        case(vxrm)
          RNU: begin
            for(int i=0;i<`VLENB;i=i+1) begin
              round8_src[i] = {src2_data[i][`BYTE_WIDTH-1]^src1_data[i][`BYTE_WIDTH-1]?(!cout8[i]):cout8[i],product8[i][`BYTE_WIDTH-1:1]};
              round8[i] = product8[i][0] ? round8_src[i]+1'b1 : round8_src[i]; 
                                            
            end
            
            for(int i=0;i<`VLEN/`HWORD_WIDTH;i=i+1) begin
              round16_src[i] = {src2_data[2*i+1][`BYTE_WIDTH-1]^src1_data[2*i+1][`BYTE_WIDTH-1]?(!cout16[i]):cout16[i],product16[i][`HWORD_WIDTH-1:1]};
              round16[i] = product16[i][0] ? round16_src[i]+1'b1 : round16_src[i]; 
            end

            for(int i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
              round32_src[i] = {src2_data[4*i+3][`BYTE_WIDTH-1]^src1_data[4*i+3][`BYTE_WIDTH-1]?(!cout32[i]):cout32[i],product32[i][`WORD_WIDTH-1:1]};
              round32[i] = product32[i][0] ? f_src_plus1(round32_src[i]) : round32_src[i]; 
            end
          end
          RNE: begin
            for(int i=0;i<`VLENB;i=i+1) begin
              round8_src[i] = {src2_data[i][`BYTE_WIDTH-1]^src1_data[i][`BYTE_WIDTH-1]?(!cout8[i]):cout8[i],product8[i][`BYTE_WIDTH-1:1]};
              round8[i] = product8[i][0]&product8[i][1] ? round8_src[i]+1'b1 : round8_src[i]; 
            end
    
            for(int i=0;i<`VLEN/`HWORD_WIDTH;i=i+1) begin
              round16_src[i] = {src2_data[2*i+1][`BYTE_WIDTH-1]^src1_data[2*i+1][`BYTE_WIDTH-1]?(!cout16[i]):cout16[i],product16[i][`HWORD_WIDTH-1:1]};
              round16[i] = product16[i][0]&product16[i][1] ? round16_src[i]+1'b1 : round16_src[i]; 
            end
    
            for(int i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
              round32_src[i] = {src2_data[4*i+3][`BYTE_WIDTH-1]^src1_data[4*i+3][`BYTE_WIDTH-1]?(!cout32[i]):cout32[i],product32[i][`WORD_WIDTH-1:1]};
              round32[i] = product32[i][0]&product32[i][1] ? f_src_plus1(round32_src[i]) : round32_src[i]; 
            end
          end
          RDN: begin
            for(int i=0;i<`VLENB;i=i+1) begin
              round8_src[i] = {src2_data[i][`BYTE_WIDTH-1]^src1_data[i][`BYTE_WIDTH-1]?(!cout8[i]):cout8[i],product8[i][`BYTE_WIDTH-1:1]}; 
              round8[i] = round8_src[i];
            end
    
            for(int i=0;i<`VLEN/`HWORD_WIDTH;i=i+1) begin
              round16_src[i] = {src2_data[2*i+1][`BYTE_WIDTH-1]^src1_data[2*i+1][`BYTE_WIDTH-1]?(!cout16[i]):cout16[i],product16[i][`HWORD_WIDTH-1:1]}; 
              round16[i] = round16_src[i];
            end
    
            for(int i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
              round32_src[i] = {src2_data[4*i+3][`BYTE_WIDTH-1]^src1_data[4*i+3][`BYTE_WIDTH-1]?(!cout32[i]):cout32[i],product32[i][`WORD_WIDTH-1:1]}; 
              round32[i] = round32_src[i];
            end
          end
          ROD: begin
            for(int i=0;i<`VLENB;i=i+1) begin
              round8_src[i] = {src2_data[i][`BYTE_WIDTH-1]^src1_data[i][`BYTE_WIDTH-1]?(!cout8[i]):cout8[i],product8[i][`BYTE_WIDTH-1:1]};
              round8[i] = (!product8[i][1])&product8[i][0] ? round8_src[i]+1'b1 : round8_src[i]; 
            end
    
            for(int i=0;i<`VLEN/`HWORD_WIDTH;i=i+1) begin
              round16_src[i] = {src2_data[2*i+1][`BYTE_WIDTH-1]^src1_data[2*i+1][`BYTE_WIDTH-1]?(!cout16[i]):cout16[i],product16[i][`HWORD_WIDTH-1:1]};
              round16[i] = (!product16[i][1])&product16[i][0] ? round16_src[i]+1'b1 : round16_src[i]; 
            end
    
            for(int i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
              round32_src[i] = {src2_data[4*i+3][`BYTE_WIDTH-1]^src1_data[4*i+3][`BYTE_WIDTH-1]?(!cout32[i]):cout32[i],product32[i][`WORD_WIDTH-1:1]};
              round32[i] = (!product32[i][1])&product32[i][0] ? f_src_plus1(round32_src[i]) : round32_src[i]; 
            end
          end
        endcase
      end
    endcase
  end

  // overflow check
  generate 
    for (j=0;j<`VLEN/`WORD_WIDTH;j++) begin: OVERFLOW
      always_comb begin
        // initial
        addu_upoverflow[   4*j +: 4] = 'b0;
        add_upoverflow[    4*j +: 4] = 'b0;
        add_underoverflow[ 4*j +: 4] = 'b0;
        subu_underoverflow[4*j +: 4] = 'b0;
        sub_upoverflow[    4*j +: 4] = 'b0;
        sub_underoverflow[ 4*j +: 4] = 'b0;
          
        case(vs2_eew)
          EEW8: begin
            addu_upoverflow[4*j +: 4] = {cout8[4*j+3],cout8[4*j+2],cout8[4*j+1],cout8[4*j]};

            add_upoverflow[4*j +: 4] = {
              ((product8[4*j+3][`BYTE_WIDTH-1]==1'b1)&(src2_data[4*j+3][`BYTE_WIDTH-1]==1'b0)&(src1_data[4*j+3][`BYTE_WIDTH-1]==1'b0)),
              ((product8[4*j+2][`BYTE_WIDTH-1]==1'b1)&(src2_data[4*j+2][`BYTE_WIDTH-1]==1'b0)&(src1_data[4*j+2][`BYTE_WIDTH-1]==1'b0)),
              ((product8[4*j+1][`BYTE_WIDTH-1]==1'b1)&(src2_data[4*j+1][`BYTE_WIDTH-1]==1'b0)&(src1_data[4*j+1][`BYTE_WIDTH-1]==1'b0)),
              ((product8[4*j  ][`BYTE_WIDTH-1]==1'b1)&(src2_data[4*j  ][`BYTE_WIDTH-1]==1'b0)&(src1_data[4*j  ][`BYTE_WIDTH-1]==1'b0))};

            add_underoverflow[4*j +: 4] = {
              ((product8[4*j+3][`BYTE_WIDTH-1]==1'b0)&(src2_data[4*j+3][`BYTE_WIDTH-1]==1'b1)&(src1_data[4*j+3][`BYTE_WIDTH-1]==1'b1)),
              ((product8[4*j+2][`BYTE_WIDTH-1]==1'b0)&(src2_data[4*j+2][`BYTE_WIDTH-1]==1'b1)&(src1_data[4*j+2][`BYTE_WIDTH-1]==1'b1)),
              ((product8[4*j+1][`BYTE_WIDTH-1]==1'b0)&(src2_data[4*j+1][`BYTE_WIDTH-1]==1'b1)&(src1_data[4*j+1][`BYTE_WIDTH-1]==1'b1)),
              ((product8[4*j  ][`BYTE_WIDTH-1]==1'b0)&(src2_data[4*j  ][`BYTE_WIDTH-1]==1'b1)&(src1_data[4*j  ][`BYTE_WIDTH-1]==1'b1))};
            
            subu_underoverflow[4*j +: 4] = {cout8[4*j+3],cout8[4*j+2],cout8[4*j+1],cout8[4*j]};

            sub_upoverflow[4*j +: 4] = {
              ((product8[4*j+3][`BYTE_WIDTH-1]==1'b1)&(src2_data[4*j+3][`BYTE_WIDTH-1]==1'b0)&(src1_data[4*j+3][`BYTE_WIDTH-1]==1'b1)),
              ((product8[4*j+2][`BYTE_WIDTH-1]==1'b1)&(src2_data[4*j+2][`BYTE_WIDTH-1]==1'b0)&(src1_data[4*j+2][`BYTE_WIDTH-1]==1'b1)),
              ((product8[4*j+1][`BYTE_WIDTH-1]==1'b1)&(src2_data[4*j+1][`BYTE_WIDTH-1]==1'b0)&(src1_data[4*j+1][`BYTE_WIDTH-1]==1'b1)),
              ((product8[4*j  ][`BYTE_WIDTH-1]==1'b1)&(src2_data[4*j  ][`BYTE_WIDTH-1]==1'b0)&(src1_data[4*j  ][`BYTE_WIDTH-1]==1'b1))};

            sub_underoverflow[4*j +: 4] = {
              ((product8[4*j+3][`BYTE_WIDTH-1]==1'b0)&(src2_data[4*j+3][`BYTE_WIDTH-1]==1'b1)&(src1_data[4*j+3][`BYTE_WIDTH-1]==1'b0)),
              ((product8[4*j+2][`BYTE_WIDTH-1]==1'b0)&(src2_data[4*j+2][`BYTE_WIDTH-1]==1'b1)&(src1_data[4*j+2][`BYTE_WIDTH-1]==1'b0)),
              ((product8[4*j+1][`BYTE_WIDTH-1]==1'b0)&(src2_data[4*j+1][`BYTE_WIDTH-1]==1'b1)&(src1_data[4*j+1][`BYTE_WIDTH-1]==1'b0)),
              ((product8[4*j  ][`BYTE_WIDTH-1]==1'b0)&(src2_data[4*j  ][`BYTE_WIDTH-1]==1'b1)&(src1_data[4*j  ][`BYTE_WIDTH-1]==1'b0))};
          end
          EEW16: begin
            addu_upoverflow[4*j +: 4] = {cout16[2*j+1],1'b0,cout16[2*j],1'b0};

            add_upoverflow[4*j +: 4] = {
              ((product16[2*j+1][`HWORD_WIDTH-1]==1'b1)&(src2_data[4*j+3][`BYTE_WIDTH-1]==1'b0)&(src1_data[4*j+3][`BYTE_WIDTH-1]==1'b0)),
              1'b0,
              ((product16[2*j  ][`HWORD_WIDTH-1]==1'b1)&(src2_data[4*j+1][`BYTE_WIDTH-1]==1'b0)&(src1_data[4*j+1][`BYTE_WIDTH-1]==1'b0)),
              1'b0};

            add_underoverflow[4*j +: 4] = {
              ((product16[2*j+1][`HWORD_WIDTH-1]==1'b0)&(src2_data[4*j+3][`BYTE_WIDTH-1]==1'b1)&(src1_data[4*j+3][`BYTE_WIDTH-1]==1'b1)),
              1'b0,
              ((product16[2*j  ][`HWORD_WIDTH-1]==1'b0)&(src2_data[4*j+1][`BYTE_WIDTH-1]==1'b1)&(src1_data[4*j+1][`BYTE_WIDTH-1]==1'b1)),
              1'b0};

            subu_underoverflow[4*j +: 4] = {cout16[2*j+1],1'b0,cout16[2*j],1'b0};

            sub_upoverflow[4*j +: 4] = {
              ((product16[2*j+1][`HWORD_WIDTH-1]==1'b1)&(src2_data[4*j+3][`BYTE_WIDTH-1]==1'b0)&(src1_data[4*j+3][`BYTE_WIDTH-1]==1'b1)),
              1'b0,
              ((product16[2*j  ][`HWORD_WIDTH-1]==1'b1)&(src2_data[4*j+1][`BYTE_WIDTH-1]==1'b0)&(src1_data[4*j+1][`BYTE_WIDTH-1]==1'b1)),
              1'b0};

            sub_underoverflow[4*j +: 4] = {
              ((product16[2*j+1][`HWORD_WIDTH-1]==1'b0)&(src2_data[4*j+3][`BYTE_WIDTH-1]==1'b1)&(src1_data[4*j+3][`BYTE_WIDTH-1]==1'b0)),
              1'b0,
              ((product16[2*j  ][`HWORD_WIDTH-1]==1'b0)&(src2_data[4*j+1][`BYTE_WIDTH-1]==1'b1)&(src1_data[4*j+1][`BYTE_WIDTH-1]==1'b0)),
              1'b0};
          end
          EEW32: begin
            addu_upoverflow[4*j +: 4] = {cout32[j],3'b0};

            add_upoverflow[4*j +: 4] = {
              ((product32[j][`WORD_WIDTH-1]==1'b1)&(src2_data[4*j+3][`BYTE_WIDTH-1]==1'b0)&(src1_data[4*j+3][`BYTE_WIDTH-1]==1'b0)),
              3'b0};

            add_underoverflow[4*j +: 4] = {
              ((product32[j][`WORD_WIDTH-1]==1'b0)&(src2_data[4*j+3][`BYTE_WIDTH-1]==1'b1)&(src1_data[4*j+3][`BYTE_WIDTH-1]==1'b1)),
              3'b0};

            subu_underoverflow[4*j +: 4] = {cout32[j],3'b0};

            sub_upoverflow[4*j +: 4] = {
              ((product32[j][`WORD_WIDTH-1]==1'b1)&(src2_data[4*j+3][`BYTE_WIDTH-1]==1'b0)&(src1_data[4*j+3][`BYTE_WIDTH-1]==1'b1)),
              3'b0};

            sub_underoverflow[4*j +: 4] = {
              ((product32[j][`WORD_WIDTH-1]==1'b0)&(src2_data[4*j+3][`BYTE_WIDTH-1]==1'b1)&(src1_data[4*j+3][`BYTE_WIDTH-1]==1'b0)),
              3'b0};
          end
        endcase
      end
    end
  endgenerate

  // assign to result_data
  generate 
    for (j=0;j<`VLEN/`WORD_WIDTH;j++) begin: GET_RESULT_DATA
      always_comb begin
        // initial the data
        result_data[j*`WORD_WIDTH +: `WORD_WIDTH] = 'b0;
        result_minmax8[4*j+3]  = 'b0;
        result_minmax8[4*j+2]  = 'b0;
        result_minmax8[4*j+1]  = 'b0;
        result_minmax8[4*j]    = 'b0;
        result_minmax16[2*j+1] = 'b0;
        result_minmax16[2*j]   = 'b0;
        result_minmax32[j]     = 'b0;
 
        // calculate result data
        case(uop_funct3) 
          OPIVV,
          OPIVX,
          OPIVI: begin
            case(uop_funct6.ari_funct6)
              VADD,
              VSUB,
              VRSUB,
              VADC,
              VSBC: begin
                case(vs2_eew)
                  EEW8: begin
                    result_data[j*`WORD_WIDTH +: `WORD_WIDTH] = {product8[4*j+3],product8[4*j+2],product8[4*j+1],product8[4*j]};
                  end
                  EEW16: begin
                    result_data[j*`WORD_WIDTH +: `WORD_WIDTH] = {product16[2*j+1],product16[2*j]};
                  end
                  EEW32: begin
                    result_data[j*`WORD_WIDTH +: `WORD_WIDTH] = product32[j];
                  end
                endcase
              end
              
              VSADDU: begin
                case(vs2_eew)
                  EEW8: begin
                    if(addu_upoverflow[4*j])
                      result_data[j*`WORD_WIDTH +: `BYTE_WIDTH] = 'hff;
                    else
                      result_data[j*`WORD_WIDTH +: `BYTE_WIDTH] = product8[4*j];
                      
                    if(addu_upoverflow[4*j+1])
                      result_data[j*`WORD_WIDTH+1*`BYTE_WIDTH +: `BYTE_WIDTH] = 'hff;
                    else
                      result_data[j*`WORD_WIDTH+1*`BYTE_WIDTH +: `BYTE_WIDTH] = product8[4*j+1];
                    
                    if(addu_upoverflow[4*j+2])
                      result_data[j*`WORD_WIDTH+2*`BYTE_WIDTH +: `BYTE_WIDTH] = 'hff;
                    else
                      result_data[j*`WORD_WIDTH+2*`BYTE_WIDTH +: `BYTE_WIDTH] = product8[4*j+2];

                    if(addu_upoverflow[4*j+3])
                      result_data[j*`WORD_WIDTH+3*`BYTE_WIDTH +: `BYTE_WIDTH] = 'hff;
                    else
                      result_data[j*`WORD_WIDTH+3*`BYTE_WIDTH +: `BYTE_WIDTH] = product8[4*j+3];
                  end
                  EEW16: begin
                    if(addu_upoverflow[4*j+1])
                      result_data[j*`WORD_WIDTH +: `HWORD_WIDTH] = 'hffff;
                    else
                      result_data[j*`WORD_WIDTH +: `HWORD_WIDTH] = product16[2*j];
                      
                    if(addu_upoverflow[4*j+3])
                      result_data[j*`WORD_WIDTH+1*`HWORD_WIDTH +: `HWORD_WIDTH] = 'hffff;
                    else
                      result_data[j*`WORD_WIDTH+1*`HWORD_WIDTH +: `HWORD_WIDTH] = product16[2*j+1];
                  end
                  EEW32: begin
                    if(addu_upoverflow[4*j+3])
                      result_data[j*`WORD_WIDTH +: `WORD_WIDTH] = 'hffff_ffff;
                    else
                      result_data[j*`WORD_WIDTH +: `WORD_WIDTH] = product32[j];
                  end
                endcase
              end

              VSADD: begin
                case(vs2_eew)
                  EEW8: begin
                    if (add_upoverflow[4*j])
                      result_data[j*`WORD_WIDTH +: `BYTE_WIDTH] = 'h7f;
                    else if (add_underoverflow[4*j])
                      result_data[j*`WORD_WIDTH +: `BYTE_WIDTH] = 'h80;
                    else
                      result_data[j*`WORD_WIDTH +: `BYTE_WIDTH] = product8[4*j];
                      
                    if (add_upoverflow[4*j+1])
                      result_data[j*`WORD_WIDTH+1*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h7f;
                    else if (add_underoverflow[4*j+1])
                      result_data[j*`WORD_WIDTH+1*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h80;
                    else
                      result_data[j*`WORD_WIDTH+1*`BYTE_WIDTH +: `BYTE_WIDTH] = product8[4*j+1];
                    
                    if (add_upoverflow[4*j+2])
                      result_data[j*`WORD_WIDTH+2*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h7f;
                    else if (add_underoverflow[4*j+2])
                      result_data[j*`WORD_WIDTH+2*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h80;
                    else
                      result_data[j*`WORD_WIDTH+2*`BYTE_WIDTH +: `BYTE_WIDTH] = product8[4*j+2];

                    if (add_upoverflow[4*j+3])
                      result_data[j*`WORD_WIDTH+3*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h7f;
                    else if (add_underoverflow[4*j+3])
                      result_data[j*`WORD_WIDTH+3*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h80;
                    else
                      result_data[j*`WORD_WIDTH+3*`BYTE_WIDTH +: `BYTE_WIDTH] = product8[4*j+3];
                  end
                  EEW16: begin
                    if (add_upoverflow[4*j+1])
                      result_data[j*`WORD_WIDTH +: `HWORD_WIDTH] = 'h7fff;
                    else if (add_underoverflow[4*j+1])
                      result_data[j*`WORD_WIDTH +: `HWORD_WIDTH] = 'h8000;
                    else
                      result_data[j*`WORD_WIDTH +: `HWORD_WIDTH] = product16[2*j];                   

                    if (add_upoverflow[4*j+3])
                      result_data[j*`WORD_WIDTH+1*`HWORD_WIDTH +: `HWORD_WIDTH] = 'h7fff;
                    else if (add_underoverflow[4*j+3])
                      result_data[j*`WORD_WIDTH+1*`HWORD_WIDTH +: `HWORD_WIDTH] = 'h8000;
                    else
                      result_data[j*`WORD_WIDTH+1*`HWORD_WIDTH +: `HWORD_WIDTH] = product16[2*j+1];                   
                  end
                  EEW32: begin
                    if (add_upoverflow[4*j+3])
                      result_data[j*`WORD_WIDTH +: `WORD_WIDTH] = 'h7fff_ffff;
                    else if (add_underoverflow[4*j+3])
                      result_data[j*`WORD_WIDTH +: `WORD_WIDTH] = 'h8000_0000;
                    else
                      result_data[j*`WORD_WIDTH +: `WORD_WIDTH] = product32[j]; 
                  end
                endcase
              end

              VSSUBU: begin
                case(vs2_eew)
                  EEW8: begin
                    if(subu_underoverflow[4*j])
                      result_data[j*`WORD_WIDTH +: `BYTE_WIDTH] = 'd0;
                    else
                      result_data[j*`WORD_WIDTH +: `BYTE_WIDTH] = product8[4*j];
                      
                    if(subu_underoverflow[4*j+1])
                      result_data[j*`WORD_WIDTH+1*`BYTE_WIDTH +: `BYTE_WIDTH] = 'd0;
                    else
                      result_data[j*`WORD_WIDTH+1*`BYTE_WIDTH +: `BYTE_WIDTH] = product8[4*j+1];
                    
                    if(subu_underoverflow[4*j+2])
                      result_data[j*`WORD_WIDTH+2*`BYTE_WIDTH +: `BYTE_WIDTH] = 'd0;
                    else
                      result_data[j*`WORD_WIDTH+2*`BYTE_WIDTH +: `BYTE_WIDTH] = product8[4*j+2];

                    if(subu_underoverflow[4*j+3])
                      result_data[j*`WORD_WIDTH+3*`BYTE_WIDTH +: `BYTE_WIDTH] = 'd0;
                    else
                      result_data[j*`WORD_WIDTH+3*`BYTE_WIDTH +: `BYTE_WIDTH] = product8[4*j+3];
                  end
                  EEW16: begin
                    if(subu_underoverflow[4*j+1])
                      result_data[j*`WORD_WIDTH +: `HWORD_WIDTH] = 'd0;
                    else
                      result_data[j*`WORD_WIDTH +: `HWORD_WIDTH] = product16[2*j];
                      
                    if(subu_underoverflow[4*j+3])
                      result_data[j*`WORD_WIDTH+1*`HWORD_WIDTH +: `HWORD_WIDTH] = 'd0;
                    else
                      result_data[j*`WORD_WIDTH+1*`HWORD_WIDTH +: `HWORD_WIDTH] = product16[2*j+1];
                  end
                  EEW32: begin
                    if(subu_underoverflow[4*j+3])
                      result_data[j*`WORD_WIDTH +: `WORD_WIDTH] = 'd0;
                    else
                      result_data[j*`WORD_WIDTH +: `WORD_WIDTH] = product32[j];
                  end
                endcase
              end

              VSSUB: begin
                case(vs2_eew)
                  EEW8: begin
                    if (sub_upoverflow[4*j])
                      result_data[j*`WORD_WIDTH +: `BYTE_WIDTH] = 'h7f;
                    else if (sub_underoverflow[4*j])
                      result_data[j*`WORD_WIDTH +: `BYTE_WIDTH] = 'h80;
                    else
                      result_data[j*`WORD_WIDTH +: `BYTE_WIDTH] = product8[4*j];
                      
                    if (sub_upoverflow[4*j+1])
                      result_data[j*`WORD_WIDTH+1*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h7f;
                    else if (sub_underoverflow[4*j+1])
                      result_data[j*`WORD_WIDTH+1*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h80;
                    else
                      result_data[j*`WORD_WIDTH+1*`BYTE_WIDTH +: `BYTE_WIDTH] = product8[4*j+1];
                    
                    if (sub_upoverflow[4*j+2])
                      result_data[j*`WORD_WIDTH+2*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h7f;
                    else if (sub_underoverflow[4*j+2])
                      result_data[j*`WORD_WIDTH+2*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h80;
                    else
                      result_data[j*`WORD_WIDTH+2*`BYTE_WIDTH +: `BYTE_WIDTH] = product8[4*j+2];

                    if (sub_upoverflow[4*j+3])
                      result_data[j*`WORD_WIDTH+3*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h7f;
                    else if (sub_underoverflow[4*j+3])
                      result_data[j*`WORD_WIDTH+3*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h80;
                    else
                      result_data[j*`WORD_WIDTH+3*`BYTE_WIDTH +: `BYTE_WIDTH] = product8[4*j+3];
                  end
                  EEW16: begin
                    if (sub_upoverflow[4*j+1])
                      result_data[j*`WORD_WIDTH +: `HWORD_WIDTH] = 'h7fff;
                    else if (sub_underoverflow[4*j+1])
                      result_data[j*`WORD_WIDTH +: `HWORD_WIDTH] = 'h8000;
                    else
                      result_data[j*`WORD_WIDTH +: `HWORD_WIDTH] = product16[2*j];                   

                    if (sub_upoverflow[4*j+3])
                      result_data[j*`WORD_WIDTH+1*`HWORD_WIDTH +: `HWORD_WIDTH] = 'h7fff;
                    else if (sub_underoverflow[4*j+3])
                      result_data[j*`WORD_WIDTH+1*`HWORD_WIDTH +: `HWORD_WIDTH] = 'h8000;
                    else
                      result_data[j*`WORD_WIDTH+1*`HWORD_WIDTH +: `HWORD_WIDTH] = product16[2*j+1];                   
                  end
                  EEW32: begin
                    if (sub_upoverflow[4*j+3])
                      result_data[j*`WORD_WIDTH +: `WORD_WIDTH] = 'h7fff_ffff;
                    else if (sub_underoverflow[4*j+3])
                      result_data[j*`WORD_WIDTH +: `WORD_WIDTH] = 'h8000_0000;
                    else
                      result_data[j*`WORD_WIDTH +: `WORD_WIDTH] = product32[j]; 
                  end
                endcase
              end

              VMINU: begin
                case(vs2_eew)
                  EEW8: begin
                    result_minmax8[4*j+3] = cout8[4*j+3] ? src2_data[4*j+3] : src1_data[4*j+3];
                    result_minmax8[4*j+2] = cout8[4*j+2] ? src2_data[4*j+2] : src1_data[4*j+2];
                    result_minmax8[4*j+1] = cout8[4*j+1] ? src2_data[4*j+1] : src1_data[4*j+1];
                    result_minmax8[4*j  ] = cout8[4*j  ] ? src2_data[4*j  ] : src1_data[4*j  ];

                    result_data[j*`WORD_WIDTH +: `WORD_WIDTH] = {result_minmax8[4*j+3],
                                                                 result_minmax8[4*j+2],
                                                                 result_minmax8[4*j+1],
                                                                 result_minmax8[4*j]};
                  end
                  EEW16: begin
                    result_minmax16[2*j+1] = cout16[2*j+1] ? {src2_data[4*j+3],src2_data[4*j+2]} : {src1_data[4*j+3],src1_data[4*j+2]}; 
                    result_minmax16[2*j  ] = cout16[2*j  ] ? {src2_data[4*j+1],src2_data[4*j  ]} : {src1_data[4*j+1],src1_data[4*j  ]};

                    result_data[j*`WORD_WIDTH +: `WORD_WIDTH] = {result_minmax16[2*j+1],
                                                                 result_minmax16[2*j]};
                  end
                  EEW32: begin
                    result_minmax32[j] = cout32[j] ? {src2_data[4*j+3],src2_data[4*j+2],src2_data[4*j+1],src2_data[4*j]}: 
                                                     {src1_data[4*j+3],src1_data[4*j+2],src1_data[4*j+1],src1_data[4*j]}; 

                    result_data[j*`WORD_WIDTH +: `WORD_WIDTH] = result_minmax32[j];
                  end
                endcase
              end

              VMIN: begin
                case(vs2_eew)
                  EEW8: begin
                    case({src2_data[4*j][`BYTE_WIDTH-1],src1_data[4*j][`BYTE_WIDTH-1]})
                      2'b10  : result_minmax8[4*j] = src2_data[4*j];
                      2'b01  : result_minmax8[4*j] = src1_data[4*j];
                      default: result_minmax8[4*j] = product8[4*j][`BYTE_WIDTH-1] ? src2_data[4*j] : src1_data[4*j];
                    endcase

                    case({src2_data[4*j+1][`BYTE_WIDTH-1],src1_data[4*j+1][`BYTE_WIDTH-1]})
                      2'b10  : result_minmax8[4*j+1] = src2_data[4*j+1];
                      2'b01  : result_minmax8[4*j+1] = src1_data[4*j+1];
                      default: result_minmax8[4*j+1] = product8[4*j+1][`BYTE_WIDTH-1] ? src2_data[4*j+1] : src1_data[4*j+1];
                    endcase

                    case({src2_data[4*j+2][`BYTE_WIDTH-1],src1_data[4*j+2][`BYTE_WIDTH-1]})
                      2'b10  : result_minmax8[4*j+2] = src2_data[4*j+2];
                      2'b01  : result_minmax8[4*j+2] = src1_data[4*j+2];
                      default: result_minmax8[4*j+2] = product8[4*j+2][`BYTE_WIDTH-1] ? src2_data[4*j+2] : src1_data[4*j+2];
                    endcase

                    case({src2_data[4*j+3][`BYTE_WIDTH-1],src1_data[4*j+3][`BYTE_WIDTH-1]})
                      2'b10  : result_minmax8[4*j+3] = src2_data[4*j+3];
                      2'b01  : result_minmax8[4*j+3] = src1_data[4*j+3];
                      default: result_minmax8[4*j+3] = product8[4*j+3][`BYTE_WIDTH-1] ? src2_data[4*j+3] : src1_data[4*j+3];
                    endcase

                    result_data[j*`WORD_WIDTH +: `WORD_WIDTH] = {result_minmax8[4*j+3],
                                                                 result_minmax8[4*j+2],
                                                                 result_minmax8[4*j+1],
                                                                 result_minmax8[4*j]};
                  end
                  EEW16: begin
                    case({src2_data[4*j+1][`BYTE_WIDTH-1],src1_data[4*j+1][`BYTE_WIDTH-1]})
                      2'b10  : result_minmax16[2*j] = {src2_data[4*j+1],src2_data[4*j]};
                      2'b01  : result_minmax16[2*j] = {src1_data[4*j+1],src1_data[4*j]};
                      default: result_minmax16[2*j] = product16[2*j][`HWORD_WIDTH-1] ? {src2_data[4*j+1],src2_data[4*j]} : {src1_data[4*j+1],src1_data[4*j]};
                    endcase

                    case({src2_data[4*j+3][`BYTE_WIDTH-1],src1_data[4*j+3][`BYTE_WIDTH-1]})
                      2'b10  : result_minmax16[2*j+1] = {src2_data[4*j+3],src2_data[4*j+2]};
                      2'b01  : result_minmax16[2*j+1] = {src1_data[4*j+3],src1_data[4*j+2]};
                      default: result_minmax16[2*j+1] = product16[2*j+1][`HWORD_WIDTH-1] ? {src2_data[4*j+3],src2_data[4*j+2]} : {src1_data[4*j+3],src1_data[4*j+2]};
                    endcase

                    result_data[j*`WORD_WIDTH +: `WORD_WIDTH] = {result_minmax16[2*j+1],
                                                                 result_minmax16[2*j]};
                  end
                  EEW32: begin
                    case({src2_data[4*j+3][`BYTE_WIDTH-1],src1_data[4*j+3][`BYTE_WIDTH-1]})
                      2'b10  : result_minmax32[j] = {src2_data[4*j+3],src2_data[4*j+2],src2_data[4*j+1],src2_data[4*j]};
                      2'b01  : result_minmax32[j] = {src1_data[4*j+3],src1_data[4*j+2],src1_data[4*j+1],src1_data[4*j]};
                      default: result_minmax32[j] = product32[j][`WORD_WIDTH-1] ? 
                                                      {src2_data[4*j+3],src2_data[4*j+2],src2_data[4*j+1],src2_data[4*j]}:
                                                      {src1_data[4*j+3],src1_data[4*j+2],src1_data[4*j+1],src1_data[4*j]}; 
                    endcase

                    result_data[j*`WORD_WIDTH +: `WORD_WIDTH] = result_minmax32[j];
                  end
                endcase
              end

              VMAXU: begin
                case(vs2_eew)
                  EEW8: begin
                    result_minmax8[4*j+3] = cout8[4*j+3] ? src1_data[4*j+3] : src2_data[4*j+3];
                    result_minmax8[4*j+2] = cout8[4*j+2] ? src1_data[4*j+2] : src2_data[4*j+2];
                    result_minmax8[4*j+1] = cout8[4*j+1] ? src1_data[4*j+1] : src2_data[4*j+1];
                    result_minmax8[4*j  ] = cout8[4*j  ] ? src1_data[4*j  ] : src2_data[4*j  ];

                    result_data[j*`WORD_WIDTH +: `WORD_WIDTH] = {result_minmax8[4*j+3],
                                                                 result_minmax8[4*j+2],
                                                                 result_minmax8[4*j+1],
                                                                 result_minmax8[4*j]};
                  end
                  EEW16: begin
                    result_minmax16[2*j+1] = cout16[2*j+1] ? {src1_data[4*j+3],src1_data[4*j+2]} : {src2_data[4*j+3],src2_data[4*j+2]}; 
                    result_minmax16[2*j  ] = cout16[2*j  ] ? {src1_data[4*j+1],src1_data[4*j  ]} : {src2_data[4*j+1],src2_data[4*j  ]};

                    result_data[j*`WORD_WIDTH +: `WORD_WIDTH] = {result_minmax16[2*j+1],
                                                                 result_minmax16[2*j]};
                  end
                  EEW32: begin
                    result_minmax32[j] = cout32[j] ? {src1_data[4*j+3],src1_data[4*j+2],src1_data[4*j+1],src1_data[4*j]}: 
                                                     {src2_data[4*j+3],src2_data[4*j+2],src2_data[4*j+1],src2_data[4*j]}; 

                    result_data[j*`WORD_WIDTH +: `WORD_WIDTH] = result_minmax32[j];
                  end
                endcase
              end

              VMAX: begin
                case(vs2_eew)
                  EEW8: begin
                    case({src2_data[4*j][`BYTE_WIDTH-1],src1_data[4*j][`BYTE_WIDTH-1]})
                      2'b01  : result_minmax8[4*j] = src2_data[4*j];
                      2'b10  : result_minmax8[4*j] = src1_data[4*j];
                      default: result_minmax8[4*j] = product8[4*j][`BYTE_WIDTH-1] ? src1_data[4*j] : src2_data[4*j];
                    endcase

                    case({src2_data[4*j+1][`BYTE_WIDTH-1],src1_data[4*j+1][`BYTE_WIDTH-1]})
                      2'b01  : result_minmax8[4*j+1] = src2_data[4*j+1];
                      2'b10  : result_minmax8[4*j+1] = src1_data[4*j+1];
                      default: result_minmax8[4*j+1] = product8[4*j+1][`BYTE_WIDTH-1] ? src1_data[4*j+1] : src2_data[4*j+1];
                    endcase

                    case({src2_data[4*j+2][`BYTE_WIDTH-1],src1_data[4*j+2][`BYTE_WIDTH-1]})
                      2'b01  : result_minmax8[4*j+2] = src2_data[4*j+2];
                      2'b10  : result_minmax8[4*j+2] = src1_data[4*j+2];
                      default: result_minmax8[4*j+2] = product8[4*j+2][`BYTE_WIDTH-1] ? src1_data[4*j+2] : src2_data[4*j+2];
                    endcase

                    case({src2_data[4*j+3][`BYTE_WIDTH-1],src1_data[4*j+3][`BYTE_WIDTH-1]})
                      2'b01  : result_minmax8[4*j+3] = src2_data[4*j+3];
                      2'b10  : result_minmax8[4*j+3] = src1_data[4*j+3];
                      default: result_minmax8[4*j+3] = product8[4*j+3][`BYTE_WIDTH-1] ? src1_data[4*j+3] : src2_data[4*j+3];
                    endcase

                    result_data[j*`WORD_WIDTH +: `WORD_WIDTH] = {result_minmax8[4*j+3],
                                                                 result_minmax8[4*j+2],
                                                                 result_minmax8[4*j+1],
                                                                 result_minmax8[4*j]};
                  end
                  EEW16: begin
                    case({src2_data[4*j+1][`BYTE_WIDTH-1],src1_data[4*j+1][`BYTE_WIDTH-1]})
                      2'b01  : result_minmax16[2*j] = {src2_data[4*j+1],src2_data[4*j]};
                      2'b10  : result_minmax16[2*j] = {src1_data[4*j+1],src1_data[4*j]};
                      default: result_minmax16[2*j] = product16[2*j][`HWORD_WIDTH-1] ? {src1_data[4*j+1],src1_data[4*j]} : {src2_data[4*j+1],src2_data[4*j]};
                    endcase

                    case({src2_data[4*j+3][`BYTE_WIDTH-1],src1_data[4*j+3][`BYTE_WIDTH-1]})
                      2'b01  : result_minmax16[2*j+1] = {src2_data[4*j+3],src2_data[4*j+2]};
                      2'b10  : result_minmax16[2*j+1] = {src1_data[4*j+3],src1_data[4*j+2]};
                      default: result_minmax16[2*j+1] = product16[2*j+1][`HWORD_WIDTH-1] ? {src1_data[4*j+3],src1_data[4*j+2]} : {src2_data[4*j+3],src2_data[4*j+2]};
                    endcase

                    result_data[j*`WORD_WIDTH +: `WORD_WIDTH] = {result_minmax16[2*j+1],
                                                                 result_minmax16[2*j]};
                  end
                  EEW32: begin
                    case({src2_data[4*j+3][`BYTE_WIDTH-1],src1_data[4*j+3][`BYTE_WIDTH-1]})
                      2'b01  : result_minmax32[j] = {src2_data[4*j+3],src2_data[4*j+2],src2_data[4*j+1],src2_data[4*j]};
                      2'b10  : result_minmax32[j] = {src1_data[4*j+3],src1_data[4*j+2],src1_data[4*j+1],src1_data[4*j]};
                      default: result_minmax32[j] = product32[j][`WORD_WIDTH-1] ? 
                                                      {src1_data[4*j+3],src1_data[4*j+2],src1_data[4*j+1],src1_data[4*j]}:
                                                      {src2_data[4*j+3],src2_data[4*j+2],src2_data[4*j+1],src2_data[4*j]}; 
                    endcase

                    result_data[j*`WORD_WIDTH +: `WORD_WIDTH] = result_minmax32[j];
                  end
                endcase
              end        


            endcase
          end
          
          OPMVV,
          OPMVX: begin
            case(uop_funct6.ari_funct6)
              VWADDU,
              VWSUBU,
              VWADD,
              VWSUB: begin
                case(vs2_eew)
                  EEW8: begin
                    result_data[j*`WORD_WIDTH +: `WORD_WIDTH] = {product16[2*j+1], product16[2*j]};
                  end
                  EEW16: begin
                    result_data[j*`WORD_WIDTH +: `WORD_WIDTH] = product32[j];
                  end
                endcase
              end

              VWADDU_W,
              VWSUBU_W,
              VWADD_W,
              VWSUB_W: begin
                case(vs2_eew)
                  EEW16: begin
                    result_data[j*`WORD_WIDTH +: `WORD_WIDTH] = {product16[2*j+1], product16[2*j]};
                  end
                  EEW32: begin
                    result_data[j*`WORD_WIDTH +: `WORD_WIDTH] = product32[j];
                  end
                endcase
              end

              VAADDU,
              VAADD,
              VASUBU,
              VASUB: begin
                case(vs2_eew)
                  EEW8: begin
                    result_data[j*`WORD_WIDTH +: `WORD_WIDTH] = {round8[4*j+3], round8[4*j+2], round8[4*j+1], round8[4*j]};
                  end
                  EEW16: begin
                    result_data[j*`WORD_WIDTH +: `WORD_WIDTH] = {round16[2*j+1], round16[2*j]};
                  end
                  EEW32: begin
                    result_data[j*`WORD_WIDTH +: `WORD_WIDTH] = round32[j];
                  end
                endcase
              end
            endcase
          end
        endcase
      end
    end
  endgenerate

//
// submit result to ROB
//
  always_comb begin
    // initial
  `ifdef TB_SUPPORT
    result.uop_pc    = alu_uop.uop_pc;
  `endif
    result.rob_entry = rob_entry;
    result.w_data    = result_data;
    result.w_valid   = result_valid;
    result.vsaturate = 'b0;

    case(uop_funct3) 
      OPIVV,
      OPIVX,
      OPIVI: begin
        case(uop_funct6.ari_funct6)
          VSADDU: begin
            result.vsaturate = addu_upoverflow;
          end
          VSADD: begin
            result.vsaturate = add_upoverflow|add_underoverflow;
          end
          VSSUBU: begin
            result.vsaturate = subu_underoverflow;
          end
          VSSUB: begin
            result.vsaturate = sub_upoverflow|sub_underoverflow;
          end
        endcase
      end
    endcase
  end

//
// function unit
//
  // add and sub function
  function [`BYTE_WIDTH:0] f_full_addsub8;
    // x +/- (y+cin)
    input ADDSUB_e                opcode;  
    input logic [`BYTE_WIDTH-1:0] src_x;
    input logic [`BYTE_WIDTH-1:0] src_y;
    input logic                   src_cin;

    logic [`BYTE_WIDTH-1:0]       result;
    logic                         cout;

    if (opcode==ADDSUB_VADD) 
      {cout,result} = (`BYTE_WIDTH+1)'(src_x) + (`BYTE_WIDTH+1)'(src_y) + (`BYTE_WIDTH+1)'(src_cin);
    else //(opcode==ADDSUB_VSUB)
      {cout,result} = (`BYTE_WIDTH+1)'(src_x) - (`BYTE_WIDTH+1)'(src_y) - (`BYTE_WIDTH+1)'(src_cin);
    
    return {cout,result};

  endfunction

  function [`BYTE_WIDTH:0] f_half_addsub8;
    // x +/- cin
    input ADDSUB_e              opcode;  
    input logic [`BYTE_WIDTH:0] src_x;
    input logic                 src_cin;

    logic [`BYTE_WIDTH-1:0]     result;
    logic                       cout;
    
    if (opcode==ADDSUB_VADD)
      {cout,result} = src_x + src_cin;
    else //(opcode==ADDSUB_VSUB)
      {cout,result} = src_x - src_cin;

    return {cout,result};  

  endfunction

  function [`HWORD_WIDTH:0] f_half_addsub16;
    // x +/- cin
    input ADDSUB_e               opcode;  
    input logic [`HWORD_WIDTH:0] src_x;
    input logic                  src_cin;

    logic [`HWORD_WIDTH-1:0]     result;
    logic                        cout;
    
    if (opcode==ADDSUB_VADD)
      {cout,result} = src_x + src_cin;
    else //(opcode==ADDSUB_VSUB)
      {cout,result} = src_x - src_cin;

    return {cout,result}; 

  endfunction

  function [`WORD_WIDTH-1:0] f_src_plus1;
    // x + cin
    input logic [`WORD_WIDTH-1:0] src_x;

    logic [`HWORD_WIDTH-1:0] res_hi;
    logic [`HWORD_WIDTH:0]   res_lo;

    res_hi = src_x[`WORD_WIDTH-1:`HWORD_WIDTH] + 1'b1;
    res_lo = (`HWORD_WIDTH+1)'(src_x[`HWORD_WIDTH-1:0]) + 1'b1;
    
    if (res_lo[`HWORD_WIDTH])
      return {res_hi,res_lo[`HWORD_WIDTH-1:0]};
    else
      return {src_x[`WORD_WIDTH-1:`HWORD_WIDTH],res_lo[`HWORD_WIDTH-1:0]};

  endfunction

endmodule
