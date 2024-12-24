// Description:
// 1. rvv_backend_dispatch_opr_byte_type sub-module is for generating byte type for operand(s)
//    a. it is convenient for PU&RT to check if byte data shoud be updated or used for uop(s)

`include "rvv_backend.svh"
`include "rvv_backend_dispatch.svh"

module rvv_backend_dispatch_opr_byte_type
(
    operand_byte_type,
    uop_info,
    v0_enable
);
// ---parameter definition--------------------------------------------
    localparam VLENB_WIDTH = $clog2(`VLENB);
    localparam logic [`VLENB-1:0][VLENB_WIDTH-1:0] BYTE_INDEX =
        {4'd15, 4'd14, 4'd13, 4'd12, 4'd11, 4'd10, 4'd9, 4'd8, 
         4'd7 , 4'd6 , 4'd5 , 4'd4 , 4'd3 , 4'd2 , 4'd1, 4'd0};
    //localparam logic [`VLENB-1:0][VLENB_WIDTH-1:0] BYTE_INDEX =
    //    {0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,
    //    16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31};

// ---port definition-------------------------------------------------
    output UOP_OPN_BYTE_TYPE_t operand_byte_type;
    input  UOP_INFO_t          uop_info;
    input  logic [`VLEN-1:0]   v0_enable;

// ---internal signal definition--------------------------------------
    logic  [1:0]                        vs1_eew_shift;
    logic  [`VSTART_WIDTH-1:0]          uop_vs1_start;
    logic  [`VLENB-1:0][`VL_WIDTH-1:0]  vs1_ele_index; // element index
    logic  [`VLENB-1:0]                 vs1_enable, vs1_enable_tmp;
    
    logic  [1:0]                        vs2_eew_shift;
    logic  [`VSTART_WIDTH-1:0]          uop_vs2_start;
    logic  [`VLENB-1:0][`VL_WIDTH-1:0]  vs2_ele_index; // element index
    logic  [`VLENB-1:0]                 vs2_enable, vs2_enable_tmp;

    logic  [1:0]                        vd_eew_shift;
    logic  [`VSTART_WIDTH-1:0]          uop_vd_start;
    logic  [`VLENB-1:0][`VL_WIDTH-1:0]  vd_ele_index; // element index
    logic  [`VLENB-1:0]                 vd_enable, vd_enable_tmp;

// ---code start------------------------------------------------------
    genvar i;
// for vs1 byte type
    generate
        always_comb begin
            case (uop_info.vs1_eew)
                EEW8:   vs1_eew_shift = 2'h0;
                EEW16:  vs1_eew_shift = 2'h1;
                EEW32:  vs1_eew_shift = 2'h2;
                default:vs1_eew_shift = 2'h0;
            endcase
        end
        assign uop_vs1_start = uop_info.uop_index << (VLENB_WIDTH - vs1_eew_shift);

        assign vs1_enable_tmp  = v0_enable[uop_vs1_start+:`VLENB]; 

        for (i=0; i<`VLENB; i++) begin : gen_vs1_byte_type
            // ele_index = uop_index * (VLEN/vs1_eew) + BYTE_INDEX[MSB:vs1_eew]
            assign vs1_ele_index[i] = uop_vs1_start + (BYTE_INDEX[i] >> vs1_eew_shift);
            assign vs1_enable[i] = uop_info.vm ? vs1_enable_tmp[BYTE_INDEX[i] >> vs1_eew_shift] : 1'b1;
            always_comb begin
                if (vs1_ele_index[i] > uop_info.vl) operand_byte_type.vs1[i] = TAIL;       // tail
                else if (vs1_ele_index[i] < {1'b0, uop_info.vstart}) 
                                                    operand_byte_type.vs1[i] = NOT_CHANGE; // prestart
                else                                operand_byte_type.vs1[i] = vs1_enable[i] ? BODY_ACTIVE
                                                                                             : BODY_INACTIVE;
            end
        end
    endgenerate

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
        assign uop_vs2_start = uop_info.uop_index << (VLENB_WIDTH - vs2_eew_shift);

        assign vs2_enable_tmp  = v0_enable[uop_vs2_start+:`VLENB]; 

        for (i=0; i<`VLENB; i++) begin : gen_vs2_byte_type
            // ele_index = uop_index * (VLEN/vs2_eew) + BYTE_INDEX[MSB:vs2_eew]
            assign vs2_ele_index[i] = uop_vs2_start + (BYTE_INDEX[i] >> vs2_eew_shift);
            assign vs2_enable[i] = uop_info.vm ? vs2_enable_tmp[BYTE_INDEX[i] >> vs2_eew_shift] : 1'b1;
            always_comb begin
                if (vs2_ele_index[i] > uop_info.vl) operand_byte_type.vs2[i] = TAIL;       // tail
                else if (vs2_ele_index[i] < {1'b0, uop_info.vstart}) 
                                                    operand_byte_type.vs2[i] = NOT_CHANGE; // prestart
                else                                operand_byte_type.vs2[i] = vs2_enable[i] ? BODY_ACTIVE
                                                                                             : BODY_INACTIVE;
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
        assign uop_vd_start = uop_info.uop_index << (VLENB_WIDTH - vd_eew_shift);

        assign vd_enable_tmp  = v0_enable[uop_vd_start+:`VLENB]; 

        for (i=0; i<`VLENB; i++) begin : gen_vd_byte_type
            // ele_index = uop_index * (VLEN/vd_eew) + BYTE_INDEX[MSB:vd_eew]
            assign vd_ele_index[i] = uop_vd_start + (BYTE_INDEX[i] >> vd_eew_shift);
            assign vd_enable[i] = uop_info.vm ? vd_enable_tmp[BYTE_INDEX[i] >> vd_eew_shift] : 1'b1;
            always_comb begin
                if (vd_ele_index[i] >= uop_info.vl) operand_byte_type.vd[i] = TAIL;       // tail
                else if (vd_ele_index[i] < {1'b0, uop_info.vstart}) 
                                                    operand_byte_type.vd[i] = NOT_CHANGE; // prestart
                else                                operand_byte_type.vd[i] = vd_enable[i] ? BODY_ACTIVE
                                                                                           : BODY_INACTIVE;
            end
        end
    endgenerate

endmodule
