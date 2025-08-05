// Description:
// 1. rvv_backend_dispatch_opr_byte_type sub-module is for generating byte type for operand(s)
//    a. it is convenient for PU&RT to check if byte data shoud be updated or used for uop(s)

`ifndef HDL_VERILOG_RVV_DESIGN_RVV_SVH
`include "rvv_backend.svh"
`endif
`ifndef RVV_DISPATCH__SVH
`include "rvv_backend_dispatch.svh"
`endif

module rvv_backend_dispatch_opr_byte_type
(
    operand_byte_type,
    uop_info,
    v0_enable
);
// ---parameter definition--------------------------------------------
    localparam VLENB_WIDTH = $clog2(`VLENB);

// ---port definition-------------------------------------------------
    output UOP_OPN_BYTE_TYPE_t operand_byte_type;
    input  UOP_INFO_t          uop_info;
    input  logic [`VLEN-1:0]   v0_enable;

// ---internal signal definition--------------------------------------
    EEW_e                               eew_max;
    logic  [1:0]                        eew_max_shift;
    
    logic  [1:0]                        vs2_eew_shift;
    logic  [`VSTART_WIDTH-1:0]          uop_vs2_start;
    logic  [`VLENB-1:0][`VL_WIDTH-1:0]  vs2_ele_index; // element index
    logic  [`VLENB-1:0]                 vs2_enable, vs2_enable_tmp;

    logic  [1:0]                        vd_eew_shift;
    logic  [`VSTART_WIDTH-1:0]          uop_v0_start;
    logic  [`VSTART_WIDTH-1:0]          uop_vd_start;
    logic  [`VSTART_WIDTH-1:0]          uop_vd_end;
    logic  [`VLENB-1:0][`VL_WIDTH-1:0]  vd_ele_index; // element index
    logic  [`VLENB-1:0]                 vd_enable, vd_enable_tmp;
    
    // result
    BYTE_TYPE_t                         vs2;
    BYTE_TYPE_t                         vd;
    logic [`VLENB-1:0]                  v0_strobe;

// ---code start------------------------------------------------------
    // find eew_max and shift amount
    always_comb begin
      if ((uop_info.vs1_eew==EEW32)||(uop_info.vs2_eew==EEW32)||(uop_info.vd_eew==EEW32)) begin
        eew_max       = EEW32;
        eew_max_shift = 2'h2;
      end
      else if ((uop_info.vs1_eew==EEW16)||(uop_info.vs2_eew==EEW16)||(uop_info.vd_eew==EEW16)) begin
        eew_max       = EEW16;
        eew_max_shift = 2'h1;
      end
      else if ((uop_info.vs1_eew==EEW8)||(uop_info.vs2_eew==EEW8)||(uop_info.vd_eew==EEW8)) begin
        eew_max       = EEW8;
        eew_max_shift = 2'h0;
      end
      else if ((uop_info.vs1_eew==EEW1)||(uop_info.vs2_eew==EEW1)||(uop_info.vd_eew==EEW1)) begin
        eew_max       = EEW1;
        eew_max_shift = 2'h0;
      end
      else begin
        eew_max       = EEW_NONE;
        eew_max_shift = 2'h0;
      end
    end

    genvar i;

// for vs2 byte type
    generate
        always_comb begin
            case (uop_info.vs2_eew)
                EEW8:   vs2_eew_shift = 2'h0;
                EEW16:  vs2_eew_shift = 2'h1;
                EEW32:  vs2_eew_shift = 2'h2;
                default:vs2_eew_shift = 2'h0;
            endcase
        end

        // for RDT instruction, eew_max == vs2_eew
        always_comb begin
          case (uop_info.uop_exe_unit)
            RDT:begin
              uop_vs2_start = (`VSTART_WIDTH)'(uop_info.uop_index) << (VLENB_WIDTH - vs2_eew_shift);
            end
            default:begin
              case({eew_max,uop_info.vs2_eew})
                {EEW32,EEW32},
                {EEW16,EEW16},
                {EEW8,EEW8}: begin
                  // regular and narrowing instruction
                  uop_vs2_start = (`VSTART_WIDTH)'(uop_info.uop_index) << (VLENB_WIDTH - vs2_eew_shift);
                end
                {EEW32,EEW16},
                {EEW16,EEW8}: begin
                  // widening instruction: EEW_vd:EEW_vs = 2:1
                  uop_vs2_start = (`VSTART_WIDTH)'(uop_info.uop_index[`UOP_INDEX_WIDTH-1:1]) << (VLENB_WIDTH - vs2_eew_shift);
                end
                {EEW32,EEW8}: begin
                  // widening instruction: EEW_vd:EEW_vs = 4:1
                  uop_vs2_start = (`VSTART_WIDTH)'(uop_info.uop_index[`UOP_INDEX_WIDTH-1:2]) << (VLENB_WIDTH - vs2_eew_shift);
                end
                default: begin
                  uop_vs2_start = 'b0;
                end
              endcase
            end
          endcase
        end

        assign vs2_enable_tmp  = v0_enable[uop_vs2_start+:`VLENB]; 

        for (i=0; i<`VLENB; i++) begin : gen_vs2_byte_type
            // ele_index = uop_index * (VLEN/vs2_eew) + BYTE_INDEX[MSB:vs2_eew]
            assign vs2_enable[i] = uop_info.vm ? 1'b1 : vs2_enable_tmp[i >> vs2_eew_shift];
            assign vs2_ele_index[i] = (`VL_WIDTH)'(uop_vs2_start) + (i >> vs2_eew_shift);
            always_comb begin
                if (uop_info.ignore_vta&uop_info.ignore_vma)
                    vs2[i] = BODY_ACTIVE;       
                else if (vs2_ele_index[i] >= uop_info.vl) 
                    vs2[i] = TAIL; 
                else if (vs2_ele_index[i] < {1'b0, uop_info.vstart}) 
                    vs2[i] = NOT_CHANGE; // prestart
                else begin 
                    vs2[i] = (vs2_enable[i] || uop_info.ignore_vma) ? BODY_ACTIVE : BODY_INACTIVE;
                end
            end
        end
    endgenerate

// for vd byte type
    generate
        always_comb begin
            case (uop_info.vd_eew)
                EEW8:   vd_eew_shift = 2'h0;
                EEW16:  vd_eew_shift = 2'h1;
                EEW32:  vd_eew_shift = 2'h2;
                default:vd_eew_shift = 2'h0;
            endcase
        end
        
        always_comb begin
          case({eew_max,uop_info.vd_eew})
            {EEW32,EEW32},
            {EEW16,EEW16},
            {EEW8,EEW8}: begin
              uop_v0_start = (`VSTART_WIDTH)'(uop_info.uop_index) << (VLENB_WIDTH - vd_eew_shift);
              uop_vd_start = uop_v0_start; 
              uop_vd_end = uop_vd_start + (`VLENB >> eew_max_shift) - 1'b1;
            end
            {EEW32,EEW16},
            {EEW16,EEW8}: begin
              // narrowing instruction: EEW_vd:EEW_vs = 1:2
              uop_v0_start = (`VSTART_WIDTH)'(uop_info.uop_index[`UOP_INDEX_WIDTH-1:1]) << (VLENB_WIDTH - vd_eew_shift);
              uop_vd_start = uop_info.uop_index[0] ? uop_v0_start + (`VLENB >> eew_max_shift):
                                                     uop_v0_start;
              uop_vd_end = uop_vd_start + (`VLENB >> eew_max_shift) - 1'b1 ; 
            end
            {EEW32,EEW8}: begin
              // narrowing instruction: EEW_vd:EEW_vs = 1:4
              uop_v0_start = (`VSTART_WIDTH)'(uop_info.uop_index[`UOP_INDEX_WIDTH-1:2]) << VLENB_WIDTH;
              case(uop_info.uop_index[1:0])
                2'd3: begin
                  uop_vd_start = uop_v0_start + `VLENB*3/4;
                end
                2'd2: begin
                  uop_vd_start = uop_v0_start + `VLENB*2/4;
                end
                2'd1: begin
                  uop_vd_start = uop_v0_start + `VLENB*1/4;
                end
                default: begin
                  uop_vd_start = uop_v0_start;
                end
              endcase
              uop_vd_end = uop_vd_start + (`VLENB/4-1);
            end
            default: begin  // {EEW1,EEW1}
              uop_v0_start = 'b0; 
              uop_vd_start = uop_info.vstart; 
              uop_vd_end = uop_info.vl;
            end
          endcase
        end

        assign vd_enable_tmp  = v0_enable[uop_v0_start+:`VLENB]; 

        for (i=0; i<`VLENB; i++) begin : gen_vd_byte_type
          if (i==0) begin
            // ele_index = uop_index * (VLEN/vd_eew) + BYTE_INDEX[MSB:vd_eew]
            assign vd_enable[0] = uop_info.vm ? 1'b1 : vd_enable_tmp[0];
            assign vd_ele_index[0] = (`VL_WIDTH)'(uop_v0_start);

            always_comb begin
              v0_strobe[0] = 'b0;

              case (uop_info.uop_exe_unit)
                RDT:begin
                  case(uop_info.vd_eew)
                    EEW32:vd[0]   = BODY_ACTIVE;
                    EEW16:vd[0]   = BODY_ACTIVE;
                    default:vd[0] = BODY_ACTIVE;
                  endcase
                end
                default:begin
                  if (uop_info.ignore_vta&uop_info.ignore_vma)
                      vd[0] = BODY_ACTIVE;       
                  else if (vd_ele_index[0] >= uop_info.vl) 
                      vd[0] = TAIL;       
                  else if ((vd_ele_index[0] < {1'b0, uop_info.vstart})&(uop_info.vstart>=uop_vd_start)) 
                      vd[0] = NOT_CHANGE;     // prestart
                  else if (vd_ele_index[0] < {1'b0, uop_vd_start}) // &(uop_info.vstart<uop_vd_start)
                      vd[0] = NOT_CHANGE;     // prestart
                  else begin 
                      vd[0] = (vd_enable[0] || uop_info.ignore_vma) ? BODY_ACTIVE
                                                                                      : BODY_INACTIVE;
                      v0_strobe[0] = vd_enable[0] || uop_info.ignore_vma;
                  end
                end
              endcase
            end
          end else begin
            // ele_index = uop_index * (VLEN/vd_eew) + BYTE_INDEX[MSB:vd_eew]
            assign vd_enable[i] = uop_info.vm ? 1'b1 : vd_enable_tmp[i >> vd_eew_shift];
            assign vd_ele_index[i] = (`VL_WIDTH)'(uop_v0_start) + (i >> vd_eew_shift);

            always_comb begin
              v0_strobe[i] = 'b0;

              case (uop_info.uop_exe_unit)
                RDT:begin
                  case(uop_info.vd_eew)
                    EEW32:vd[i] = i<4 ? BODY_ACTIVE : TAIL;
                    EEW16:vd[i] = i<2 ? BODY_ACTIVE : TAIL;
                    default:vd[i] = i<1 ? BODY_ACTIVE : TAIL;
                  endcase
                end
                default:begin
                  if (uop_info.ignore_vta&uop_info.ignore_vma)
                      vd[i] = BODY_ACTIVE;       
                  else if (vd_ele_index[i] >= uop_info.vl) 
                      vd[i] = TAIL;       
                  else if ((vd_ele_index[i] < {1'b0, uop_info.vstart})&(uop_info.vstart>=uop_vd_start)) 
                      vd[i] = NOT_CHANGE;     // prestart
                  else if (vd_ele_index[i] < {1'b0, uop_vd_start}) // &(uop_info.vstart<uop_vd_start)
                      vd[i] = NOT_CHANGE;     // prestart
                  else if (vd_ele_index[i] > {1'b0, uop_vd_end}) 
                      vd[i] = BODY_INACTIVE;
                  else begin 
                      vd[i] = (vd_enable[i] || uop_info.ignore_vma) ? BODY_ACTIVE
                                                                                      : BODY_INACTIVE;
                      v0_strobe[i] = vd_enable[i] || uop_info.ignore_vma;
                  end
                end
              endcase
            end
          end
        end
    endgenerate

    assign operand_byte_type.vs2       = vs2;
    assign operand_byte_type.vd        = vd;
    assign operand_byte_type.v0_strobe = v0_strobe;

endmodule
