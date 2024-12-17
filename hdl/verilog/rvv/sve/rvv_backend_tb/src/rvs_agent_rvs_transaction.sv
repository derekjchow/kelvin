`ifndef RVS_TRANSACTION__SV
`define RVS_TRANSACTION__SV

`include "inst_description.svh"

class rvs_transaction extends uvm_sequence_item;
  /* Tr config field */
  rand bit use_vlmax = 0;

  /* VCSR field */
  rand vtype_t vtype;
  rand logic [`XLEN-1:0] vl;
       logic [`XLEN-1:0] vlmax;
  rand logic [`XLEN-1:0] vstart;
  rand logic [`XLEN-1:0] vxrm;
  rand logic [`XLEN-1:0] vxsat;  

  /* Instruction description field */
  rand inst_type_e inst_type;// opcode

  // Load/Store inst
  rand lsu_mop_e lsu_mop;
  rand lsu_umop_e lsu_umop;
  rand lsu_nf_e lsu_nf;
  rand eew_e lsu_eew;

  // Algoritm inst
  rand alu_type_e alu_type;  // func3
  rand opi_type_e opi_type;  // func6
  rand opm_type_e opm_type;  // func6

  rand logic vm; // Mask bit. 0 - Use v0.t

  // Generate oprand
  rand oprand_type_e dest_type;
  rand oprand_type_e src1_type;
  rand oprand_type_e src2_type;
  rand oprand_type_e src3_type;
  rand logic [4:0] dest_idx;
  rand logic [4:0] src1_idx;
  rand logic [4:0] src2_idx;
  rand logic [4:0] src3_idx;
   
  rand logic [`XLEN-1:0] rs_data;

  /* Real instruction */
  rand logic [31:0] pc;
       logic [31:0] bin_inst; 
       string asm_string;

  /* Write back info */
  rt_xrf_t wb_xrf;
  logic wb_xrf_valid;

  /* Trap field */
  // TODO
// Constrain ----------------------------------------------------------

  constraint c_normal_set {
    vtype.vill == 1'b0;
    vtype.rsv  ==  'b0;  
    vstart == 0;
    vxsat inside {0,1,2,3};
    vxrm inside {0,1,2,3};
  }

  constraint c_vl {
    if(vtype.vlmul[2])
      vl <= (`VLENB >> (~vtype.vlmul +3'b1)) >> vtype.vsew;
    else  
      vl <= (`VLENB << vtype.vlmul) >> vtype.vsew;
  }

  constraint c_oprand {
    dest_type inside {VRF, XRF};
    if(inst_type == ALU && alu_type == OPI && opi_type == VADD) dest_type inside {VRF};
    if(inst_type == ALU && alu_type == OPI && opi_type == VADD) src1_type inside {VRF, XRF, IMM};
    if(inst_type == ALU && alu_type == OPI && opi_type == VADD) src2_type inside {VRF};
    if(inst_type == ALU) src3_type == UNUSE;
    solve inst_type before src3_type;
  }


// Auto Field ---------------------------------------------------------
  `uvm_object_utils_begin(rvs_transaction) 
    `uvm_field_int(pc,UVM_ALL_ON)
    `uvm_field_int(bin_inst,UVM_ALL_ON)
    `uvm_field_string(asm_string,UVM_ALL_ON)

    `uvm_field_enum(sew_e,vtype.vsew,UVM_ALL_ON)
    `uvm_field_enum(lmul_e,vtype.vlmul,UVM_ALL_ON)
    `uvm_field_enum(agnostic_e,vtype.vma,UVM_ALL_ON)
    `uvm_field_enum(agnostic_e,vtype.vta,UVM_ALL_ON)

    `uvm_field_int(vlmax,UVM_ALL_ON)
    `uvm_field_int(use_vlmax,UVM_ALL_ON)
    `uvm_field_int(vl,UVM_ALL_ON)
    `uvm_field_int(vstart,UVM_ALL_ON)
    `uvm_field_int(vxrm,UVM_ALL_ON)
    `uvm_field_int(vxsat,UVM_ALL_ON)

    `uvm_field_enum(inst_type_e,inst_type,UVM_ALL_ON)
    if(inst_type == ALU) begin
      `uvm_field_enum(alu_type_e,alu_type,UVM_ALL_ON)
      `uvm_field_enum(opi_type_e,opi_type,UVM_ALL_ON)
      `uvm_field_enum(opm_type_e,opm_type,UVM_ALL_ON)
    end
    if(inst_type == LD || inst_type == ST) begin
      `uvm_field_enum(lsu_mop_e,lsu_mop,UVM_ALL_ON)
      `uvm_field_enum(lsu_umop_e,lsu_umop,UVM_ALL_ON)
      `uvm_field_enum(lsu_nf_e,lsu_nf,UVM_ALL_ON)
      `uvm_field_enum(eew_e,lsu_eew,UVM_ALL_ON)
    end

    `uvm_field_enum(oprand_type_e,dest_type,UVM_ALL_ON)
    `uvm_field_int(dest_idx,UVM_ALL_ON)
    `uvm_field_enum(oprand_type_e,src1_type,UVM_ALL_ON)
    `uvm_field_int(src1_idx,UVM_ALL_ON)
    `uvm_field_enum(oprand_type_e,src2_type,UVM_ALL_ON)
    `uvm_field_int(src2_idx,UVM_ALL_ON)
    `uvm_field_enum(oprand_type_e,src3_type,UVM_ALL_ON)
    `uvm_field_int(src3_idx,UVM_ALL_ON)
    `uvm_field_int(rs_data,UVM_ALL_ON)

    `uvm_field_int(wb_xrf.rt_index ,UVM_ALL_ON)
    `uvm_field_int(wb_xrf.rt_data  ,UVM_ALL_ON)
    `uvm_field_int(wb_xrf_valid,UVM_ALL_ON)
  `uvm_object_utils_end

  extern function new(string name = "Trans");
  extern function void post_randomize();
  extern function void asm_string_gen();

endclass: rvs_transaction


function rvs_transaction::new(string name = "Trans");
  super.new(name);
endfunction: new

function void rvs_transaction::post_randomize();
  // post cal
  if(inst_type == ALU && alu_type == OPM && opm_type == VMAND) vm = 1;  
  if(src1_type != XRF && src2_type != XRF) rs_data = '1;

  // constraint vl
  if(vtype.vlmul[2]) begin
    logic [2:0] vlmul = ~vtype.vlmul +3'b1;
    vlmax = (`VLENB >> vlmul) >> vtype.vsew; 
  end else begin
    logic [2:0] vlmul = vtype.vlmul;
    vlmax = (`VLENB << vlmul) >> vtype.vsew;
  end
  if(use_vlmax) begin 
    vl = vlmax;
  end else begin
    vl = vl > vlmax ? vlmax : vl;
  end

  // gen bin_inst
  case(inst_type)
    LD: bin_inst[31:26] = '0; //FIXME
    ST: bin_inst[31:26] = '0; //FIXME
    ALU: begin
      case(alu_type)
        OPI: bin_inst[31:26] = opi_type;
        OPM: bin_inst[31:26] = opm_type;
      endcase
    end
  endcase
  bin_inst[25]    = vm;
  bin_inst[24:20] = src2_idx;
  bin_inst[19:15] = src1_idx;
  case(inst_type)
    LD: bin_inst[14:12] = '0; // FIXME
    ST: bin_inst[14:12] = '0; // FIXME
    ALU: bin_inst[14:12] = alu_type;
  endcase
  bin_inst[11:7]  = dest_idx;
  bin_inst[6:0]   = inst_type;

  asm_string_gen();
endfunction: post_randomize

function void rvs_transaction::asm_string_gen();
  string inst = "nop";
  string suff = "";
  string suf1 = "";
  string src1 = "";
  string suf2 = "";
  string src2 = "";
  string dest = "";
  string mask = "";
  string comm = "# an example";
  case(inst_type)
    LD: ; 
    ST: ; 
    ALU: begin
      case(alu_type)
        OPI: inst = this.opi_type.name();
        OPM: inst = this.opm_type.name();
      endcase
    end
  endcase
  inst = inst.tolower();
  case(this.src1_type)
    VRF: begin suf1 = "v"; src1 = $sformatf("v%0d",this.src1_idx); end
    XRF: begin suf1 = "x"; src1 = $sformatf("x%0d",this.src1_idx); end
    IMM: begin suf1 = "i"; src1 = $sformatf("%0d",$signed(this.src1_idx)); end
  endcase
  case(this.src2_type)
    VRF: begin suf2 = "v"; src2 = $sformatf("v%0d",this.src2_idx); end
    XRF: begin suf2 = "x"; src2 = $sformatf("x%0d",this.src2_idx); end
    IMM: begin suf2 = "i"; src2 = $sformatf("%0d",$signed(this.src2_idx)); end
  endcase
  suff = $sformatf("%s%s",suf2,suf1);

  case(this.dest_type)
    VRF: dest = $sformatf("v%0d",this.dest_idx);
    XRF: dest = $sformatf("x%0d",this.dest_idx);
  endcase
  mask = this.vm ? "" : "v0.t";
  comm = $sformatf("# vlmul=%0s, vsew=%0s, vl=%0d", vtype.vlmul.name(), vtype.vsew.name(), vl);

  if(this.vm) 
    this.asm_string = $sformatf("%s.%s %s, %s, %s %s",inst, suff, dest, src2, src1, comm);
  else
    this.asm_string = $sformatf("%s.%s %s, %s, %s, %s %s",inst, suff, dest, src2, src1, mask, comm);
endfunction: asm_string_gen
`endif // RVS_TRANSACTION__SV
