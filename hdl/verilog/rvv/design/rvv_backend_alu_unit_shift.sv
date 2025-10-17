
`ifndef HDL_VERILOG_RVV_DESIGN_RVV_SVH
`include "rvv_backend.svh"
`endif
`ifndef RVV_ASSERT__SVH
`include "rvv_backend_sva.svh"
`endif

module rvv_backend_alu_unit_shift
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
  RVVXRM                          vxrm;       
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
  logic   [`VLENB/2-1:0][`BYTE_WIDTH-1:0]                      src2_data8;
  logic   [`VLEN/`HWORD_WIDTH/2-1:0][`HWORD_WIDTH-1:0]         src2_data16;
  logic   [`VLEN/`WORD_WIDTH-1:0][`WORD_WIDTH-1:0]             src2_data32;
  logic   [`VLENB/2-1:0][$clog2(`BYTE_WIDTH)-1:0]              shift_amount8;
  logic   [`VLEN/`HWORD_WIDTH/2-1:0][$clog2(`HWORD_WIDTH)-1:0] shift_amount16;
  logic   [`VLEN/`WORD_WIDTH-1:0][$clog2(`WORD_WIDTH)-1:0]     shift_amount32;
  logic   [`VLENB/2-1:0][`BYTE_WIDTH-1:0]                      product8_tmp;
  logic   [`VLEN/`HWORD_WIDTH/2-1:0][`HWORD_WIDTH-1:0]         product16_tmp;
  logic   [`VLEN/`WORD_WIDTH-1:0][`WORD_WIDTH-1:0]             product32_tmp;
  logic   [`VLENB-1:0][`BYTE_WIDTH-1:0]                        product8;
  logic   [`VLEN/`HWORD_WIDTH-1:0][`HWORD_WIDTH-1:0]           product16;
  logic   [`VLEN/`WORD_WIDTH-1:0][`WORD_WIDTH-1:0]             product32;
  logic   [`VLENB/2-1:0][`BYTE_WIDTH-1:0]                      round_bits8_tmp;
  logic   [`VLEN/`HWORD_WIDTH/2-1:0][`HWORD_WIDTH-1:0]         round_bits16_tmp;
  logic   [`VLEN/`WORD_WIDTH-1:0][`WORD_WIDTH-1:0]             round_bits32_tmp;
  logic   [`VLENB-1:0][`BYTE_WIDTH-1:0]                        round_bits8;
  logic   [`VLEN/`HWORD_WIDTH-1:0][`HWORD_WIDTH-1:0]           round_bits16;
  logic   [`VLEN/`WORD_WIDTH-1:0][`WORD_WIDTH-1:0]             round_bits32;
  logic   [`VLENB-1:0]                                         round_increment8;
  logic   [`VLEN/`HWORD_WIDTH-1:0]                             round_increment16;
  logic   [`VLEN/`WORD_WIDTH-1:0]                              round_increment32;
  logic   [`VLENB-1:0][`BYTE_WIDTH-1:0]                        round8;
  logic   [`VLEN/`HWORD_WIDTH-1:0][`HWORD_WIDTH-1:0]           round16;
  logic   [`VLEN/`WORD_WIDTH-1:0][`WORD_WIDTH-1:0]             round32;
  logic   [`VLEN/`HWORD_WIDTH-1:0]                             cout16;
  logic   [`VLEN/`WORD_WIDTH-1:0]                              cout32;
  logic   [`VLENB-1:0]                                         upoverflow;
  logic   [`VLENB-1:0]                                         underoverflow;
  logic   [`VLEN-1:0]                                          result_data; 
  SHIFT_e                                                      opcode;
  
  // for-loop
  genvar                          j;

//
// prepare source data to calculate    
//
  // split ALU_RS_t struct
  assign  rob_entry      = alu_uop.rob_entry;
  assign  uop_funct6     = alu_uop.uop_funct6;
  assign  uop_funct3     = alu_uop.uop_funct3;
  assign  vxrm           = alu_uop.vxrm;
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
    result_valid   = 'b0;

    case(uop_funct3) 
      OPIVV: begin
        case(uop_funct6.ari_funct6)
          VSLL,
          VSRL,
          VSRA,
          VSSRL,
          VSSRA: begin
            result_valid = alu_uop_valid&vs2_data_valid&vs1_data_valid;
          end

          VNSRL,
          VNSRA,
          VNCLIPU,
          VNCLIP: begin
            result_valid = alu_uop_valid&vs2_data_valid&vs1_data_valid&((vs2_eew==EEW16)|(vs2_eew==EEW32));
          end
        endcase
      end

      OPIVX,
      OPIVI: begin
        case(uop_funct6.ari_funct6)
          VSLL,
          VSRL,
          VSRA,
          VSSRL,
          VSSRA: begin
            result_valid = alu_uop_valid&vs2_data_valid&rs1_data_valid;
          end

          VNSRL,
          VNSRA,
          VNCLIPU,
          VNCLIP: begin
            result_valid = alu_uop_valid&vs2_data_valid&rs1_data_valid&((vs2_eew==EEW16)|(vs2_eew==EEW32));
          end
        endcase
      end
    endcase
  end

  // prepare source data
  always_comb begin
    // initial the data
    src2_data8     = 'b0;
    src2_data16    = 'b0;
    src2_data32    = 'b0;
    shift_amount8  = 'b0;
    shift_amount16 = 'b0;
    shift_amount32 = 'b0;

    case(uop_funct3) 
      OPIVV: begin
        case(uop_funct6.ari_funct6)
          VSLL,
          VSRL,
          VSSRL: begin
            case(vs2_eew)
              EEW8: begin
                for(int i=0;i<`VLENB/2;i=i+1) begin
                  src2_data8[i]    = vs2_data[i*`BYTE_WIDTH +: `BYTE_WIDTH];
                  shift_amount8[i] = vs1_data[i*`BYTE_WIDTH +: $clog2(`BYTE_WIDTH)];
                end
                for(int i=`VLENB/2;i<`VLENB*3/4;i=i+1) begin
                  src2_data16[   i-`VLENB/2] = {8'b0,vs2_data[i*`BYTE_WIDTH +: `BYTE_WIDTH]};
                  shift_amount16[i-`VLENB/2] = {1'b0,vs1_data[i*`BYTE_WIDTH +: $clog2(`BYTE_WIDTH)]};
                end         
                for(int i=`VLENB*3/4;i<`VLENB;i=i+1) begin
                  src2_data32[   i-`VLENB*3/4] = {24'b0,vs2_data[i*`BYTE_WIDTH +: `BYTE_WIDTH]};
                  shift_amount32[i-`VLENB*3/4] = {2'b0, vs1_data[i*`BYTE_WIDTH +: $clog2(`BYTE_WIDTH)]};
                end
              end
              EEW16: begin
                for(int i=0;i<`VLEN/`HWORD_WIDTH/2;i=i+1) begin
                  src2_data16[i]    = vs2_data[i*`HWORD_WIDTH +: `HWORD_WIDTH];
                  shift_amount16[i] = vs1_data[i*`HWORD_WIDTH +: $clog2(`HWORD_WIDTH)];
                end
                for(int i=`VLEN/`HWORD_WIDTH/2;i<`VLEN/`HWORD_WIDTH;i=i+1) begin
                  src2_data32[   i-`VLEN/`HWORD_WIDTH/2] = {16'b0,vs2_data[i*`HWORD_WIDTH +: `HWORD_WIDTH]};
                  shift_amount32[i-`VLEN/`HWORD_WIDTH/2] = {1'b0, vs1_data[i*`HWORD_WIDTH +: $clog2(`HWORD_WIDTH)]};
                end   
              end
              EEW32: begin
                for(int i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
                  src2_data32[i]    = vs2_data[i*`WORD_WIDTH +: `WORD_WIDTH];
                  shift_amount32[i] = vs1_data[i*`WORD_WIDTH +: $clog2(`WORD_WIDTH)];
                end
              end
            endcase
          end

          VSRA,
          VSSRA: begin
             case(vs2_eew)
              EEW8: begin
                for(int i=0;i<`VLENB/2;i=i+1) begin
                  src2_data8[i]    = vs2_data[i*`BYTE_WIDTH +: `BYTE_WIDTH];
                  shift_amount8[i] = vs1_data[i*`BYTE_WIDTH +: $clog2(`BYTE_WIDTH)];
                end
                for(int i=`VLENB/2;i<`VLENB*3/4;i=i+1) begin
                  src2_data16[   i-`VLENB/2] = {{8{vs2_data[(i+1)*`BYTE_WIDTH-1]}},vs2_data[i*`BYTE_WIDTH +: `BYTE_WIDTH]};
                  shift_amount16[i-`VLENB/2] = {1'b0,vs1_data[i*`BYTE_WIDTH +: $clog2(`BYTE_WIDTH)]};
                end         
                for(int i=`VLENB*3/4;i<`VLENB;i=i+1) begin
                  src2_data32[   i-`VLENB*3/4] = {{24{vs2_data[(i+1)*`BYTE_WIDTH-1]}},vs2_data[i*`BYTE_WIDTH +: `BYTE_WIDTH]};
                  shift_amount32[i-`VLENB*3/4] = {2'b0,vs1_data[i*`BYTE_WIDTH +: $clog2(`BYTE_WIDTH)]};
                end
              end
              EEW16: begin
                for(int i=0;i<`VLEN/`HWORD_WIDTH/2;i=i+1) begin
                  src2_data16[i]    = vs2_data[i*`HWORD_WIDTH +: `HWORD_WIDTH];
                  shift_amount16[i] = vs1_data[i*`HWORD_WIDTH +: $clog2(`HWORD_WIDTH)];
                end
                for(int i=`VLEN/`HWORD_WIDTH/2;i<`VLEN/`HWORD_WIDTH;i=i+1) begin
                  src2_data32[   i-`VLEN/`HWORD_WIDTH/2] = {{16{vs2_data[(i+1)*`HWORD_WIDTH-1]}},vs2_data[i*`HWORD_WIDTH +: `HWORD_WIDTH]};
                  shift_amount32[i-`VLEN/`HWORD_WIDTH/2] = {1'b0,vs1_data[i*`HWORD_WIDTH +: $clog2(`HWORD_WIDTH)]};
                end   
              end
              EEW32: begin
                for(int i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
                  src2_data32[i]    = vs2_data[i*`WORD_WIDTH +: `WORD_WIDTH];
                  shift_amount32[i] = vs1_data[i*`WORD_WIDTH +: $clog2(`WORD_WIDTH)];
                end
              end
            endcase         
          end

          VNSRL,
          VNCLIPU: begin
            case(vs2_eew)
              EEW16: begin
                for(int i=0;i<`VLEN/`HWORD_WIDTH/2;i=i+1) begin
                  src2_data16[i] = vs2_data[i*`HWORD_WIDTH +: `HWORD_WIDTH];
                  if (uop_index[0]==1'b0)
                    shift_amount16[i] = vs1_data[i*`BYTE_WIDTH  +: $clog2(`HWORD_WIDTH)];
                  else
                    shift_amount16[i] = vs1_data[`VLEN/2+i*`BYTE_WIDTH  +: $clog2(`HWORD_WIDTH)];
                end
                for(int i=`VLEN/`HWORD_WIDTH/2;i<`VLEN/`HWORD_WIDTH;i=i+1) begin
                  src2_data32[   i-`VLEN/`HWORD_WIDTH/2] = {16'b0,vs2_data[i*`HWORD_WIDTH +: `HWORD_WIDTH]};
                  if (uop_index[0]==1'b0)
                    shift_amount32[i-`VLEN/`HWORD_WIDTH/2] = {1'b0, vs1_data[i*`BYTE_WIDTH  +: $clog2(`HWORD_WIDTH)]};
                  else
                    shift_amount32[i-`VLEN/`HWORD_WIDTH/2] = {1'b0, vs1_data[`VLEN/2+i*`BYTE_WIDTH  +: $clog2(`HWORD_WIDTH)]};
                end   
              end
              EEW32: begin
                for(int i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
                  src2_data32[i] = vs2_data[i*`WORD_WIDTH  +: `WORD_WIDTH];
                  if (uop_index[0]==1'b0)
                    shift_amount32[i] = vs1_data[i*`HWORD_WIDTH +: $clog2(`WORD_WIDTH)];
                  else
                    shift_amount32[i] = vs1_data[`VLEN/2+i*`HWORD_WIDTH +: $clog2(`WORD_WIDTH)];
                end
              end
            endcase
          end

          VNSRA,
          VNCLIP: begin
             case(vs2_eew)
              EEW16: begin
                for(int i=0;i<`VLEN/`HWORD_WIDTH/2;i=i+1) begin
                  src2_data16[i] = vs2_data[i*`HWORD_WIDTH +: `HWORD_WIDTH];
                  if (uop_index[0]==1'b0)
                    shift_amount16[i] = vs1_data[i*`BYTE_WIDTH  +: $clog2(`HWORD_WIDTH)];
                  else
                    shift_amount16[i] = vs1_data[`VLEN/2+i*`BYTE_WIDTH  +: $clog2(`HWORD_WIDTH)];
                end
                for(int i=`VLEN/`HWORD_WIDTH/2;i<`VLEN/`HWORD_WIDTH;i=i+1) begin
                  src2_data32[i-`VLEN/`HWORD_WIDTH/2] = {{16{vs2_data[(i+1)*`HWORD_WIDTH-1]}},vs2_data[i*`HWORD_WIDTH +: `HWORD_WIDTH]};
                  if (uop_index[0]==1'b0)
                    shift_amount32[i-`VLEN/`HWORD_WIDTH/2] = {1'b0, vs1_data[i*`BYTE_WIDTH +: $clog2(`HWORD_WIDTH)]};
                  else
                    shift_amount32[i-`VLEN/`HWORD_WIDTH/2] = {1'b0, vs1_data[`VLEN/2+i*`BYTE_WIDTH +: $clog2(`HWORD_WIDTH)]};
                end   
              end
              EEW32: begin
                for(int i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
                  src2_data32[i] = vs2_data[i*`WORD_WIDTH  +: `WORD_WIDTH];
                  if (uop_index[0]==1'b0)
                    shift_amount32[i] = vs1_data[i*`HWORD_WIDTH +: $clog2(`WORD_WIDTH)];
                  else
                    shift_amount32[i] = vs1_data[`VLEN/2+i*`HWORD_WIDTH +: $clog2(`WORD_WIDTH)];
                end
              end
            endcase  
          end
        endcase
      end

      OPIVX,
      OPIVI: begin
        case(uop_funct6.ari_funct6)
          VSLL,
          VSRL,
          VSSRL: begin
             case(vs2_eew)
              EEW8: begin
                for(int i=0;i<`VLENB/2;i=i+1) begin
                  src2_data8[i]    = vs2_data[i*`BYTE_WIDTH +: `BYTE_WIDTH];
                  shift_amount8[i] = rs1_data[0             +: $clog2(`BYTE_WIDTH)];
                end
                for(int i=`VLENB/2;i<`VLENB*3/4;i=i+1) begin
                  src2_data16[   i-`VLENB/2] = {8'b0,vs2_data[i*`BYTE_WIDTH +: `BYTE_WIDTH]};
                  shift_amount16[i-`VLENB/2] = {1'b0,rs1_data[0             +: $clog2(`BYTE_WIDTH)]};
                end         
                for(int i=`VLENB*3/4;i<`VLENB;i=i+1) begin
                  src2_data32[   i-`VLENB*3/4] = {24'b0,vs2_data[i*`BYTE_WIDTH +: `BYTE_WIDTH]};
                  shift_amount32[i-`VLENB*3/4] = {2'b0, rs1_data[0             +: $clog2(`BYTE_WIDTH)]};
                end
              end
              EEW16: begin
                for(int i=0;i<`VLEN/`HWORD_WIDTH/2;i=i+1) begin
                  src2_data16[i]    = vs2_data[i*`HWORD_WIDTH +: `HWORD_WIDTH];
                  shift_amount16[i] = rs1_data[0              +: $clog2(`HWORD_WIDTH)];
                end
                for(int i=`VLEN/`HWORD_WIDTH/2;i<`VLEN/`HWORD_WIDTH;i=i+1) begin
                  src2_data32[   i-`VLEN/`HWORD_WIDTH/2] = {16'b0,vs2_data[i*`HWORD_WIDTH +: `HWORD_WIDTH]};
                  shift_amount32[i-`VLEN/`HWORD_WIDTH/2] = {1'b0, rs1_data[0              +: $clog2(`HWORD_WIDTH)]};
                end   
              end
              EEW32: begin
                for(int i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
                  src2_data32[i]    = vs2_data[i*`WORD_WIDTH +: `WORD_WIDTH];
                  shift_amount32[i] = rs1_data[0             +: $clog2(`WORD_WIDTH)];
                end
              end
            endcase       
          end

          VSRA,
          VSSRA: begin
            case(vs2_eew)
              EEW8: begin
                for(int i=0;i<`VLENB/2;i=i+1) begin
                  src2_data8[i]    = vs2_data[i*`BYTE_WIDTH +: `BYTE_WIDTH];
                  shift_amount8[i] = rs1_data[0             +: $clog2(`BYTE_WIDTH)];
                end
                for(int i=`VLENB/2;i<`VLENB*3/4;i=i+1) begin
                  src2_data16[   i-`VLENB/2] = {{8{vs2_data[(i+1)*`BYTE_WIDTH-1]}},vs2_data[i*`BYTE_WIDTH +: `BYTE_WIDTH]};
                  shift_amount16[i-`VLENB/2] = {1'b0,rs1_data[0 +: $clog2(`BYTE_WIDTH)]};
                end         
                for(int i=`VLENB*3/4;i<`VLENB;i=i+1) begin
                  src2_data32[   i-`VLENB*3/4] = {{24{vs2_data[(i+1)*`BYTE_WIDTH-1]}},vs2_data[i*`BYTE_WIDTH +: `BYTE_WIDTH]};
                  shift_amount32[i-`VLENB*3/4] = {2'b0,rs1_data[0 +: $clog2(`BYTE_WIDTH)]};
                end
              end
              EEW16: begin
                for(int i=0;i<`VLEN/`HWORD_WIDTH/2;i=i+1) begin
                  src2_data16[i]    = vs2_data[i*`HWORD_WIDTH +: `HWORD_WIDTH];
                  shift_amount16[i] = rs1_data[0              +: $clog2(`HWORD_WIDTH)];
                end
                for(int i=`VLEN/`HWORD_WIDTH/2;i<`VLEN/`HWORD_WIDTH;i=i+1) begin
                  src2_data32[   i-`VLEN/`HWORD_WIDTH/2] = {{16{vs2_data[(i+1)*`HWORD_WIDTH-1]}},vs2_data[i*`HWORD_WIDTH +: `HWORD_WIDTH]};
                  shift_amount32[i-`VLEN/`HWORD_WIDTH/2] = {1'b0,rs1_data[0 +: $clog2(`HWORD_WIDTH)]};
                end   
              end
              EEW32: begin
                for(int i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
                  src2_data32[i]    = vs2_data[i*`WORD_WIDTH +: `WORD_WIDTH];
                  shift_amount32[i] = rs1_data[0 +: $clog2(`WORD_WIDTH)];
                end
              end
            endcase          
          end

          VNSRL,
          VNCLIPU: begin
            case(vs2_eew)
              EEW16: begin
                for(int i=0;i<`VLEN/`HWORD_WIDTH/2;i=i+1) begin
                  src2_data16[i]    = vs2_data[i*`HWORD_WIDTH +: `HWORD_WIDTH];
                  shift_amount16[i] = rs1_data[0              +: $clog2(`HWORD_WIDTH)];
                end
                for(int i=`VLEN/`HWORD_WIDTH/2;i<`VLEN/`HWORD_WIDTH;i=i+1) begin
                  src2_data32[   i-`VLEN/`HWORD_WIDTH/2] = {16'b0,vs2_data[i*`HWORD_WIDTH +: `HWORD_WIDTH]};
                  shift_amount32[i-`VLEN/`HWORD_WIDTH/2] = {1'b0, rs1_data[0              +: $clog2(`HWORD_WIDTH)]};
                end   
              end
              EEW32: begin
                for(int i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
                  src2_data32[i]    = vs2_data[i*`WORD_WIDTH +: `WORD_WIDTH];
                  shift_amount32[i] = rs1_data[0             +: $clog2(`WORD_WIDTH)];
                end
              end
            endcase  
          end

          VNSRA,
          VNCLIP: begin
            case(vs2_eew)
              EEW16: begin
                for(int i=0;i<`VLEN/`HWORD_WIDTH/2;i=i+1) begin
                  src2_data16[i]    = vs2_data[i*`HWORD_WIDTH +: `HWORD_WIDTH];
                  shift_amount16[i] = rs1_data[0              +: $clog2(`HWORD_WIDTH)];
                end
                for(int i=`VLEN/`HWORD_WIDTH/2;i<`VLEN/`HWORD_WIDTH;i=i+1) begin
                  src2_data32[   i-`VLEN/`HWORD_WIDTH/2] = {{16{vs2_data[(i+1)*`HWORD_WIDTH-1]}},vs2_data[i*`HWORD_WIDTH +: `HWORD_WIDTH]};
                  shift_amount32[i-`VLEN/`HWORD_WIDTH/2] = {1'b0,rs1_data[0 +: $clog2(`HWORD_WIDTH)]};
                end   
              end
              EEW32: begin
                for(int i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
                  src2_data32[i]    = vs2_data[i*`WORD_WIDTH +: `WORD_WIDTH];
                  shift_amount32[i] = rs1_data[0 +: $clog2(`WORD_WIDTH)];
                end
              end
            endcase 
          end
        endcase
      end
    endcase
  end

  // get opcode for f_addsub
  always_comb begin
    // initial the data
    opcode = SHIFT_SLL;

    // prepare source data
    case(uop_funct3) 
      OPIVV,
      OPIVX,
      OPIVI: begin
        case(uop_funct6.ari_funct6)    
          VSLL: begin
            opcode = SHIFT_SLL;
          end
          VSRL,
          VNSRL,
          VSSRL,
          VNCLIPU: begin
            opcode = SHIFT_SRL;
          end
          VSRA,
          VNSRA,
          VSSRA,
          VNCLIP: begin
            opcode = SHIFT_SRA;
          end
        endcase
      end
    endcase
  end

//    
// calculate the result
//
  // shift instructions
  generate
    for (j=0;j<`VLENB/2;j=j+1) begin: EXE_PROD8
      assign {product8_tmp[j], round_bits8_tmp[j]} = f_shift8(opcode, src2_data8[j], shift_amount8[j]);
    end
  endgenerate
  
  generate
    for (j=0;j<`VLEN/`HWORD_WIDTH/2;j=j+1) begin: EXE_PROD16
      assign {product16_tmp[j], round_bits16_tmp[j]} = f_shift16(opcode, src2_data16[j], shift_amount16[j]);
    end
  endgenerate 

  generate
    for (j=0;j<`VLEN/`WORD_WIDTH;j=j+1) begin: EXE_PROD32
      assign {product32_tmp[j], round_bits32_tmp[j]} = f_shift32(opcode, src2_data32[j], shift_amount32[j]);
    end
  endgenerate 
  
  always_comb begin
    product8    = 'b0;
    round_bits8 = 'b0;

    for(int i=0;i<`VLENB/2;i=i+1) begin
      product8[i]    = product8_tmp[i];
      round_bits8[i] = round_bits8_tmp[i];
    end
    for(int i=`VLENB/2;i<`VLENB*3/4;i=i+1) begin
      product8[i]    = product16_tmp[   i-`VLENB/2][0           +: `BYTE_WIDTH];
      round_bits8[i] = round_bits16_tmp[i-`VLENB/2][`BYTE_WIDTH +: `BYTE_WIDTH];
    end         
    for(int i=`VLENB*3/4;i<`VLENB;i=i+1) begin
      product8[i]    = product32_tmp[   i-`VLENB*3/4][0             +: `BYTE_WIDTH];
      round_bits8[i] = round_bits32_tmp[i-`VLENB*3/4][3*`BYTE_WIDTH +: `BYTE_WIDTH];
    end
  end
 
  always_comb begin
    product16    = 'b0;
    round_bits16 = 'b0;

    for(int i=0;i<`VLEN/`HWORD_WIDTH/2;i=i+1) begin
      product16[i]    = product16_tmp[i];
      round_bits16[i] = round_bits16_tmp[i];
    end
    for(int i=`VLEN/`HWORD_WIDTH/2;i<`VLEN/`HWORD_WIDTH;i=i+1) begin
      product16[i]    = product32_tmp[   i-`VLEN/`HWORD_WIDTH/2][0            +: `HWORD_WIDTH];
      round_bits16[i] = round_bits32_tmp[i-`VLEN/`HWORD_WIDTH/2][`HWORD_WIDTH +: `HWORD_WIDTH];
    end   
  end

  always_comb begin
    product32    = 'b0;
    round_bits32 = 'b0;

    for(int i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
      product32[i]    = product32_tmp[i];
      round_bits32[i] = round_bits32_tmp[i];
    end
  end

  // round increment
  generate
    for (j=0;j<`VLENB;j++) begin: INCREMENT8
      always_comb begin
        round_increment8[j] = 'b0;
        
        case(vxrm)
          RNU: begin
            round_increment8[j] = round_bits8[j][`BYTE_WIDTH-1];
          end
          RNE: begin
            round_increment8[j] = round_bits8[j][`BYTE_WIDTH-1] & (
                                  (round_bits8[j][`BYTE_WIDTH-2:0]!='b0) |
                                  product8[j][0]);
          end
          RDN: begin
            round_increment8[j] = 'b0;
          end
          ROD: begin
            round_increment8[j] = (!product8[j][0]) & (round_bits8[j]!='b0);
          end
        endcase
      end
    end
  endgenerate

  generate
    for (j=0;j<`VLEN/`HWORD_WIDTH;j++) begin: INCREMENT16
      always_comb begin
        round_increment16[j] = 'b0;
        
        case(vxrm)
          RNU: begin
            round_increment16[j] = round_bits16[j][`HWORD_WIDTH-1];
          end
          RNE: begin
            round_increment16[j] = round_bits16[j][`HWORD_WIDTH-1] & (
                                  (round_bits16[j][`HWORD_WIDTH-2:0]!='b0) |
                                  product16[j][0]);
          end
          RDN: begin
            round_increment16[j] = 'b0;
          end
          ROD: begin
            round_increment16[j] = (!product16[j][0]) & (round_bits16[j]!='b0);
          end
        endcase
      end
    end
  endgenerate

  generate
    for (j=0;j<`VLEN/`WORD_WIDTH;j++) begin: INCREMENT32
      always_comb begin
        round_increment32[j] = 'b0;
        
        case(vxrm)
          RNU: begin
            round_increment32[j] = round_bits32[j][`WORD_WIDTH-1];
          end
          RNE: begin
            round_increment32[j] = round_bits32[j][`WORD_WIDTH-1] & (
                                  (round_bits32[j][`WORD_WIDTH-2:0]!='b0) |
                                  product32[j][0]);
          end
          RDN: begin
            round_increment32[j] = 'b0;
          end
          ROD: begin
            round_increment32[j] = (!product32[j][0]) & (round_bits32[j]!='b0);
          end
        endcase
      end
    end
  endgenerate

  // rounding result
  generate
    for (j=0;j<`VLENB;j++) begin: ROUND8
      always_comb begin
        round8[j] = 'b0;

        if (opcode == SHIFT_SRL)
          round8[j] = f_half_add8({1'b0, product8[j]}, round_increment8[j]); 
        else if (opcode == SHIFT_SRA)
          round8[j] = f_half_add8({product8[j][`BYTE_WIDTH-1], product8[j]}, round_increment8[j]); 
      end
    end
  endgenerate

  generate
    for (j=0;j<`VLEN/`HWORD_WIDTH;j++) begin: ROUND16
      always_comb begin
        cout16[j]  = 'b0; 
        round16[j] = 'b0;

        if (opcode == SHIFT_SRL)
          {cout16[j], round16[j]} = f_half_add16({1'b0, product16[j]}, round_increment16[j]); 
        else if (opcode == SHIFT_SRA)
          {cout16[j], round16[j]} = f_half_add16({product16[j][`HWORD_WIDTH-1], product16[j]}, round_increment16[j]); 
      end
    end
  endgenerate

  generate
    for (j=0;j<`VLEN/`WORD_WIDTH;j++) begin: ROUND32
      always_comb begin
        cout32[j]  = 'b0; 
        round32[j] = 'b0;

        if (opcode == SHIFT_SRL)
          {cout32[j], round32[j]} = f_half_add32({1'b0, product32[j]}, round_increment32[j]); 
        else if (opcode == SHIFT_SRA)
          {cout32[j], round32[j]} = f_half_add32({product32[j][`WORD_WIDTH-1], product32[j]}, round_increment32[j]); 
      end
    end
  endgenerate

  // overflow check for vnclipu and vnclip 
  generate 
    for (j=0;j<`VLEN/`WORD_WIDTH/2;j++) begin: GET_OVERFLOW
      always_comb begin
        // initial
        upoverflow[   4*j +: 4] = 'b0;
        underoverflow[4*j +: 4] = 'b0;
        upoverflow[   4*(j+`VLEN/`WORD_WIDTH/2) +: 4] = 'b0;
        underoverflow[4*(j+`VLEN/`WORD_WIDTH/2) +: 4] = 'b0;
          
        case(vs2_eew)
          EEW16: begin
            case(opcode)
              SHIFT_SRL: begin
              // unsigned overflow check for vnclipu
                if(uop_index[0]==1'b0) begin
                  upoverflow[4*j +: 4] = {
                    ({cout16[4*j+3], round16[4*j+3][`BYTE_WIDTH +: `BYTE_WIDTH]}!='b0),
                    ({cout16[4*j+2], round16[4*j+2][`BYTE_WIDTH +: `BYTE_WIDTH]}!='b0),
                    ({cout16[4*j+1], round16[4*j+1][`BYTE_WIDTH +: `BYTE_WIDTH]}!='b0),
                    ({cout16[4*j  ], round16[4*j  ][`BYTE_WIDTH +: `BYTE_WIDTH]}!='b0)};

                  upoverflow[4*(j+`VLEN/`WORD_WIDTH/2) +: 4] = 'b0;
                end
                else begin
                  upoverflow[4*j +: 4] = 'b0;

                  upoverflow[4*(j+`VLEN/`WORD_WIDTH/2) +: 4] = {
                    ({cout16[4*j+3], round16[4*j+3][`BYTE_WIDTH +: `BYTE_WIDTH]}!='b0),
                    ({cout16[4*j+2], round16[4*j+2][`BYTE_WIDTH +: `BYTE_WIDTH]}!='b0),
                    ({cout16[4*j+1], round16[4*j+1][`BYTE_WIDTH +: `BYTE_WIDTH]}!='b0),
                    ({cout16[4*j  ], round16[4*j  ][`BYTE_WIDTH +: `BYTE_WIDTH]}!='b0)};
                end
              end
              SHIFT_SRA: begin
              // signed overflow check for vnclip
                if(uop_index[0]==1'b0) begin
                  upoverflow[4*j +: 4] = {
                    (cout16[4*j+3]=='b0)&(round16[4*j+3][`BYTE_WIDTH-1 +: `BYTE_WIDTH+1]!='b0),
                    (cout16[4*j+2]=='b0)&(round16[4*j+2][`BYTE_WIDTH-1 +: `BYTE_WIDTH+1]!='b0),
                    (cout16[4*j+1]=='b0)&(round16[4*j+1][`BYTE_WIDTH-1 +: `BYTE_WIDTH+1]!='b0),
                    (cout16[4*j  ]=='b0)&(round16[4*j  ][`BYTE_WIDTH-1 +: `BYTE_WIDTH+1]!='b0)};

                  underoverflow[4*j +: 4] = {
                    (cout16[4*j+3]=='b1)&(round16[4*j+3][`BYTE_WIDTH-1 +: `BYTE_WIDTH+1]!='h1ff),
                    (cout16[4*j+2]=='b1)&(round16[4*j+2][`BYTE_WIDTH-1 +: `BYTE_WIDTH+1]!='h1ff),
                    (cout16[4*j+1]=='b1)&(round16[4*j+1][`BYTE_WIDTH-1 +: `BYTE_WIDTH+1]!='h1ff),
                    (cout16[4*j  ]=='b1)&(round16[4*j  ][`BYTE_WIDTH-1 +: `BYTE_WIDTH+1]!='h1ff)};

                  upoverflow[4*(j+`VLEN/`WORD_WIDTH/2) +: 4] = 'b0;
                  underoverflow[4*(j+`VLEN/`WORD_WIDTH/2) +: 4] = 'b0;
                end
                else begin
                  upoverflow[4*j +: 4] = 'b0;
                  underoverflow[4*j +: 4] = 'b0;

                  upoverflow[4*(j+`VLEN/`WORD_WIDTH/2) +: 4] = {
                    (cout16[4*j+3]=='b0)&(round16[4*j+3][`BYTE_WIDTH-1 +: `BYTE_WIDTH+1]!='b0),
                    (cout16[4*j+2]=='b0)&(round16[4*j+2][`BYTE_WIDTH-1 +: `BYTE_WIDTH+1]!='b0),
                    (cout16[4*j+1]=='b0)&(round16[4*j+1][`BYTE_WIDTH-1 +: `BYTE_WIDTH+1]!='b0),
                    (cout16[4*j  ]=='b0)&(round16[4*j  ][`BYTE_WIDTH-1 +: `BYTE_WIDTH+1]!='b0)};

                  underoverflow[4*(j+`VLEN/`WORD_WIDTH/2) +: 4] = {
                    (cout16[4*j+3]=='b1)&(round16[4*j+3][`BYTE_WIDTH-1 +: `BYTE_WIDTH+1]!='h1ff),
                    (cout16[4*j+2]=='b1)&(round16[4*j+2][`BYTE_WIDTH-1 +: `BYTE_WIDTH+1]!='h1ff),
                    (cout16[4*j+1]=='b1)&(round16[4*j+1][`BYTE_WIDTH-1 +: `BYTE_WIDTH+1]!='h1ff),
                    (cout16[4*j  ]=='b1)&(round16[4*j  ][`BYTE_WIDTH-1 +: `BYTE_WIDTH+1]!='h1ff)};
                end
              end
            endcase
          end
          EEW32: begin
            case(opcode)
              SHIFT_SRL: begin
              // unsigned overflow check for vnclipu
                if(uop_index[0]==1'b0) begin
                  upoverflow[4*j +: 4] = {
                    ({cout32[2*j+1], round32[2*j+1][`HWORD_WIDTH +: `HWORD_WIDTH]}!='b0),1'b0,
                    ({cout32[2*j  ], round32[2*j  ][`HWORD_WIDTH +: `HWORD_WIDTH]}!='b0),1'b0};

                  upoverflow[4*(j+`VLEN/`WORD_WIDTH/2) +: 4] = 'b0;
                end
                else begin
                  upoverflow[4*j +: 4] = 'b0;

                  upoverflow[4*(j+`VLEN/`WORD_WIDTH/2) +: 4] = {
                    ({cout32[2*j+1], round32[2*j+1][`HWORD_WIDTH +: `HWORD_WIDTH]}!='b0),1'b0,
                    ({cout32[2*j  ], round32[2*j  ][`HWORD_WIDTH +: `HWORD_WIDTH]}!='b0),1'b0};
                end
              end
              SHIFT_SRA: begin
              // signed overflow check for vnclip
                if(uop_index[0]==1'b0) begin
                  upoverflow[4*j +: 4] = {
                    (cout32[2*j+1]=='b0)&(round32[2*j+1][`HWORD_WIDTH-1 +: `HWORD_WIDTH+1]!='b0),1'b0,
                    (cout32[2*j  ]=='b0)&(round32[2*j  ][`HWORD_WIDTH-1 +: `HWORD_WIDTH+1]!='b0),1'b0};

                  underoverflow[4*j +: 4] = {
                    (cout32[2*j+1]=='b1)&(round32[2*j+1][`HWORD_WIDTH-1 +: `HWORD_WIDTH+1]!='h1ffff),1'b0,
                    (cout32[2*j  ]=='b1)&(round32[2*j  ][`HWORD_WIDTH-1 +: `HWORD_WIDTH+1]!='h1ffff),1'b0};

                  upoverflow[4*(j+`VLEN/`WORD_WIDTH/2) +: 4] = 'b0;
                  underoverflow[4*(j+`VLEN/`WORD_WIDTH/2) +: 4] = 'b0;
                end
                else begin
                  upoverflow[4*j +: 4] = 'b0;
                  underoverflow[4*j +: 4] = 'b0;

                  upoverflow[4*(j+`VLEN/`WORD_WIDTH/2) +: 4] = {
                    (cout32[2*j+1]=='b0)&(round32[2*j+1][`HWORD_WIDTH-1 +: `HWORD_WIDTH+1]!='b0),1'b0,
                    (cout32[2*j  ]=='b0)&(round32[2*j  ][`HWORD_WIDTH-1 +: `HWORD_WIDTH+1]!='b0),1'b0};

                  underoverflow[4*(j+`VLEN/`WORD_WIDTH/2) +: 4] = {
                    (cout32[2*j+1]=='b1)&(round32[2*j+1][`HWORD_WIDTH-1 +: `HWORD_WIDTH+1]!='h1ffff),1'b0,
                    (cout32[2*j  ]=='b1)&(round32[2*j  ][`HWORD_WIDTH-1 +: `HWORD_WIDTH+1]!='h1ffff),1'b0};
                end
              end
            endcase
          end
        endcase
      end
    end
  endgenerate

  // assign to result_data
  always_comb begin
    // initial the data
    result_data = 'b0;
 
    for(int i=0;i<`VLEN/`WORD_WIDTH;i++) begin
      // calculate result data
      case(uop_funct3) 
        OPIVV,
        OPIVX,
        OPIVI: begin
          case(uop_funct6.ari_funct6)
            VSLL,
            VSRL,
            VSRA: begin
              case(vs2_eew)
                EEW8: begin
                  result_data[i*`WORD_WIDTH +: `WORD_WIDTH] = {product8[4*i+3],product8[4*i+2],product8[4*i+1],product8[4*i]};
                end
                EEW16: begin
                  result_data[i*`WORD_WIDTH +: `WORD_WIDTH] = {product16[2*i+1],product16[2*i]};
                end
                EEW32: begin
                  result_data[i*`WORD_WIDTH +: `WORD_WIDTH] = product32[i];
                end
              endcase
            end
  
            VNSRL,
            VNSRA: begin
              case(vs2_eew)
                EEW16: begin
                  if (uop_index[0]==1'b0)
                    result_data[i*`HWORD_WIDTH         +: `HWORD_WIDTH] = {product16[2*i+1][`BYTE_WIDTH-1:0],product16[2*i][`BYTE_WIDTH-1:0]};
                  else
                    result_data[`VLEN/2+i*`HWORD_WIDTH +: `HWORD_WIDTH] = {product16[2*i+1][`BYTE_WIDTH-1:0],product16[2*i][`BYTE_WIDTH-1:0]};
                end
                EEW32: begin
                  if (uop_index[0]==1'b0)
                    result_data[i*`HWORD_WIDTH         +: `HWORD_WIDTH] = product32[i][`HWORD_WIDTH-1:0];
                  else
                    result_data[`VLEN/2+i*`HWORD_WIDTH +: `HWORD_WIDTH] = product32[i][`HWORD_WIDTH-1:0];
                end
              endcase
            end

            VSSRL,
            VSSRA: begin
              case(vs2_eew)
                EEW8: begin
                  result_data[i*`WORD_WIDTH +: `WORD_WIDTH] = {round8[4*i+3],round8[4*i+2],round8[4*i+1],round8[4*i]};
                end
                EEW16: begin
                  result_data[i*`WORD_WIDTH +: `WORD_WIDTH] = {round16[2*i+1],round16[2*i]};
                end
                EEW32: begin
                  result_data[i*`WORD_WIDTH +: `WORD_WIDTH] = round32[i];
                end
              endcase
            end

            VNCLIPU: begin
              case(vs2_eew)
                EEW16: begin
                  if (i<`VLEN/`WORD_WIDTH/2) begin
                    if (upoverflow[4*i])
                      result_data[(4*i)*`BYTE_WIDTH +: `BYTE_WIDTH] = 'hff;
                    else
                      result_data[(4*i)*`BYTE_WIDTH +: `BYTE_WIDTH] = round16[4*i][`BYTE_WIDTH-1 : 0];

                    if (upoverflow[4*i+1])
                      result_data[(4*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH] = 'hff;
                    else
                      result_data[(4*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH] = round16[4*i+1][`BYTE_WIDTH-1 : 0];

                    if (upoverflow[4*i+2])
                      result_data[(4*i+2)*`BYTE_WIDTH +: `BYTE_WIDTH] = 'hff;
                    else
                      result_data[(4*i+2)*`BYTE_WIDTH +: `BYTE_WIDTH] = round16[4*i+2][`BYTE_WIDTH-1 : 0];

                    if (upoverflow[4*i+3])
                      result_data[(4*i+3)*`BYTE_WIDTH +: `BYTE_WIDTH] = 'hff;
                    else
                      result_data[(4*i+3)*`BYTE_WIDTH +: `BYTE_WIDTH] = round16[4*i+3][`BYTE_WIDTH-1 : 0];
                  end
                  else begin
                    if (upoverflow[4*i])
                      result_data[(4*i)*`BYTE_WIDTH +: `BYTE_WIDTH] = 'hff;
                    else
                      result_data[(4*i)*`BYTE_WIDTH +: `BYTE_WIDTH] = round16[4*(i-`VLEN/`WORD_WIDTH/2)][`BYTE_WIDTH-1 : 0];

                    if (upoverflow[4*i+1])
                      result_data[(4*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH] = 'hff;
                    else
                      result_data[(4*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH] = round16[4*(i-`VLEN/`WORD_WIDTH/2)+1][`BYTE_WIDTH-1 : 0];

                    if (upoverflow[4*i+2])
                      result_data[(4*i+2)*`BYTE_WIDTH +: `BYTE_WIDTH] = 'hff;
                    else
                      result_data[(4*i+2)*`BYTE_WIDTH +: `BYTE_WIDTH] = round16[4*(i-`VLEN/`WORD_WIDTH/2)+2][`BYTE_WIDTH-1 : 0];

                    if (upoverflow[4*i+3])
                      result_data[(4*i+3)*`BYTE_WIDTH +: `BYTE_WIDTH] = 'hff;
                    else
                      result_data[(4*i+3)*`BYTE_WIDTH +: `BYTE_WIDTH] = round16[4*(i-`VLEN/`WORD_WIDTH/2)+3][`BYTE_WIDTH-1 : 0];
                  end
                end
                EEW32: begin
                  if (i<`VLEN/`WORD_WIDTH/2) begin
                    if (upoverflow[4*i+1])
                      result_data[(2*i)*`HWORD_WIDTH +: `HWORD_WIDTH] = 'hffff;
                    else
                      result_data[(2*i)*`HWORD_WIDTH +: `HWORD_WIDTH] = round32[2*i][`HWORD_WIDTH-1 : 0];

                    if (upoverflow[4*i+3])
                      result_data[(2*i+1)*`HWORD_WIDTH +: `HWORD_WIDTH] = 'hffff;
                    else
                      result_data[(2*i+1)*`HWORD_WIDTH +: `HWORD_WIDTH] = round32[2*i+1][`HWORD_WIDTH-1 : 0];
                  end
                  else begin
                    if (upoverflow[4*i+1])
                      result_data[(2*i)*`HWORD_WIDTH +: `HWORD_WIDTH] = 'hffff;
                    else
                      result_data[(2*i)*`HWORD_WIDTH +: `HWORD_WIDTH] = round32[2*(i-`VLEN/`WORD_WIDTH/2)][`HWORD_WIDTH-1 : 0];

                    if (upoverflow[4*i+3])
                      result_data[(2*i+1)*`HWORD_WIDTH +: `HWORD_WIDTH] = 'hffff;
                    else
                      result_data[(2*i+1)*`HWORD_WIDTH +: `HWORD_WIDTH] = round32[2*(i-`VLEN/`WORD_WIDTH/2)+1][`HWORD_WIDTH-1 : 0];
                  end
                end
              endcase
            end

            VNCLIP: begin
              case(vs2_eew)
                EEW16: begin
                  if (i<`VLEN/`WORD_WIDTH/2) begin
                    if (upoverflow[4*i])
                      result_data[(4*i)*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h7f;
                    else if (underoverflow[4*i])
                      result_data[(4*i)*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h80;
                    else
                      result_data[(4*i)*`BYTE_WIDTH +: `BYTE_WIDTH] = round16[4*i][`BYTE_WIDTH-1 : 0];

                    if (upoverflow[4*i+1])
                      result_data[(4*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h7f;
                    else if (underoverflow[4*i+1])
                      result_data[(4*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h80;
                    else
                      result_data[(4*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH] = round16[4*i+1][`BYTE_WIDTH-1 : 0];

                    if (upoverflow[4*i+2])
                      result_data[(4*i+2)*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h7f;
                    else if (underoverflow[4*i+2])
                      result_data[(4*i+2)*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h80;
                    else
                      result_data[(4*i+2)*`BYTE_WIDTH +: `BYTE_WIDTH] = round16[4*i+2][`BYTE_WIDTH-1 : 0];

                    if (upoverflow[4*i+3])
                      result_data[(4*i+3)*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h7f;
                    else if (underoverflow[4*i+3])
                      result_data[(4*i+3)*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h80;
                    else
                      result_data[(4*i+3)*`BYTE_WIDTH +: `BYTE_WIDTH] = round16[4*i+3][`BYTE_WIDTH-1 : 0];
                  end
                  else begin
                    if (upoverflow[4*i])
                      result_data[(4*i)*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h7f;
                    else if (underoverflow[4*i])
                      result_data[(4*i)*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h80;
                    else
                      result_data[(4*i)*`BYTE_WIDTH +: `BYTE_WIDTH] = round16[4*(i-`VLEN/`WORD_WIDTH/2)][`BYTE_WIDTH-1 : 0];

                    if (upoverflow[4*i+1])
                      result_data[(4*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h7f;
                    else if (underoverflow[4*i+1])
                      result_data[(4*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h80;
                    else
                      result_data[(4*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH] = round16[4*(i-`VLEN/`WORD_WIDTH/2)+1][`BYTE_WIDTH-1 : 0];

                    if (upoverflow[4*i+2])
                      result_data[(4*i+2)*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h7f;
                    else if (underoverflow[4*i+2])
                      result_data[(4*i+2)*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h80;
                    else
                      result_data[(4*i+2)*`BYTE_WIDTH +: `BYTE_WIDTH] = round16[4*(i-`VLEN/`WORD_WIDTH/2)+2][`BYTE_WIDTH-1 : 0];

                    if (upoverflow[4*i+3])
                      result_data[(4*i+3)*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h7f;
                    else if (underoverflow[4*i+3])
                      result_data[(4*i+3)*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h80;
                    else
                      result_data[(4*i+3)*`BYTE_WIDTH +: `BYTE_WIDTH] = round16[4*(i-`VLEN/`WORD_WIDTH/2)+3][`BYTE_WIDTH-1 : 0];
                  end
                end
                EEW32: begin
                  if (i<`VLEN/`WORD_WIDTH/2) begin
                    if (upoverflow[4*i+1])
                      result_data[(2*i)*`HWORD_WIDTH +: `HWORD_WIDTH] = 'h7fff;
                    else if (underoverflow[4*i+1])
                      result_data[(2*i)*`HWORD_WIDTH +: `HWORD_WIDTH] = 'h8000;
                    else
                      result_data[(2*i)*`HWORD_WIDTH +: `HWORD_WIDTH] = round32[2*i][`HWORD_WIDTH-1 : 0];

                    if (upoverflow[4*i+3])
                      result_data[(2*i+1)*`HWORD_WIDTH +: `HWORD_WIDTH] = 'h7fff;
                    else if (underoverflow[4*i+3])
                      result_data[(2*i+1)*`HWORD_WIDTH +: `HWORD_WIDTH] = 'h8000;
                    else
                      result_data[(2*i+1)*`HWORD_WIDTH +: `HWORD_WIDTH] = round32[2*i+1][`HWORD_WIDTH-1 : 0];
                  end
                  else begin
                    if (upoverflow[4*i+1])
                      result_data[(2*i)*`HWORD_WIDTH +: `HWORD_WIDTH] = 'h7fff;
                    else if (underoverflow[4*i+1])
                      result_data[(2*i)*`HWORD_WIDTH +: `HWORD_WIDTH] = 'h8000;
                    else
                      result_data[(2*i)*`HWORD_WIDTH +: `HWORD_WIDTH] = round32[2*(i-`VLEN/`WORD_WIDTH/2)][`HWORD_WIDTH-1 : 0];

                    if (upoverflow[4*i+3])
                      result_data[(2*i+1)*`HWORD_WIDTH +: `HWORD_WIDTH] = 'h7fff;
                    else if (underoverflow[4*i+3])
                      result_data[(2*i+1)*`HWORD_WIDTH +: `HWORD_WIDTH] = 'h8000;
                    else
                      result_data[(2*i+1)*`HWORD_WIDTH +: `HWORD_WIDTH] = round32[2*(i-`VLEN/`WORD_WIDTH/2)+1][`HWORD_WIDTH-1 : 0];
                  end
                end
              endcase
            end
          endcase
        end
      endcase
    end
  end

//
// submit result to ROB
//
  // saturate signal
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
          VNCLIPU: begin
            result.vsaturate = upoverflow;
          end
          VNCLIP: begin
            result.vsaturate = underoverflow|upoverflow;
          end
        endcase
      end
    endcase
  end

//
// function unit
//
  // shifter function
  function [2*`BYTE_WIDTH-1:0] f_shift8;
    input SHIFT_e                         opcode;
    input logic [`BYTE_WIDTH-1:0]         operand;
    input logic [$clog2(`BYTE_WIDTH)-1:0] amount;

    logic signed [`BYTE_WIDTH:0]   src;
    logic signed [`BYTE_WIDTH:0]   res;
    logic signed [`BYTE_WIDTH-1:0] round;

    if ((opcode==SHIFT_SLL)||(opcode==SHIFT_SRL))
      src = {1'b0,operand};
    else 
      src = {operand[`BYTE_WIDTH-1],operand};   // (opcode==SHIFT_SRA)

    if (opcode==SHIFT_SLL) begin
      res = src<<amount;
      round  = 'b0;
    end
    else begin
      // ((opcode==SHIFT_SRL)||(opcode==SHIFT_SRA))
      res = src>>>amount;    
      round  = operand<<(`BYTE_WIDTH-amount); 
    end

    return {res[`BYTE_WIDTH-1:0],round};
  endfunction

  function [2*`HWORD_WIDTH-1:0] f_shift16;
    input SHIFT_e                          opcode;
    input logic [`HWORD_WIDTH-1:0]         operand;
    input logic [$clog2(`HWORD_WIDTH)-1:0] amount;

    logic signed [`HWORD_WIDTH:0]   src;
    logic signed [`HWORD_WIDTH:0]   res;
    logic signed [`HWORD_WIDTH-1:0] round;

    if ((opcode==SHIFT_SLL)||(opcode==SHIFT_SRL))
      src = {1'b0,operand};
    else 
      src = {operand[`HWORD_WIDTH-1],operand};   // (opcode==SHIFT_SRA)

    if (opcode==SHIFT_SLL) begin
      res = src<<amount;
      round  = 'b0;
    end
    else begin
      // ((opcode==SHIFT_SRL)||(opcode==SHIFT_SRA))
      res = src>>>amount;    
      round  = operand<<(`HWORD_WIDTH-amount); 
    end

    return {res[`HWORD_WIDTH-1:0],round};

  endfunction

  function [2*`WORD_WIDTH-1:0] f_shift32;
    input SHIFT_e                         opcode;
    input logic [`WORD_WIDTH-1:0]         operand;
    input logic [$clog2(`WORD_WIDTH)-1:0] amount;

    logic signed [`WORD_WIDTH:0]   src;
    logic signed [`WORD_WIDTH:0]   res;
    logic signed [`WORD_WIDTH-1:0] round;

    if ((opcode==SHIFT_SLL)||(opcode==SHIFT_SRL))
      src = {1'b0,operand};
    else 
      src = {operand[`WORD_WIDTH-1],operand};   // (opcode==SHIFT_SRA)

    if (opcode==SHIFT_SLL) begin
      res = src<<amount;
      round  = 'b0;
    end
    else begin
      // ((opcode==SHIFT_SRL)||(opcode==SHIFT_SRA))
      res = src>>>amount;    
      round  = operand<<(`WORD_WIDTH-amount); 
    end

    return {res[`WORD_WIDTH-1:0],round};

  endfunction

  function [`BYTE_WIDTH-1:0] f_half_add8;
    // x + cin
    input logic [`BYTE_WIDTH:0] src_x;
    input logic                 cin;
    
    logic [`BYTE_WIDTH:0] result;

    result = cin ? src_x + 1'b1 : src_x;

    f_half_add8 = result[`BYTE_WIDTH-1:0];
  endfunction

  function [`HWORD_WIDTH:0] f_half_add16;
    // x + cin
    input logic [`HWORD_WIDTH:0] src_x;
    input logic                  cin;

    f_half_add16 = cin ? src_x + 1'b1 : src_x;
  endfunction

  function [`WORD_WIDTH:0] f_half_add32;
    // x + cin
    input logic [`WORD_WIDTH:0] src_x;
    input logic                 cin;

    f_half_add32 = cin ? src_x + 1'b1 : src_x;
  endfunction

endmodule
