
`include "rvv_backend.svh"
`include "rvv_backend_sva.svh"

module rvv_backend_alu_unit_shift
(
`ifdef ASSERT_ON
  clk,
  rst_n,
`endif
  alu_uop_valid,
  alu_uop,
  result_valid,
  result
);
//
// interface signals
//
  // global signal
`ifdef ASSERT_ON
  input   logic                         clk;
  input   logic                         rst_n;
`endif

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
  logic   [`VLEN-1:0]                                        src2_data;
  logic   [`VLENB-1:0][$clog2(`BYTE_WIDTH)-1:0]              shift_amount8;
  logic   [`VLEN/`HWORD_WIDTH-1:0][$clog2(`HWORD_WIDTH)-1:0] shift_amount16;
  logic   [`VLEN/`WORD_WIDTH-1:0][$clog2(`WORD_WIDTH)-1:0]   shift_amount32;
  logic   [`VLENB-1:0][`BYTE_WIDTH-1:0]                      product8;
  logic   [`VLEN/`HWORD_WIDTH-1:0][`HWORD_WIDTH-1:0]         product16;
  logic   [`VLEN/`WORD_WIDTH-1:0][`WORD_WIDTH-1:0]           product32;
  logic   [`VLENB-1:0][`BYTE_WIDTH-1:0]                      round_bits8;
  logic   [`VLEN/`HWORD_WIDTH-1:0][`HWORD_WIDTH-1:0]         round_bits16;
  logic   [`VLEN/`WORD_WIDTH-1:0][`WORD_WIDTH-1:0]           round_bits32;
  logic   [`VLENB-1:0]                                       round_increment8;
  logic   [`VLEN/`HWORD_WIDTH-1:0]                           round_increment16;
  logic   [`VLEN/`WORD_WIDTH-1:0]                            round_increment32;
  logic   [`VLENB-1:0][`BYTE_WIDTH-1:0]                      round8;
  logic   [`VLEN/`HWORD_WIDTH-1:0][`HWORD_WIDTH-1:0]         round16;
  logic   [`VLEN/`WORD_WIDTH-1:0][`WORD_WIDTH-1:0]           round32;
  logic   [`VLEN/`HWORD_WIDTH-1:0]                           cout16;
  logic   [`VLEN/`WORD_WIDTH-1:0]                            cout32;
  logic   [`VLENB-1:0]                                       upoverflow;
  logic   [`VLENB-1:0]                                       underoverflow;
  logic   [`VLEN-1:0]                                        result_data; 
  SHIFT_e                                                    opcode;

  // PU2ROB_t  struct signals
  logic   [`VLEN-1:0]             w_data;             // when w_type=XRF, w_data[`XLEN-1:0] will store the scalar result
  logic                           w_valid; 
  logic   [`VCSR_VXSAT_WIDTH-1:0] vxsat;     
  logic                           ignore_vta;
  logic                           ignore_vma;
  
  // for-loop
  integer                         i;
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
  // prepare valid signal and source data
  always_comb begin
    // initial the data
    result_valid   = 'b0;
    src2_data      = 'b0;
    shift_amount8  = 'b0;
    shift_amount16 = 'b0;
    shift_amount32 = 'b0;

    case({alu_uop_valid,uop_funct3}) 
      {1'b1,OPIVV}: begin
        case(uop_funct6.ari_funct6)
          VSLL,
          VSRL,
          VSRA,
          VSSRL,
          VSSRA: begin
            if (vs2_data_valid&vs1_data_valid) begin
              result_valid = 'b1;
              
              src2_data = vs2_data;

              for (i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
                case(vs2_eew)
                  EEW8: begin
                    shift_amount8[4*i]   = vs1_data[(4*i  )*`BYTE_WIDTH +: $clog2(`BYTE_WIDTH)];
                    shift_amount8[4*i+1] = vs1_data[(4*i+1)*`BYTE_WIDTH +: $clog2(`BYTE_WIDTH)];
                    shift_amount8[4*i+2] = vs1_data[(4*i+2)*`BYTE_WIDTH +: $clog2(`BYTE_WIDTH)];
                    shift_amount8[4*i+3] = vs1_data[(4*i+3)*`BYTE_WIDTH +: $clog2(`BYTE_WIDTH)];
                  end
                  EEW16: begin
                    shift_amount16[2*i]   = vs1_data[(2*i  )*`HWORD_WIDTH +: $clog2(`HWORD_WIDTH)];
                    shift_amount16[2*i+1] = vs1_data[(2*i+1)*`HWORD_WIDTH +: $clog2(`HWORD_WIDTH)];
                  end
                  EEW32: begin
                    shift_amount32[i] = vs1_data[i*`WORD_WIDTH +: $clog2(`WORD_WIDTH)];
                  end
                endcase
              end
            end

            `ifdef ASSERT_ON
              `rvv_expect(vs2_data_valid==1'b1)
              else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

              `rvv_expect(vs1_data_valid==1'b1)
              else $error("vs1_data_valid(%d) should be 1.\n",vs1_data_valid);
            `endif
          end

          VNSRL,
          VNSRA,
          VNCLIPU,
          VNCLIP: begin
            if (vs2_data_valid&vs1_data_valid&((vs2_eew==EEW16)|(vs2_eew==EEW32))) begin
              result_valid = 'b1;
              
              src2_data = vs2_data;

              for (i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
                case(vs2_eew)
                  EEW16: begin
                    shift_amount16[2*i]   = vs1_data[(2*i  )*`HWORD_WIDTH +: $clog2(`HWORD_WIDTH)];
                    shift_amount16[2*i+1] = vs1_data[(2*i+1)*`HWORD_WIDTH +: $clog2(`HWORD_WIDTH)];
                  end
                  EEW32: begin
                    shift_amount32[i] = vs1_data[i*`WORD_WIDTH +: $clog2(`WORD_WIDTH)];
                  end
                endcase
              end      
            end

            `ifdef ASSERT_ON
              `rvv_expect(vs2_data_valid==1'b1)
              else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

              `rvv_expect(vs1_data_valid==1'b1)
              else $error("vs1_data_valid(%d) should be 1.\n",vs1_data_valid);

              `rvv_expect((vs2_eew==EEW16)|(vs2_eew==EEW32))
              else $error("vs2_eew(%s) is not supported.\n",vs2_eew.name());
            `endif
          end
        endcase
      end

      {1'b1,OPIVX},
      {1'b1,OPIVI}: begin
        case(uop_funct6.ari_funct6)
          VSLL,
          VSRL,
          VSRA,
          VSSRL,
          VSSRA: begin
            if (vs2_data_valid&rs1_data_valid) begin
              result_valid = 'b1;
              
              src2_data = vs2_data;
              for (i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
                case(vs2_eew)
                  EEW8: begin
                    shift_amount8[4*i]   = rs1_data[0 +: $clog2(`BYTE_WIDTH)];
                    shift_amount8[4*i+1] = rs1_data[0 +: $clog2(`BYTE_WIDTH)];
                    shift_amount8[4*i+2] = rs1_data[0 +: $clog2(`BYTE_WIDTH)];
                    shift_amount8[4*i+3] = rs1_data[0 +: $clog2(`BYTE_WIDTH)];
                  end
                  EEW16: begin
                    shift_amount16[2*i]   = rs1_data[0 +: $clog2(`HWORD_WIDTH)];
                    shift_amount16[2*i+1] = rs1_data[0 +: $clog2(`HWORD_WIDTH)];
                  end
                  EEW32: begin
                    shift_amount32[i] = rs1_data[0 +: $clog2(`WORD_WIDTH)];
                  end
                endcase
              end          
            end

            `ifdef ASSERT_ON
              `rvv_expect(vs2_data_valid==1'b1)
              else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

              `rvv_expect(rs1_data_valid==1'b1)
              else $error("rs1_data_valid(%d) should be 1.\n",rs1_data_valid);
            `endif
          end

          VNSRL,
          VNSRA,
          VNCLIPU,
          VNCLIP: begin
            if (vs2_data_valid&rs1_data_valid&((vs2_eew==EEW16)|(vs2_eew==EEW32))) begin
              result_valid = 'b1;
              
              src2_data = vs2_data;
              for (i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
                case(vs2_eew)
                  EEW16: begin
                    shift_amount16[2*i]   = rs1_data[0 +: $clog2(`HWORD_WIDTH)];
                    shift_amount16[2*i+1] = rs1_data[0 +: $clog2(`HWORD_WIDTH)];
                  end
                  EEW32: begin
                    shift_amount32[i] = rs1_data[0 +: $clog2(`WORD_WIDTH)];
                  end
                endcase
              end          
            end

            `ifdef ASSERT_ON
              `rvv_expect(vs2_data_valid==1'b1)
              else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

              `rvv_expect(rs1_data_valid==1'b1)
              else $error("rs1_data_valid(%d) should be 1.\n",rs1_data_valid);

              `rvv_expect((vs2_eew==EEW16)|(vs2_eew==EEW32))
              else $error("vs2_eew(%s) is not supported.\n",vs2_eew.name());
            `endif
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
    case({alu_uop_valid,uop_funct3}) 
      {1'b1,OPIVV},
      {1'b1,OPIVX},
      {1'b1,OPIVI}: begin
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
  // shifte instructions
  generate
    for (j=0;j<`VLENB;j=j+1) begin: EXE_PROD8
      assign {product8[j], round_bits8[j]} = f_shift8(opcode, {src2_data[j*`BYTE_WIDTH +: `BYTE_WIDTH],{`BYTE_WIDTH{1'b0}}}, shift_amount8[j]);
    end
  endgenerate
  
  generate
    for (j=0;j<`VLEN/`HWORD_WIDTH;j=j+1) begin: EXE_PROD16
      assign {product16[j], round_bits16[j]} = f_shift16(opcode, {src2_data[j*`HWORD_WIDTH +: `HWORD_WIDTH],{`HWORD_WIDTH{1'b0}}}, shift_amount16[j]);
    end
  endgenerate 

  generate
    for (j=0;j<`VLEN/`WORD_WIDTH;j=j+1) begin: EXE_PROD32
      assign {product32[j], round_bits32[j]} = f_shift32(opcode, {src2_data[j*`WORD_WIDTH +: `WORD_WIDTH],{`WORD_WIDTH{1'b0}}}, shift_amount32[j]);
    end
  endgenerate 
 
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
                                  src2_data[j*`BYTE_WIDTH]);
          end
          RDN: begin
            round_increment8[j] = 'b0;
          end
          ROD: begin
            round_increment8[j] = (!src2_data[j*`BYTE_WIDTH]) & (round_bits8[j]!='b0);
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
                                  src2_data[j*`HWORD_WIDTH]);
          end
          RDN: begin
            round_increment16[j] = 'b0;
          end
          ROD: begin
            round_increment16[j] = (!src2_data[j*`HWORD_WIDTH]) & (round_bits16[j]!='b0);
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
                                  src2_data[j*`WORD_WIDTH]);
          end
          RDN: begin
            round_increment32[j] = 'b0;
          end
          ROD: begin
            round_increment32[j] = (!src2_data[j*`WORD_WIDTH]) & (round_bits32[j]!='b0);
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
    for (j=0;j<`VLEN/`WORD_WIDTH;j++) begin: GET_OVERFLOW
      always_comb begin
        // initial
        upoverflow[   4*j +: 4] = 'b0;
        underoverflow[4*j +: 4] = 'b0;
          
        case(vs2_eew)
          EEW16: begin
            // unsigned overflow check for vnclipu
            if (opcode == SHIFT_SRL) begin
              upoverflow[4*j +: 4] = {
                1'b0, ({cout16[2*j+1], round16[2*j+1][`BYTE_WIDTH +: `BYTE_WIDTH]}!='b0),
                1'b0, ({cout16[2*j],   round16[2*j][  `BYTE_WIDTH +: `BYTE_WIDTH]}!='b0)};
            end
            else if (opcode == SHIFT_SRA) begin
            // signed overflow check for vnclip
              upoverflow[4*j +: 4] = {
                1'b0, ({cout16[2*j+1], round16[2*j+1][`BYTE_WIDTH +: `BYTE_WIDTH]}!='b0)&(round16[2*j+1][`BYTE_WIDTH-1]==1'b0),
                1'b0, ({cout16[2*j],   round16[2*j][  `BYTE_WIDTH +: `BYTE_WIDTH]}!='b0)&(round16[2*j][  `BYTE_WIDTH-1]==1'b0)};

              underoverflow[4*j +: 4] = {
                1'b0, ((&{cout16[2*j+1], round16[2*j+1][`BYTE_WIDTH +: `BYTE_WIDTH]})!=1'b1)&(round16[2*j+1][`BYTE_WIDTH-1]==1'b1),
                1'b0, ((&{cout16[2*j],   round16[2*j][  `BYTE_WIDTH +: `BYTE_WIDTH]})!=1'b1)&(round16[2*j][  `BYTE_WIDTH-1]==1'b1)};
            end
          end
          EEW32: begin
            // unsigned overflow check for vnclipu
            if (opcode == SHIFT_SRL) begin
              upoverflow[4*j +: 4] = {
                3'b0, ({cout32[j], round32[j][`HWORD_WIDTH +: `HWORD_WIDTH]}!='b0)};
            end
            else if (opcode == SHIFT_SRA) begin
            // signed overflow check for vnclip
              upoverflow[4*j +: 4] = {
                3'b0, ({cout32[j], round32[j][`HWORD_WIDTH +: `HWORD_WIDTH]}!='b0)&(round32[j][`HWORD_WIDTH-1]==1'b0)};

              underoverflow[4*j +: 4] = {
                3'b0, ((&{cout32[j], round32[j][`HWORD_WIDTH +: `HWORD_WIDTH]})!=1'b1)&(round32[j][`HWORD_WIDTH-1]==1'b1)};
            end
          end
        endcase
      end
    end
  endgenerate

  // assign to result_data
  always_comb begin
    // initial the data
    result_data = 'b0;
 
    for (i=0;i<`VLEN/`WORD_WIDTH;i++) begin
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
                  if (uop_index[0]==1'b0) begin
                    if (upoverflow[2*i])
                      result_data[i*`HWORD_WIDTH +: `BYTE_WIDTH] = 'hff;
                    else
                      result_data[i*`HWORD_WIDTH +: `BYTE_WIDTH] = round16[2*i][`BYTE_WIDTH-1 : 0];

                    if (upoverflow[2*i+2])
                      result_data[i*`HWORD_WIDTH+1*`BYTE_WIDTH +: `BYTE_WIDTH] = 'hff;
                    else
                      result_data[i*`HWORD_WIDTH+1*`BYTE_WIDTH +: `BYTE_WIDTH] = round16[2*i+1][`BYTE_WIDTH-1 : 0];
                  end
                  else begin
                    if (upoverflow[2*i])
                      result_data[`VLEN/2+i*`HWORD_WIDTH +: `BYTE_WIDTH] = 'hff;
                    else
                      result_data[`VLEN/2+i*`HWORD_WIDTH +: `BYTE_WIDTH] = round16[2*i][`BYTE_WIDTH-1 : 0];

                    if (upoverflow[2*i+2])
                      result_data[`VLEN/2+i*`HWORD_WIDTH+1*`BYTE_WIDTH +: `BYTE_WIDTH] = 'hff;
                    else
                      result_data[`VLEN/2+i*`HWORD_WIDTH+1*`BYTE_WIDTH +: `BYTE_WIDTH] = round16[2*i+1][`BYTE_WIDTH-1 : 0];
                  end
                end
                EEW32: begin
                  if (uop_index[0]==1'b0) begin
                    if (upoverflow[4*i])
                      result_data[i*`HWORD_WIDTH +: `HWORD_WIDTH] = 'hffff;
                    else
                      result_data[i*`HWORD_WIDTH +: `HWORD_WIDTH] = round32[i][`HWORD_WIDTH-1 : 0];
                  end
                  else begin
                    if (upoverflow[4*i])
                      result_data[`VLEN/2+i*`HWORD_WIDTH +: `HWORD_WIDTH] = 'hffff;
                    else
                      result_data[`VLEN/2+i*`HWORD_WIDTH +: `HWORD_WIDTH] = round32[i][`HWORD_WIDTH-1 : 0];
                  end
                end
              endcase
            end

            VNCLIP: begin
              case(vs2_eew)
                EEW16: begin
                  if (uop_index[0]==1'b0) begin
                    if (upoverflow[2*i])
                      result_data[i*`HWORD_WIDTH +: `BYTE_WIDTH] = 'h7f;
                    else if (underoverflow[2*i])
                      result_data[i*`HWORD_WIDTH +: `BYTE_WIDTH] = 'h80;
                    else
                      result_data[i*`HWORD_WIDTH +: `BYTE_WIDTH] = round16[2*i][`BYTE_WIDTH-1 : 0];

                    if (upoverflow[2*i+2])
                      result_data[i*`HWORD_WIDTH+1*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h7f;
                    else if (underoverflow[2*i+2])
                      result_data[i*`HWORD_WIDTH+1*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h80;
                    else
                      result_data[i*`HWORD_WIDTH+1*`BYTE_WIDTH +: `BYTE_WIDTH] = round16[2*i+1][`BYTE_WIDTH-1 : 0];
                  end
                  else begin
                    if (upoverflow[2*i])
                      result_data[`VLEN/2+i*`HWORD_WIDTH +: `BYTE_WIDTH] = 'h7f;
                    else if (underoverflow[2*i])
                      result_data[`VLEN/2+i*`HWORD_WIDTH +: `BYTE_WIDTH] = 'h80;
                    else
                      result_data[`VLEN/2+i*`HWORD_WIDTH +: `BYTE_WIDTH] = round16[2*i][`BYTE_WIDTH-1 : 0];

                    if (upoverflow[2*i+2])
                      result_data[`VLEN/2+i*`HWORD_WIDTH+1*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h7f;
                    else if (underoverflow[2*i+2])
                      result_data[`VLEN/2+i*`HWORD_WIDTH+1*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h80;
                    else
                      result_data[`VLEN/2+i*`HWORD_WIDTH+1*`BYTE_WIDTH +: `BYTE_WIDTH] = round16[2*i+1][`BYTE_WIDTH-1 : 0];
                  end
                end
                EEW32: begin
                  if (uop_index[0]==1'b0) begin
                    if (upoverflow[4*i])
                      result_data[i*`HWORD_WIDTH +: `HWORD_WIDTH] = 'h7fff;
                    else if (underoverflow[4*i])
                      result_data[i*`HWORD_WIDTH +: `HWORD_WIDTH] = 'h8000;
                    else
                      result_data[i*`HWORD_WIDTH +: `HWORD_WIDTH] = round32[i][`HWORD_WIDTH-1 : 0];
                  end
                  else begin
                    if (upoverflow[4*i])
                      result_data[`VLEN/2+i*`HWORD_WIDTH +: `HWORD_WIDTH] = 'h7fff;
                    else if (underoverflow[4*i])
                      result_data[`VLEN/2+i*`HWORD_WIDTH +: `HWORD_WIDTH] = 'h8000;
                    else
                      result_data[`VLEN/2+i*`HWORD_WIDTH +: `HWORD_WIDTH] = round32[i][`HWORD_WIDTH-1 : 0];
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
  assign  result.rob_entry  = rob_entry;
  assign  result.w_data     = w_data;
  assign  result.w_valid    = w_valid;
  assign  result.vxsat      = vxsat;
  assign  result.ignore_vta = ignore_vta;
  assign  result.ignore_vma = ignore_vma;

  // result data
  assign w_data = result_data;

  // result type and valid signal
  assign w_valid = result_valid;

  // saturate signal
  always_comb begin
    // initial
    vxsat = 'b0;

    case({alu_uop_valid,uop_funct3}) 
      {1'b1,OPIVV},
      {1'b1,OPIVX},
      {1'b1,OPIVI}: begin
        case(uop_funct6.ari_funct6)
          VNCLIPU: begin
            vxsat = upoverflow;
          end
          VNCLIP: begin
            vxsat = underoverflow | upoverflow;
          end
        endcase
      end
    endcase
  end

  // ignore vta an vma signal
  assign ignore_vta = 'b0;
  assign ignore_vma = 'b0;

//
// function unit
//
  // shifter function
  function [2*`BYTE_WIDTH-1:0] f_shift8;
    input SHIFT_e                           opcode;
    input logic signed [2*`BYTE_WIDTH-1:0]  operand;
    input logic [$clog2(`BYTE_WIDTH)-1:0]   amount;

    if (opcode==SHIFT_SLL)
      f_shift8 = operand << amount;
    else if (opcode==SHIFT_SRL)
      f_shift8 = operand >> amount;
    else if (opcode==SHIFT_SRA)
      f_shift8 = operand >>> amount;
    else
      f_shift8 = 'b0;
  endfunction

  function [2*`HWORD_WIDTH-1:0] f_shift16;
    input SHIFT_e                            opcode;
    input logic signed [2*`HWORD_WIDTH-1:0]  operand;
    input logic [$clog2(`HWORD_WIDTH)-1:0]   amount;

    if (opcode==SHIFT_SLL)
      f_shift16 = operand << amount;
    else if (opcode==SHIFT_SRL)
      f_shift16 = operand >> amount;
    else if (opcode==SHIFT_SRA)
      f_shift16 = operand >>> amount;
    else
      f_shift16 = 'b0;
  endfunction

  function [2*`WORD_WIDTH-1:0] f_shift32;
    input SHIFT_e                           opcode;
    input logic signed [2*`WORD_WIDTH-1:0]  operand;
    input logic [$clog2(`WORD_WIDTH)-1:0]   amount;

    if (opcode==SHIFT_SLL)
      f_shift32 = operand << amount;
    else if (opcode==SHIFT_SRL)
      f_shift32 = operand >> amount;
    else if (opcode==SHIFT_SRA)
      f_shift32 = operand >>> amount;
    else
      f_shift32 = 'b0;
  endfunction

  function [`BYTE_WIDTH-1:0] f_half_add8;
    // x + cin
    input logic [`BYTE_WIDTH:0] src_x;
    input logic                 cin;
    
    logic [`BYTE_WIDTH:0] result;

    result = src_x +cin;

    f_half_add8 = result[`BYTE_WIDTH-1:0];
  endfunction

  function [`HWORD_WIDTH:0] f_half_add16;
    // x + cin
    input logic [`HWORD_WIDTH:0] src_x;
    input logic                  cin;

    f_half_add16 = src_x + cin;
  endfunction

  function [`WORD_WIDTH:0] f_half_add32;
    // x + cin
    input logic [`WORD_WIDTH:0] src_x;
    input logic                 cin;

    f_half_add32 = src_x + cin;
  endfunction

endmodule
