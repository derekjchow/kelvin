
`include "rvv_backend.svh"
`include "rvv_backend_alu.svh"

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
  logic   [`VLEN-1:0]                                 result_data_rg;   // regular data for EEW_vd = 8b,16b,32b
  logic   [`VLEN-1:0]                                 result_data_sp;   // special data for EEW_vd = 1b 
  logic   [`VLEN-1:0]                                 mask_sp_bit0;     // control logic for result_data_sp 
  logic   [`VLEN-1:0]                                 mask_sp_bit1;     // control logic for result_data_sp 
  logic   [`VLEN-1:0]                                 mask_sp_bit2;     // control logic for result_data_sp 
  ADDSUB_e                                            opcode;

  // PU2ROB_t  struct signals
  logic   [`VLEN-1:0]             w_data;             // when w_type=XRF, w_data[`XLEN-1:0] will store the scalar result
  logic                           w_valid; 
  logic   [`VCSR_VXSAT_WIDTH-1:0] vxsat;     
  logic                           ignore_vta;
  logic                           ignore_vma;
  
  // for-loop

  genvar                          j;

//
// prepare source data to calculate    
//
  // split ALU_RS_t struct
  assign  rob_entry      = alu_uop.rob_entry;
  assign  uop_funct6     = alu_uop.uop_funct6;
  assign  uop_funct3     = alu_uop.uop_funct3;
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
 
  always_comb begin
    v0_data_in_use = 'b0;

    case(vs2_eew)
      EEW8: begin
        v0_data_in_use = v0_data[{uop_index,{($clog2(`VLENB)){1'b0}}} +: `VLENB];
      end
      EEW16: begin
        v0_data_in_use = v0_data[{uop_index,{($clog2(`VLENB/2)){1'b0}}} +: `VLENB];
      end
      EEW32: begin
        v0_data_in_use = v0_data[{uop_index,{($clog2(`VLENB/4)){1'b0}}} +: `VLENB];
      end
    endcase
  end

//  
// prepare source data 
//
  // prepare valid signal 
  always_comb begin
    // initial the data
    result_valid = 'b0;

    case({alu_uop_valid,uop_funct3}) 
      {1'b1,OPIVV}: begin
        case(uop_funct6.ari_funct6)
          VADD,
          VSUB,
          VSADD,
          VSSUB: begin
            if (vs2_data_valid&vs1_data_valid) begin
              result_valid = 'b1;
            end

            `ifdef ASSERT_ON
              assert(vs2_data_valid==1'b1)
                else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

              assert(vs1_data_valid==1'b1)
                else $error("vs1_data_valid(%d) should be 1.\n",vs1_data_valid);
            `endif
          end

          VADC,
          VSBC: begin
            if (vs2_data_valid&vs1_data_valid&(vm==1'b0)&v0_data_valid) begin
              result_valid = 'b1;
            end

            `ifdef ASSERT_ON
              assert(vs2_data_valid==1'b1)
                else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

              assert(vs1_data_valid==1'b1)
                else $error("vs1_data_valid(%d) should be 1.\n",vs1_data_valid);

              assert(vm==1'b0)
                else $error("vm(%d) should be 0.\n",vm);

              assert(v0_data_valid==1'b1)
                else $error("v0_data_valid(%d) should be 1.\n",v0_data_valid);
            `endif
          end

          VMADC,
          VMSBC: begin
            if (vs2_data_valid&vs1_data_valid&vd_data_valid&(vm^v0_data_valid)) begin
              result_valid = 'b1;
            end

            `ifdef ASSERT_ON
              assert(vs2_data_valid==1'b1)
                else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

              assert(vs1_data_valid==1'b1)
                else $error("vs1_data_valid(%d) should be 1.\n",vs1_data_valid);

              assert(vd_data_valid==1'b1)
                else $error("vd_data_valid(%d) should be 1.\n",vd_data_valid);

              assert(vm^v0_data_valid)
                else $error("vm^v0_data_valid(%d) should be 1.\n",vm^v0_data_valid);
            `endif
          end

          VSADDU,
          VSSUBU: begin
            if (vs2_data_valid&vs1_data_valid) begin
              result_valid = 'b1;
            end
      
            `ifdef ASSERT_ON
              assert(vs2_data_valid==1'b1)
                else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

              assert(vs1_data_valid==1'b1)
                else $error("vs1_data_valid(%d) should be 1.\n",vs1_data_valid);
            `endif
          end
        endcase
      end

      {1'b1,OPIVX}: begin
        case(uop_funct6.ari_funct6)
          VADD,
          VSUB,
          VSADD,
          VSSUB: begin
            if (vs2_data_valid&rs1_data_valid) begin
              result_valid = 'b1;
            end

            `ifdef ASSERT_ON
              assert(vs2_data_valid==1'b1)
                else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

              assert(rs1_data_valid==1'b1)
                else $error("rs1_data_valid(%d) should be 1.\n",rs1_data_valid);
            `endif
          end
          
          VRSUB: begin
            if (vs2_data_valid&rs1_data_valid) begin
              result_valid = 'b1;
            end

            `ifdef ASSERT_ON
              assert(vs2_data_valid==1'b1)
                else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

              assert(rs1_data_valid==1'b1)
                else $error("rs1_data_valid(%d) should be 1.\n",rs1_data_valid);
            `endif
          end

          VADC,
          VSBC: begin
            if (vs2_data_valid&rs1_data_valid&(vm==1'b0)&v0_data_valid) begin
              result_valid = 'b1;
            end

            `ifdef ASSERT_ON
              assert(vs2_data_valid==1'b1)
                else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

              assert(rs1_data_valid==1'b1)
                else $error("rs1_data_valid(%d) should be 1.\n",rs1_data_valid);

              assert(vm==1'b0)
                else $error("vm(%d) should be 0.\n",vm);

              assert(v0_data_valid==1'b1)
                else $error("v0_data_valid(%d) should be 1.\n",v0_data_valid);
            `endif
          end

          VMADC,
          VMSBC: begin
            if (vs2_data_valid&vs1_data_valid&vd_data_valid&(vm^v0_data_valid)) begin
              result_valid = 'b1;
            end

            `ifdef ASSERT_ON
              assert(vs2_data_valid==1'b1)
                else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

              assert(rs1_data_valid==1'b1)
                else $error("rs1_data_valid(%d) should be 1.\n",rs1_data_valid);

              assert(vd_data_valid==1'b1)
                else $error("vd_data_valid(%d) should be 1.\n",vd_data_valid);

              assert(vm^v0_data_valid)
                else $error("vm^v0_data_valid(%d) should be 1.\n",vm^v0_data_valid);
            `endif
          end

          VSADDU,
          VSSUBU: begin
            if (vs2_data_valid&rs1_data_valid) begin
              result_valid = 'b1;
            end

            `ifdef ASSERT_ON
              assert(vs2_data_valid==1'b1)
                else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

              assert(rs1_data_valid==1'b1)
                else $error("rs1_data_valid(%d) should be 1.\n",rs1_data_valid);
            `endif
          end
        endcase
      end
      {1'b1,OPIVI}: begin
        case(uop_funct6.ari_funct6)
          VADD,
          VSADD: begin
            if (vs2_data_valid&rs1_data_valid) begin
              result_valid = 'b1;
            end

            `ifdef ASSERT_ON
              assert(vs2_data_valid==1'b1)
                else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

              assert(rs1_data_valid==1'b1)
                else $error("rs1_data_valid(%d) should be 1.\n",rs1_data_valid);
            `endif
          end
          
          VRSUB: begin
            if (vs2_data_valid&rs1_data_valid) begin
              result_valid = 'b1;
            end

            `ifdef ASSERT_ON
              assert(vs2_data_valid==1'b1)
                else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

              assert(rs1_data_valid==1'b1)
                else $error("rs1_data_valid(%d) should be 1.\n",rs1_data_valid);
            `endif
          end

          VADC: begin
            if (vs2_data_valid&rs1_data_valid&(vm==1'b0)&v0_data_valid) begin
              result_valid = 'b1;
            end

            `ifdef ASSERT_ON
              assert(vs2_data_valid==1'b1)
                else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

              assert(rs1_data_valid==1'b1)
                else $error("rs1_data_valid(%d) should be 1.\n",rs1_data_valid);

              assert(vm==1'b0)
                else $error("vm(%d) should be 0.\n",vm);

              assert(v0_data_valid==1'b1)
                else $error("v0_data_valid(%d) should be 1.\n",v0_data_valid);
            `endif
          end
          
          VMADC: begin
            if (vs2_data_valid&vs1_data_valid&vd_data_valid&(vm^v0_data_valid)) begin
              result_valid = 'b1;
            end

            `ifdef ASSERT_ON
              assert(vs2_data_valid==1'b1)
                else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

              assert(rs1_data_valid==1'b1)
                else $error("rs1_data_valid(%d) should be 1.\n",rs1_data_valid);

              assert(vd_data_valid==1'b1)
                else $error("vd_data_valid(%d) should be 1.\n",vd_data_valid);

              assert(vm^v0_data_valid)
                else $error("vm^v0_data_valid(%d) should be 1.\n",vm^v0_data_valid);
            `endif
          end

          VSADDU: begin
            if (vs2_data_valid&rs1_data_valid) begin
              result_valid = 'b1;
            end

            `ifdef ASSERT_ON
              assert(vs2_data_valid==1'b1)
                else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

              assert(rs1_data_valid==1'b1)
                else $error("rs1_data_valid(%d) should be 1.\n",rs1_data_valid);
            `endif
          end
        endcase
      end

      {1'b1,OPMVV}: begin
        case(uop_funct6.ari_funct6)
          VWADDU,
          VWSUBU: begin
            if (vs2_data_valid&vs1_data_valid&((vs2_eew==EEW8)|(vs2_eew==EEW16))) begin
              result_valid = 'b1;
            end

            `ifdef ASSERT_ON
              assert(vs2_data_valid==1'b1)
                else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

              assert(vs1_data_valid==1'b1)
                else $error("vs1_data_valid(%d) should be 1.\n",vs1_data_valid);

              assert((vs2_eew==EEW16)|(vs2_eew==EEW32))
                else $error("vs2_eew(%s) is not supported.\n",vs2_eew.name());
            `endif
          end

          VWADD,
          VWSUB: begin
            if (vs2_data_valid&vs1_data_valid&((vs2_eew==EEW8)|(vs2_eew==EEW16))) begin
              result_valid = 'b1;
            end

            `ifdef ASSERT_ON
              assert(vs2_data_valid==1'b1)
                else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

              assert(vs1_data_valid==1'b1)
                else $error("vs1_data_valid(%d) should be 1.\n",vs1_data_valid);

              assert((vs2_eew==EEW16)|(vs2_eew==EEW32))
                else $error("vs2_eew(%s) is not supported.\n",vs2_eew.name());
            `endif
          end

          VWADDU_W,
          VWSUBU_W: begin
            if (vs2_data_valid&vs1_data_valid&((vs2_eew==EEW16)|(vs2_eew==EEW32))) begin
              result_valid = 'b1;
            end

            `ifdef ASSERT_ON
              assert(vs2_data_valid==1'b1)
                else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

              assert(vs1_data_valid==1'b1)
                else $error("vs1_data_valid(%d) should be 1.\n",vs1_data_valid);

              assert((vs2_eew==EEW16)|(vs2_eew==EEW32))
                else $error("vs2_eew(%s) is not supported.\n",vs2_eew.name());
            `endif
          end

          VWADD_W,
          VWSUB_W: begin
            if (vs2_data_valid&vs1_data_valid&((vs2_eew==EEW16)|(vs2_eew==EEW32))) begin
              result_valid = 'b1;
            end

            `ifdef ASSERT_ON
              assert(vs2_data_valid==1'b1)
                else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

              assert(vs1_data_valid==1'b1)
                else $error("vs1_data_valid(%d) should be 1.\n",vs1_data_valid);

              assert((vs2_eew==EEW16)|(vs2_eew==EEW32))
                else $error("vs2_eew(%s) is not supported.\n",vs2_eew.name());
            `endif
          end

          VAADDU,
          VASUBU: begin
            if (vs2_data_valid&vs1_data_valid) begin
              result_valid   = 'b1;
            end

            `ifdef ASSERT_ON
              assert(vs2_data_valid==1'b1)
                else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

              assert(vs1_data_valid==1'b1)
                else $error("vs1_data_valid(%d) should be 1.\n",vs1_data_valid);
            `endif
          end

          VAADD,
          VASUB: begin
            if (vs2_data_valid&vs1_data_valid) begin
              result_valid = 'b1;
            end

            `ifdef ASSERT_ON
              assert(vs2_data_valid==1'b1)
                else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

              assert(vs1_data_valid==1'b1)
                else $error("vs1_data_valid(%d) should be 1.\n",vs1_data_valid);
            `endif
          end
        endcase
      end
      
      {1'b1,OPMVX}: begin
        case(uop_funct6.ari_funct6)
          VWADDU,
          VWSUBU: begin
            if (vs2_data_valid&rs1_data_valid&((vs2_eew==EEW8)|(vs2_eew==EEW16))) begin
              result_valid = 'b1;
            end

            `ifdef ASSERT_ON
              assert(vs2_data_valid==1'b1)
                else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

              assert(rs1_data_valid==1'b1)
                else $error("rs1_data_valid(%d) should be 1.\n",rs1_data_valid);

              assert((vs2_eew==EEW16)|(vs2_eew==EEW32))
                else $error("vs2_eew(%s) is not supported.\n",vs2_eew.name());
            `endif
          end

          VWADD,
          VWSUB: begin
            if (vs2_data_valid&rs1_data_valid&((vs2_eew==EEW8)|(vs2_eew==EEW16))) begin
              result_valid = 'b1;
            end

            `ifdef ASSERT_ON
              assert(vs2_data_valid==1'b1)
                else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

              assert(rs1_data_valid==1'b1)
                else $error("rs1_data_valid(%d) should be 1.\n",rs1_data_valid);

              assert((vs2_eew==EEW16)|(vs2_eew==EEW32))
                else $error("vs2_eew(%s) is not supported.\n",vs2_eew.name());
            `endif
          end

          VWADDU_W,
          VWSUBU_W: begin
            if (vs2_data_valid&rs1_data_valid&((vs2_eew==EEW16)|(vs2_eew==EEW32))) begin
              result_valid = 'b1;
            end

            `ifdef ASSERT_ON
              assert(vs2_data_valid==1'b1)
                else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

              assert(rs1_data_valid==1'b1)
                else $error("rs1_data_valid(%d) should be 1.\n",rs1_data_valid);

              assert((vs2_eew==EEW16)|(vs2_eew==EEW32))
                else $error("vs2_eew(%s) is not supported.\n",vs2_eew.name());
            `endif
          end

          VWADD_W,
          VWSUB_W: begin
            if (vs2_data_valid&rs1_data_valid&((vs2_eew==EEW16)|(vs2_eew==EEW32))) begin
              result_valid = 'b1;
            end

            `ifdef ASSERT_ON
              assert(vs2_data_valid==1'b1)
                else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

              assert(rs1_data_valid==1'b1)
                else $error("rs1_data_valid(%d) should be 1.\n",rs1_data_valid);

              assert((vs2_eew==EEW16)|(vs2_eew==EEW32))
                else $error("vs2_eew(%s) is not supported.\n",vs2_eew.name());
            `endif
          end

          VAADDU,
          VASUBU: begin
            if (vs2_data_valid&rs1_data_valid) begin
              result_valid   = 'b1;
            end

            `ifdef ASSERT_ON
              assert(vs2_data_valid==1'b1)
                else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

              assert(rs1_data_valid==1'b1)
                else $error("rs1_data_valid(%d) should be 1.\n",rs1_data_valid);
            `endif
          end

          VAADD,
          VASUB: begin
            if (vs2_data_valid&rs1_data_valid) begin
              result_valid   = 'b1;
            end

            `ifdef ASSERT_ON
              assert(vs2_data_valid==1'b1)
                else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

              assert(rs1_data_valid==1'b1)
                else $error("rs1_data_valid(%d) should be 1.\n",rs1_data_valid);
            `endif
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
          VMADC,
          VSBC,
          VMSBC,
          VSADDU,
          VSADD,
          VSSUBU,
          VSSUB: begin
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
          VMADC,
          VSBC,
          VMSBC,
          VSADDU,
          VSADD,
          VSSUBU,
          VSSUB: begin
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
          VMADC,
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
          VWSUBU,
          VWADD,
          VWSUB: begin
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

                    src1_data[4*i]   = {1'b0, vs1_data[`VLEN/2+(2*i  )*`BYTE_WIDTH +: `BYTE_WIDTH]};
                    src1_data[4*i+1] = {1'b0, vs1_data[`VLEN/2+(2*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH]};
                    src1_data[4*i+2] = 'b0;
                    src1_data[4*i+3] = 'b0;
                  end
                end
              endcase
            end
          end

          VWADDU_W,
          VWSUBU_W,
          VWADD_W,
          VWSUB_W: begin
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
          VWSUBU,
          VWADD,
          VWSUB: begin
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

          VWADDU_W,
          VWSUBU_W,
          VWADD_W,
          VWSUB_W: begin
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
              VMADC,
              VSBC,
              VMSBC: begin
                if ((vm==1'b0)&v0_data_valid) begin
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
          VMADC,
          VSADDU,
          VSADD: begin
            opcode = ADDSUB_VADD;
          end
          VSUB,
          VRSUB,
          VSBC,
          VMSBC,
          VSSUBU,
          VSSUB: begin
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
    round8  = 'b0;
    round16 = 'b0;
    round32 = 'b0;

    case(vxrm)
      RNU: begin
        for(int i=0;i<`VLENB;i=i+1) begin
          round8[i] = f_half_add8({cout8[i],product8[i][`BYTE_WIDTH-1:1]}, product8[i][0]); 
        end
        
        for(int i=0;i<`VLEN/`HWORD_WIDTH;i=i+1) begin
          round16[i] = f_half_add16({cout16[i],product16[i][`HWORD_WIDTH-1:1]}, product16[i][0]); 
        end
        for(int i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
          round32[i] = f_half_add32({cout32[i],product32[i][`WORD_WIDTH-1:1]}, product32[i][0]); 
        end
      end
      RNE: begin
        for(int i=0;i<`VLENB;i=i+1) begin
          round8[i] = f_half_add8({cout8[i],product8[i][`BYTE_WIDTH-1:1]}, (product8[i][0]&product8[i][1])); 
        end

        for(int i=0;i<`VLEN/`HWORD_WIDTH;i=i+1) begin
          round16[i] = f_half_add16({cout16[i],product16[i][`HWORD_WIDTH-1:1]}, (product16[i][0]&product16[i][1])); 
        end

        for(int i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
          round32[i] = f_half_add32({cout32[i],product32[i][`WORD_WIDTH-1:1]}, (product32[i][0]&product32[i][1])); 
        end
      end
      RDN: begin
        for(int i=0;i<`VLENB;i=i+1) begin
          round8[i] = {cout8[i],product8[i][`BYTE_WIDTH-1:1]}; 
        end

        for(int i=0;i<`VLEN/`HWORD_WIDTH;i=i+1) begin
          round16[i] = {cout16[i],product16[i][`HWORD_WIDTH-1:1]}; 
        end

        for(int i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
          round32[i] = {cout32[i],product32[i][`WORD_WIDTH-1:1]}; 
        end
      end
      ROD: begin
        for(int i=0;i<`VLENB;i=i+1) begin
          round8[i] = f_half_add8({cout8[i],product8[i][`BYTE_WIDTH-1:1]}, ((!product8[i][1])&product8[i][0])); 
        end

        for(int i=0;i<`VLEN/`HWORD_WIDTH;i=i+1) begin
          round16[i] = f_half_add16({cout16[i],product16[i][`HWORD_WIDTH-1:1]}, ((!product16[i][1])&product16[i][0])); 
        end

        for(int i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
          round32[i] = f_half_add32({cout32[i],product32[i][`WORD_WIDTH-1:1]}, ((!product32[i][1])&product32[i][0])); 
        end
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
              ((cout8[4*j+3]==1'b1)&(src2_data[4*j+3][`BYTE_WIDTH-1]==1'b0)&(src1_data[4*j+3][`BYTE_WIDTH-1]==1'b0)),
              ((cout8[4*j+2]==1'b1)&(src2_data[4*j+2][`BYTE_WIDTH-1]==1'b0)&(src1_data[4*j+2][`BYTE_WIDTH-1]==1'b0)),
              ((cout8[4*j+1]==1'b1)&(src2_data[4*j+1][`BYTE_WIDTH-1]==1'b0)&(src1_data[4*j+1][`BYTE_WIDTH-1]==1'b0)),
              ((cout8[4*j]  ==1'b1)&(src2_data[4*j  ][`BYTE_WIDTH-1]==1'b0)&(src1_data[4*j  ][`BYTE_WIDTH-1]==1'b0))};

            add_underoverflow[4*j +: 4] = {
              ((cout8[4*j+3]==1'b0)&(src2_data[4*j+3][`BYTE_WIDTH-1]==1'b1)&(src1_data[4*j+3][`BYTE_WIDTH-1]==1'b1)),
              ((cout8[4*j+2]==1'b0)&(src2_data[4*j+2][`BYTE_WIDTH-1]==1'b1)&(src1_data[4*j+2][`BYTE_WIDTH-1]==1'b1)),
              ((cout8[4*j+1]==1'b0)&(src2_data[4*j+1][`BYTE_WIDTH-1]==1'b1)&(src1_data[4*j+1][`BYTE_WIDTH-1]==1'b1)),
              ((cout8[4*j]  ==1'b0)&(src2_data[4*j  ][`BYTE_WIDTH-1]==1'b1)&(src1_data[4*j  ][`BYTE_WIDTH-1]==1'b1))};
            
            subu_underoverflow[4*j +: 4] = {cout8[4*j+3],cout8[4*j+2],cout8[4*j+1],cout8[4*j]};

            sub_upoverflow[4*j +: 4] = {
              ((cout8[4*j+3]==1'b1)&(src2_data[4*j+3][`BYTE_WIDTH-1]==1'b0)&(src1_data[4*j+3][`BYTE_WIDTH-1]==1'b1)),
              ((cout8[4*j+2]==1'b1)&(src2_data[4*j+2][`BYTE_WIDTH-1]==1'b0)&(src1_data[4*j+2][`BYTE_WIDTH-1]==1'b1)),
              ((cout8[4*j+1]==1'b1)&(src2_data[4*j+1][`BYTE_WIDTH-1]==1'b0)&(src1_data[4*j+1][`BYTE_WIDTH-1]==1'b1)),
              ((cout8[4*j]  ==1'b1)&(src2_data[4*j  ][`BYTE_WIDTH-1]==1'b0)&(src1_data[4*j  ][`BYTE_WIDTH-1]==1'b1))};

            sub_underoverflow[4*j +: 4] = {
              ((cout8[4*j+3]==1'b0)&(src2_data[4*j+3][`BYTE_WIDTH-1]==1'b1)&(src1_data[4*j+3][`BYTE_WIDTH-1]==1'b0)),
              ((cout8[4*j+2]==1'b0)&(src2_data[4*j+2][`BYTE_WIDTH-1]==1'b1)&(src1_data[4*j+2][`BYTE_WIDTH-1]==1'b0)),
              ((cout8[4*j+1]==1'b0)&(src2_data[4*j+1][`BYTE_WIDTH-1]==1'b1)&(src1_data[4*j+1][`BYTE_WIDTH-1]==1'b0)),
              ((cout8[4*j]  ==1'b0)&(src2_data[4*j  ][`BYTE_WIDTH-1]==1'b1)&(src1_data[4*j  ][`BYTE_WIDTH-1]==1'b0))};
          end
          EEW16: begin
            addu_upoverflow[4*j +: 4] = {1'b0,cout16[2*j+1],1'b0,cout16[2*j]};

            add_upoverflow[4*j +: 4] = {
              1'b0,
              ((cout16[2*j+1]==1'b1)&(src2_data[4*j+3][`BYTE_WIDTH-1]==1'b0)&(src1_data[4*j+3][`BYTE_WIDTH-1]==1'b0)),
              1'b0,
              ((cout16[2*j]  ==1'b1)&(src2_data[4*j+1][`BYTE_WIDTH-1]==1'b0)&(src1_data[4*j+1][`BYTE_WIDTH-1]==1'b0))};

            add_underoverflow[4*j +: 4] = {
              1'b0,
              ((cout16[2*j+1]==1'b0)&(src2_data[4*j+3][`BYTE_WIDTH-1]==1'b1)&(src1_data[4*j+3][`BYTE_WIDTH-1]==1'b1)),
              1'b0,
              ((cout16[2*j]  ==1'b0)&(src2_data[4*j+1][`BYTE_WIDTH-1]==1'b1)&(src1_data[4*j+1][`BYTE_WIDTH-1]==1'b1))};

            subu_underoverflow[4*j +: 4] = {1'b0,cout16[2*j+1],1'b0,cout16[2*j]};

            sub_upoverflow[4*j +: 4] = {
              1'b0,
              ((cout16[2*j+1]==1'b1)&(src2_data[4*j+3][`BYTE_WIDTH-1]==1'b0)&(src1_data[4*j+3][`BYTE_WIDTH-1]==1'b1)),
              1'b0,
              ((cout16[2*j]  ==1'b1)&(src2_data[4*j+1][`BYTE_WIDTH-1]==1'b0)&(src1_data[4*j+1][`BYTE_WIDTH-1]==1'b1))};

            sub_underoverflow[4*j +: 4] = {
              1'b0,
              ((cout16[2*j+1]==1'b0)&(src2_data[4*j+3][`BYTE_WIDTH-1]==1'b1)&(src1_data[4*j+3][`BYTE_WIDTH-1]==1'b0)),
              1'b0,
              ((cout16[2*j]  ==1'b0)&(src2_data[4*j+1][`BYTE_WIDTH-1]==1'b1)&(src1_data[4*j+1][`BYTE_WIDTH-1]==1'b0))};
          end
          EEW32: begin
            addu_upoverflow[4*j +: 4] = {3'b0,cout32[j]};

            add_upoverflow[4*j +: 4] = {
              3'b0,
              ((cout32[j]==1'b1)&(src2_data[4*j+3][`BYTE_WIDTH-1]==1'b0)&(src1_data[4*j+3][`BYTE_WIDTH-1]==1'b0))};

            add_underoverflow[4*j +: 4] = {
              3'b0,
              ((cout32[j]==1'b0)&(src2_data[4*j+3][`BYTE_WIDTH-1]==1'b1)&(src1_data[4*j+3][`BYTE_WIDTH-1]==1'b1))};

            subu_underoverflow[4*j +: 4] = {3'b0,cout32[j]};

            sub_upoverflow[4*j +: 4] = {
              3'b0,
              ((cout32[j]==1'b1)&(src2_data[4*j+3][`BYTE_WIDTH-1]==1'b0)&(src1_data[4*j+3][`BYTE_WIDTH-1]==1'b1))};

            sub_underoverflow[4*j +: 4] = {
              3'b0,
              ((cout32[j]==1'b0)&(src2_data[4*j+3][`BYTE_WIDTH-1]==1'b1)&(src1_data[4*j+3][`BYTE_WIDTH-1]==1'b0))};
          end
        endcase
      end
    end
  endgenerate

  // assign to result_data_rg
  generate 
    for (j=0;j<`VLEN/`WORD_WIDTH;j++) begin: GET_RESULT_DATA_RG
      always_comb begin
        // initial the data
        result_data_rg[j*`WORD_WIDTH +: `WORD_WIDTH] = 'b0;
 
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
                    result_data_rg[j*`WORD_WIDTH +: `WORD_WIDTH] = {product8[4*j+3],product8[4*j+2],product8[4*j+1],product8[4*j]};
                  end
                  EEW16: begin
                    result_data_rg[j*`WORD_WIDTH +: `WORD_WIDTH] = {product16[2*j+1],product16[2*j]};
                  end
                  EEW32: begin
                    result_data_rg[j*`WORD_WIDTH +: `WORD_WIDTH] = product32[j];
                  end
                endcase
              end
              
              VSADDU: begin
                case(vs2_eew)
                  EEW8: begin
                    if(addu_upoverflow[4*j])
                      result_data_rg[j*`WORD_WIDTH +: `BYTE_WIDTH] = 'hff;
                    else
                      result_data_rg[j*`WORD_WIDTH +: `BYTE_WIDTH] = product8[4*j];
                      
                    if(addu_upoverflow[4*j+1])
                      result_data_rg[j*`WORD_WIDTH+1*`BYTE_WIDTH +: `BYTE_WIDTH] = 'hff;
                    else
                      result_data_rg[j*`WORD_WIDTH+1*`BYTE_WIDTH +: `BYTE_WIDTH] = product8[4*j+1];
                    
                    if(addu_upoverflow[4*j+2])
                      result_data_rg[j*`WORD_WIDTH+2*`BYTE_WIDTH +: `BYTE_WIDTH] = 'hff;
                    else
                      result_data_rg[j*`WORD_WIDTH+2*`BYTE_WIDTH +: `BYTE_WIDTH] = product8[4*j+2];

                    if(addu_upoverflow[4*j+3])
                      result_data_rg[j*`WORD_WIDTH+3*`BYTE_WIDTH +: `BYTE_WIDTH] = 'hff;
                    else
                      result_data_rg[j*`WORD_WIDTH+3*`BYTE_WIDTH +: `BYTE_WIDTH] = product8[4*j+3];
                  end
                  EEW16: begin
                    if(addu_upoverflow[4*j])
                      result_data_rg[j*`WORD_WIDTH +: `HWORD_WIDTH] = 'hffff;
                    else
                      result_data_rg[j*`WORD_WIDTH +: `HWORD_WIDTH] = product16[2*j];
                      
                    if(addu_upoverflow[4*j+2])
                      result_data_rg[j*`WORD_WIDTH+1*`HWORD_WIDTH +: `HWORD_WIDTH] = 'hffff;
                    else
                      result_data_rg[j*`WORD_WIDTH+1*`HWORD_WIDTH +: `HWORD_WIDTH] = product16[2*j+1];
                  end
                  EEW32: begin
                    if(addu_upoverflow[4*j])
                      result_data_rg[j*`WORD_WIDTH +: `WORD_WIDTH] = 'hffff_ffff;
                    else
                      result_data_rg[j*`WORD_WIDTH +: `WORD_WIDTH] = product32[j];
                  end
                endcase
              end

              VSADD: begin
                case(vs2_eew)
                  EEW8: begin
                    if (add_upoverflow[4*j])
                      result_data_rg[j*`WORD_WIDTH +: `BYTE_WIDTH] = 'h7f;
                    else if (add_underoverflow[4*j])
                      result_data_rg[j*`WORD_WIDTH +: `BYTE_WIDTH] = 'h80;
                    else
                      result_data_rg[j*`WORD_WIDTH +: `BYTE_WIDTH] = product8[4*j];
                      
                    if (add_upoverflow[4*j+1])
                      result_data_rg[j*`WORD_WIDTH+1*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h7f;
                    else if (add_underoverflow[4*j+1])
                      result_data_rg[j*`WORD_WIDTH+1*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h80;
                    else
                      result_data_rg[j*`WORD_WIDTH+1*`BYTE_WIDTH +: `BYTE_WIDTH] = product8[4*j+1];
                    
                    if (add_upoverflow[4*j+2])
                      result_data_rg[j*`WORD_WIDTH+2*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h7f;
                    else if (add_underoverflow[4*j+2])
                      result_data_rg[j*`WORD_WIDTH+2*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h80;
                    else
                      result_data_rg[j*`WORD_WIDTH+2*`BYTE_WIDTH +: `BYTE_WIDTH] = product8[4*j+2];

                    if (add_upoverflow[4*j+3])
                      result_data_rg[j*`WORD_WIDTH+3*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h7f;
                    else if (add_underoverflow[4*j+3])
                      result_data_rg[j*`WORD_WIDTH+3*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h80;
                    else
                      result_data_rg[j*`WORD_WIDTH+3*`BYTE_WIDTH +: `BYTE_WIDTH] = product8[4*j+3];
                  end
                  EEW16: begin
                    if (add_upoverflow[4*j])
                      result_data_rg[j*`WORD_WIDTH +: `HWORD_WIDTH] = 'h7fff;
                    else if (add_underoverflow[4*j])
                      result_data_rg[j*`WORD_WIDTH +: `HWORD_WIDTH] = 'h8000;
                    else
                      result_data_rg[j*`WORD_WIDTH +: `HWORD_WIDTH] = product16[2*j];                   

                    if (add_upoverflow[4*j+2])
                      result_data_rg[j*`WORD_WIDTH+1*`HWORD_WIDTH +: `HWORD_WIDTH] = 'h7fff;
                    else if (add_underoverflow[4*j])
                      result_data_rg[j*`WORD_WIDTH+1*`HWORD_WIDTH +: `HWORD_WIDTH] = 'h8000;
                    else
                      result_data_rg[j*`WORD_WIDTH+1*`HWORD_WIDTH +: `HWORD_WIDTH] = product16[2*j+1];                   
                  end
                  EEW32: begin
                    if (add_upoverflow[4*j])
                      result_data_rg[j*`WORD_WIDTH +: `WORD_WIDTH] = 'h7fff_ffff;
                    else if (add_underoverflow[4*j])
                      result_data_rg[j*`WORD_WIDTH +: `WORD_WIDTH] = 'h8000_0000;
                    else
                      result_data_rg[j*`WORD_WIDTH +: `WORD_WIDTH] = product32[j]; 
                  end
                endcase
              end

              VSSUBU: begin
                case(vs2_eew)
                  EEW8: begin
                    if(subu_underoverflow[4*j])
                      result_data_rg[j*`WORD_WIDTH +: `BYTE_WIDTH] = 'd0;
                    else
                      result_data_rg[j*`WORD_WIDTH +: `BYTE_WIDTH] = product8[4*j];
                      
                    if(subu_underoverflow[4*j+1])
                      result_data_rg[j*`WORD_WIDTH+1*`BYTE_WIDTH +: `BYTE_WIDTH] = 'd0;
                    else
                      result_data_rg[j*`WORD_WIDTH+1*`BYTE_WIDTH +: `BYTE_WIDTH] = product8[4*j+1];
                    
                    if(subu_underoverflow[4*j+2])
                      result_data_rg[j*`WORD_WIDTH+2*`BYTE_WIDTH +: `BYTE_WIDTH] = 'd0;
                    else
                      result_data_rg[j*`WORD_WIDTH+2*`BYTE_WIDTH +: `BYTE_WIDTH] = product8[4*j+2];

                    if(subu_underoverflow[4*j+3])
                      result_data_rg[j*`WORD_WIDTH+3*`BYTE_WIDTH +: `BYTE_WIDTH] = 'd0;
                    else
                      result_data_rg[j*`WORD_WIDTH+3*`BYTE_WIDTH +: `BYTE_WIDTH] = product8[4*j+3];
                  end
                  EEW16: begin
                    if(subu_underoverflow[4*j])
                      result_data_rg[j*`WORD_WIDTH +: `HWORD_WIDTH] = 'd0;
                    else
                      result_data_rg[j*`WORD_WIDTH +: `HWORD_WIDTH] = product16[2*j];
                      
                    if(subu_underoverflow[4*j+2])
                      result_data_rg[j*`WORD_WIDTH+1*`HWORD_WIDTH +: `HWORD_WIDTH] = 'd0;
                    else
                      result_data_rg[j*`WORD_WIDTH+1*`HWORD_WIDTH +: `HWORD_WIDTH] = product16[2*j+1];
                  end
                  EEW32: begin
                    if(subu_underoverflow[4*j])
                      result_data_rg[j*`WORD_WIDTH +: `WORD_WIDTH] = 'd0;
                    else
                      result_data_rg[j*`WORD_WIDTH +: `WORD_WIDTH] = product32[j];
                  end
                endcase
              end

              VSSUB: begin
                case(vs2_eew)
                  EEW8: begin
                    if (sub_upoverflow[4*j])
                      result_data_rg[j*`WORD_WIDTH +: `BYTE_WIDTH] = 'h7f;
                    else if (sub_underoverflow[4*j])
                      result_data_rg[j*`WORD_WIDTH +: `BYTE_WIDTH] = 'h80;
                    else
                      result_data_rg[j*`WORD_WIDTH +: `BYTE_WIDTH] = product8[4*j];
                      
                    if (sub_upoverflow[4*j+1])
                      result_data_rg[j*`WORD_WIDTH+1*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h7f;
                    else if (sub_underoverflow[4*j+1])
                      result_data_rg[j*`WORD_WIDTH+1*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h80;
                    else
                      result_data_rg[j*`WORD_WIDTH+1*`BYTE_WIDTH +: `BYTE_WIDTH] = product8[4*j+1];
                    
                    if (sub_upoverflow[4*j+2])
                      result_data_rg[j*`WORD_WIDTH+2*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h7f;
                    else if (sub_underoverflow[4*j+2])
                      result_data_rg[j*`WORD_WIDTH+2*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h80;
                    else
                      result_data_rg[j*`WORD_WIDTH+2*`BYTE_WIDTH +: `BYTE_WIDTH] = product8[4*j+2];

                    if (sub_upoverflow[4*j+3])
                      result_data_rg[j*`WORD_WIDTH+3*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h7f;
                    else if (sub_underoverflow[4*j+3])
                      result_data_rg[j*`WORD_WIDTH+3*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h80;
                    else
                      result_data_rg[j*`WORD_WIDTH+3*`BYTE_WIDTH +: `BYTE_WIDTH] = product8[4*j+3];
                  end
                  EEW16: begin
                    if (sub_upoverflow[4*j])
                      result_data_rg[j*`WORD_WIDTH +: `HWORD_WIDTH] = 'h7fff;
                    else if (sub_underoverflow[4*j])
                      result_data_rg[j*`WORD_WIDTH +: `HWORD_WIDTH] = 'h8000;
                    else
                      result_data_rg[j*`WORD_WIDTH +: `HWORD_WIDTH] = product16[2*j];                   

                    if (sub_upoverflow[4*j+2])
                      result_data_rg[j*`WORD_WIDTH+1*`HWORD_WIDTH +: `HWORD_WIDTH] = 'h7fff;
                    else if (sub_underoverflow[4*j])
                      result_data_rg[j*`WORD_WIDTH+1*`HWORD_WIDTH +: `HWORD_WIDTH] = 'h8000;
                    else
                      result_data_rg[j*`WORD_WIDTH+1*`HWORD_WIDTH +: `HWORD_WIDTH] = product16[2*j+1];                   
                  end
                  EEW32: begin
                    if (sub_upoverflow[4*j])
                      result_data_rg[j*`WORD_WIDTH +: `WORD_WIDTH] = 'h7fff_ffff;
                    else if (sub_underoverflow[4*j])
                      result_data_rg[j*`WORD_WIDTH +: `WORD_WIDTH] = 'h8000_0000;
                    else
                      result_data_rg[j*`WORD_WIDTH +: `WORD_WIDTH] = product32[j]; 
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
                    result_data_rg[j*`WORD_WIDTH +: `WORD_WIDTH] = {product16[2*j+1], product16[2*j]};
                  end
                  EEW16: begin
                    result_data_rg[j*`WORD_WIDTH +: `WORD_WIDTH] = product32[j];
                  end
                endcase
              end

              VWADDU_W,
              VWSUBU_W,
              VWADD_W,
              VWSUB_W: begin
                case(vs2_eew)
                  EEW16: begin
                    result_data_rg[j*`WORD_WIDTH +: `WORD_WIDTH] = {product16[2*j+1], product16[2*j]};
                  end
                  EEW32: begin
                    result_data_rg[j*`WORD_WIDTH +: `WORD_WIDTH] = product32[j];
                  end
                endcase
              end

              VAADDU,
              VAADD,
              VASUBU,
              VASUB: begin
                case(vs2_eew)
                  EEW8: begin
                    result_data_rg[j*`WORD_WIDTH +: `WORD_WIDTH] = {round8[4*j+3], round8[4*j+2], round8[4*j+1], round8[4*j]};
                  end
                  EEW16: begin
                    result_data_rg[j*`WORD_WIDTH +: `WORD_WIDTH] = {round16[2*j+1], round16[2*j]};
                  end
                  EEW32: begin
                    result_data_rg[j*`WORD_WIDTH +: `WORD_WIDTH] = round32[j];
                  end
                endcase
              end
            endcase
          end
        endcase
      end
    end
  endgenerate

  // mask logic for result_data_sp
  always_comb begin
    mask_sp_bit0 = 'b0;
    
    case(vs2_eew)
      EEW8: begin
        if (uop_index[0])
          mask_sp_bit0 = {{(`VLEN-2*`VLENB){1'b0}}, {`VLENB{1'b1}}, {`VLENB{1'b0}}};
        else
          mask_sp_bit0 = {{(`VLEN-`VLENB){1'b0}}, {`VLENB{1'b1}}};
      end
      EEW16: begin
        if (uop_index[0])
          mask_sp_bit0 = {{(`VLEN-2*`VLEN/`HWORD_WIDTH){1'b0}}, {`VLEN/`HWORD_WIDTH{1'b1}}, {(`VLEN/`HWORD_WIDTH){1'b0}}};
        else
          mask_sp_bit0 = {{(`VLEN-`VLEN/`HWORD_WIDTH){1'b0}}, {`VLEN/`HWORD_WIDTH{1'b1}}};
      end
      EEW32: begin
        if (uop_index[0])
          mask_sp_bit0 = {{(`VLEN-2*`VLEN/`WORD_WIDTH){1'b0}}, {`VLEN/`WORD_WIDTH{1'b1}}, {(`VLEN/`WORD_WIDTH){1'b0}}};
        else
          mask_sp_bit0 = {{(`VLEN-`VLEN/`WORD_WIDTH){1'b0}}, {`VLEN/`WORD_WIDTH{1'b1}}};
      end
    endcase
  end

  always_comb begin
    mask_sp_bit1 = mask_sp_bit0;
    
    case(vs2_eew)
      EEW8: begin
        if (uop_index[1]) begin
          mask_sp_bit1 = {mask_sp_bit0[`VLEN-1 : 4*`VLENB], 
                          mask_sp_bit0[0        +: 2*`VLENB], 
                          mask_sp_bit0[2*`VLENB +: 2*`VLENB]};
        end
      end
      EEW16: begin
        if (uop_index[1]) begin
          mask_sp_bit1 = {mask_sp_bit0[`VLEN-1 : 4*`VLEN/`HWORD_WIDTH], 
                          mask_sp_bit0[0                    +: 2*`VLEN/`HWORD_WIDTH], 
                          mask_sp_bit0[2*`VLEN/`HWORD_WIDTH +: 2*`VLEN/`HWORD_WIDTH]};
        end
      end
      EEW32: begin
        if (uop_index[1]) begin
          mask_sp_bit1 = {mask_sp_bit0[`VLEN-1 : 4*`VLEN/`WORD_WIDTH], 
                          mask_sp_bit0[0                   +: 2*`VLEN/`WORD_WIDTH], 
                          mask_sp_bit0[2*`VLEN/`WORD_WIDTH +: 2*`VLEN/`WORD_WIDTH]};
        end
      end
    endcase
  end

  always_comb begin
    mask_sp_bit2 = mask_sp_bit1;
    
    case(vs2_eew)
      EEW8: begin
        if (uop_index[2]) begin
          mask_sp_bit2 = {mask_sp_bit1[0      +: 4*`VLENB], 
                          mask_sp_bit1[`VLEN-1 : 4*`VLENB]}; 
        end
      end
      EEW16: begin
        if (uop_index[2]) begin
          mask_sp_bit2 = {mask_sp_bit1[0      +: 4*`VLEN/`HWORD_WIDTH],
                          mask_sp_bit1[`VLEN-1 : 4*`VLEN/`HWORD_WIDTH]}; 
        end
      end
      EEW32: begin
        if (uop_index[2]) begin
          mask_sp_bit2 = {mask_sp_bit1[0      +: 4*`VLEN/`WORD_WIDTH], 
                          mask_sp_bit1[`VLEN-1 : 4*`VLEN/`WORD_WIDTH]};
        end
      end
    endcase
  end

  // assign to result_data_sp
  always_comb begin
    result_data_sp = 'b0; 

    case(vs2_eew)
      EEW8: begin
        result_data_sp = {`BYTE_WIDTH{cout8}}; 
      end
      EEW16: begin
        result_data_sp = {`HWORD_WIDTH{cout16}}; 
      end
      EEW32: begin
        result_data_sp = {`WORD_WIDTH{cout32}}; 
      end
    endcase
  end

//
// submit result to ROB
//
`ifdef TB_SUPPORT
  assign  result.uop_pc     = alu_uop.uop_pc;
`endif
  assign  result.rob_entry  = rob_entry;
  assign  result.w_data     = w_data;
  assign  result.w_valid    = w_valid;
  assign  result.vxsat      = vxsat;
  assign  result.ignore_vta = ignore_vta;
  assign  result.ignore_vma = ignore_vma;

  // result data 
  always_comb begin
    w_data = result_data_rg;

    case(uop_funct3) 
      OPIVV,
      OPIVX,
      OPIVI: begin
        case(uop_funct6.ari_funct6)
          VMADC,
          VMSBC: begin
            w_data = (result_data_sp&mask_sp_bit2) | (vd_data&(~mask_sp_bit2)); 
          end
        endcase
      end
    endcase
  end

  // result type and valid signal
  assign w_valid = result_valid;

  // saturate signal
  always_comb begin
  // initial
    vxsat = 'b0;

    case(uop_funct3) 
      OPIVV,
      OPIVX,
      OPIVI: begin
        case(uop_funct6.ari_funct6)
          VSADDU: begin
            vxsat = (addu_upoverflow!='b0);
          end
          VSADD: begin
            vxsat = ({add_upoverflow,add_underoverflow}!='b0);
          end
          VSSUBU: begin
            vxsat = (subu_underoverflow!='b0);
          end
          VSUB: begin
            vxsat = ({sub_upoverflow,sub_underoverflow}!='b0);
          end
        endcase
      end
    endcase
  end

  // ignore vta an vma signal
  always_comb begin
    ignore_vta            = 'b0;
    ignore_vma            = 'b0;
    
    case(uop_funct3) 
      OPIVV,
      OPIVX,
      OPIVI: begin
        case(uop_funct6.ari_funct6)
          VADC,
          VSBC: begin
            ignore_vta    = 'b0;
            ignore_vma    = 'b1;
          end
          VMADC,
          VMSBC: begin
            ignore_vta    = 'b1;
            ignore_vma    = 'b1;
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

    logic [`BYTE_WIDTH-1:0]       y;
    logic                         cin;
    logic [`BYTE_WIDTH-1:0]       result;
    logic                         cout;

    if (opcode==ADDSUB_VADD) begin
      y = src_y;
      cin = src_cin;
    end
    else begin
      y = ~src_y;
      cin = ~src_cin;
    end

    {cout,result} = src_x + y + cin;
    
    return {cout,result};

  endfunction

  function [`BYTE_WIDTH:0] f_half_addsub8;
    // x +/- cin
    input ADDSUB_e              opcode;  
    input logic [`BYTE_WIDTH:0] src_x;
    input logic                 src_cin;

    logic [`BYTE_WIDTH-1:0]     y;
    logic [`BYTE_WIDTH-1:0]     result;
    logic                       cout;
    
    if (opcode==ADDSUB_VADD) begin
      y = src_cin; 
    end
    else begin
      //                        -'d2                -'d1
      y = src_cin ? {{(`BYTE_WIDTH-1){1'b1}},1'b0} : '1;
    end
    
    {cout,result} = src_x + y;

    return {cout,result};  

  endfunction

  function [`HWORD_WIDTH:0] f_half_addsub16;
    // x +/- cin
    input ADDSUB_e               opcode;  
    input logic [`HWORD_WIDTH:0] src_x;
    input logic                  src_cin;

    logic [`HWORD_WIDTH-1:0]     y;
    logic [`HWORD_WIDTH-1:0]     result;
    logic                        cout;
    
    if (opcode==ADDSUB_VADD) begin
      y = src_cin; 
    end
    else begin
      y = src_cin ? '1 : 'b0;
    end
    
    {cout,result} = src_x + y;

    return {cout,result}; 

  endfunction

  function [`BYTE_WIDTH-1:0] f_half_add8;
    // x + cin
    input logic [`BYTE_WIDTH-1:0] src_x;
    input logic                   cin;

    return src_x + cin;

  endfunction

  function [`HWORD_WIDTH-1:0] f_half_add16;
    // x + cin
    input logic [`HWORD_WIDTH-1:0] src_x;
    input logic                    cin;

    return src_x + cin;

  endfunction

  function [`WORD_WIDTH-1:0] f_half_add32;
    // x + cin
    input logic [`WORD_WIDTH-1:0] src_x;
    input logic                   cin;

    return src_x + cin;

  endfunction

endmodule
