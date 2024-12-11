
`include "rvv_backend.svh"
`include "rvv_backend_alu.svh"

module rvv_backend_alu_unit_addsub
(
  alu_uop_valid,
  alu_uop,
  result_valid_ex2rob,
  result_ex2rob
);
//
// interface signals
//
  // ALU RS handshake signals
  input   logic                   alu_uop_valid;
  input   ALU_RS_t                alu_uop;

  // ALU send result signals to ROB
  output  logic                   result_valid_ex2rob;
  output  ALU2ROB_t               result_ex2rob;

//
// internal signals
//
  // ALU_RS_t struct signals
  logic   [`ROB_DEPTH_WIDTH-1:0]  rob_entry;
  FUNCT6_u                        uop_funct6
  logic   [`FUNCT3_WIDTH-1:0]     uop_funct3;
  logic   [`VSTART_WIDTH-1:0]     vstart;
  logic                           vm;       
  RVVXRM                          vxrm;       
  logic   [`VLENB-1:0]            v0_data;
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
  logic   [`VLEN-1:0]                                 src2_vdata;
  logic   [`VLEN-1:0]                                 src1_vdata;
  logic   [`VLENB-1:0][`BYTE_WIDTH-1:0]               product8;
  logic   [`VLEN/`HWORD_WIDTH-1:0][`HWORD_WIDTH-1:0]  product16;
  logic   [`VLEN/`WORD_WIDTH-1:0][`WORD_WIDTH-1:0]    product32;
  logic   [`VLENB-1:0][`BYTE_WIDTH-1:0]               round8;
  logic   [`VLEN/`HWORD_WIDTH-1:0][`HWORD_WIDTH-1:0]  round16;
  logic   [`VLEN/`WORD_WIDTH-1:0][`WORD_WIDTH-1:0]    round32;
  logic   [`VLENB-1:0]                                cin;
  logic   [`VLENB-1:0]                                cout8;
  logic   [`VLENB-1:0]                                cout16;
  logic   [`VLENB-1:0]                                cout32;
  logic                                               result_valid;
  logic   [`VLEN-1:0]                                 result_vdata;
  F_ADDSUB_t                                          opcode;

  // ALU2ROB_t struct signals
  logic   [`VLEN-1:0]             w_data;             // when w_type=XRF, w_data[`XLEN-1:0] will store the scalar result
  W_DATA_TYPE_t                   w_type;
  logic                           w_valid; 
  logic   [`VCSR_VXSAT-1:0]       vxsat;     
  logic                           ignore_vta;
  logic                           ignore_vma;
  
  //
  integer                         i;
  genvar                          j;


//
// prepare source data to calculate    
//
  // split ALU_RS_t struct
  assign  rob_entry           = alu_uop.rob_entry;
  assign  uop_funct6          = alu_uop.uop_funct6;
  assign  uop_funct3          = alu_uop.uop_funct3;
  assign  vstart              = alu_uop.vstart;
  assign  vm                  = alu_uop.vm;
  assign  vxrm                = alu_uop.vxrm;
  assign  v0_data             = alu_uop.v0_data;
  assign  v0_data_valid       = alu_uop.v0_data_valid;
  assign  vd_data             = alu_uop.vd_data;
  assign  vd_data_valid       = alu_uop.vd_data_valid;
  assign  vs1                 = alu_uop.vs1;
  assign  vs1_data            = alu_uop.vs1_data;
  assign  vs1_data_valid      = alu_uop.vs1_data_valid;
  assign  vs2_data            = alu_uop.vs2_data;
  assign  vs2_data_valid      = alu_uop.vs2_data_valid;
  assign  vs2_eew             = alu_uop.vs2_eew;
  assign  rs1_data            = alu_uop.rs1_data;
  assign  rs1_data_valid      = alu_uop.rs1_data_valid;
  assign  uop_index           = alu_uop.uop_index;
  
//  
// prepare source data 
//
  // for add and sub instructions
  always_comb begin
    // initial the data
    result_valid   = 'b0;
    src2_vdata     = 'b0;
    src1_vdata     = 'b0;
    cin            = 'b0;

    // prepare source data
    case({alu_uop_valid,uop_funct3}) 
      {1'b1,OPIVV}: begin
        case(uop_funct6.ari_funct6)
          VADD,
          VSUB,
          VSADDU,
          VSADD,
          VSSUBU,
          VSSUB: begin
            if (vs2_data_valid&vs1_data_valid) begin
              result_valid   = 'b1;

              for (i=0;i<`VLENB;i=i+1) begin
                src2_vdata[i]  = vs2_data[i*`BYTE_WIDTH +: `BYTE_WIDTH];
                src1_vdata[i]  = vs1_data[i*`BYTE_WIDTH +: `BYTE_WIDTH];
              end
            end
            else begin
              `ifdef ASSERT_ON
                `rvv_expect(vs2_data_valid==1'b1)
                else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

                `rvv_expect(vs1_data_valid==1'b1)
                else $error("vs1_data_valid(%d) should be 1.\n",vs1_data_valid);
              `endif
            end
          end

          VADC,
          VSBC: begin
            if (vs2_data_valid&vs1_data_valid&(vm==1'b0)&v0_data_valid) begin
              result_valid   = 'b1;

              for (i=0;i<`VLENB;i=i+1) begin
                src2_vdata[i]  = vs2_data[i*`BYTE_WIDTH +: `BYTE_WIDTH];
                src1_vdata[i]  = vs1_data[i*`BYTE_WIDTH +: `BYTE_WIDTH];
                cin[i]         = v0_data[i];
              end

              for (i=0;i<`VLENB/4;i=i+1) begin
                case(vs2_eew)
                  EEW8: begin                    
                    cin[4*i]   = v0_data[4*i];
                    cin[4*i+1] = v0_data[4*i+1];
                    cin[4*i+2] = v0_data[4*i+2];
                    cin[4*i+3] = v0_data[4*i+3];
                  end
                  EEW16: begin
                    cin[4*i]   = v0_data[2*i];
                    cin[4*i+1] = 'b0;
                    cin[4*i+2] = v0_data[2*i+1];
                    cin[4*i+3] = 'b0;
                  end
                  EEW32: begin
                    cin[4*i]   = v0_data[i];
                    cin[4*i+1] = 'b0;
                    cin[4*i+2] = 'b0;
                    cin[4*i+3] = 'b0;
                  end
                endcase
              end
            end
            else begin
              `ifdef ASSERT_ON
                `rvv_expect(vs2_data_valid==1'b1)
                else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

                `rvv_expect(vs1_data_valid==1'b1)
                else $error("vs1_data_valid(%d) should be 1.\n",vs1_data_valid);

                `rvv_expect(vm==1'b0)
                else $error("vm(%d) should be 0.\n",vm);

                `rvv_expect(v0_data_valid==1'b1)
                else $error("v0_data_valid(%d) should be 1.\n",v0_data_valid);
              `endif
            end
          end

          VMADC,
          VMSBC: begin
            if (vs2_data_valid&vs1_data_valid&vd_data_valid) begin
              result_valid   = 'b1;

              for (i=0;i<`VLENB;i=i+1) begin
                src2_vdata[i]  = vs2_data[i*`BYTE_WIDTH +: `BYTE_WIDTH];
                src1_vdata[i]  = vs1_data[i*`BYTE_WIDTH +: `BYTE_WIDTH];
              end

              if((vm==1'b0)&v0_data_valid) begin
                for (i=0;i<`VLENB/4;i=i+1) begin
                  case(vs2_eew)
                    EEW8: begin                    
                      cin[4*i]   = v0_data[4*i];
                      cin[4*i+1] = v0_data[4*i+1];
                      cin[4*i+2] = v0_data[4*i+2];
                      cin[4*i+3] = v0_data[4*i+3];
                    end
                    EEW16: begin
                      cin[4*i]   = v0_data[2*i];
                      cin[4*i+1] = 'b0;
                      cin[4*i+2] = v0_data[2*i+1];
                      cin[4*i+3] = 'b0;
                    end
                    EEW32: begin
                      cin[4*i]   = v0_data[i];
                      cin[4*i+1] = 'b0;
                      cin[4*i+2] = 'b0;
                      cin[4*i+3] = 'b0;
                    end
                  endcase
                end
              end
            end
            else begin
              `ifdef ASSERT_ON
                `rvv_expect(vs2_data_valid==1'b1)
                else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

                `rvv_expect(vs1_data_valid==1'b1)
                else $error("vs1_data_valid(%d) should be 1.\n",vs1_data_valid);

                `rvv_expect(vd_data_valid==1'b1)
                else $error("vd_data_valid(%d) should be 1.\n",vd_data_valid);
              `endif
            end
          end
        endcase
      end
      {1'b1,OPIVX}: begin
        case(uop_funct6.ari_funct6)
          VADD,
          VSUB,
          VSADDU,
          VSADD,
          VSSUBU,
          VSSUB: begin
            if (vs2_data_valid&rs1_data_valid) begin
              result_valid   = 'b1;
              
              for (i=0;i<`VLENB;i=i+1) begin
                src2_vdata[i]  = vs2_data[i*`BYTE_WIDTH +: `BYTE_WIDTH];
              end

              for (i=0;i<`VLENB/4;i=i+1) begin
                case(vs2_eew)
                  EEW8: begin
                    src1_vdata[4*i]   = rs1_data[7:0];
                    src1_vdata[4*i+1] = rs1_data[7:0];
                    src1_vdata[4*i+2] = rs1_data[7:0];
                    src1_vdata[4*i+3] = rs1_data[7:0];
                  end
                  EEW16: begin  
                    src1_vdata[4*i]   = rs1_data[7:0];
                    src1_vdata[4*i+1] = rs1_data[15:8];
                    src1_vdata[4*i+2] = rs1_data[7:0];
                    src1_vdata[4*i+3] = rs1_data[15:8];
                  end
                  EEW32: begin 
                    src1_vdata[4*i]   = rs1_data[7:0];
                    src1_vdata[4*i+1] = rs1_data[15:8];
                    src1_vdata[4*i+2] = rs1_data[23:16];
                    src1_vdata[4*i+3] = rs1_data[31:24];
                  end
                endcase
              end
            end
            else begin
              `ifdef ASSERT_ON
                `rvv_expect(vs2_data_valid==1'b1)
                else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

                `rvv_expect(rs1_data_valid==1'b1)
                else $error("rs1_data_valid(%d) should be 1.\n",rs1_data_valid);
              `endif
            end
          end
          
          VRSUB: begin
            if (vs2_data_valid&rs1_data_valid) begin
              result_valid   = 'b1;

              for (i=0;i<`VLENB/4;i=i+1) begin
                case(vs2_eew)
                  EEW8: begin
                    src1_vdata[4*i]   = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+1] = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+2] = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+3] = rs1_data[0 +: `BYTE_WIDTH];
                  end
                  EEW16: begin  
                    src1_vdata[4*i]   = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+1] = rs1_data[8 +: `BYTE_WIDTH];
                    src1_vdata[4*i+2] = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+3] = rs1_data[8 +: `BYTE_WIDTH];
                  end
                  EEW32: begin 
                    src1_vdata[4*i]   = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+1] = rs1_data[8 +: `BYTE_WIDTH];
                    src1_vdata[4*i+2] = rs1_data[16 +: `BYTE_WIDTH];
                    src1_vdata[4*i+3] = rs1_data[24 +: `BYTE_WIDTH];
                  end
                endcase
              end
            
              for (i=0;i<`VLENB;i=i+1) begin
                src1_vdata[i]  = vs2_data[i*`BYTE_WIDTH +: `BYTE_WIDTH];
              end
            end
            else begin
              `ifdef ASSERT_ON
                `rvv_expect(vs2_data_valid==1'b1)
                else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

                `rvv_expect(rs1_data_valid==1'b1)
                else $error("rs1_data_valid(%d) should be 1.\n",rs1_data_valid);
              `endif
            end
          end

          VADC,
          VSBC: begin
            if (vs2_data_valid&rs1_data_valid&(vm==1'b0)&v0_data_valid) begin
              result_valid   = 'b1;
              
              for (i=0;i<`VLENB;i=i+1) begin
                src2_vdata[i]  = vs2_data[i*`BYTE_WIDTH +: `BYTE_WIDTH];
              end

              for (i=0;i<`VLENB/4;i=i+1) begin
                case(vs2_eew)
                  EEW8: begin
                    src1_vdata[4*i]   = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+1] = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+2] = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+3] = rs1_data[0 +: `BYTE_WIDTH];
                    
                    cin[4*i]   = v0_data[4*i];
                    cin[4*i+1] = v0_data[4*i+1];
                    cin[4*i+2] = v0_data[4*i+2];
                    cin[4*i+3] = v0_data[4*i+3];
                  end
                  EEW16: begin  
                    src1_vdata[4*i]   = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+1] = rs1_data[8 +: `BYTE_WIDTH];
                    src1_vdata[4*i+2] = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+3] = rs1_data[8 +: `BYTE_WIDTH];

                    cin[4*i]   = v0_data[2*i];
                    cin[4*i+1] = 'b0;
                    cin[4*i+2] = v0_data[2*i+1];
                    cin[4*i+3] = 'b0;
                  end
                  EEW32: begin 
                    src1_vdata[4*i]   = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+1] = rs1_data[8 +: `BYTE_WIDTH];
                    src1_vdata[4*i+2] = rs1_data[16 +: `BYTE_WIDTH];
                    src1_vdata[4*i+3] = rs1_data[24 +: `BYTE_WIDTH];

                    cin[4*i]   = v0_data[i];
                    cin[4*i+1] = 'b0;
                    cin[4*i+2] = 'b0;
                    cin[4*i+3] = 'b0;
                  end
                endcase
              end
            end
            else begin
              `ifdef ASSERT_ON
                `rvv_expect(vs2_data_valid==1'b1)
                else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

                `rvv_expect(rs1_data_valid==1'b1)
                else $error("rs1_data_valid(%d) should be 1.\n",rs1_data_valid);

                `rvv_expect(vm==1'b0)
                else $error("vm(%d) should be 0.\n",vm);

                `rvv_expect(v0_data_valid==1'b1)
                else $error("v0_data_valid(%d) should be 1.\n",v0_data_valid);
              `endif
            end
          end

          VMADC,
          VMSBC: begin
            if (vs2_data_valid&rs1_data_valid&vd_data_valid) begin
              result_valid   = 'b1;
              
              for (i=0;i<`VLENB;i=i+1) begin
                src2_vdata[i]  = vs2_data[i*`BYTE_WIDTH +: `BYTE_WIDTH];
              end

              for (i=0;i<`VLENB/4;i=i+1) begin
                case(vs2_eew)
                  EEW8: begin
                    src1_vdata[4*i]   = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+1] = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+2] = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+3] = rs1_data[0 +: `BYTE_WIDTH];

                    if ((vm==1'b0)&v0_data_valid) begin 
                      cin[4*i]   = v0_data[4*i];
                      cin[4*i+1] = v0_data[4*i+1];
                      cin[4*i+2] = v0_data[4*i+2];
                      cin[4*i+3] = v0_data[4*i+3];
                    end
                  end
                  EEW16: begin  
                    src1_vdata[4*i]   = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+1] = rs1_data[8 +: `BYTE_WIDTH];
                    src1_vdata[4*i+2] = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+3] = rs1_data[8 +: `BYTE_WIDTH];

                    if ((vm==1'b0)&v0_data_valid) begin 
                      cin[4*i]   = v0_data[2*i];
                      cin[4*i+1] = 'b0;
                      cin[4*i+2] = v0_data[2*i+1];
                      cin[4*i+3] = 'b0;
                    end
                  end
                  EEW32: begin 
                    src1_vdata[4*i]   = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+1] = rs1_data[8 +: `BYTE_WIDTH];
                    src1_vdata[4*i+2] = rs1_data[16 +: `BYTE_WIDTH];
                    src1_vdata[4*i+3] = rs1_data[24 +: `BYTE_WIDTH];

                    if ((vm==1'b0)&v0_data_valid) begin 
                      cin[4*i]   = v0_data[i];
                      cin[4*i+1] = 'b0;
                      cin[4*i+2] = 'b0;
                      cin[4*i+3] = 'b0;
                    end
                  end
                endcase
              end
            end
            else begin
              `ifdef ASSERT_ON
                `rvv_expect(vs2_data_valid==1'b1)
                else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

                `rvv_expect(rs1_data_valid==1'b1)
                else $error("rs1_data_valid(%d) should be 1.\n",rs1_data_valid);

                `rvv_expect(vd_data_valid==1'b1)
                else $error("vd_data_valid(%d) should be 1.\n",vd_data_valid);
              `endif
            end
          end
        endcase
      end
      {1'b1,OPIVI}: begin
        case(uop_funct6.ari_funct6)
          VADD,
          VSADDU,
          VSADD,
          VSSUBU,
          VSSUB: begin
            if (vs2_data_valid&rs1_data_valid) begin
              result_valid   = 'b1;

              for (i=0;i<`VLENB;i=i+1) begin
                src2_vdata[i]  = vs2_data[i*`BYTE_WIDTH +: `BYTE_WIDTH];
              end

              for (i=0;i<`VLENB/4;i=i+1) begin
                case(vs2_eew)
                  EEW8: begin  
                    src1_vdata[4*i]   = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+1] = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+2] = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+3] = rs1_data[0 +: `BYTE_WIDTH];
                  end
                  EEW16: begin  
                    src1_vdata[4*i]   = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+1] = rs1_data[8 +: `BYTE_WIDTH];
                    src1_vdata[4*i+2] = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+3] = rs1_data[8 +: `BYTE_WIDTH];
                  end
                  EEW32: begin  
                    src1_vdata[4*i]   = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+1] = rs1_data[8 +: `BYTE_WIDTH];
                    src1_vdata[4*i+2] = rs1_data[16 +: `BYTE_WIDTH];
                    src1_vdata[4*i+3] = rs1_data[24 +: `BYTE_WIDTH];
                  end
                endcase
              end
            end
            else begin
              `ifdef ASSERT_ON
                `rvv_expect(vs2_data_valid==1'b1)
                else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

                `rvv_expect(rs1_data_valid==1'b1)
                else $error("rs1_data_valid(%d) should be 1.\n",rs1_data_valid);
              `endif
            end
          end
          
          VRSUB: begin
            if (vs2_data_valid&rs1_data_valid) begin
              result_valid   = 'b1;

              for (i=0;i<`VLENB/4;i=i+1) begin
                case(vs2_eew)
                  EEW8: begin  
                    src2_vdata[4*i]   = rs1_data[0 +: `BYTE_WIDTH];
                    src2_vdata[4*i+1] = rs1_data[0 +: `BYTE_WIDTH];
                    src2_vdata[4*i+2] = rs1_data[0 +: `BYTE_WIDTH];
                    src2_vdata[4*i+3] = rs1_data[0 +: `BYTE_WIDTH];
                  end
                  EEW16: begin  
                    src2_vdata[4*i]   = rs1_data[0 +: `BYTE_WIDTH];
                    src2_vdata[4*i+1] = rs1_data[8 +: `BYTE_WIDTH];
                    src2_vdata[4*i+2] = rs1_data[0 +: `BYTE_WIDTH];
                    src2_vdata[4*i+3] = rs1_data[8 +: `BYTE_WIDTH];
                  end
                  EEW32: begin  
                    src2_vdata[4*i]   = rs1_data[0 +: `BYTE_WIDTH];
                    src2_vdata[4*i+1] = rs1_data[8 +: `BYTE_WIDTH];
                    src2_vdata[4*i+2] = rs1_data[16 +: `BYTE_WIDTH];
                    src2_vdata[4*i+3] = rs1_data[24 +: `BYTE_WIDTH];
                  end
                endcase
              end

              for (i=0;i<`VLENB;i=i+1) begin
                src1_vdata[i]  = vs2_data[i*`BYTE_WIDTH +: `BYTE_WIDTH];
              end
            end
            else begin
              `ifdef ASSERT_ON
                `rvv_expect(vs2_data_valid==1'b1)
                else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

                `rvv_expect(rs1_data_valid==1'b1)
                else $error("rs1_data_valid(%d) should be 1.\n",rs1_data_valid);
              `endif
            end
          end

          VADC,
          VSBC: begin
            if (vs2_data_valid&rs1_data_valid&(vm==1'b0)&v0_data_valid) begin
              result_valid   = 'b1;

              for (i=0;i<`VLENB;i=i+1) begin
                src2_vdata[i]  = vs2_data[i*`BYTE_WIDTH +: `BYTE_WIDTH];
              end

              for (i=0;i<`VLENB/4;i=i+1) begin
                case(vs2_eew)
                  EEW8: begin    
                    src1_vdata[4*i]   = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+1] = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+2] = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+3] = rs1_data[0 +: `BYTE_WIDTH];
                    
                    cin[4*i]   = v0_data[4*i];
                    cin[4*i+1] = v0_data[4*i+1];
                    cin[4*i+2] = v0_data[4*i+2];
                    cin[4*i+3] = v0_data[4*i+3];
                  end
                  EEW16: begin
                    src1_vdata[4*i]   = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+1] = rs1_data[8 +: `BYTE_WIDTH];
                    src1_vdata[4*i+2] = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+3] = rs1_data[8 +: `BYTE_WIDTH];
                    
                    cin[4*i]   = v0_data[2*i];
                    cin[4*i+1] = 'b0;
                    cin[4*i+2] = v0_data[2*i+1];
                    cin[4*i+3] = 'b0;
                  end
                  EEW32: begin
                    src1_vdata[4*i]   = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+1] = rs1_data[8 +: `BYTE_WIDTH];
                    src1_vdata[4*i+2] = rs1_data[16 +: `BYTE_WIDTH];
                    src1_vdata[4*i+3] = rs1_data[24 +: `BYTE_WIDTH];
                    
                    cin[4*i]   = v0_data[i];
                    cin[4*i+1] = 'b0;
                    cin[4*i+2] = 'b0;
                    cin[4*i+3] = 'b0;
                  end
                endcase
              end
            end
            else begin
              `ifdef ASSERT_ON
                `rvv_expect(vs2_data_valid==1'b1)
                else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

                `rvv_expect(rs1_data_valid==1'b1)
                else $error("rs1_data_valid(%d) should be 1.\n",rs1_data_valid);

                `rvv_expect(vm==1'b0)
                else $error("vm(%d) should be 0.\n",vm);

                `rvv_expect(v0_data_valid==1'b1)
                else $error("v0_data_valid(%d) should be 1.\n",v0_data_valid);
              `endif
            end
          end
          
          VMADC: begin
            if (vs2_data_valid&rs1_data_valid&vd_data_valid) begin
              result_valid   = 'b1;
              
              for (i=0;i<`VLENB;i=i+1) begin
                src2_vdata[i]  = vs2_data[i*`BYTE_WIDTH +: `BYTE_WIDTH];
              end

              for (i=0;i<`VLENB/4;i=i+1) begin
                case(vs2_eew)
                  EEW8: begin
                    src1_vdata[4*i]   = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+1] = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+2] = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+3] = rs1_data[0 +: `BYTE_WIDTH];

                    if ((vm==1'b0)&v0_data_valid) begin 
                      cin[4*i]   = v0_data[4*i];
                      cin[4*i+1] = v0_data[4*i+1];
                      cin[4*i+2] = v0_data[4*i+2];
                      cin[4*i+3] = v0_data[4*i+3];
                    end
                  end
                  EEW16: begin  
                    src1_vdata[4*i]   = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+1] = rs1_data[8 +: `BYTE_WIDTH];
                    src1_vdata[4*i+2] = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+3] = rs1_data[8 +: `BYTE_WIDTH];

                    if ((vm==1'b0)&v0_data_valid) begin 
                      cin[4*i]   = v0_data[2*i];
                      cin[4*i+1] = 'b0;
                      cin[4*i+2] = v0_data[2*i+1];
                      cin[4*i+3] = 'b0;
                    end
                  end
                  EEW32: begin 
                    src1_vdata[4*i]   = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+1] = rs1_data[8 +: `BYTE_WIDTH];
                    src1_vdata[4*i+2] = rs1_data[16 +: `BYTE_WIDTH];
                    src1_vdata[4*i+3] = rs1_data[24 +: `BYTE_WIDTH];

                    if ((vm==1'b0)&v0_data_valid) begin 
                      cin[4*i]   = v0_data[i];
                      cin[4*i+1] = 'b0;
                      cin[4*i+2] = 'b0;
                      cin[4*i+3] = 'b0;
                    end
                  end
                endcase
              end
            end
            else begin
              `ifdef ASSERT_ON
                `rvv_expect(vs2_data_valid==1'b1)
                else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

                `rvv_expect(rs1_data_valid==1'b1)
                else $error("rs1_data_valid(%d) should be 1.\n",rs1_data_valid);

                `rvv_expect(vd_data_valid==1'b1)
                else $error("vd_data_valid(%d) should be 1.\n",vd_data_valid);
              `endif
            end
          end
        endcase
      end

      {1'b1,OPMVV}: begin
        case(uop_funct6.ari_funct6)
          VWADDU,
          VWSUBU,
          VWADD,
          VWSUB: begin
            if (vs2_data_valid&vs1_data_valid) begin
              result_valid   = 'b1;
              
              for (i=0;i<`VLENB/4;i=i+1) begin
                case(vs2_eew)
                  EEW8: begin
                    if(uop_index[0]==1'b0) begin
                      src2_vdata[4*i]   = vs2_data[(2*i)*`BYTE_WIDTH +: `BYTE_WIDTH];
                      src2_vdata[4*i+1] = 'b0;
                      src2_vdata[4*i+2] = vs2_data[(2*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                      src2_vdata[4*i+3] = 'b0;

                      src1_vdata[4*i]   = vs1_data[(2*i)*`BYTE_WIDTH +: `BYTE_WIDTH];
                      src1_vdata[4*i+1] = 'b0;
                      src1_vdata[4*i+2] = vs1_data[(2*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                      src1_vdata[4*i+3] = 'b0;
                    end
                    else begin
                      src2_vdata[4*i]   = vs2_data[(2*(i+`VLENB/4))*`BYTE_WIDTH +: `BYTE_WIDTH];
                      src2_vdata[4*i+1] = 'b0;
                      src2_vdata[4*i+2] = vs2_data[(2*(i+`VLENB/4)+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                      src2_vdata[4*i+3] = 'b0;

                      src1_vdata[4*i]   = vs1_data[(2*(i+`VLENB/4))*`BYTE_WIDTH +: `BYTE_WIDTH];
                      src1_vdata[4*i+1] = 'b0;
                      src1_vdata[4*i+2] = vs1_data[(2*(i+`VLENB/4)+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                      src1_vdata[4*i+3] = 'b0;
                    end
                  end
                  EEW16: begin
                    if(uop_index[0]==1'b0) begin
                      src2_vdata[4*i]   = vs2_data[(2*i)*`BYTE_WIDTH +: `BYTE_WIDTH];
                      src2_vdata[4*i+1] = vs2_data[(2*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                      src2_vdata[4*i+2] = 'b0;
                      src2_vdata[4*i+3] = 'b0;

                      src1_vdata[4*i]   = vs1_data[(2*i)*`BYTE_WIDTH +: `BYTE_WIDTH];
                      src1_vdata[4*i+1] = vs1_data[(2*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                      src1_vdata[4*i+2] = 'b0;
                      src1_vdata[4*i+3] = 'b0;
                    end
                    else begin
                      src2_vdata[4*i]   = vs2_data[(2*(i+`VLENB/4))*`BYTE_WIDTH +: `BYTE_WIDTH];
                      src2_vdata[4*i+1] = vs2_data[(2*(i+`VLENB/4)+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                      src2_vdata[4*i+2] = 'b0;
                      src2_vdata[4*i+3] = 'b0;

                      src1_vdata[4*i]   = vs1_data[(2*(i+`VLENB/4))*`BYTE_WIDTH +: `BYTE_WIDTH];
                      src1_vdata[4*i+1] = vs1_data[(2*(i+`VLENB/4)+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                      src1_vdata[4*i+2] = 'b0;
                      src1_vdata[4*i+3] = 'b0;
                    end
                  end
                endcase
              end
            end
            else begin
              `ifdef ASSERT_ON
                `rvv_expect(vs2_data_valid==1'b1)
                else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

                `rvv_expect(vs1_data_valid==1'b1)
                else $error("vs1_data_valid(%d) should be 1.\n",vs1_data_valid);
              `endif
            end
          end

          VWADDU_W,
          VWSUBU_W,
          VWADD_W,
          VWSUB_W: begin
            if (vs2_data_valid&vs1_data_valid) begin
              result_valid   = 'b1;
              
              for (i=0;i<`VLENB;i=i+1) begin
                src2_vdata[i] = vs2_data[i*`BYTE_WIDTH +: `BYTE_WIDTH];
              end

              for (i=0;i<`VLENB/4;i=i+1) begin
                case(vs2_eew)
                  EEW16: begin
                    if(uop_index[0]==1'b0) begin
                      src1_vdata[4*i]   = vs1_data[(2*i)*`BYTE_WIDTH +: `BYTE_WIDTH];
                      src1_vdata[4*i+1] = 'b0;
                      src1_vdata[4*i+2] = vs1_data[(2*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                      src1_vdata[4*i+3] = 'b0;
                    end
                    else begin
                      src1_vdata[4*i]   = vs1_data[(2*(i+`VLENB/4))*`BYTE_WIDTH +: `BYTE_WIDTH];
                      src1_vdata[4*i+1] = 'b0;
                      src1_vdata[4*i+2] = vs1_data[(2*(i+`VLENB/4)+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                      src1_vdata[4*i+3] = 'b0;
                    end
                  end
                  EEW32: begin
                    if(uop_index[0]==1'b0) begin
                      src1_vdata[4*i]   = vs1_data[(2*i)*`BYTE_WIDTH +: `BYTE_WIDTH];
                      src1_vdata[4*i+1] = vs1_data[(2*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                      src1_vdata[4*i+2] = 'b0;
                      src1_vdata[4*i+3] = 'b0;
                    end
                    else begin
                      src1_vdata[4*i]   = vs1_data[(2*(i+`VLENB/4))*`BYTE_WIDTH +: `BYTE_WIDTH];
                      src1_vdata[4*i+1] = vs1_data[(2*(i+`VLENB/4)+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                      src1_vdata[4*i+2] = 'b0;
                      src1_vdata[4*i+3] = 'b0;
                    end
                  end
                endcase
              end
            end
            else begin
              `ifdef ASSERT_ON
                `rvv_expect(vs2_data_valid==1'b1)
                else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

                `rvv_expect(vs1_data_valid==1'b1)
                else $error("vs1_data_valid(%d) should be 1.\n",vs1_data_valid);
              `endif
            end
          end

          VAADDU,
          VAADD,
          VASUBU,
          VASUB: begin
            if (vs2_data_valid&vs1_data_valid) begin
              result_valid   = 'b1;

              for (i=0;i<`VLENB;i=i+1) begin
                src2_vdata[i]  = vs2_data[i*`BYTE_WIDTH +: `BYTE_WIDTH];
                src1_vdata[i]  = vs1_data[i*`BYTE_WIDTH +: `BYTE_WIDTH];
              end
            end
            else begin
              `ifdef ASSERT_ON
                `rvv_expect(vs2_data_valid==1'b1)
                else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

                `rvv_expect(vs1_data_valid==1'b1)
                else $error("vs1_data_valid(%d) should be 1.\n",vs1_data_valid);
              `endif
            end
          end

        endcase
      end
      
      {1'b1,OPMVX}: begin
        case(uop_funct6.ari_funct6)
          VWADDU,
          VWSUBU,
          VWADD,
          VWSUB: begin
            if (vs2_data_valid&rs1_data_valid) begin
              result_valid   = 'b1;
              
              for (i=0;i<`VLENB/4;i=i+1) begin
                case(vs2_eew)
                  EEW8: begin
                    src1_vdata[4*i]   = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+1] = 'b0;
                    src1_vdata[4*i+2] = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+3] = 'b0;

                    if(uop_index[0]==1'b0) begin
                      src2_vdata[4*i]   = vs2_data[(2*i)*`BYTE_WIDTH +: `BYTE_WIDTH];
                      src2_vdata[4*i+1] = 'b0;
                      src2_vdata[4*i+2] = vs2_data[(2*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                      src2_vdata[4*i+3] = 'b0;
                    end
                    else begin
                      src2_vdata[4*i]   = vs2_data[(2*(i+`VLENB/4))*`BYTE_WIDTH +: `BYTE_WIDTH];
                      src2_vdata[4*i+1] = 'b0;
                      src2_vdata[4*i+2] = vs2_data[(2*(i+`VLENB/4)+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                      src2_vdata[4*i+3] = 'b0;
                    end
                  end
                  EEW16: begin
                    src1_vdata[4*i]   = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+1] = rs1_data[`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_vdata[4*i+2] = 'b0;
                    src1_vdata[4*i+3] = 'b0;

                    if(uop_index[0]==1'b0) begin
                      src2_vdata[4*i]   = vs2_data[(2*i)*`BYTE_WIDTH +: `BYTE_WIDTH];
                      src2_vdata[4*i+1] = vs2_data[(2*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                      src2_vdata[4*i+2] = 'b0;
                      src2_vdata[4*i+3] = 'b0;
                    end
                    else begin
                      src2_vdata[4*i]   = vs2_data[(2*(i+`VLENB/4))*`BYTE_WIDTH +: `BYTE_WIDTH];
                      src2_vdata[4*i+1] = vs2_data[(2*(i+`VLENB/4)+1)*`BYTE_WIDTH +: `BYTE_WIDTH];
                      src2_vdata[4*i+2] = 'b0;
                      src2_vdata[4*i+3] = 'b0;
                    end
                  end
                endcase
              end
            end
            else begin
              `ifdef ASSERT_ON
                `rvv_expect(vs2_data_valid==1'b1)
                else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

                `rvv_expect(rs1_data_valid==1'b1)
                else $error("rs1_data_valid(%d) should be 1.\n",rs1_data_valid);
              `endif
            end
          end

          VWADDU_W,
          VWSUBU_W,
          VWADD_W,
          VWSUB_W: begin
            if (vs2_data_valid&rs1_data_valid) begin
              result_valid   = 'b1;
              
              for (i=0;i<`VLENB;i=i+1) begin
                src2_vdata[i] = vs2_data[i*`BYTE_WIDTH +: `BYTE_WIDTH];
              end

              for (i=0;i<`VLENB/4;i=i+1) begin
                case(vs2_eew)
                  EEW16: begin
                    src1_vdata[4*i]   = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+1] = 'b0;
                    src1_vdata[4*i+2] = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+3] = 'b0;
                  end
                  EEW32: begin
                    src1_vdata[4*i]   = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+1] = rs1_data[`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_vdata[4*i+2] = 'b0;
                    src1_vdata[4*i+3] = 'b0;
                  end
                endcase
              end
            end
            else begin
              `ifdef ASSERT_ON
                `rvv_expect(vs2_data_valid==1'b1)
                else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

                `rvv_expect(rs1_data_valid==1'b1)
                else $error("rs1_data_valid(%d) should be 1.\n",rs1_data_valid);
              `endif
            end
          end

          VAADDU,
          VAADD,
          VASUBU,
          VASUB: begin
            if (vs2_data_valid&rs1_data_valid) begin
              result_valid   = 'b1;
              
              for (i=0;i<`VLENB;i=i+1) begin
                src2_vdata[i]  = vs2_data[i*`BYTE_WIDTH +: `BYTE_WIDTH];
              end

              for (i=0;i<`VLENB/4;i=i+1) begin
                case(vs2_eew)
                  EEW8: begin
                    src1_vdata[4*i]   = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+1] = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+2] = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+3] = rs1_data[0 +: `BYTE_WIDTH];
                  end
                  EEW16: begin  
                    src1_vdata[4*i]   = rs1_data[0 +: `BYTE_WIDTH];
                    src1_vdata[4*i+1] = rs1_data[`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_vdata[4*i+2] = rs1_data[0 +: `BYTE_WIDTH7:0];
                    src1_vdata[4*i+3] = rs1_data[`BYTE_WIDTH +: `BYTE_WIDTH];
                  end
                  EEW32: begin 
                    src1_vdata[4*i]   = rs1_data[0 +: `BYTE_WIDTH7:0];
                    src1_vdata[4*i+1] = rs1_data[`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_vdata[4*i+2] = rs1_data[2*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_vdata[4*i+3] = rs1_data[3*`BYTE_WIDTH +: `BYTE_WIDTH];
                  end
                endcase
              end
            end
            else begin
              `ifdef ASSERT_ON
                `rvv_expect(vs2_data_valid==1'b1)
                else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

                `rvv_expect(rs1_data_valid==1'b1)
                else $error("rs1_data_valid(%d) should be 1.\n",rs1_data_valid);
              `endif
            end
          end
        endcase
      end
    endcase
  end
  
  always_comb begin
    // initial the data
    opcode = ADDSUB_VADD;

    // prepare source data
    case({alu_uop_valid,uop_funct3}) 
      {1'b1,OPIVV},
      {1'b1,OPIVX},
      {1'b1,OPIVI}: begin
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
      {1'b1,OPMVV},
      {1'b1,OPMVX}: begin
        case(uop_funct6.ari_funct6)    
          VWADDU,
          VWADD,
          VWADDU_W,
          VWADD_W,
          VAADDU,
          VAADD: begin
            opcode = ADDSUB_VSUB;
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
      assign {cout8[i],product8[i]} = f_addsub(opcode, {vs2_vdata[i][`BYTE_WIDTH],vs2_vdata[i]}, {vs1_vdata[i][`BYTE_WIDTH],vs1_vdata[i]}, cin[i]);
    end
  endgenerate
  
   generate
    for (j=0;j<`VLEN/`HWORD_WIDTH;j=j+1) begin: EXE_VADDSUB_PROD16
      assign {cout16[i],product16[i]} = f_addsub(opcode, {cout8[2*i+1],product8[2*i+1]}, 'd0, cout8[2*i])::product8[2*i];
    end
  endgenerate 

   generate
    for (j=0;j<`VLEN/`WORD_WIDTH;j=j+1) begin: EXE_VADDSUB_PROD32
      assign {cout32[i],product32[i]} = f_addsub(opcode, {cout16[2*i+1],product16[2*i+1]}, 'd0, cout16[2*i])::product16[2*i];
    end
  endgenerate 
  
  // rounding result
  always_comb begin
    round8  = 'b0;
    round16 = 'b0;
    rount32 = 'b0;

    case(vxrm)
      RNU: begin
        case(vs2_eew)
          EEW8: begin
            for (i=0;i<`VLENB;i=i+1) begin
              round8[i] = {cout8[i],product8[i][`BYTE_WIDTH-1:1]} + product8[i][0]; 
            end
          end
          EEW16: begin
            for (i=0;i<`VLEN/`HWORD_WIDTH;i=i+1) begin
              round16[i] = {cout16[i],product16[i][`HWORD_WIDTH-1:1]} + product16[i][0]; 
            end
          end
          EEW32: begin
            for (i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
              round32[i] = {cout32[i],product32[i][`WORD_WIDTH-1:1]} + product32[i][0]; 
            end
          end
        endcase
      end
      RNE: begin
        case(vs2_eew)
          EEW8: begin
            for (i=0;i<`VLENB;i=i+1) begin
              round8[i] = {cout8[i],product8[i][`BYTE_WIDTH-1:1]} + (product8[i][0]&product8[i][1]); 
            end
          end
          EEW16: begin
            for (i=0;i<`VLEN/`HWORD_WIDTH;i=i+1) begin
              round16[i] = {cout16[i],product16[i][`HWORD_WIDTH-1:1]} + (product16[i][0]&product16[i][1]); 
            end
          end
          EEW32: begin
            for (i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
              round32[i] = {cout32[i],product32[i][`WORD_WIDTH-1:1]} + (product32[i][0]&product32[i][1]); 
            end
          end
        endcase
      end
      RDN: begin
        case(vs2_eew)
          EEW8: begin
            for (i=0;i<`VLENB;i=i+1) begin
              round8[i] = {cout8[i],product8[i][`BYTE_WIDTH-1:1]}; 
            end
          end
          EEW16: begin
            for (i=0;i<`VLEN/`HWORD_WIDTH;i=i+1) begin
              round16[i] = {cout16[i],product16[i][`HWORD_WIDTH-1:1]}; 
            end
          end
          EEW32: begin
            for (i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
              round32[i] = {cout32[i],product32[i][`WORD_WIDTH-1:1]}; 
            end
          end
        endcase
      end
      ROD: begin
        case(vs2_eew)
          EEW8: begin
            for (i=0;i<`VLENB;i=i+1) begin
              round8[i] = {cout8[i],product8[i][`BYTE_WIDTH-1:1]} + ((!product8[i][1])&product8[i][0]); 
            end
          end
          EEW16: begin
            for (i=0;i<`VLEN/`HWORD_WIDTH;i=i+1) begin
              round16[i] = {cout16[i],product16[i][`HWORD_WIDTH-1:1]} + ((!product16[i][1])&product16[i][0]); 
            end
          end
          EEW32: begin
            for (i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
              round32[i] = {cout32[i],product32[i][`WORD_WIDTH-1:1]} + ((!product32[i][1])&product32[i][0]); 
            end
          end
        endcase
      end
    endcase
  end

  // assign to result
  always_comb begin
    // initial the data
    result_vdata   = 'b0; 
 
    // calculate result data
    case({alu_uop_valid,uop_funct3}) 
      {1'b1,OPIVV},
      {1'b1,OPIVX},
      {1'b1,OPIVI}: begin
        case(uop_funct6.ari_funct6)
          VADD,
          VADC: begin
            case(vs2_eew)
              EEW8: begin
                for (i=0;i<`VLENB;i=i+1) begin
                  result_vdata[i*`BYTE_WIDTH +: `BYTE_WIDTH] = product8[i];
                end
              end
              EEW16: begin
                for (i=0;i<`VLEN/`HWORD_WIDTH;i=i+1) begin
                  result_vdata[i*`HWORD_WIDTH +: `HWORD_WIDTH] = product16[i];
                end
              end
              EEW32: begin
                for (i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
                  result_vdata[i*`WORD_WIDTH +: `WORD_WIDTH] = product32[i];
                end
              end
            endcase
          end

          VSUB,
          VSBC: begin
            case(uop_funct3) 
              OPIVV,
              OPIVX: begin
                case(vs2_eew)
                  EEW8: begin
                    for (i=0;i<`VLENB;i=i+1) begin
                      result_vdata[i*`BYTE_WIDTH +: `BYTE_WIDTH] = product8[i];
                    end
                  end
                  EEW16: begin
                    for (i=0;i<`VLEN/`HWORD_WIDTH;i=i+1) begin
                      result_vdata[i*`HWORD_WIDTH +: `HWORD_WIDTH] = product16[i];
                    end
                  end
                  EEW32: begin
                    for (i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
                      result_vdata[i*`WORD_WIDTH +: `WORD_WIDTH] = product32[i];
                    end
                  end
                endcase
              end
            endcase
          end
           
          VRSUB: begin
            case(uop_funct3) 
              OPIVX,
              OPIVI: begin
                case(vs2_eew)
                  EEW8: begin
                    for (i=0;i<`VLENB;i=i+1) begin
                      result_vdata[i*`BYTE_WIDTH +: `BYTE_WIDTH] = product8[i];
                    end
                  end
                  EEW16: begin
                    for (i=0;i<`VLEN/`HWORD_WIDTH;i=i+1) begin
                      result_vdata[i*`HWORD_WIDTH +: `HWORD_WIDTH] = product16[i];
                    end
                  end
                  EEW32: begin
                    for (i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
                      result_vdata[i*`WORD_WIDTH +: `WORD_WIDTH] = product32[i];
                    end
                  end
                endcase
              end
            endcase
          end
          
          VMADC: begin
            result_vdata = vd_data;
            
            case(vs2_eew)
              EEW8: begin
                for (i=0;i<`VLENB;i=i+1) begin
                  result_vdata[i] = cout8[i];
                end
              end
              EEW16: begin
                for (i=0;i<`VLEN/`HWORD_WIDTH;i=i+1) begin
                  result_vdata[i] = cout16[i];
                end
              end
              EEW32: begin
                for (i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
                  result_vdata[i] = cout32[i];
                end
              end
            endcase
          end
          
          VMSBC: begin
            result_vdata = vd_data;

            case(uop_funct3) 
              OPIVX,
              OPIVI: begin
                case(vs2_eew)
                  EEW8: begin
                    for (i=0;i<`VLENB;i=i+1) begin
                      result_vdata[i] = cout8[i];
                    end
                  end
                  EEW16: begin
                    for (i=0;i<`VLEN/`HWORD_WIDTH;i=i+1) begin
                      result_vdata[i] = cout16[i];
                    end
                  end
                  EEW32: begin
                    for (i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
                      result_vdata[i] = cout32[i];
                    end
                  end
                endcase
              end
            endcase
          end

          VSADDU: begin
            case(vs2_eew)
              EEW8: begin
                for (i=0;i<`VLENB;i=i+1) begin
                  if (cout8[i])
                    result_vdata[i] = 'hff;
                  else
                    result_vdata[i*`BYTE_WIDTH +: `BYTE_WIDTH] = product8[i];
                end
              end
              EEW16: begin
                for (i=0;i<`VLEN/`HWORD_WIDTH;i=i+1) begin
                  if (cout16[i])
                    result_vdata[i*`HWORD_WIDTH +: `HWORD_WIDTH] = 'hffff;
                  else
                    result_vdata[i*`HWORD_WIDTH +: `HWORD_WIDTH] = product16[i];
                end
              end
              EEW32: begin
                for (i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
                  if (cout32[i])
                    result_vdata[i*`WORD_WIDTH +: `WORD_WIDTH] = 'hffff_ffff;
                  else
                    result_vdata[i*`WORD_WIDTH +: `WORD_WIDTH] = product32[i];
                end
              end
            endcase
          end

          VSADD: begin
            case(vs2_eew)
              EEW8: begin
                for (i=0;i<`VLENB;i=i+1) begin
                  if ((cout8[i]==1'b1)&(vs2_vdata[i][`BYTE_WIDTH-1]==1'b0)&(vs1_vdata[i][`BYTE_WIDTH-1]==1'b0))
                    result_vdata[i*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h7f;
                  else if ((cout8[i]==1'b0)&(vs2_vdata[i][`BYTE_WIDTH-1]==1'b1)&(vs1_vdata[i][`BYTE_WIDTH-1]==1'b1))
                    result_vdata[i*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h80;
                  else
                    result_vdata[i*`BYTE_WIDTH +: `BYTE_WIDTH] = product8[i];
                end
              end
              EEW16: begin
                for (i=0;i<`VLEN/`HWORD_WIDTH;i=i+1) begin
                  if ((cout16[i]==1'b1)&(vs2_vdata[2*i+1][`BYTE_WIDTH-1]==1'b0)&(vs1_vdata[2*i+1][`BYTE_WIDTH-1]==1'b0))
                    result_vdata[i] = 'h7fff;
                  else if ((cout16[i]==1'b0)&(vs2_vdata[2*i+1][`BYTE_WIDTH-1]==1'b1)&(vs1_vdata[2*i+1][`BYTE_WIDTH-1]==1'b1))
                    result_vdata[i] = 'h8000;
                  else
                    result_vdata[i*`HWORD_WIDTH +: `HWORD_WIDTH] = product16[i];
                end
              end
              EEW32: begin
                for (i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
                  if ((cout32[i]==1'b1)&(vs2_vdata[4*i+3][`BYTE_WIDTH-1]==1'b0)&(vs1_vdata[4*i+3][`BYTE_WIDTH-1]==1'b0))
                    result_vdata[i*`WORD_WIDTH +: `WORD_WIDTH] = 'h7fff_ffff;
                  if ((cout32[i]==1'b0)&(vs2_vdata[4*i+3][`BYTE_WIDTH-1]==1'b1)&(vs1_vdata[4*i+3][`BYTE_WIDTH-1]==1'b1))
                    result_vdata[i*`WORD_WIDTH +: `WORD_WIDTH] = 'h8000_0000;
                  else
                    result_vdata[i*`WORD_WIDTH +: `WORD_WIDTH] = product32[i];
                end
              end
            endcase
          end

          VSSUBU: begin
            case(vs2_eew)
              EEW8: begin
                for (i=0;i<`VLENB;i=i+1) begin
                  if (cout8[i])
                    result_vdata[i] = 'd0;
                  else
                    result_vdata[i*`BYTE_WIDTH +: `BYTE_WIDTH] = product8[i];
                end
              end
              EEW16: begin
                for (i=0;i<`VLEN/`HWORD_WIDTH;i=i+1) begin
                  if (cout16[i])
                    result_vdata[i*`HWORD_WIDTH +: `HWORD_WIDTH] = 'd0;
                  else
                    result_vdata[i*`HWORD_WIDTH +: `HWORD_WIDTH] = product16[i];
                end
              end
              EEW32: begin
                for (i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
                  if (cout32[i])
                    result_vdata[i*`WORD_WIDTH +: `WORD_WIDTH] = 'd0;
                  else
                    result_vdata[i*`WORD_WIDTH +: `WORD_WIDTH] = product32[i];
                end
              end
            endcase
          end

          VSSUB: begin
            case(vs2_eew)
              EEW8: begin
                for (i=0;i<`VLENB;i=i+1) begin
                  if ((cout8[i]==1'b1)&(vs2_vdata[i][`BYTE_WIDTH-1]==1'b0)&(vs1_vdata[i][`BYTE_WIDTH-1]==1'b1))
                    result_vdata[i*`BYTE_WIDTH +: `BYTE_WIDTH] = 'hff;
                  else if ((cout8[i]==1'b0)&(vs2_vdata[i][`BYTE_WIDTH-1]==1'b1)&(vs1_vdata[i][`BYTE_WIDTH-1]==1'b0))
                    result_vdata[i*`BYTE_WIDTH +: `BYTE_WIDTH] = 'h80;
                  else
                    result_vdata[i*`BYTE_WIDTH +: `BYTE_WIDTH] = product8[i];
                end
              end
              EEW16: begin
                for (i=0;i<`VLEN/`HWORD_WIDTH;i=i+1) begin
                  if ((cout16[i]==1'b1)&(vs2_vdata[2*i+1][`BYTE_WIDTH-1]==1'b0)&(vs1_vdata[2*i+1][`BYTE_WIDTH-1]==1'b1))
                    result_vdata[i] = 'h7fff;
                  else if ((cout16[i]==1'b0)&(vs2_vdata[2*i+1][`BYTE_WIDTH-1]==1'b1)&(vs1_vdata[2*i+1][`BYTE_WIDTH-1]==1'b0))
                    result_vdata[i] = 'h8000;
                  else
                    result_vdata[i*`HWORD_WIDTH +: `HWORD_WIDTH] = product16[i];
                end
              end
              EEW32: begin
                for (i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
                  if ((cout32[i]==1'b1)&(vs2_vdata[4*i+3][`BYTE_WIDTH-1]==1'b0)&(vs1_vdata[4*i+3][`BYTE_WIDTH-1]==1'b1))
                    result_vdata[i*`WORD_WIDTH +: `WORD_WIDTH] = 'h7fff_ffff;
                  if ((cout32[i]==1'b0)&(vs2_vdata[4*i+3][`BYTE_WIDTH-1]==1'b1)&(vs1_vdata[4*i+3][`BYTE_WIDTH-1]==1'b0))
                    result_vdata[i*`WORD_WIDTH +: `WORD_WIDTH] = 'h8000_0000;
                  else
                    result_vdata[i*`WORD_WIDTH +: `WORD_WIDTH] = product32[i];
                end
              end
            endcase
          end


        endcase
      end

      {1'b1,OPMVV},
      {1'b1,OPMVX}: begin
        case(uop_funct6.ari_funct6)
          VWADDU,
          VWSUBU,
          VWADD,
          VWSUB: begin
            case(vs2_eew)
              EEW8: begin
                for (i=0;i<`VLEN/`HWORD_WIDTH;i=i+1) begin
                  result_vdata[i*`HWORD_WIDTH +: `HWORD_WIDTH] = product16[i];
                end
              end
              EEW16: begin
                for (i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
                  result_vdata[i*`WORD_WIDTH +: `WORD_WIDTH] = product32[i];
                end
              end
            endcase
          end

          VWADDU_W,
          VWSUBU_W,
          VWADD_W,
          VWSUB_W: begin
            case(vs2_eew)
              EEW16: begin
                for (i=0;i<`VLEN/`HWORD_WIDTH;i=i+1) begin
                  result_vdata[i*`HWORD_WIDTH +: `HWORD_WIDTH] = product16[i];
                end
              end
              EEW32: begin
                for (i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
                  result_vdata[i*`WORD_WIDTH +: `WORD_WIDTH] = product32[i];
                end
              end
            endcase
          end

          VAADDU,
          VAADD,
          VASUBU,
          VASUB: begin
            case(vs2_eew)
              EEW8: begin
                for (i=0;i<`VLENB;i=i+1) begin
                  result_vdata[i*`BYTE_WIDTH +: `BYTE_WIDTH] = round8[i];
                end
              end
              EEW16: begin
                for (i=0;i<`VLEN/`HWORD_WIDTH;i=i+1) begin
                  result_vdata[i*`HWORD_WIDTH +: `HWORD_WIDTH] = round16[i];
                end
              end
              EEW32: begin
                for (i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
                  result_vdata[i*`WORD_WIDTH +: `WORD_WIDTH] = round32[i];
                end
              end
            endcase
          end
        endcase
      end
    endcase
  end

//
// submit result to ROB
//
  assign  result_ex2rob.rob_entry  = rob_entry;
  assign  result_ex2rob.w_data     = w_data;
  assign  result_ex2rob.w_type     = w_type;
  assign  result_ex2rob.w_valid    = w_valid;
  assign  result_ex2rob.vxsat      = vxsat;
  assign  result_ex2rob.ignore_vta = ignore_vta;
  assign  result_ex2rob.ignore_vma = ignore_vma;

  // valid signal
  assign result_valid_ex2rob = result_valid; 

  // result data 
  assign w_data = result_vdata; 

  // result type and valid signal
  assign w_type = VRF;
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
          VSADDU,
          VSSUBU: begin
            case(vs2_eew)
              EEW8: begin
                for (i=0;i<`VLENB;i=i+1) begin
                  if (cout8[i])
                    vxsat = 1'b1;
                end
              end
              EEW16: begin
                for (i=0;i<`VLEN/`HWORD_WIDTH;i=i+1) begin
                  if (cout16[i])
                    vxsat = 1'b1;
                end
              end
              EEW32: begin
                for (i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
                  if (cout32[i])
                    vxsat = 1'b1;
                end
              end
            endcase
          end

          VSADD: begin
            case(vs2_eew)
              EEW8: begin
                for (i=0;i<`VLENB;i=i+1) begin
                  if (((cout8[i]==1'b1)&(vs2_vdata[i][`BYTE_WIDTH-1]==1'b0)&(vs1_vdata[i][`BYTE_WIDTH-1]==1'b0)) |
                      ((cout8[i]==1'b0)&(vs2_vdata[i][`BYTE_WIDTH-1]==1'b1)&(vs1_vdata[i][`BYTE_WIDTH-1]==1'b1)) )
                    vxsat = 1'b1;
                end
              end
              EEW16: begin
                for (i=0;i<`VLEN/`HWORD_WIDTH;i=i+1) begin
                  if (((cout16[i]==1'b1)&(vs2_vdata[2*i+1][`BYTE_WIDTH-1]==1'b0)&(vs1_vdata[2*i+1][`BYTE_WIDTH-1]==1'b0))|
                      ((cout16[i]==1'b0)&(vs2_vdata[2*i+1][`BYTE_WIDTH-1]==1'b1)&(vs1_vdata[2*i+1][`BYTE_WIDTH-1]==1'b1)))
                    vxsat = 1'b1;
                end
              end
              EEW32: begin
                for (i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
                  if (((cout32[i]==1'b1)&(vs2_vdata[4*i+3][`BYTE_WIDTH-1]==1'b0)&(vs1_vdata[4*i+3][`BYTE_WIDTH-1]==1'b0))|
                      ((cout32[i]==1'b0)&(vs2_vdata[4*i+3][`BYTE_WIDTH-1]==1'b1)&(vs1_vdata[4*i+3][`BYTE_WIDTH-1]==1'b1)))
                    vxsat = 1'b1;
                end
              end
            endcase
          end

          VSUB: begin
            case(vs2_eew)
              EEW8: begin
                for (i=0;i<`VLENB;i=i+1) begin
                  if (((cout8[i]==1'b1)&(vs2_vdata[i][`BYTE_WIDTH-1]==1'b0)&(vs1_vdata[i][`BYTE_WIDTH-1]==1'b1)) |
                      ((cout8[i]==1'b0)&(vs2_vdata[i][`BYTE_WIDTH-1]==1'b1)&(vs1_vdata[i][`BYTE_WIDTH-1]==1'b0)) )
                    vxsat = 1'b1;
                end
              end
              EEW16: begin
                for (i=0;i<`VLEN/`HWORD_WIDTH;i=i+1) begin
                  if (((cout16[i]==1'b1)&(vs2_vdata[2*i+1][`BYTE_WIDTH-1]==1'b0)&(vs1_vdata[2*i+1][`BYTE_WIDTH-1]==1'b1))|
                      ((cout16[i]==1'b0)&(vs2_vdata[2*i+1][`BYTE_WIDTH-1]==1'b1)&(vs1_vdata[2*i+1][`BYTE_WIDTH-1]==1'b0)))
                    vxsat = 1'b1;
                end
              end
              EEW32: begin
                for (i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
                  if (((cout32[i]==1'b1)&(vs2_vdata[4*i+3][`BYTE_WIDTH-1]==1'b0)&(vs1_vdata[4*i+3][`BYTE_WIDTH-1]==1'b1))|
                      ((cout32[i]==1'b0)&(vs2_vdata[4*i+3][`BYTE_WIDTH-1]==1'b1)&(vs1_vdata[4*i+3][`BYTE_WIDTH-1]==1'b0)))
                    vxsat = 1'b1;
                end
              end
            endcase
          end
        endcase
      end
    endcase
  end

  // ignore vta an vma signal
  always_comb begin
    ignore_vta            = 'b0;
    ignore_vma            = 'b0;
    
    case({alu_uop_valid,uop_funct3}) 
      {1'b1,OPIVV},
      {1'b1,OPIVX},
      {1'b1,OPIVI}: begin
        case(uop_funct6.ari_funct6)
          VMADC: begin
            ignore_vta    = 'b1;
            ignore_vma    = 'b1;
          end
          VMSBC: begin
            case(uop_funct3) 
              OPIVX,
              OPIVI: begin
                ignore_vta  = 'b1;
                ignore_vma  = 'b1;
              end
            endcase
          end
        endcase
      end
    endcase
  end

//
// function unit
//
  // add and sub function
  function [`BYTE_WIDTH:0] f_addsub;
    // x +/- (y+cin)
    input F_ADDSUB_t            opcode;  
    input logic [`BYTE_WIDTH:0] src_x;
    input logic [`BYTE_WIDTH:0] src_y;
    input logic                 cin;

    logic [`BYTE_WIDTH:0] src_y_plus_cin;

    src_y_plus_cin = src_y + cin;

    if (opcode==ADDSUB_VADD) begin
      f_addsub = src_x + src_y_plus_cin;
    end
    else begin
      f_addsub = src_x - src_y_plus_cin;
    end
  endfunction


endmodule
