// per inst coverage -----------------------------------------------------------
covergroup Cov_rvv_zve32x_vadd_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vadd.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000000, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vadd_vv

covergroup Cov_rvv_zve32x_vadd_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vadd.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000000, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vadd_vx

covergroup Cov_rvv_zve32x_vadd_vi with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vadd.vi";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000000, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vadd_vi

covergroup Cov_rvv_zve32x_vsub_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsub.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsub_vv

covergroup Cov_rvv_zve32x_vsub_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsub.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000010, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsub_vx

covergroup Cov_rvv_zve32x_vrsub_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vrsub.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000011, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vrsub_vx

covergroup Cov_rvv_zve32x_vrsub_vi with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vrsub.vi";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000011, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vrsub_vi

covergroup Cov_rvv_zve32x_vwaddu_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vwaddu.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b110000, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vwaddu_vv

covergroup Cov_rvv_zve32x_vwaddu_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vwaddu.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b110000, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vwaddu_vx

covergroup Cov_rvv_zve32x_vwsubu_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vwsubu.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b110010, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vwsubu_vv

covergroup Cov_rvv_zve32x_vwsubu_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vwsubu.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b110010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vwsubu_vx

covergroup Cov_rvv_zve32x_vwadd_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vwadd.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b110001, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vwadd_vv

covergroup Cov_rvv_zve32x_vwadd_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vwadd.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b110001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vwadd_vx

covergroup Cov_rvv_zve32x_vwsub_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vwsub.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b110011, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vwsub_vv

covergroup Cov_rvv_zve32x_vwsub_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vwsub.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b110011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vwsub_vx

covergroup Cov_rvv_zve32x_vwaddu_wv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vwaddu.wv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b110100, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vwaddu_wv

covergroup Cov_rvv_zve32x_vwaddu_wx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vwaddu.wx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b110100, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vwaddu_wx

covergroup Cov_rvv_zve32x_vwsubu_wv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vwsubu.wv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b110110, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vwsubu_wv

covergroup Cov_rvv_zve32x_vwsubu_wx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vwsubu.wx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b110110, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vwsubu_wx

covergroup Cov_rvv_zve32x_vwadd_wv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vwadd.wv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b110101, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vwadd_wv

covergroup Cov_rvv_zve32x_vwadd_wx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vwadd.wx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b110101, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vwadd_wx

covergroup Cov_rvv_zve32x_vwsub_wv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vwsub.wv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b110111, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vwsub_wv

covergroup Cov_rvv_zve32x_vwsub_wx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vwsub.wx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b110111, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vwsub_wx

covergroup Cov_rvv_zve32x_vzext_vf2 with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vzext.vf2";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010010, 1'b?, 5'b?????, 5'b00110, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vzext_vf2

covergroup Cov_rvv_zve32x_vsext_vf2 with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsext.vf2";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010010, 1'b?, 5'b?????, 5'b00111, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsext_vf2

covergroup Cov_rvv_zve32x_vzext_vf4 with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vzext.vf4";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010010, 1'b?, 5'b?????, 5'b00100, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vzext_vf4

covergroup Cov_rvv_zve32x_vsext_vf4 with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsext.vf4";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010010, 1'b?, 5'b?????, 5'b00101, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsext_vf4

covergroup Cov_rvv_zve32x_vadc_vvm with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vadc.vvm";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010000, 1'b0, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vadc_vvm

covergroup Cov_rvv_zve32x_vadc_vxm with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vadc.vxm";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010000, 1'b0, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vadc_vxm

covergroup Cov_rvv_zve32x_vadc_vim with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vadc.vim";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010000, 1'b0, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vadc_vim

covergroup Cov_rvv_zve32x_vmadc_vvm with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmadc.vvm";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010001, 1'b0, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmadc_vvm

covergroup Cov_rvv_zve32x_vmadc_vxm with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmadc.vxm";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010001, 1'b0, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmadc_vxm

covergroup Cov_rvv_zve32x_vmadc_vim with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmadc.vim";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010001, 1'b0, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmadc_vim

covergroup Cov_rvv_zve32x_vmadc_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmadc.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010001, 1'b1, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmadc_vv

covergroup Cov_rvv_zve32x_vmadc_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmadc.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010001, 1'b1, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmadc_vx

covergroup Cov_rvv_zve32x_vmadc_vi with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmadc.vi";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010001, 1'b1, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmadc_vi

covergroup Cov_rvv_zve32x_vsbc_vvm with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsbc.vvm";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010010, 1'b0, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsbc_vvm

covergroup Cov_rvv_zve32x_vsbc_vxm with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsbc.vxm";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010010, 1'b0, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsbc_vxm

covergroup Cov_rvv_zve32x_vmsbc_vvm with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmsbc.vvm";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010011, 1'b0, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmsbc_vvm

covergroup Cov_rvv_zve32x_vmsbc_vxm with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmsbc.vxm";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010011, 1'b0, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmsbc_vxm

covergroup Cov_rvv_zve32x_vmsbc_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmsbc.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010011, 1'b1, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmsbc_vv

covergroup Cov_rvv_zve32x_vmsbc_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmsbc.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010011, 1'b1, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmsbc_vx

covergroup Cov_rvv_zve32x_vand_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vand.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vand_vv

covergroup Cov_rvv_zve32x_vand_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vand.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001001, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vand_vx

covergroup Cov_rvv_zve32x_vand_vi with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vand.vi";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001001, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vand_vi

covergroup Cov_rvv_zve32x_vor_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vor.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vor_vv

covergroup Cov_rvv_zve32x_vor_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vor.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001010, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vor_vx

covergroup Cov_rvv_zve32x_vor_vi with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vor.vi";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001010, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vor_vi

covergroup Cov_rvv_zve32x_vxor_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vxor.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vxor_vv

covergroup Cov_rvv_zve32x_vxor_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vxor.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001011, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vxor_vx

covergroup Cov_rvv_zve32x_vxor_vi with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vxor.vi";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001011, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vxor_vi

covergroup Cov_rvv_zve32x_vsll_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsll.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100101, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsll_vv

covergroup Cov_rvv_zve32x_vsll_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsll.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100101, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsll_vx

covergroup Cov_rvv_zve32x_vsll_vi with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsll.vi";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100101, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsll_vi

covergroup Cov_rvv_zve32x_vsrl_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsrl.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101000, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsrl_vv

covergroup Cov_rvv_zve32x_vsrl_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsrl.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101000, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsrl_vx

covergroup Cov_rvv_zve32x_vsrl_vi with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsrl.vi";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101000, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsrl_vi

covergroup Cov_rvv_zve32x_vsra_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsra.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsra_vv

covergroup Cov_rvv_zve32x_vsra_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsra.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101001, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsra_vx

covergroup Cov_rvv_zve32x_vsra_vi with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsra.vi";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101001, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsra_vi

covergroup Cov_rvv_zve32x_vnsrl_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vnsrl.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101100, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vnsrl_vv

covergroup Cov_rvv_zve32x_vnsrl_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vnsrl.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101100, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vnsrl_vx

covergroup Cov_rvv_zve32x_vnsrl_vi with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vnsrl.vi";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101100, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vnsrl_vi

covergroup Cov_rvv_zve32x_vnsra_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vnsra.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101101, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vnsra_vv

covergroup Cov_rvv_zve32x_vnsra_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vnsra.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101101, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vnsra_vx

covergroup Cov_rvv_zve32x_vnsra_vi with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vnsra.vi";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101101, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vnsra_vi

covergroup Cov_rvv_zve32x_vmseq_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmseq.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011000, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmseq_vv

covergroup Cov_rvv_zve32x_vmseq_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmseq.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011000, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmseq_vx

covergroup Cov_rvv_zve32x_vmseq_vi with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmseq.vi";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011000, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmseq_vi

covergroup Cov_rvv_zve32x_vmsne_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmsne.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmsne_vv

covergroup Cov_rvv_zve32x_vmsne_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmsne.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011001, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmsne_vx

covergroup Cov_rvv_zve32x_vmsne_vi with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmsne.vi";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011001, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmsne_vi

covergroup Cov_rvv_zve32x_vmsltu_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmsltu.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmsltu_vv

covergroup Cov_rvv_zve32x_vmsltu_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmsltu.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011010, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmsltu_vx

covergroup Cov_rvv_zve32x_vmslt_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmslt.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmslt_vv

covergroup Cov_rvv_zve32x_vmslt_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmslt.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011011, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmslt_vx

covergroup Cov_rvv_zve32x_vmsleu_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmsleu.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011100, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmsleu_vv

covergroup Cov_rvv_zve32x_vmsleu_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmsleu.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011100, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmsleu_vx

covergroup Cov_rvv_zve32x_vmsleu_vi with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmsleu.vi";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011100, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmsleu_vi

covergroup Cov_rvv_zve32x_vmsle_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmsle.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011101, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmsle_vv

covergroup Cov_rvv_zve32x_vmsle_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmsle.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011101, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmsle_vx

covergroup Cov_rvv_zve32x_vmsle_vi with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmsle.vi";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011101, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmsle_vi

covergroup Cov_rvv_zve32x_vmsgtu_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmsgtu.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011110, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmsgtu_vx

covergroup Cov_rvv_zve32x_vmsgtu_vi with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmsgtu.vi";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011110, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmsgtu_vi

covergroup Cov_rvv_zve32x_vmsgt_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmsgt.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011111, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmsgt_vx

covergroup Cov_rvv_zve32x_vmsgt_vi with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmsgt.vi";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011111, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmsgt_vi

covergroup Cov_rvv_zve32x_vminu_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vminu.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000100, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vminu_vv

covergroup Cov_rvv_zve32x_vminu_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vminu.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000100, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vminu_vx

covergroup Cov_rvv_zve32x_vmin_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmin.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000101, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmin_vv

covergroup Cov_rvv_zve32x_vmin_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmin.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000101, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmin_vx

covergroup Cov_rvv_zve32x_vmaxu_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmaxu.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000110, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmaxu_vv

covergroup Cov_rvv_zve32x_vmaxu_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmaxu.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000110, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmaxu_vx

covergroup Cov_rvv_zve32x_vmax_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmax.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000111, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmax_vv

covergroup Cov_rvv_zve32x_vmax_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmax.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000111, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmax_vx

covergroup Cov_rvv_zve32x_vmul_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmul.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100101, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmul_vv

covergroup Cov_rvv_zve32x_vmul_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmul.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100101, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmul_vx

covergroup Cov_rvv_zve32x_vmulh_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmulh.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100111, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmulh_vv

covergroup Cov_rvv_zve32x_vmulh_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmulh.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100111, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmulh_vx

covergroup Cov_rvv_zve32x_vmulhu_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmulhu.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100100, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmulhu_vv

covergroup Cov_rvv_zve32x_vmulhu_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmulhu.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100100, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmulhu_vx

covergroup Cov_rvv_zve32x_vmulhsu_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmulhsu.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100110, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmulhsu_vv

covergroup Cov_rvv_zve32x_vmulhsu_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmulhsu.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100110, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmulhsu_vx

covergroup Cov_rvv_zve32x_vwmul_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vwmul.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b111011, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vwmul_vv

covergroup Cov_rvv_zve32x_vwmul_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vwmul.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b111011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vwmul_vx

covergroup Cov_rvv_zve32x_vwmulu_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vwmulu.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b111000, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vwmulu_vv

covergroup Cov_rvv_zve32x_vwmulu_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vwmulu.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b111000, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vwmulu_vx

covergroup Cov_rvv_zve32x_vwmulsu_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vwmulsu.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b111010, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vwmulsu_vv

covergroup Cov_rvv_zve32x_vwmulsu_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vwmulsu.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b111010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vwmulsu_vx

covergroup Cov_rvv_zve32x_vmacc_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmacc.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101101, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmacc_vv

covergroup Cov_rvv_zve32x_vmacc_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmacc.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101101, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmacc_vx

covergroup Cov_rvv_zve32x_vnmsac_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vnmsac.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101111, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vnmsac_vv

covergroup Cov_rvv_zve32x_vnmsac_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vnmsac.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101111, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vnmsac_vx

covergroup Cov_rvv_zve32x_vmadd_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmadd.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101001, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmadd_vv

covergroup Cov_rvv_zve32x_vmadd_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmadd.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmadd_vx

covergroup Cov_rvv_zve32x_vnmsub_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vnmsub.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101011, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vnmsub_vv

covergroup Cov_rvv_zve32x_vnmsub_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vnmsub.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vnmsub_vx

covergroup Cov_rvv_zve32x_vwmaccu_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vwmaccu.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b111100, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vwmaccu_vv

covergroup Cov_rvv_zve32x_vwmaccu_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vwmaccu.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b111100, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vwmaccu_vx

covergroup Cov_rvv_zve32x_vwmacc_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vwmacc.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b111101, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vwmacc_vv

covergroup Cov_rvv_zve32x_vwmacc_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vwmacc.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b111101, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vwmacc_vx

covergroup Cov_rvv_zve32x_vwmaccsu_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vwmaccsu.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b111111, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vwmaccsu_vv

covergroup Cov_rvv_zve32x_vwmaccsu_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vwmaccsu.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b111111, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vwmaccsu_vx

covergroup Cov_rvv_zve32x_vwmaccus_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vwmaccus.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b111110, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vwmaccus_vx

covergroup Cov_rvv_zve32x_vdivu_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vdivu.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100000, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vdivu_vv

covergroup Cov_rvv_zve32x_vdivu_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vdivu.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100000, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vdivu_vx

covergroup Cov_rvv_zve32x_vdiv_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vdiv.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100001, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vdiv_vv

covergroup Cov_rvv_zve32x_vdiv_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vdiv.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vdiv_vx

covergroup Cov_rvv_zve32x_vremu_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vremu.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100010, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vremu_vv

covergroup Cov_rvv_zve32x_vremu_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vremu.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vremu_vx

covergroup Cov_rvv_zve32x_vrem_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vrem.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100011, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vrem_vv

covergroup Cov_rvv_zve32x_vrem_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vrem.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vrem_vx

covergroup Cov_rvv_zve32x_vmerge_vvm with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmerge.vvm";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010111, 1'b0, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmerge_vvm

covergroup Cov_rvv_zve32x_vmerge_vxm with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmerge.vxm";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010111, 1'b0, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmerge_vxm

covergroup Cov_rvv_zve32x_vmerge_vim with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmerge.vim";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010111, 1'b0, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmerge_vim

covergroup Cov_rvv_zve32x_vmv_v_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmv.v.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010111, 1'b1, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmv_v_v

covergroup Cov_rvv_zve32x_vmv_v_x with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmv.v.x";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010111, 1'b1, 5'b00000, 5'b?????, 3'b100, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmv_v_x

covergroup Cov_rvv_zve32x_vmv_v_i with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmv.v.i";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010111, 1'b1, 5'b00000, 5'b?????, 3'b011, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmv_v_i

covergroup Cov_rvv_zve32x_vsaddu_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsaddu.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100000, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsaddu_vv

covergroup Cov_rvv_zve32x_vsaddu_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsaddu.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100000, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsaddu_vx

covergroup Cov_rvv_zve32x_vsaddu_vi with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsaddu.vi";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100000, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsaddu_vi

covergroup Cov_rvv_zve32x_vsadd_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsadd.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsadd_vv

covergroup Cov_rvv_zve32x_vsadd_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsadd.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100001, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsadd_vx

covergroup Cov_rvv_zve32x_vsadd_vi with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsadd.vi";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100001, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsadd_vi

covergroup Cov_rvv_zve32x_vssubu_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vssubu.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vssubu_vv

covergroup Cov_rvv_zve32x_vssubu_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vssubu.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100010, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vssubu_vx

covergroup Cov_rvv_zve32x_vssub_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vssub.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vssub_vv

covergroup Cov_rvv_zve32x_vssub_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vssub.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100011, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vssub_vx

covergroup Cov_rvv_zve32x_vaaddu_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vaaddu.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001000, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vaaddu_vv

covergroup Cov_rvv_zve32x_vaaddu_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vaaddu.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001000, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vaaddu_vx

covergroup Cov_rvv_zve32x_vaadd_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vaadd.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001001, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vaadd_vv

covergroup Cov_rvv_zve32x_vaadd_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vaadd.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vaadd_vx

covergroup Cov_rvv_zve32x_vasubu_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vasubu.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001010, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vasubu_vv

covergroup Cov_rvv_zve32x_vasubu_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vasubu.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vasubu_vx

covergroup Cov_rvv_zve32x_vasub_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vasub.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001011, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vasub_vv

covergroup Cov_rvv_zve32x_vasub_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vasub.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vasub_vx

covergroup Cov_rvv_zve32x_vsmul_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsmul.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100111, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsmul_vv

covergroup Cov_rvv_zve32x_vsmul_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsmul.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100111, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsmul_vx

covergroup Cov_rvv_zve32x_vssrl_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vssrl.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vssrl_vv

covergroup Cov_rvv_zve32x_vssrl_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vssrl.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101010, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vssrl_vx

covergroup Cov_rvv_zve32x_vssrl_vi with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vssrl.vi";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101010, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vssrl_vi

covergroup Cov_rvv_zve32x_vssra_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vssra.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vssra_vv

covergroup Cov_rvv_zve32x_vssra_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vssra.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101011, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vssra_vx

covergroup Cov_rvv_zve32x_vssra_vi with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vssra.vi";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101011, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vssra_vi

covergroup Cov_rvv_zve32x_vnclipu_wv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vnclipu.wv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101110, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vnclipu_wv

covergroup Cov_rvv_zve32x_vnclipu_wx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vnclipu.wx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101110, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vnclipu_wx

covergroup Cov_rvv_zve32x_vnclipu_wi with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vnclipu.wi";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101110, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vnclipu_wi

covergroup Cov_rvv_zve32x_vnclip_wv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vnclip.wv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101111, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vnclip_wv

covergroup Cov_rvv_zve32x_vnclip_wx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vnclip.wx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101111, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vnclip_wx

covergroup Cov_rvv_zve32x_vnclip_wi with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vnclip.wi";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101111, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vnclip_wi

covergroup Cov_rvv_zve32x_vredsum_vs with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vredsum.vs";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000000, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vredsum_vs

covergroup Cov_rvv_zve32x_vredmaxu_vs with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vredmaxu.vs";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000110, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vredmaxu_vs

covergroup Cov_rvv_zve32x_vredmax_vs with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vredmax.vs";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000111, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vredmax_vs

covergroup Cov_rvv_zve32x_vredminu_vs with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vredminu.vs";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000100, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vredminu_vs

covergroup Cov_rvv_zve32x_vredmin_vs with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vredmin.vs";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000101, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vredmin_vs

covergroup Cov_rvv_zve32x_vredand_vs with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vredand.vs";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000001, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vredand_vs

covergroup Cov_rvv_zve32x_vredor_vs with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vredor.vs";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000010, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vredor_vs

covergroup Cov_rvv_zve32x_vredxor_vs with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vredxor.vs";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000011, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vredxor_vs

covergroup Cov_rvv_zve32x_vwredsumu_vs with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vwredsumu.vs";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b110000, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vwredsumu_vs

covergroup Cov_rvv_zve32x_vwredsum_vs with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vwredsum.vs";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b110001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vwredsum_vs

covergroup Cov_rvv_zve32x_vmand_mm with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmand.mm";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011001, 1'b1, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmand_mm

covergroup Cov_rvv_zve32x_vmnand_mm with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmnand.mm";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011101, 1'b1, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmnand_mm

covergroup Cov_rvv_zve32x_vmandn_mm with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmandn.mm";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011000, 1'b1, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmandn_mm

covergroup Cov_rvv_zve32x_vmxor_mm with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmxor.mm";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011011, 1'b1, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmxor_mm

covergroup Cov_rvv_zve32x_vmor_mm with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmor.mm";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011010, 1'b1, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmor_mm

covergroup Cov_rvv_zve32x_vmnor_mm with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmnor.mm";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011110, 1'b1, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmnor_mm

covergroup Cov_rvv_zve32x_vmorn_mm with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmorn.mm";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011100, 1'b1, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmorn_mm

covergroup Cov_rvv_zve32x_vmxnor_mm with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmxnor.mm";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011111, 1'b1, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmxnor_mm

covergroup Cov_rvv_zve32x_vcpop_m with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vcpop.m";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010000, 1'b?, 5'b?????, 5'b10000, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vcpop_m

covergroup Cov_rvv_zve32x_vfirst_m with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vfirst.m";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010000, 1'b?, 5'b?????, 5'b10001, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vfirst_m

covergroup Cov_rvv_zve32x_vmsbf_m with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmsbf.m";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010100, 1'b?, 5'b?????, 5'b00001, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmsbf_m

covergroup Cov_rvv_zve32x_vmsif_m with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmsif.m";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010100, 1'b?, 5'b?????, 5'b00011, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmsif_m

covergroup Cov_rvv_zve32x_vmsof_m with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmsof.m";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010100, 1'b?, 5'b?????, 5'b00010, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmsof_m

covergroup Cov_rvv_zve32x_viota_m with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "viota.m";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010100, 1'b?, 5'b?????, 5'b10000, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_viota_m

covergroup Cov_rvv_zve32x_vid_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vid.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010100, 1'b?, 5'b00000, 5'b10001, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vid_v

covergroup Cov_rvv_zve32x_vmv_x_s with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmv.x.s";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010000, 1'b1, 5'b?????, 5'b00000, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmv_x_s

covergroup Cov_rvv_zve32x_vmv_s_x with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmv.s.x";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010000, 1'b1, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmv_s_x

covergroup Cov_rvv_zve32x_vslideup_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vslideup.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001110, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vslideup_vx

covergroup Cov_rvv_zve32x_vslideup_vi with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vslideup.vi";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001110, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vslideup_vi

covergroup Cov_rvv_zve32x_vslidedown_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vslidedown.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001111, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vslidedown_vx

covergroup Cov_rvv_zve32x_vslidedown_vi with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vslidedown.vi";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001111, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vslidedown_vi

covergroup Cov_rvv_zve32x_vslide1up_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vslide1up.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001110, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vslide1up_vx

covergroup Cov_rvv_zve32x_vslide1down_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vslide1down.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001111, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vslide1down_vx

covergroup Cov_rvv_zve32x_vrgather_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vrgather.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001100, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vrgather_vv

covergroup Cov_rvv_zve32x_vrgatherei16_vv with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vrgatherei16.vv";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001110, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vrgatherei16_vv

covergroup Cov_rvv_zve32x_vrgather_vx with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vrgather.vx";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001100, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vrgather_vx

covergroup Cov_rvv_zve32x_vrgather_vi with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vrgather.vi";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001100, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vrgather_vi

covergroup Cov_rvv_zve32x_vcompress_vm with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vcompress.vm";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010111, 1'b1, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vcompress_vm

covergroup Cov_rvv_zve32x_vmv1r_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmv1r.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100111, 1'b1, 5'b?????, 5'b00000, 3'b011, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmv1r_v

covergroup Cov_rvv_zve32x_vmv2r_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmv2r.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100111, 1'b1, 5'b?????, 5'b00001, 3'b011, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmv2r_v

covergroup Cov_rvv_zve32x_vmv4r_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmv4r.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100111, 1'b1, 5'b?????, 5'b00011, 3'b011, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmv4r_v

covergroup Cov_rvv_zve32x_vmv8r_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vmv8r.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100111, 1'b1, 5'b?????, 5'b00111, 3'b011, 5'b?????, 7'b1010111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vmv8r_v

covergroup Cov_rvv_zve32x_vle8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vle8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vle8_v

covergroup Cov_rvv_zve32x_vle16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vle16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vle16_v

covergroup Cov_rvv_zve32x_vle32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vle32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vle32_v

covergroup Cov_rvv_zve32x_vse8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vse8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vse8_v

covergroup Cov_rvv_zve32x_vse16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vse16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vse16_v

covergroup Cov_rvv_zve32x_vse32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vse32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vse32_v

covergroup Cov_rvv_zve32x_vlm_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlm.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000000, 1'b1, 5'b01011, 5'b?????, 3'b000, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlm_v

covergroup Cov_rvv_zve32x_vsm_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsm.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000000, 1'b1, 5'b01011, 5'b?????, 3'b000, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsm_v

covergroup Cov_rvv_zve32x_vlse8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlse8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlse8_v

covergroup Cov_rvv_zve32x_vlse16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlse16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlse16_v

covergroup Cov_rvv_zve32x_vlse32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlse32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlse32_v

covergroup Cov_rvv_zve32x_vsse8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsse8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsse8_v

covergroup Cov_rvv_zve32x_vsse16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsse16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsse16_v

covergroup Cov_rvv_zve32x_vsse32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsse32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsse32_v

covergroup Cov_rvv_zve32x_vluxei8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vluxei8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vluxei8_v

covergroup Cov_rvv_zve32x_vluxei16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vluxei16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vluxei16_v

covergroup Cov_rvv_zve32x_vluxei32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vluxei32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vluxei32_v

covergroup Cov_rvv_zve32x_vloxei8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vloxei8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vloxei8_v

covergroup Cov_rvv_zve32x_vloxei16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vloxei16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vloxei16_v

covergroup Cov_rvv_zve32x_vloxei32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vloxei32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vloxei32_v

covergroup Cov_rvv_zve32x_vsuxei8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsuxei8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsuxei8_v

covergroup Cov_rvv_zve32x_vsuxei16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsuxei16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsuxei16_v

covergroup Cov_rvv_zve32x_vsuxei32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsuxei32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsuxei32_v

covergroup Cov_rvv_zve32x_vsoxei8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsoxei8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsoxei8_v

covergroup Cov_rvv_zve32x_vsoxei16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsoxei16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsoxei16_v

covergroup Cov_rvv_zve32x_vsoxei32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsoxei32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsoxei32_v

covergroup Cov_rvv_zve32x_vle8ff_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vle8ff.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000000, 1'b?, 5'b10000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vle8ff_v

covergroup Cov_rvv_zve32x_vle16ff_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vle16ff.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000000, 1'b?, 5'b10000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vle16ff_v

covergroup Cov_rvv_zve32x_vle32ff_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vle32ff.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000000, 1'b?, 5'b10000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vle32ff_v

covergroup Cov_rvv_zve32x_vlseg2e8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlseg2e8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlseg2e8_v

covergroup Cov_rvv_zve32x_vlseg3e8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlseg3e8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlseg3e8_v

covergroup Cov_rvv_zve32x_vlseg4e8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlseg4e8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlseg4e8_v

covergroup Cov_rvv_zve32x_vlseg5e8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlseg5e8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlseg5e8_v

covergroup Cov_rvv_zve32x_vlseg6e8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlseg6e8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlseg6e8_v

covergroup Cov_rvv_zve32x_vlseg7e8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlseg7e8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b110000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlseg7e8_v

covergroup Cov_rvv_zve32x_vlseg8e8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlseg8e8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b111000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlseg8e8_v

covergroup Cov_rvv_zve32x_vlseg2e16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlseg2e16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlseg2e16_v

covergroup Cov_rvv_zve32x_vlseg3e16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlseg3e16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlseg3e16_v

covergroup Cov_rvv_zve32x_vlseg4e16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlseg4e16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlseg4e16_v

covergroup Cov_rvv_zve32x_vlseg5e16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlseg5e16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlseg5e16_v

covergroup Cov_rvv_zve32x_vlseg6e16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlseg6e16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlseg6e16_v

covergroup Cov_rvv_zve32x_vlseg7e16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlseg7e16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b110000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlseg7e16_v

covergroup Cov_rvv_zve32x_vlseg8e16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlseg8e16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b111000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlseg8e16_v

covergroup Cov_rvv_zve32x_vlseg2e32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlseg2e32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlseg2e32_v

covergroup Cov_rvv_zve32x_vlseg3e32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlseg3e32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlseg3e32_v

covergroup Cov_rvv_zve32x_vlseg4e32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlseg4e32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlseg4e32_v

covergroup Cov_rvv_zve32x_vlseg5e32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlseg5e32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlseg5e32_v

covergroup Cov_rvv_zve32x_vlseg6e32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlseg6e32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlseg6e32_v

covergroup Cov_rvv_zve32x_vlseg7e32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlseg7e32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b110000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlseg7e32_v

covergroup Cov_rvv_zve32x_vlseg8e32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlseg8e32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b111000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlseg8e32_v

covergroup Cov_rvv_zve32x_vsseg2e8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsseg2e8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsseg2e8_v

covergroup Cov_rvv_zve32x_vsseg3e8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsseg3e8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsseg3e8_v

covergroup Cov_rvv_zve32x_vsseg4e8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsseg4e8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsseg4e8_v

covergroup Cov_rvv_zve32x_vsseg5e8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsseg5e8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsseg5e8_v

covergroup Cov_rvv_zve32x_vsseg6e8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsseg6e8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsseg6e8_v

covergroup Cov_rvv_zve32x_vsseg7e8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsseg7e8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b110000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsseg7e8_v

covergroup Cov_rvv_zve32x_vsseg8e8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsseg8e8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b111000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsseg8e8_v

covergroup Cov_rvv_zve32x_vsseg2e16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsseg2e16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsseg2e16_v

covergroup Cov_rvv_zve32x_vsseg3e16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsseg3e16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsseg3e16_v

covergroup Cov_rvv_zve32x_vsseg4e16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsseg4e16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsseg4e16_v

covergroup Cov_rvv_zve32x_vsseg5e16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsseg5e16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsseg5e16_v

covergroup Cov_rvv_zve32x_vsseg6e16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsseg6e16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsseg6e16_v

covergroup Cov_rvv_zve32x_vsseg7e16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsseg7e16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b110000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsseg7e16_v

covergroup Cov_rvv_zve32x_vsseg8e16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsseg8e16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b111000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsseg8e16_v

covergroup Cov_rvv_zve32x_vsseg2e32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsseg2e32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsseg2e32_v

covergroup Cov_rvv_zve32x_vsseg3e32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsseg3e32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsseg3e32_v

covergroup Cov_rvv_zve32x_vsseg4e32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsseg4e32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsseg4e32_v

covergroup Cov_rvv_zve32x_vsseg5e32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsseg5e32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsseg5e32_v

covergroup Cov_rvv_zve32x_vsseg6e32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsseg6e32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsseg6e32_v

covergroup Cov_rvv_zve32x_vsseg7e32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsseg7e32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b110000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsseg7e32_v

covergroup Cov_rvv_zve32x_vsseg8e32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsseg8e32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b111000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsseg8e32_v

covergroup Cov_rvv_zve32x_vlseg2e8ff_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlseg2e8ff.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001000, 1'b?, 5'b10000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlseg2e8ff_v

covergroup Cov_rvv_zve32x_vlseg3e8ff_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlseg3e8ff.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010000, 1'b?, 5'b10000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlseg3e8ff_v

covergroup Cov_rvv_zve32x_vlseg4e8ff_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlseg4e8ff.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011000, 1'b?, 5'b10000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlseg4e8ff_v

covergroup Cov_rvv_zve32x_vlseg5e8ff_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlseg5e8ff.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100000, 1'b?, 5'b10000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlseg5e8ff_v

covergroup Cov_rvv_zve32x_vlseg6e8ff_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlseg6e8ff.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101000, 1'b?, 5'b10000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlseg6e8ff_v

covergroup Cov_rvv_zve32x_vlseg7e8ff_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlseg7e8ff.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b110000, 1'b?, 5'b10000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlseg7e8ff_v

covergroup Cov_rvv_zve32x_vlseg8e8ff_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlseg8e8ff.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b111000, 1'b?, 5'b10000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlseg8e8ff_v

covergroup Cov_rvv_zve32x_vlseg2e16ff_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlseg2e16ff.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001000, 1'b?, 5'b10000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlseg2e16ff_v

covergroup Cov_rvv_zve32x_vlseg3e16ff_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlseg3e16ff.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010000, 1'b?, 5'b10000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlseg3e16ff_v

covergroup Cov_rvv_zve32x_vlseg4e16ff_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlseg4e16ff.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011000, 1'b?, 5'b10000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlseg4e16ff_v

covergroup Cov_rvv_zve32x_vlseg5e16ff_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlseg5e16ff.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100000, 1'b?, 5'b10000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlseg5e16ff_v

covergroup Cov_rvv_zve32x_vlseg6e16ff_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlseg6e16ff.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101000, 1'b?, 5'b10000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlseg6e16ff_v

covergroup Cov_rvv_zve32x_vlseg7e16ff_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlseg7e16ff.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b110000, 1'b?, 5'b10000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlseg7e16ff_v

covergroup Cov_rvv_zve32x_vlseg8e16ff_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlseg8e16ff.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b111000, 1'b?, 5'b10000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlseg8e16ff_v

covergroup Cov_rvv_zve32x_vlseg2e32ff_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlseg2e32ff.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001000, 1'b?, 5'b10000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlseg2e32ff_v

covergroup Cov_rvv_zve32x_vlseg3e32ff_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlseg3e32ff.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010000, 1'b?, 5'b10000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlseg3e32ff_v

covergroup Cov_rvv_zve32x_vlseg4e32ff_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlseg4e32ff.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011000, 1'b?, 5'b10000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlseg4e32ff_v

covergroup Cov_rvv_zve32x_vlseg5e32ff_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlseg5e32ff.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100000, 1'b?, 5'b10000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlseg5e32ff_v

covergroup Cov_rvv_zve32x_vlseg6e32ff_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlseg6e32ff.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101000, 1'b?, 5'b10000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlseg6e32ff_v

covergroup Cov_rvv_zve32x_vlseg7e32ff_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlseg7e32ff.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b110000, 1'b?, 5'b10000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlseg7e32ff_v

covergroup Cov_rvv_zve32x_vlseg8e32ff_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlseg8e32ff.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b111000, 1'b?, 5'b10000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlseg8e32ff_v

covergroup Cov_rvv_zve32x_vlsseg2e8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlsseg2e8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlsseg2e8_v

covergroup Cov_rvv_zve32x_vlsseg3e8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlsseg3e8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlsseg3e8_v

covergroup Cov_rvv_zve32x_vlsseg4e8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlsseg4e8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlsseg4e8_v

covergroup Cov_rvv_zve32x_vlsseg5e8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlsseg5e8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlsseg5e8_v

covergroup Cov_rvv_zve32x_vlsseg6e8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlsseg6e8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlsseg6e8_v

covergroup Cov_rvv_zve32x_vlsseg7e8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlsseg7e8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b110010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlsseg7e8_v

covergroup Cov_rvv_zve32x_vlsseg8e8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlsseg8e8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b111010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlsseg8e8_v

covergroup Cov_rvv_zve32x_vlsseg2e16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlsseg2e16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlsseg2e16_v

covergroup Cov_rvv_zve32x_vlsseg3e16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlsseg3e16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlsseg3e16_v

covergroup Cov_rvv_zve32x_vlsseg4e16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlsseg4e16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlsseg4e16_v

covergroup Cov_rvv_zve32x_vlsseg5e16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlsseg5e16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlsseg5e16_v

covergroup Cov_rvv_zve32x_vlsseg6e16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlsseg6e16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlsseg6e16_v

covergroup Cov_rvv_zve32x_vlsseg7e16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlsseg7e16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b110010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlsseg7e16_v

covergroup Cov_rvv_zve32x_vlsseg8e16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlsseg8e16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b111010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlsseg8e16_v

covergroup Cov_rvv_zve32x_vlsseg2e32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlsseg2e32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlsseg2e32_v

covergroup Cov_rvv_zve32x_vlsseg3e32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlsseg3e32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlsseg3e32_v

covergroup Cov_rvv_zve32x_vlsseg4e32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlsseg4e32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlsseg4e32_v

covergroup Cov_rvv_zve32x_vlsseg5e32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlsseg5e32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlsseg5e32_v

covergroup Cov_rvv_zve32x_vlsseg6e32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlsseg6e32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlsseg6e32_v

covergroup Cov_rvv_zve32x_vlsseg7e32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlsseg7e32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b110010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlsseg7e32_v

covergroup Cov_rvv_zve32x_vlsseg8e32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vlsseg8e32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b111010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vlsseg8e32_v

covergroup Cov_rvv_zve32x_vssseg2e8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vssseg2e8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vssseg2e8_v

covergroup Cov_rvv_zve32x_vssseg3e8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vssseg3e8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vssseg3e8_v

covergroup Cov_rvv_zve32x_vssseg4e8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vssseg4e8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vssseg4e8_v

covergroup Cov_rvv_zve32x_vssseg5e8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vssseg5e8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vssseg5e8_v

covergroup Cov_rvv_zve32x_vssseg6e8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vssseg6e8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vssseg6e8_v

covergroup Cov_rvv_zve32x_vssseg7e8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vssseg7e8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b110010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vssseg7e8_v

covergroup Cov_rvv_zve32x_vssseg8e8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vssseg8e8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b111010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vssseg8e8_v

covergroup Cov_rvv_zve32x_vssseg2e16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vssseg2e16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vssseg2e16_v

covergroup Cov_rvv_zve32x_vssseg3e16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vssseg3e16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vssseg3e16_v

covergroup Cov_rvv_zve32x_vssseg4e16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vssseg4e16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vssseg4e16_v

covergroup Cov_rvv_zve32x_vssseg5e16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vssseg5e16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vssseg5e16_v

covergroup Cov_rvv_zve32x_vssseg6e16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vssseg6e16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vssseg6e16_v

covergroup Cov_rvv_zve32x_vssseg7e16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vssseg7e16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b110010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vssseg7e16_v

covergroup Cov_rvv_zve32x_vssseg8e16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vssseg8e16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b111010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vssseg8e16_v

covergroup Cov_rvv_zve32x_vssseg2e32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vssseg2e32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vssseg2e32_v

covergroup Cov_rvv_zve32x_vssseg3e32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vssseg3e32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vssseg3e32_v

covergroup Cov_rvv_zve32x_vssseg4e32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vssseg4e32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vssseg4e32_v

covergroup Cov_rvv_zve32x_vssseg5e32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vssseg5e32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vssseg5e32_v

covergroup Cov_rvv_zve32x_vssseg6e32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vssseg6e32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vssseg6e32_v

covergroup Cov_rvv_zve32x_vssseg7e32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vssseg7e32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b110010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vssseg7e32_v

covergroup Cov_rvv_zve32x_vssseg8e32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vssseg8e32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b111010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vssseg8e32_v

covergroup Cov_rvv_zve32x_vluxseg2ei8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vluxseg2ei8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vluxseg2ei8_v

covergroup Cov_rvv_zve32x_vluxseg3ei8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vluxseg3ei8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vluxseg3ei8_v

covergroup Cov_rvv_zve32x_vluxseg4ei8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vluxseg4ei8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vluxseg4ei8_v

covergroup Cov_rvv_zve32x_vluxseg5ei8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vluxseg5ei8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vluxseg5ei8_v

covergroup Cov_rvv_zve32x_vluxseg6ei8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vluxseg6ei8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vluxseg6ei8_v

covergroup Cov_rvv_zve32x_vluxseg7ei8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vluxseg7ei8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b110001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vluxseg7ei8_v

covergroup Cov_rvv_zve32x_vluxseg8ei8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vluxseg8ei8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b111001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vluxseg8ei8_v

covergroup Cov_rvv_zve32x_vluxseg2ei16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vluxseg2ei16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vluxseg2ei16_v

covergroup Cov_rvv_zve32x_vluxseg3ei16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vluxseg3ei16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vluxseg3ei16_v

covergroup Cov_rvv_zve32x_vluxseg4ei16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vluxseg4ei16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vluxseg4ei16_v

covergroup Cov_rvv_zve32x_vluxseg5ei16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vluxseg5ei16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vluxseg5ei16_v

covergroup Cov_rvv_zve32x_vluxseg6ei16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vluxseg6ei16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vluxseg6ei16_v

covergroup Cov_rvv_zve32x_vluxseg7ei16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vluxseg7ei16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b110001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vluxseg7ei16_v

covergroup Cov_rvv_zve32x_vluxseg8ei16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vluxseg8ei16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b111001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vluxseg8ei16_v

covergroup Cov_rvv_zve32x_vluxseg2ei32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vluxseg2ei32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vluxseg2ei32_v

covergroup Cov_rvv_zve32x_vluxseg3ei32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vluxseg3ei32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vluxseg3ei32_v

covergroup Cov_rvv_zve32x_vluxseg4ei32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vluxseg4ei32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vluxseg4ei32_v

covergroup Cov_rvv_zve32x_vluxseg5ei32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vluxseg5ei32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vluxseg5ei32_v

covergroup Cov_rvv_zve32x_vluxseg6ei32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vluxseg6ei32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vluxseg6ei32_v

covergroup Cov_rvv_zve32x_vluxseg7ei32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vluxseg7ei32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b110001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vluxseg7ei32_v

covergroup Cov_rvv_zve32x_vluxseg8ei32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vluxseg8ei32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b111001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vluxseg8ei32_v

covergroup Cov_rvv_zve32x_vloxseg2ei8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vloxseg2ei8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vloxseg2ei8_v

covergroup Cov_rvv_zve32x_vloxseg3ei8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vloxseg3ei8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vloxseg3ei8_v

covergroup Cov_rvv_zve32x_vloxseg4ei8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vloxseg4ei8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vloxseg4ei8_v

covergroup Cov_rvv_zve32x_vloxseg5ei8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vloxseg5ei8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vloxseg5ei8_v

covergroup Cov_rvv_zve32x_vloxseg6ei8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vloxseg6ei8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vloxseg6ei8_v

covergroup Cov_rvv_zve32x_vloxseg7ei8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vloxseg7ei8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b110011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vloxseg7ei8_v

covergroup Cov_rvv_zve32x_vloxseg8ei8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vloxseg8ei8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b111011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vloxseg8ei8_v

covergroup Cov_rvv_zve32x_vloxseg2ei16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vloxseg2ei16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vloxseg2ei16_v

covergroup Cov_rvv_zve32x_vloxseg3ei16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vloxseg3ei16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vloxseg3ei16_v

covergroup Cov_rvv_zve32x_vloxseg4ei16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vloxseg4ei16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vloxseg4ei16_v

covergroup Cov_rvv_zve32x_vloxseg5ei16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vloxseg5ei16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vloxseg5ei16_v

covergroup Cov_rvv_zve32x_vloxseg6ei16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vloxseg6ei16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vloxseg6ei16_v

covergroup Cov_rvv_zve32x_vloxseg7ei16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vloxseg7ei16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b110011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vloxseg7ei16_v

covergroup Cov_rvv_zve32x_vloxseg8ei16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vloxseg8ei16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b111011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vloxseg8ei16_v

covergroup Cov_rvv_zve32x_vloxseg2ei32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vloxseg2ei32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vloxseg2ei32_v

covergroup Cov_rvv_zve32x_vloxseg3ei32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vloxseg3ei32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vloxseg3ei32_v

covergroup Cov_rvv_zve32x_vloxseg4ei32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vloxseg4ei32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vloxseg4ei32_v

covergroup Cov_rvv_zve32x_vloxseg5ei32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vloxseg5ei32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vloxseg5ei32_v

covergroup Cov_rvv_zve32x_vloxseg6ei32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vloxseg6ei32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vloxseg6ei32_v

covergroup Cov_rvv_zve32x_vloxseg7ei32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vloxseg7ei32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b110011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vloxseg7ei32_v

covergroup Cov_rvv_zve32x_vloxseg8ei32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vloxseg8ei32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b111011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vloxseg8ei32_v

covergroup Cov_rvv_zve32x_vsuxseg2ei8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsuxseg2ei8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsuxseg2ei8_v

covergroup Cov_rvv_zve32x_vsuxseg3ei8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsuxseg3ei8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsuxseg3ei8_v

covergroup Cov_rvv_zve32x_vsuxseg4ei8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsuxseg4ei8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsuxseg4ei8_v

covergroup Cov_rvv_zve32x_vsuxseg5ei8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsuxseg5ei8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsuxseg5ei8_v

covergroup Cov_rvv_zve32x_vsuxseg6ei8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsuxseg6ei8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsuxseg6ei8_v

covergroup Cov_rvv_zve32x_vsuxseg7ei8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsuxseg7ei8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b110001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsuxseg7ei8_v

covergroup Cov_rvv_zve32x_vsuxseg8ei8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsuxseg8ei8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b111001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsuxseg8ei8_v

covergroup Cov_rvv_zve32x_vsuxseg2ei16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsuxseg2ei16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsuxseg2ei16_v

covergroup Cov_rvv_zve32x_vsuxseg3ei16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsuxseg3ei16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsuxseg3ei16_v

covergroup Cov_rvv_zve32x_vsuxseg4ei16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsuxseg4ei16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsuxseg4ei16_v

covergroup Cov_rvv_zve32x_vsuxseg5ei16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsuxseg5ei16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsuxseg5ei16_v

covergroup Cov_rvv_zve32x_vsuxseg6ei16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsuxseg6ei16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsuxseg6ei16_v

covergroup Cov_rvv_zve32x_vsuxseg7ei16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsuxseg7ei16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b110001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsuxseg7ei16_v

covergroup Cov_rvv_zve32x_vsuxseg8ei16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsuxseg8ei16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b111001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsuxseg8ei16_v

covergroup Cov_rvv_zve32x_vsuxseg2ei32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsuxseg2ei32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsuxseg2ei32_v

covergroup Cov_rvv_zve32x_vsuxseg3ei32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsuxseg3ei32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsuxseg3ei32_v

covergroup Cov_rvv_zve32x_vsuxseg4ei32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsuxseg4ei32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsuxseg4ei32_v

covergroup Cov_rvv_zve32x_vsuxseg5ei32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsuxseg5ei32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsuxseg5ei32_v

covergroup Cov_rvv_zve32x_vsuxseg6ei32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsuxseg6ei32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsuxseg6ei32_v

covergroup Cov_rvv_zve32x_vsuxseg7ei32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsuxseg7ei32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b110001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsuxseg7ei32_v

covergroup Cov_rvv_zve32x_vsuxseg8ei32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsuxseg8ei32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b111001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsuxseg8ei32_v

covergroup Cov_rvv_zve32x_vsoxseg2ei8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsoxseg2ei8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsoxseg2ei8_v

covergroup Cov_rvv_zve32x_vsoxseg3ei8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsoxseg3ei8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsoxseg3ei8_v

covergroup Cov_rvv_zve32x_vsoxseg4ei8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsoxseg4ei8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsoxseg4ei8_v

covergroup Cov_rvv_zve32x_vsoxseg5ei8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsoxseg5ei8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsoxseg5ei8_v

covergroup Cov_rvv_zve32x_vsoxseg6ei8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsoxseg6ei8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsoxseg6ei8_v

covergroup Cov_rvv_zve32x_vsoxseg7ei8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsoxseg7ei8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b110011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsoxseg7ei8_v

covergroup Cov_rvv_zve32x_vsoxseg8ei8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsoxseg8ei8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b111011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsoxseg8ei8_v

covergroup Cov_rvv_zve32x_vsoxseg2ei16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsoxseg2ei16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsoxseg2ei16_v

covergroup Cov_rvv_zve32x_vsoxseg3ei16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsoxseg3ei16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsoxseg3ei16_v

covergroup Cov_rvv_zve32x_vsoxseg4ei16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsoxseg4ei16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsoxseg4ei16_v

covergroup Cov_rvv_zve32x_vsoxseg5ei16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsoxseg5ei16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsoxseg5ei16_v

covergroup Cov_rvv_zve32x_vsoxseg6ei16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsoxseg6ei16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsoxseg6ei16_v

covergroup Cov_rvv_zve32x_vsoxseg7ei16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsoxseg7ei16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b110011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsoxseg7ei16_v

covergroup Cov_rvv_zve32x_vsoxseg8ei16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsoxseg8ei16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b111011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsoxseg8ei16_v

covergroup Cov_rvv_zve32x_vsoxseg2ei32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsoxseg2ei32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsoxseg2ei32_v

covergroup Cov_rvv_zve32x_vsoxseg3ei32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsoxseg3ei32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b010011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsoxseg3ei32_v

covergroup Cov_rvv_zve32x_vsoxseg4ei32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsoxseg4ei32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsoxseg4ei32_v

covergroup Cov_rvv_zve32x_vsoxseg5ei32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsoxseg5ei32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b100011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsoxseg5ei32_v

covergroup Cov_rvv_zve32x_vsoxseg6ei32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsoxseg6ei32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b101011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsoxseg6ei32_v

covergroup Cov_rvv_zve32x_vsoxseg7ei32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsoxseg7ei32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b110011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsoxseg7ei32_v

covergroup Cov_rvv_zve32x_vsoxseg8ei32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vsoxseg8ei32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b111011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_0 = {0};
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vsoxseg8ei32_v

covergroup Cov_rvv_zve32x_vl1re8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vl1re8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000000, 1'b1, 5'b01000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vl1re8_v

covergroup Cov_rvv_zve32x_vl2re8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vl2re8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001000, 1'b1, 5'b01000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vl2re8_v

covergroup Cov_rvv_zve32x_vl4re8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vl4re8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011000, 1'b1, 5'b01000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vl4re8_v

covergroup Cov_rvv_zve32x_vl8re8_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vl8re8.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b111000, 1'b1, 5'b01000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vl8re8_v

covergroup Cov_rvv_zve32x_vl1re16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vl1re16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000000, 1'b1, 5'b01000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vl1re16_v

covergroup Cov_rvv_zve32x_vl2re16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vl2re16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001000, 1'b1, 5'b01000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vl2re16_v

covergroup Cov_rvv_zve32x_vl4re16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vl4re16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011000, 1'b1, 5'b01000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vl4re16_v

covergroup Cov_rvv_zve32x_vl8re16_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vl8re16.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b111000, 1'b1, 5'b01000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vl8re16_v

covergroup Cov_rvv_zve32x_vl1re32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vl1re32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000000, 1'b1, 5'b01000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vl1re32_v

covergroup Cov_rvv_zve32x_vl2re32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vl2re32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001000, 1'b1, 5'b01000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vl2re32_v

covergroup Cov_rvv_zve32x_vl4re32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vl4re32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011000, 1'b1, 5'b01000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vl4re32_v

covergroup Cov_rvv_zve32x_vl8re32_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vl8re32.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b111000, 1'b1, 5'b01000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vl8re32_v

covergroup Cov_rvv_zve32x_vs1r_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vs1r.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b000000, 1'b1, 5'b01000, 5'b?????, 3'b000, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins LMUL8 = {rvv_tb_pkg::LMUL8};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vs1r_v

covergroup Cov_rvv_zve32x_vs2r_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vs2r.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b001000, 1'b1, 5'b01000, 5'b?????, 3'b000, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins LMUL4 = {rvv_tb_pkg::LMUL4};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vs2r_v

covergroup Cov_rvv_zve32x_vs4r_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vs4r.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b011000, 1'b1, 5'b01000, 5'b?????, 3'b000, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins LMUL2 = {rvv_tb_pkg::LMUL2};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vs4r_v

covergroup Cov_rvv_zve32x_vs8r_v with function sample(input logic [31:0] inst, logic [2:0] vsew, logic [2:0] vlmul, logic [1:0] vxrm, logic [31:0] vl, logic [31:0] vstart);
  option.comment = "vs8r.v";
  option.per_instance = 1;
  cp_inst_cnt:
    coverpoint (inst ==? {6'b111000, 1'b1, 5'b01000, 5'b?????, 3'b000, 5'b?????, 7'b0100111}) {
      option.comment = "Instruction executed times";
      bins hit = {1};
      bins misc = default;
    }
  cp_vm:
    coverpoint inst[25] {
      option.comment = "Value of vm";
      bins vm_1 = {1};
    }
  cp_vsew:
    coverpoint vsew {
      option.comment = "Value of vsew";
      bins SEW8 = {rvv_tb_pkg::SEW8};
      bins SEW16 = {rvv_tb_pkg::SEW16};
      bins SEW32 = {rvv_tb_pkg::SEW32};
      bins misc = default;
    }
  cp_vlmul:
    coverpoint vlmul {
      option.comment = "Value of vlmul";
      bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
      bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
      bins LMUL1 = {rvv_tb_pkg::LMUL1};
      bins misc = default;
    }
  cp_vl:
    coverpoint vl {
      option.comment = "Value of vl";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins part_128 = {128};
      bins misc = default;
    }
  cp_vstart:
    coverpoint vstart {
      option.comment = "Value of vstart";
      bins part_0_to_31 = {[0:31]};
      bins part_32_to_63 = {[32:63]};
      bins part_64_to_95 = {[64:95]};
      bins part_96_to_127 = {[96:127]};
      bins misc = default;
    }
  
  // Cross coverages
endgroup: Cov_rvv_zve32x_vs8r_v
initial begin: rvv_zve32x_coverage_sample
  logic [31:0] inst_bin;
  Cov_rvv_zve32x_vadd_vv         cg_rvv_zve32x_vadd_vv = new();
  Cov_rvv_zve32x_vadd_vx         cg_rvv_zve32x_vadd_vx = new();
  Cov_rvv_zve32x_vadd_vi         cg_rvv_zve32x_vadd_vi = new();
  Cov_rvv_zve32x_vsub_vv         cg_rvv_zve32x_vsub_vv = new();
  Cov_rvv_zve32x_vsub_vx         cg_rvv_zve32x_vsub_vx = new();
  Cov_rvv_zve32x_vrsub_vx        cg_rvv_zve32x_vrsub_vx = new();
  Cov_rvv_zve32x_vrsub_vi        cg_rvv_zve32x_vrsub_vi = new();
  Cov_rvv_zve32x_vwaddu_vv       cg_rvv_zve32x_vwaddu_vv = new();
  Cov_rvv_zve32x_vwaddu_vx       cg_rvv_zve32x_vwaddu_vx = new();
  Cov_rvv_zve32x_vwsubu_vv       cg_rvv_zve32x_vwsubu_vv = new();
  Cov_rvv_zve32x_vwsubu_vx       cg_rvv_zve32x_vwsubu_vx = new();
  Cov_rvv_zve32x_vwadd_vv        cg_rvv_zve32x_vwadd_vv = new();
  Cov_rvv_zve32x_vwadd_vx        cg_rvv_zve32x_vwadd_vx = new();
  Cov_rvv_zve32x_vwsub_vv        cg_rvv_zve32x_vwsub_vv = new();
  Cov_rvv_zve32x_vwsub_vx        cg_rvv_zve32x_vwsub_vx = new();
  Cov_rvv_zve32x_vwaddu_wv       cg_rvv_zve32x_vwaddu_wv = new();
  Cov_rvv_zve32x_vwaddu_wx       cg_rvv_zve32x_vwaddu_wx = new();
  Cov_rvv_zve32x_vwsubu_wv       cg_rvv_zve32x_vwsubu_wv = new();
  Cov_rvv_zve32x_vwsubu_wx       cg_rvv_zve32x_vwsubu_wx = new();
  Cov_rvv_zve32x_vwadd_wv        cg_rvv_zve32x_vwadd_wv = new();
  Cov_rvv_zve32x_vwadd_wx        cg_rvv_zve32x_vwadd_wx = new();
  Cov_rvv_zve32x_vwsub_wv        cg_rvv_zve32x_vwsub_wv = new();
  Cov_rvv_zve32x_vwsub_wx        cg_rvv_zve32x_vwsub_wx = new();
  Cov_rvv_zve32x_vzext_vf2       cg_rvv_zve32x_vzext_vf2 = new();
  Cov_rvv_zve32x_vsext_vf2       cg_rvv_zve32x_vsext_vf2 = new();
  Cov_rvv_zve32x_vzext_vf4       cg_rvv_zve32x_vzext_vf4 = new();
  Cov_rvv_zve32x_vsext_vf4       cg_rvv_zve32x_vsext_vf4 = new();
  Cov_rvv_zve32x_vadc_vvm        cg_rvv_zve32x_vadc_vvm = new();
  Cov_rvv_zve32x_vadc_vxm        cg_rvv_zve32x_vadc_vxm = new();
  Cov_rvv_zve32x_vadc_vim        cg_rvv_zve32x_vadc_vim = new();
  Cov_rvv_zve32x_vmadc_vvm       cg_rvv_zve32x_vmadc_vvm = new();
  Cov_rvv_zve32x_vmadc_vxm       cg_rvv_zve32x_vmadc_vxm = new();
  Cov_rvv_zve32x_vmadc_vim       cg_rvv_zve32x_vmadc_vim = new();
  Cov_rvv_zve32x_vmadc_vv        cg_rvv_zve32x_vmadc_vv = new();
  Cov_rvv_zve32x_vmadc_vx        cg_rvv_zve32x_vmadc_vx = new();
  Cov_rvv_zve32x_vmadc_vi        cg_rvv_zve32x_vmadc_vi = new();
  Cov_rvv_zve32x_vsbc_vvm        cg_rvv_zve32x_vsbc_vvm = new();
  Cov_rvv_zve32x_vsbc_vxm        cg_rvv_zve32x_vsbc_vxm = new();
  Cov_rvv_zve32x_vmsbc_vvm       cg_rvv_zve32x_vmsbc_vvm = new();
  Cov_rvv_zve32x_vmsbc_vxm       cg_rvv_zve32x_vmsbc_vxm = new();
  Cov_rvv_zve32x_vmsbc_vv        cg_rvv_zve32x_vmsbc_vv = new();
  Cov_rvv_zve32x_vmsbc_vx        cg_rvv_zve32x_vmsbc_vx = new();
  Cov_rvv_zve32x_vand_vv         cg_rvv_zve32x_vand_vv = new();
  Cov_rvv_zve32x_vand_vx         cg_rvv_zve32x_vand_vx = new();
  Cov_rvv_zve32x_vand_vi         cg_rvv_zve32x_vand_vi = new();
  Cov_rvv_zve32x_vor_vv          cg_rvv_zve32x_vor_vv = new();
  Cov_rvv_zve32x_vor_vx          cg_rvv_zve32x_vor_vx = new();
  Cov_rvv_zve32x_vor_vi          cg_rvv_zve32x_vor_vi = new();
  Cov_rvv_zve32x_vxor_vv         cg_rvv_zve32x_vxor_vv = new();
  Cov_rvv_zve32x_vxor_vx         cg_rvv_zve32x_vxor_vx = new();
  Cov_rvv_zve32x_vxor_vi         cg_rvv_zve32x_vxor_vi = new();
  Cov_rvv_zve32x_vsll_vv         cg_rvv_zve32x_vsll_vv = new();
  Cov_rvv_zve32x_vsll_vx         cg_rvv_zve32x_vsll_vx = new();
  Cov_rvv_zve32x_vsll_vi         cg_rvv_zve32x_vsll_vi = new();
  Cov_rvv_zve32x_vsrl_vv         cg_rvv_zve32x_vsrl_vv = new();
  Cov_rvv_zve32x_vsrl_vx         cg_rvv_zve32x_vsrl_vx = new();
  Cov_rvv_zve32x_vsrl_vi         cg_rvv_zve32x_vsrl_vi = new();
  Cov_rvv_zve32x_vsra_vv         cg_rvv_zve32x_vsra_vv = new();
  Cov_rvv_zve32x_vsra_vx         cg_rvv_zve32x_vsra_vx = new();
  Cov_rvv_zve32x_vsra_vi         cg_rvv_zve32x_vsra_vi = new();
  Cov_rvv_zve32x_vnsrl_vv        cg_rvv_zve32x_vnsrl_vv = new();
  Cov_rvv_zve32x_vnsrl_vx        cg_rvv_zve32x_vnsrl_vx = new();
  Cov_rvv_zve32x_vnsrl_vi        cg_rvv_zve32x_vnsrl_vi = new();
  Cov_rvv_zve32x_vnsra_vv        cg_rvv_zve32x_vnsra_vv = new();
  Cov_rvv_zve32x_vnsra_vx        cg_rvv_zve32x_vnsra_vx = new();
  Cov_rvv_zve32x_vnsra_vi        cg_rvv_zve32x_vnsra_vi = new();
  Cov_rvv_zve32x_vmseq_vv        cg_rvv_zve32x_vmseq_vv = new();
  Cov_rvv_zve32x_vmseq_vx        cg_rvv_zve32x_vmseq_vx = new();
  Cov_rvv_zve32x_vmseq_vi        cg_rvv_zve32x_vmseq_vi = new();
  Cov_rvv_zve32x_vmsne_vv        cg_rvv_zve32x_vmsne_vv = new();
  Cov_rvv_zve32x_vmsne_vx        cg_rvv_zve32x_vmsne_vx = new();
  Cov_rvv_zve32x_vmsne_vi        cg_rvv_zve32x_vmsne_vi = new();
  Cov_rvv_zve32x_vmsltu_vv       cg_rvv_zve32x_vmsltu_vv = new();
  Cov_rvv_zve32x_vmsltu_vx       cg_rvv_zve32x_vmsltu_vx = new();
  Cov_rvv_zve32x_vmslt_vv        cg_rvv_zve32x_vmslt_vv = new();
  Cov_rvv_zve32x_vmslt_vx        cg_rvv_zve32x_vmslt_vx = new();
  Cov_rvv_zve32x_vmsleu_vv       cg_rvv_zve32x_vmsleu_vv = new();
  Cov_rvv_zve32x_vmsleu_vx       cg_rvv_zve32x_vmsleu_vx = new();
  Cov_rvv_zve32x_vmsleu_vi       cg_rvv_zve32x_vmsleu_vi = new();
  Cov_rvv_zve32x_vmsle_vv        cg_rvv_zve32x_vmsle_vv = new();
  Cov_rvv_zve32x_vmsle_vx        cg_rvv_zve32x_vmsle_vx = new();
  Cov_rvv_zve32x_vmsle_vi        cg_rvv_zve32x_vmsle_vi = new();
  Cov_rvv_zve32x_vmsgtu_vx       cg_rvv_zve32x_vmsgtu_vx = new();
  Cov_rvv_zve32x_vmsgtu_vi       cg_rvv_zve32x_vmsgtu_vi = new();
  Cov_rvv_zve32x_vmsgt_vx        cg_rvv_zve32x_vmsgt_vx = new();
  Cov_rvv_zve32x_vmsgt_vi        cg_rvv_zve32x_vmsgt_vi = new();
  Cov_rvv_zve32x_vminu_vv        cg_rvv_zve32x_vminu_vv = new();
  Cov_rvv_zve32x_vminu_vx        cg_rvv_zve32x_vminu_vx = new();
  Cov_rvv_zve32x_vmin_vv         cg_rvv_zve32x_vmin_vv = new();
  Cov_rvv_zve32x_vmin_vx         cg_rvv_zve32x_vmin_vx = new();
  Cov_rvv_zve32x_vmaxu_vv        cg_rvv_zve32x_vmaxu_vv = new();
  Cov_rvv_zve32x_vmaxu_vx        cg_rvv_zve32x_vmaxu_vx = new();
  Cov_rvv_zve32x_vmax_vv         cg_rvv_zve32x_vmax_vv = new();
  Cov_rvv_zve32x_vmax_vx         cg_rvv_zve32x_vmax_vx = new();
  Cov_rvv_zve32x_vmul_vv         cg_rvv_zve32x_vmul_vv = new();
  Cov_rvv_zve32x_vmul_vx         cg_rvv_zve32x_vmul_vx = new();
  Cov_rvv_zve32x_vmulh_vv        cg_rvv_zve32x_vmulh_vv = new();
  Cov_rvv_zve32x_vmulh_vx        cg_rvv_zve32x_vmulh_vx = new();
  Cov_rvv_zve32x_vmulhu_vv       cg_rvv_zve32x_vmulhu_vv = new();
  Cov_rvv_zve32x_vmulhu_vx       cg_rvv_zve32x_vmulhu_vx = new();
  Cov_rvv_zve32x_vmulhsu_vv      cg_rvv_zve32x_vmulhsu_vv = new();
  Cov_rvv_zve32x_vmulhsu_vx      cg_rvv_zve32x_vmulhsu_vx = new();
  Cov_rvv_zve32x_vwmul_vv        cg_rvv_zve32x_vwmul_vv = new();
  Cov_rvv_zve32x_vwmul_vx        cg_rvv_zve32x_vwmul_vx = new();
  Cov_rvv_zve32x_vwmulu_vv       cg_rvv_zve32x_vwmulu_vv = new();
  Cov_rvv_zve32x_vwmulu_vx       cg_rvv_zve32x_vwmulu_vx = new();
  Cov_rvv_zve32x_vwmulsu_vv      cg_rvv_zve32x_vwmulsu_vv = new();
  Cov_rvv_zve32x_vwmulsu_vx      cg_rvv_zve32x_vwmulsu_vx = new();
  Cov_rvv_zve32x_vmacc_vv        cg_rvv_zve32x_vmacc_vv = new();
  Cov_rvv_zve32x_vmacc_vx        cg_rvv_zve32x_vmacc_vx = new();
  Cov_rvv_zve32x_vnmsac_vv       cg_rvv_zve32x_vnmsac_vv = new();
  Cov_rvv_zve32x_vnmsac_vx       cg_rvv_zve32x_vnmsac_vx = new();
  Cov_rvv_zve32x_vmadd_vv        cg_rvv_zve32x_vmadd_vv = new();
  Cov_rvv_zve32x_vmadd_vx        cg_rvv_zve32x_vmadd_vx = new();
  Cov_rvv_zve32x_vnmsub_vv       cg_rvv_zve32x_vnmsub_vv = new();
  Cov_rvv_zve32x_vnmsub_vx       cg_rvv_zve32x_vnmsub_vx = new();
  Cov_rvv_zve32x_vwmaccu_vv      cg_rvv_zve32x_vwmaccu_vv = new();
  Cov_rvv_zve32x_vwmaccu_vx      cg_rvv_zve32x_vwmaccu_vx = new();
  Cov_rvv_zve32x_vwmacc_vv       cg_rvv_zve32x_vwmacc_vv = new();
  Cov_rvv_zve32x_vwmacc_vx       cg_rvv_zve32x_vwmacc_vx = new();
  Cov_rvv_zve32x_vwmaccsu_vv     cg_rvv_zve32x_vwmaccsu_vv = new();
  Cov_rvv_zve32x_vwmaccsu_vx     cg_rvv_zve32x_vwmaccsu_vx = new();
  Cov_rvv_zve32x_vwmaccus_vx     cg_rvv_zve32x_vwmaccus_vx = new();
  Cov_rvv_zve32x_vdivu_vv        cg_rvv_zve32x_vdivu_vv = new();
  Cov_rvv_zve32x_vdivu_vx        cg_rvv_zve32x_vdivu_vx = new();
  Cov_rvv_zve32x_vdiv_vv         cg_rvv_zve32x_vdiv_vv = new();
  Cov_rvv_zve32x_vdiv_vx         cg_rvv_zve32x_vdiv_vx = new();
  Cov_rvv_zve32x_vremu_vv        cg_rvv_zve32x_vremu_vv = new();
  Cov_rvv_zve32x_vremu_vx        cg_rvv_zve32x_vremu_vx = new();
  Cov_rvv_zve32x_vrem_vv         cg_rvv_zve32x_vrem_vv = new();
  Cov_rvv_zve32x_vrem_vx         cg_rvv_zve32x_vrem_vx = new();
  Cov_rvv_zve32x_vmerge_vvm      cg_rvv_zve32x_vmerge_vvm = new();
  Cov_rvv_zve32x_vmerge_vxm      cg_rvv_zve32x_vmerge_vxm = new();
  Cov_rvv_zve32x_vmerge_vim      cg_rvv_zve32x_vmerge_vim = new();
  Cov_rvv_zve32x_vmv_v_v         cg_rvv_zve32x_vmv_v_v = new();
  Cov_rvv_zve32x_vmv_v_x         cg_rvv_zve32x_vmv_v_x = new();
  Cov_rvv_zve32x_vmv_v_i         cg_rvv_zve32x_vmv_v_i = new();
  Cov_rvv_zve32x_vsaddu_vv       cg_rvv_zve32x_vsaddu_vv = new();
  Cov_rvv_zve32x_vsaddu_vx       cg_rvv_zve32x_vsaddu_vx = new();
  Cov_rvv_zve32x_vsaddu_vi       cg_rvv_zve32x_vsaddu_vi = new();
  Cov_rvv_zve32x_vsadd_vv        cg_rvv_zve32x_vsadd_vv = new();
  Cov_rvv_zve32x_vsadd_vx        cg_rvv_zve32x_vsadd_vx = new();
  Cov_rvv_zve32x_vsadd_vi        cg_rvv_zve32x_vsadd_vi = new();
  Cov_rvv_zve32x_vssubu_vv       cg_rvv_zve32x_vssubu_vv = new();
  Cov_rvv_zve32x_vssubu_vx       cg_rvv_zve32x_vssubu_vx = new();
  Cov_rvv_zve32x_vssub_vv        cg_rvv_zve32x_vssub_vv = new();
  Cov_rvv_zve32x_vssub_vx        cg_rvv_zve32x_vssub_vx = new();
  Cov_rvv_zve32x_vaaddu_vv       cg_rvv_zve32x_vaaddu_vv = new();
  Cov_rvv_zve32x_vaaddu_vx       cg_rvv_zve32x_vaaddu_vx = new();
  Cov_rvv_zve32x_vaadd_vv        cg_rvv_zve32x_vaadd_vv = new();
  Cov_rvv_zve32x_vaadd_vx        cg_rvv_zve32x_vaadd_vx = new();
  Cov_rvv_zve32x_vasubu_vv       cg_rvv_zve32x_vasubu_vv = new();
  Cov_rvv_zve32x_vasubu_vx       cg_rvv_zve32x_vasubu_vx = new();
  Cov_rvv_zve32x_vasub_vv        cg_rvv_zve32x_vasub_vv = new();
  Cov_rvv_zve32x_vasub_vx        cg_rvv_zve32x_vasub_vx = new();
  Cov_rvv_zve32x_vsmul_vv        cg_rvv_zve32x_vsmul_vv = new();
  Cov_rvv_zve32x_vsmul_vx        cg_rvv_zve32x_vsmul_vx = new();
  Cov_rvv_zve32x_vssrl_vv        cg_rvv_zve32x_vssrl_vv = new();
  Cov_rvv_zve32x_vssrl_vx        cg_rvv_zve32x_vssrl_vx = new();
  Cov_rvv_zve32x_vssrl_vi        cg_rvv_zve32x_vssrl_vi = new();
  Cov_rvv_zve32x_vssra_vv        cg_rvv_zve32x_vssra_vv = new();
  Cov_rvv_zve32x_vssra_vx        cg_rvv_zve32x_vssra_vx = new();
  Cov_rvv_zve32x_vssra_vi        cg_rvv_zve32x_vssra_vi = new();
  Cov_rvv_zve32x_vnclipu_wv      cg_rvv_zve32x_vnclipu_wv = new();
  Cov_rvv_zve32x_vnclipu_wx      cg_rvv_zve32x_vnclipu_wx = new();
  Cov_rvv_zve32x_vnclipu_wi      cg_rvv_zve32x_vnclipu_wi = new();
  Cov_rvv_zve32x_vnclip_wv       cg_rvv_zve32x_vnclip_wv = new();
  Cov_rvv_zve32x_vnclip_wx       cg_rvv_zve32x_vnclip_wx = new();
  Cov_rvv_zve32x_vnclip_wi       cg_rvv_zve32x_vnclip_wi = new();
  Cov_rvv_zve32x_vredsum_vs      cg_rvv_zve32x_vredsum_vs = new();
  Cov_rvv_zve32x_vredmaxu_vs     cg_rvv_zve32x_vredmaxu_vs = new();
  Cov_rvv_zve32x_vredmax_vs      cg_rvv_zve32x_vredmax_vs = new();
  Cov_rvv_zve32x_vredminu_vs     cg_rvv_zve32x_vredminu_vs = new();
  Cov_rvv_zve32x_vredmin_vs      cg_rvv_zve32x_vredmin_vs = new();
  Cov_rvv_zve32x_vredand_vs      cg_rvv_zve32x_vredand_vs = new();
  Cov_rvv_zve32x_vredor_vs       cg_rvv_zve32x_vredor_vs = new();
  Cov_rvv_zve32x_vredxor_vs      cg_rvv_zve32x_vredxor_vs = new();
  Cov_rvv_zve32x_vwredsumu_vs    cg_rvv_zve32x_vwredsumu_vs = new();
  Cov_rvv_zve32x_vwredsum_vs     cg_rvv_zve32x_vwredsum_vs = new();
  Cov_rvv_zve32x_vmand_mm        cg_rvv_zve32x_vmand_mm = new();
  Cov_rvv_zve32x_vmnand_mm       cg_rvv_zve32x_vmnand_mm = new();
  Cov_rvv_zve32x_vmandn_mm       cg_rvv_zve32x_vmandn_mm = new();
  Cov_rvv_zve32x_vmxor_mm        cg_rvv_zve32x_vmxor_mm = new();
  Cov_rvv_zve32x_vmor_mm         cg_rvv_zve32x_vmor_mm = new();
  Cov_rvv_zve32x_vmnor_mm        cg_rvv_zve32x_vmnor_mm = new();
  Cov_rvv_zve32x_vmorn_mm        cg_rvv_zve32x_vmorn_mm = new();
  Cov_rvv_zve32x_vmxnor_mm       cg_rvv_zve32x_vmxnor_mm = new();
  Cov_rvv_zve32x_vcpop_m         cg_rvv_zve32x_vcpop_m = new();
  Cov_rvv_zve32x_vfirst_m        cg_rvv_zve32x_vfirst_m = new();
  Cov_rvv_zve32x_vmsbf_m         cg_rvv_zve32x_vmsbf_m = new();
  Cov_rvv_zve32x_vmsif_m         cg_rvv_zve32x_vmsif_m = new();
  Cov_rvv_zve32x_vmsof_m         cg_rvv_zve32x_vmsof_m = new();
  Cov_rvv_zve32x_viota_m         cg_rvv_zve32x_viota_m = new();
  Cov_rvv_zve32x_vid_v           cg_rvv_zve32x_vid_v = new();
  Cov_rvv_zve32x_vmv_x_s         cg_rvv_zve32x_vmv_x_s = new();
  Cov_rvv_zve32x_vmv_s_x         cg_rvv_zve32x_vmv_s_x = new();
  Cov_rvv_zve32x_vslideup_vx     cg_rvv_zve32x_vslideup_vx = new();
  Cov_rvv_zve32x_vslideup_vi     cg_rvv_zve32x_vslideup_vi = new();
  Cov_rvv_zve32x_vslidedown_vx   cg_rvv_zve32x_vslidedown_vx = new();
  Cov_rvv_zve32x_vslidedown_vi   cg_rvv_zve32x_vslidedown_vi = new();
  Cov_rvv_zve32x_vslide1up_vx    cg_rvv_zve32x_vslide1up_vx = new();
  Cov_rvv_zve32x_vslide1down_vx  cg_rvv_zve32x_vslide1down_vx = new();
  Cov_rvv_zve32x_vrgather_vv     cg_rvv_zve32x_vrgather_vv = new();
  Cov_rvv_zve32x_vrgatherei16_vv cg_rvv_zve32x_vrgatherei16_vv = new();
  Cov_rvv_zve32x_vrgather_vx     cg_rvv_zve32x_vrgather_vx = new();
  Cov_rvv_zve32x_vrgather_vi     cg_rvv_zve32x_vrgather_vi = new();
  Cov_rvv_zve32x_vcompress_vm    cg_rvv_zve32x_vcompress_vm = new();
  Cov_rvv_zve32x_vmv1r_v         cg_rvv_zve32x_vmv1r_v = new();
  Cov_rvv_zve32x_vmv2r_v         cg_rvv_zve32x_vmv2r_v = new();
  Cov_rvv_zve32x_vmv4r_v         cg_rvv_zve32x_vmv4r_v = new();
  Cov_rvv_zve32x_vmv8r_v         cg_rvv_zve32x_vmv8r_v = new();
  Cov_rvv_zve32x_vle8_v          cg_rvv_zve32x_vle8_v = new();
  Cov_rvv_zve32x_vle16_v         cg_rvv_zve32x_vle16_v = new();
  Cov_rvv_zve32x_vle32_v         cg_rvv_zve32x_vle32_v = new();
  Cov_rvv_zve32x_vse8_v          cg_rvv_zve32x_vse8_v = new();
  Cov_rvv_zve32x_vse16_v         cg_rvv_zve32x_vse16_v = new();
  Cov_rvv_zve32x_vse32_v         cg_rvv_zve32x_vse32_v = new();
  Cov_rvv_zve32x_vlm_v           cg_rvv_zve32x_vlm_v = new();
  Cov_rvv_zve32x_vsm_v           cg_rvv_zve32x_vsm_v = new();
  Cov_rvv_zve32x_vlse8_v         cg_rvv_zve32x_vlse8_v = new();
  Cov_rvv_zve32x_vlse16_v        cg_rvv_zve32x_vlse16_v = new();
  Cov_rvv_zve32x_vlse32_v        cg_rvv_zve32x_vlse32_v = new();
  Cov_rvv_zve32x_vsse8_v         cg_rvv_zve32x_vsse8_v = new();
  Cov_rvv_zve32x_vsse16_v        cg_rvv_zve32x_vsse16_v = new();
  Cov_rvv_zve32x_vsse32_v        cg_rvv_zve32x_vsse32_v = new();
  Cov_rvv_zve32x_vluxei8_v       cg_rvv_zve32x_vluxei8_v = new();
  Cov_rvv_zve32x_vluxei16_v      cg_rvv_zve32x_vluxei16_v = new();
  Cov_rvv_zve32x_vluxei32_v      cg_rvv_zve32x_vluxei32_v = new();
  Cov_rvv_zve32x_vloxei8_v       cg_rvv_zve32x_vloxei8_v = new();
  Cov_rvv_zve32x_vloxei16_v      cg_rvv_zve32x_vloxei16_v = new();
  Cov_rvv_zve32x_vloxei32_v      cg_rvv_zve32x_vloxei32_v = new();
  Cov_rvv_zve32x_vsuxei8_v       cg_rvv_zve32x_vsuxei8_v = new();
  Cov_rvv_zve32x_vsuxei16_v      cg_rvv_zve32x_vsuxei16_v = new();
  Cov_rvv_zve32x_vsuxei32_v      cg_rvv_zve32x_vsuxei32_v = new();
  Cov_rvv_zve32x_vsoxei8_v       cg_rvv_zve32x_vsoxei8_v = new();
  Cov_rvv_zve32x_vsoxei16_v      cg_rvv_zve32x_vsoxei16_v = new();
  Cov_rvv_zve32x_vsoxei32_v      cg_rvv_zve32x_vsoxei32_v = new();
  Cov_rvv_zve32x_vle8ff_v        cg_rvv_zve32x_vle8ff_v = new();
  Cov_rvv_zve32x_vle16ff_v       cg_rvv_zve32x_vle16ff_v = new();
  Cov_rvv_zve32x_vle32ff_v       cg_rvv_zve32x_vle32ff_v = new();
  Cov_rvv_zve32x_vlseg2e8_v      cg_rvv_zve32x_vlseg2e8_v = new();
  Cov_rvv_zve32x_vlseg3e8_v      cg_rvv_zve32x_vlseg3e8_v = new();
  Cov_rvv_zve32x_vlseg4e8_v      cg_rvv_zve32x_vlseg4e8_v = new();
  Cov_rvv_zve32x_vlseg5e8_v      cg_rvv_zve32x_vlseg5e8_v = new();
  Cov_rvv_zve32x_vlseg6e8_v      cg_rvv_zve32x_vlseg6e8_v = new();
  Cov_rvv_zve32x_vlseg7e8_v      cg_rvv_zve32x_vlseg7e8_v = new();
  Cov_rvv_zve32x_vlseg8e8_v      cg_rvv_zve32x_vlseg8e8_v = new();
  Cov_rvv_zve32x_vlseg2e16_v     cg_rvv_zve32x_vlseg2e16_v = new();
  Cov_rvv_zve32x_vlseg3e16_v     cg_rvv_zve32x_vlseg3e16_v = new();
  Cov_rvv_zve32x_vlseg4e16_v     cg_rvv_zve32x_vlseg4e16_v = new();
  Cov_rvv_zve32x_vlseg5e16_v     cg_rvv_zve32x_vlseg5e16_v = new();
  Cov_rvv_zve32x_vlseg6e16_v     cg_rvv_zve32x_vlseg6e16_v = new();
  Cov_rvv_zve32x_vlseg7e16_v     cg_rvv_zve32x_vlseg7e16_v = new();
  Cov_rvv_zve32x_vlseg8e16_v     cg_rvv_zve32x_vlseg8e16_v = new();
  Cov_rvv_zve32x_vlseg2e32_v     cg_rvv_zve32x_vlseg2e32_v = new();
  Cov_rvv_zve32x_vlseg3e32_v     cg_rvv_zve32x_vlseg3e32_v = new();
  Cov_rvv_zve32x_vlseg4e32_v     cg_rvv_zve32x_vlseg4e32_v = new();
  Cov_rvv_zve32x_vlseg5e32_v     cg_rvv_zve32x_vlseg5e32_v = new();
  Cov_rvv_zve32x_vlseg6e32_v     cg_rvv_zve32x_vlseg6e32_v = new();
  Cov_rvv_zve32x_vlseg7e32_v     cg_rvv_zve32x_vlseg7e32_v = new();
  Cov_rvv_zve32x_vlseg8e32_v     cg_rvv_zve32x_vlseg8e32_v = new();
  Cov_rvv_zve32x_vsseg2e8_v      cg_rvv_zve32x_vsseg2e8_v = new();
  Cov_rvv_zve32x_vsseg3e8_v      cg_rvv_zve32x_vsseg3e8_v = new();
  Cov_rvv_zve32x_vsseg4e8_v      cg_rvv_zve32x_vsseg4e8_v = new();
  Cov_rvv_zve32x_vsseg5e8_v      cg_rvv_zve32x_vsseg5e8_v = new();
  Cov_rvv_zve32x_vsseg6e8_v      cg_rvv_zve32x_vsseg6e8_v = new();
  Cov_rvv_zve32x_vsseg7e8_v      cg_rvv_zve32x_vsseg7e8_v = new();
  Cov_rvv_zve32x_vsseg8e8_v      cg_rvv_zve32x_vsseg8e8_v = new();
  Cov_rvv_zve32x_vsseg2e16_v     cg_rvv_zve32x_vsseg2e16_v = new();
  Cov_rvv_zve32x_vsseg3e16_v     cg_rvv_zve32x_vsseg3e16_v = new();
  Cov_rvv_zve32x_vsseg4e16_v     cg_rvv_zve32x_vsseg4e16_v = new();
  Cov_rvv_zve32x_vsseg5e16_v     cg_rvv_zve32x_vsseg5e16_v = new();
  Cov_rvv_zve32x_vsseg6e16_v     cg_rvv_zve32x_vsseg6e16_v = new();
  Cov_rvv_zve32x_vsseg7e16_v     cg_rvv_zve32x_vsseg7e16_v = new();
  Cov_rvv_zve32x_vsseg8e16_v     cg_rvv_zve32x_vsseg8e16_v = new();
  Cov_rvv_zve32x_vsseg2e32_v     cg_rvv_zve32x_vsseg2e32_v = new();
  Cov_rvv_zve32x_vsseg3e32_v     cg_rvv_zve32x_vsseg3e32_v = new();
  Cov_rvv_zve32x_vsseg4e32_v     cg_rvv_zve32x_vsseg4e32_v = new();
  Cov_rvv_zve32x_vsseg5e32_v     cg_rvv_zve32x_vsseg5e32_v = new();
  Cov_rvv_zve32x_vsseg6e32_v     cg_rvv_zve32x_vsseg6e32_v = new();
  Cov_rvv_zve32x_vsseg7e32_v     cg_rvv_zve32x_vsseg7e32_v = new();
  Cov_rvv_zve32x_vsseg8e32_v     cg_rvv_zve32x_vsseg8e32_v = new();
  Cov_rvv_zve32x_vlseg2e8ff_v    cg_rvv_zve32x_vlseg2e8ff_v = new();
  Cov_rvv_zve32x_vlseg3e8ff_v    cg_rvv_zve32x_vlseg3e8ff_v = new();
  Cov_rvv_zve32x_vlseg4e8ff_v    cg_rvv_zve32x_vlseg4e8ff_v = new();
  Cov_rvv_zve32x_vlseg5e8ff_v    cg_rvv_zve32x_vlseg5e8ff_v = new();
  Cov_rvv_zve32x_vlseg6e8ff_v    cg_rvv_zve32x_vlseg6e8ff_v = new();
  Cov_rvv_zve32x_vlseg7e8ff_v    cg_rvv_zve32x_vlseg7e8ff_v = new();
  Cov_rvv_zve32x_vlseg8e8ff_v    cg_rvv_zve32x_vlseg8e8ff_v = new();
  Cov_rvv_zve32x_vlseg2e16ff_v   cg_rvv_zve32x_vlseg2e16ff_v = new();
  Cov_rvv_zve32x_vlseg3e16ff_v   cg_rvv_zve32x_vlseg3e16ff_v = new();
  Cov_rvv_zve32x_vlseg4e16ff_v   cg_rvv_zve32x_vlseg4e16ff_v = new();
  Cov_rvv_zve32x_vlseg5e16ff_v   cg_rvv_zve32x_vlseg5e16ff_v = new();
  Cov_rvv_zve32x_vlseg6e16ff_v   cg_rvv_zve32x_vlseg6e16ff_v = new();
  Cov_rvv_zve32x_vlseg7e16ff_v   cg_rvv_zve32x_vlseg7e16ff_v = new();
  Cov_rvv_zve32x_vlseg8e16ff_v   cg_rvv_zve32x_vlseg8e16ff_v = new();
  Cov_rvv_zve32x_vlseg2e32ff_v   cg_rvv_zve32x_vlseg2e32ff_v = new();
  Cov_rvv_zve32x_vlseg3e32ff_v   cg_rvv_zve32x_vlseg3e32ff_v = new();
  Cov_rvv_zve32x_vlseg4e32ff_v   cg_rvv_zve32x_vlseg4e32ff_v = new();
  Cov_rvv_zve32x_vlseg5e32ff_v   cg_rvv_zve32x_vlseg5e32ff_v = new();
  Cov_rvv_zve32x_vlseg6e32ff_v   cg_rvv_zve32x_vlseg6e32ff_v = new();
  Cov_rvv_zve32x_vlseg7e32ff_v   cg_rvv_zve32x_vlseg7e32ff_v = new();
  Cov_rvv_zve32x_vlseg8e32ff_v   cg_rvv_zve32x_vlseg8e32ff_v = new();
  Cov_rvv_zve32x_vlsseg2e8_v     cg_rvv_zve32x_vlsseg2e8_v = new();
  Cov_rvv_zve32x_vlsseg3e8_v     cg_rvv_zve32x_vlsseg3e8_v = new();
  Cov_rvv_zve32x_vlsseg4e8_v     cg_rvv_zve32x_vlsseg4e8_v = new();
  Cov_rvv_zve32x_vlsseg5e8_v     cg_rvv_zve32x_vlsseg5e8_v = new();
  Cov_rvv_zve32x_vlsseg6e8_v     cg_rvv_zve32x_vlsseg6e8_v = new();
  Cov_rvv_zve32x_vlsseg7e8_v     cg_rvv_zve32x_vlsseg7e8_v = new();
  Cov_rvv_zve32x_vlsseg8e8_v     cg_rvv_zve32x_vlsseg8e8_v = new();
  Cov_rvv_zve32x_vlsseg2e16_v    cg_rvv_zve32x_vlsseg2e16_v = new();
  Cov_rvv_zve32x_vlsseg3e16_v    cg_rvv_zve32x_vlsseg3e16_v = new();
  Cov_rvv_zve32x_vlsseg4e16_v    cg_rvv_zve32x_vlsseg4e16_v = new();
  Cov_rvv_zve32x_vlsseg5e16_v    cg_rvv_zve32x_vlsseg5e16_v = new();
  Cov_rvv_zve32x_vlsseg6e16_v    cg_rvv_zve32x_vlsseg6e16_v = new();
  Cov_rvv_zve32x_vlsseg7e16_v    cg_rvv_zve32x_vlsseg7e16_v = new();
  Cov_rvv_zve32x_vlsseg8e16_v    cg_rvv_zve32x_vlsseg8e16_v = new();
  Cov_rvv_zve32x_vlsseg2e32_v    cg_rvv_zve32x_vlsseg2e32_v = new();
  Cov_rvv_zve32x_vlsseg3e32_v    cg_rvv_zve32x_vlsseg3e32_v = new();
  Cov_rvv_zve32x_vlsseg4e32_v    cg_rvv_zve32x_vlsseg4e32_v = new();
  Cov_rvv_zve32x_vlsseg5e32_v    cg_rvv_zve32x_vlsseg5e32_v = new();
  Cov_rvv_zve32x_vlsseg6e32_v    cg_rvv_zve32x_vlsseg6e32_v = new();
  Cov_rvv_zve32x_vlsseg7e32_v    cg_rvv_zve32x_vlsseg7e32_v = new();
  Cov_rvv_zve32x_vlsseg8e32_v    cg_rvv_zve32x_vlsseg8e32_v = new();
  Cov_rvv_zve32x_vssseg2e8_v     cg_rvv_zve32x_vssseg2e8_v = new();
  Cov_rvv_zve32x_vssseg3e8_v     cg_rvv_zve32x_vssseg3e8_v = new();
  Cov_rvv_zve32x_vssseg4e8_v     cg_rvv_zve32x_vssseg4e8_v = new();
  Cov_rvv_zve32x_vssseg5e8_v     cg_rvv_zve32x_vssseg5e8_v = new();
  Cov_rvv_zve32x_vssseg6e8_v     cg_rvv_zve32x_vssseg6e8_v = new();
  Cov_rvv_zve32x_vssseg7e8_v     cg_rvv_zve32x_vssseg7e8_v = new();
  Cov_rvv_zve32x_vssseg8e8_v     cg_rvv_zve32x_vssseg8e8_v = new();
  Cov_rvv_zve32x_vssseg2e16_v    cg_rvv_zve32x_vssseg2e16_v = new();
  Cov_rvv_zve32x_vssseg3e16_v    cg_rvv_zve32x_vssseg3e16_v = new();
  Cov_rvv_zve32x_vssseg4e16_v    cg_rvv_zve32x_vssseg4e16_v = new();
  Cov_rvv_zve32x_vssseg5e16_v    cg_rvv_zve32x_vssseg5e16_v = new();
  Cov_rvv_zve32x_vssseg6e16_v    cg_rvv_zve32x_vssseg6e16_v = new();
  Cov_rvv_zve32x_vssseg7e16_v    cg_rvv_zve32x_vssseg7e16_v = new();
  Cov_rvv_zve32x_vssseg8e16_v    cg_rvv_zve32x_vssseg8e16_v = new();
  Cov_rvv_zve32x_vssseg2e32_v    cg_rvv_zve32x_vssseg2e32_v = new();
  Cov_rvv_zve32x_vssseg3e32_v    cg_rvv_zve32x_vssseg3e32_v = new();
  Cov_rvv_zve32x_vssseg4e32_v    cg_rvv_zve32x_vssseg4e32_v = new();
  Cov_rvv_zve32x_vssseg5e32_v    cg_rvv_zve32x_vssseg5e32_v = new();
  Cov_rvv_zve32x_vssseg6e32_v    cg_rvv_zve32x_vssseg6e32_v = new();
  Cov_rvv_zve32x_vssseg7e32_v    cg_rvv_zve32x_vssseg7e32_v = new();
  Cov_rvv_zve32x_vssseg8e32_v    cg_rvv_zve32x_vssseg8e32_v = new();
  Cov_rvv_zve32x_vluxseg2ei8_v   cg_rvv_zve32x_vluxseg2ei8_v = new();
  Cov_rvv_zve32x_vluxseg3ei8_v   cg_rvv_zve32x_vluxseg3ei8_v = new();
  Cov_rvv_zve32x_vluxseg4ei8_v   cg_rvv_zve32x_vluxseg4ei8_v = new();
  Cov_rvv_zve32x_vluxseg5ei8_v   cg_rvv_zve32x_vluxseg5ei8_v = new();
  Cov_rvv_zve32x_vluxseg6ei8_v   cg_rvv_zve32x_vluxseg6ei8_v = new();
  Cov_rvv_zve32x_vluxseg7ei8_v   cg_rvv_zve32x_vluxseg7ei8_v = new();
  Cov_rvv_zve32x_vluxseg8ei8_v   cg_rvv_zve32x_vluxseg8ei8_v = new();
  Cov_rvv_zve32x_vluxseg2ei16_v  cg_rvv_zve32x_vluxseg2ei16_v = new();
  Cov_rvv_zve32x_vluxseg3ei16_v  cg_rvv_zve32x_vluxseg3ei16_v = new();
  Cov_rvv_zve32x_vluxseg4ei16_v  cg_rvv_zve32x_vluxseg4ei16_v = new();
  Cov_rvv_zve32x_vluxseg5ei16_v  cg_rvv_zve32x_vluxseg5ei16_v = new();
  Cov_rvv_zve32x_vluxseg6ei16_v  cg_rvv_zve32x_vluxseg6ei16_v = new();
  Cov_rvv_zve32x_vluxseg7ei16_v  cg_rvv_zve32x_vluxseg7ei16_v = new();
  Cov_rvv_zve32x_vluxseg8ei16_v  cg_rvv_zve32x_vluxseg8ei16_v = new();
  Cov_rvv_zve32x_vluxseg2ei32_v  cg_rvv_zve32x_vluxseg2ei32_v = new();
  Cov_rvv_zve32x_vluxseg3ei32_v  cg_rvv_zve32x_vluxseg3ei32_v = new();
  Cov_rvv_zve32x_vluxseg4ei32_v  cg_rvv_zve32x_vluxseg4ei32_v = new();
  Cov_rvv_zve32x_vluxseg5ei32_v  cg_rvv_zve32x_vluxseg5ei32_v = new();
  Cov_rvv_zve32x_vluxseg6ei32_v  cg_rvv_zve32x_vluxseg6ei32_v = new();
  Cov_rvv_zve32x_vluxseg7ei32_v  cg_rvv_zve32x_vluxseg7ei32_v = new();
  Cov_rvv_zve32x_vluxseg8ei32_v  cg_rvv_zve32x_vluxseg8ei32_v = new();
  Cov_rvv_zve32x_vloxseg2ei8_v   cg_rvv_zve32x_vloxseg2ei8_v = new();
  Cov_rvv_zve32x_vloxseg3ei8_v   cg_rvv_zve32x_vloxseg3ei8_v = new();
  Cov_rvv_zve32x_vloxseg4ei8_v   cg_rvv_zve32x_vloxseg4ei8_v = new();
  Cov_rvv_zve32x_vloxseg5ei8_v   cg_rvv_zve32x_vloxseg5ei8_v = new();
  Cov_rvv_zve32x_vloxseg6ei8_v   cg_rvv_zve32x_vloxseg6ei8_v = new();
  Cov_rvv_zve32x_vloxseg7ei8_v   cg_rvv_zve32x_vloxseg7ei8_v = new();
  Cov_rvv_zve32x_vloxseg8ei8_v   cg_rvv_zve32x_vloxseg8ei8_v = new();
  Cov_rvv_zve32x_vloxseg2ei16_v  cg_rvv_zve32x_vloxseg2ei16_v = new();
  Cov_rvv_zve32x_vloxseg3ei16_v  cg_rvv_zve32x_vloxseg3ei16_v = new();
  Cov_rvv_zve32x_vloxseg4ei16_v  cg_rvv_zve32x_vloxseg4ei16_v = new();
  Cov_rvv_zve32x_vloxseg5ei16_v  cg_rvv_zve32x_vloxseg5ei16_v = new();
  Cov_rvv_zve32x_vloxseg6ei16_v  cg_rvv_zve32x_vloxseg6ei16_v = new();
  Cov_rvv_zve32x_vloxseg7ei16_v  cg_rvv_zve32x_vloxseg7ei16_v = new();
  Cov_rvv_zve32x_vloxseg8ei16_v  cg_rvv_zve32x_vloxseg8ei16_v = new();
  Cov_rvv_zve32x_vloxseg2ei32_v  cg_rvv_zve32x_vloxseg2ei32_v = new();
  Cov_rvv_zve32x_vloxseg3ei32_v  cg_rvv_zve32x_vloxseg3ei32_v = new();
  Cov_rvv_zve32x_vloxseg4ei32_v  cg_rvv_zve32x_vloxseg4ei32_v = new();
  Cov_rvv_zve32x_vloxseg5ei32_v  cg_rvv_zve32x_vloxseg5ei32_v = new();
  Cov_rvv_zve32x_vloxseg6ei32_v  cg_rvv_zve32x_vloxseg6ei32_v = new();
  Cov_rvv_zve32x_vloxseg7ei32_v  cg_rvv_zve32x_vloxseg7ei32_v = new();
  Cov_rvv_zve32x_vloxseg8ei32_v  cg_rvv_zve32x_vloxseg8ei32_v = new();
  Cov_rvv_zve32x_vsuxseg2ei8_v   cg_rvv_zve32x_vsuxseg2ei8_v = new();
  Cov_rvv_zve32x_vsuxseg3ei8_v   cg_rvv_zve32x_vsuxseg3ei8_v = new();
  Cov_rvv_zve32x_vsuxseg4ei8_v   cg_rvv_zve32x_vsuxseg4ei8_v = new();
  Cov_rvv_zve32x_vsuxseg5ei8_v   cg_rvv_zve32x_vsuxseg5ei8_v = new();
  Cov_rvv_zve32x_vsuxseg6ei8_v   cg_rvv_zve32x_vsuxseg6ei8_v = new();
  Cov_rvv_zve32x_vsuxseg7ei8_v   cg_rvv_zve32x_vsuxseg7ei8_v = new();
  Cov_rvv_zve32x_vsuxseg8ei8_v   cg_rvv_zve32x_vsuxseg8ei8_v = new();
  Cov_rvv_zve32x_vsuxseg2ei16_v  cg_rvv_zve32x_vsuxseg2ei16_v = new();
  Cov_rvv_zve32x_vsuxseg3ei16_v  cg_rvv_zve32x_vsuxseg3ei16_v = new();
  Cov_rvv_zve32x_vsuxseg4ei16_v  cg_rvv_zve32x_vsuxseg4ei16_v = new();
  Cov_rvv_zve32x_vsuxseg5ei16_v  cg_rvv_zve32x_vsuxseg5ei16_v = new();
  Cov_rvv_zve32x_vsuxseg6ei16_v  cg_rvv_zve32x_vsuxseg6ei16_v = new();
  Cov_rvv_zve32x_vsuxseg7ei16_v  cg_rvv_zve32x_vsuxseg7ei16_v = new();
  Cov_rvv_zve32x_vsuxseg8ei16_v  cg_rvv_zve32x_vsuxseg8ei16_v = new();
  Cov_rvv_zve32x_vsuxseg2ei32_v  cg_rvv_zve32x_vsuxseg2ei32_v = new();
  Cov_rvv_zve32x_vsuxseg3ei32_v  cg_rvv_zve32x_vsuxseg3ei32_v = new();
  Cov_rvv_zve32x_vsuxseg4ei32_v  cg_rvv_zve32x_vsuxseg4ei32_v = new();
  Cov_rvv_zve32x_vsuxseg5ei32_v  cg_rvv_zve32x_vsuxseg5ei32_v = new();
  Cov_rvv_zve32x_vsuxseg6ei32_v  cg_rvv_zve32x_vsuxseg6ei32_v = new();
  Cov_rvv_zve32x_vsuxseg7ei32_v  cg_rvv_zve32x_vsuxseg7ei32_v = new();
  Cov_rvv_zve32x_vsuxseg8ei32_v  cg_rvv_zve32x_vsuxseg8ei32_v = new();
  Cov_rvv_zve32x_vsoxseg2ei8_v   cg_rvv_zve32x_vsoxseg2ei8_v = new();
  Cov_rvv_zve32x_vsoxseg3ei8_v   cg_rvv_zve32x_vsoxseg3ei8_v = new();
  Cov_rvv_zve32x_vsoxseg4ei8_v   cg_rvv_zve32x_vsoxseg4ei8_v = new();
  Cov_rvv_zve32x_vsoxseg5ei8_v   cg_rvv_zve32x_vsoxseg5ei8_v = new();
  Cov_rvv_zve32x_vsoxseg6ei8_v   cg_rvv_zve32x_vsoxseg6ei8_v = new();
  Cov_rvv_zve32x_vsoxseg7ei8_v   cg_rvv_zve32x_vsoxseg7ei8_v = new();
  Cov_rvv_zve32x_vsoxseg8ei8_v   cg_rvv_zve32x_vsoxseg8ei8_v = new();
  Cov_rvv_zve32x_vsoxseg2ei16_v  cg_rvv_zve32x_vsoxseg2ei16_v = new();
  Cov_rvv_zve32x_vsoxseg3ei16_v  cg_rvv_zve32x_vsoxseg3ei16_v = new();
  Cov_rvv_zve32x_vsoxseg4ei16_v  cg_rvv_zve32x_vsoxseg4ei16_v = new();
  Cov_rvv_zve32x_vsoxseg5ei16_v  cg_rvv_zve32x_vsoxseg5ei16_v = new();
  Cov_rvv_zve32x_vsoxseg6ei16_v  cg_rvv_zve32x_vsoxseg6ei16_v = new();
  Cov_rvv_zve32x_vsoxseg7ei16_v  cg_rvv_zve32x_vsoxseg7ei16_v = new();
  Cov_rvv_zve32x_vsoxseg8ei16_v  cg_rvv_zve32x_vsoxseg8ei16_v = new();
  Cov_rvv_zve32x_vsoxseg2ei32_v  cg_rvv_zve32x_vsoxseg2ei32_v = new();
  Cov_rvv_zve32x_vsoxseg3ei32_v  cg_rvv_zve32x_vsoxseg3ei32_v = new();
  Cov_rvv_zve32x_vsoxseg4ei32_v  cg_rvv_zve32x_vsoxseg4ei32_v = new();
  Cov_rvv_zve32x_vsoxseg5ei32_v  cg_rvv_zve32x_vsoxseg5ei32_v = new();
  Cov_rvv_zve32x_vsoxseg6ei32_v  cg_rvv_zve32x_vsoxseg6ei32_v = new();
  Cov_rvv_zve32x_vsoxseg7ei32_v  cg_rvv_zve32x_vsoxseg7ei32_v = new();
  Cov_rvv_zve32x_vsoxseg8ei32_v  cg_rvv_zve32x_vsoxseg8ei32_v = new();
  Cov_rvv_zve32x_vl1re8_v        cg_rvv_zve32x_vl1re8_v = new();
  Cov_rvv_zve32x_vl2re8_v        cg_rvv_zve32x_vl2re8_v = new();
  Cov_rvv_zve32x_vl4re8_v        cg_rvv_zve32x_vl4re8_v = new();
  Cov_rvv_zve32x_vl8re8_v        cg_rvv_zve32x_vl8re8_v = new();
  Cov_rvv_zve32x_vl1re16_v       cg_rvv_zve32x_vl1re16_v = new();
  Cov_rvv_zve32x_vl2re16_v       cg_rvv_zve32x_vl2re16_v = new();
  Cov_rvv_zve32x_vl4re16_v       cg_rvv_zve32x_vl4re16_v = new();
  Cov_rvv_zve32x_vl8re16_v       cg_rvv_zve32x_vl8re16_v = new();
  Cov_rvv_zve32x_vl1re32_v       cg_rvv_zve32x_vl1re32_v = new();
  Cov_rvv_zve32x_vl2re32_v       cg_rvv_zve32x_vl2re32_v = new();
  Cov_rvv_zve32x_vl4re32_v       cg_rvv_zve32x_vl4re32_v = new();
  Cov_rvv_zve32x_vl8re32_v       cg_rvv_zve32x_vl8re32_v = new();
  Cov_rvv_zve32x_vs1r_v          cg_rvv_zve32x_vs1r_v = new();
  Cov_rvv_zve32x_vs2r_v          cg_rvv_zve32x_vs2r_v = new();
  Cov_rvv_zve32x_vs4r_v          cg_rvv_zve32x_vs4r_v = new();
  Cov_rvv_zve32x_vs8r_v          cg_rvv_zve32x_vs8r_v = new();
  forever begin
    @(posedge clk);
    if(~rst_n) begin
    end else begin
      for(int i=0; i<`ISSUE_LANE; i++) begin
        if(rvs_if.insts_valid_rvs2cq[i] && rvs_if.insts_ready_cq2rvs[i]) begin
          case(rvs_if.insts_rvs2cq[i].opcode)
            LOAD:  inst_bin = {rvs_if.insts_rvs2cq[i].bits, 7'b0000111};
            STORE: inst_bin = {rvs_if.insts_rvs2cq[i].bits, 7'b0100111};
            RVV:   inst_bin = {rvs_if.insts_rvs2cq[i].bits, 7'b1010111};
          endcase 
          casez(inst_bin)
            {6'b000000, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vadd_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000000, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vadd_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000000, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vadd_vi.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vsub_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000010, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vsub_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000011, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vrsub_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000011, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vrsub_vi.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b110000, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vwaddu_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b110000, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vwaddu_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b110010, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vwsubu_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b110010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vwsubu_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b110001, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vwadd_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b110001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vwadd_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b110011, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vwsub_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b110011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vwsub_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b110100, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vwaddu_wv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b110100, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vwaddu_wx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b110110, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vwsubu_wv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b110110, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vwsubu_wx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b110101, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vwadd_wv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b110101, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vwadd_wx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b110111, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vwsub_wv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b110111, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vwsub_wx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010010, 1'b?, 5'b?????, 5'b00110, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vzext_vf2.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010010, 1'b?, 5'b?????, 5'b00111, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vsext_vf2.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010010, 1'b?, 5'b?????, 5'b00100, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vzext_vf4.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010010, 1'b?, 5'b?????, 5'b00101, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vsext_vf4.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010000, 1'b0, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vadc_vvm.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010000, 1'b0, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vadc_vxm.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010000, 1'b0, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vadc_vim.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010001, 1'b0, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmadc_vvm.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010001, 1'b0, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmadc_vxm.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010001, 1'b0, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmadc_vim.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010001, 1'b1, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmadc_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010001, 1'b1, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmadc_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010001, 1'b1, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmadc_vi.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010010, 1'b0, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vsbc_vvm.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010010, 1'b0, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vsbc_vxm.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010011, 1'b0, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmsbc_vvm.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010011, 1'b0, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmsbc_vxm.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010011, 1'b1, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmsbc_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010011, 1'b1, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmsbc_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vand_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001001, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vand_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001001, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vand_vi.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vor_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001010, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vor_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001010, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vor_vi.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vxor_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001011, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vxor_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001011, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vxor_vi.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100101, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vsll_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100101, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vsll_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100101, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vsll_vi.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101000, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vsrl_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101000, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vsrl_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101000, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vsrl_vi.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vsra_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101001, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vsra_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101001, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vsra_vi.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101100, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vnsrl_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101100, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vnsrl_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101100, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vnsrl_vi.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101101, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vnsra_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101101, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vnsra_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101101, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vnsra_vi.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011000, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmseq_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011000, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmseq_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011000, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmseq_vi.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmsne_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011001, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmsne_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011001, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmsne_vi.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmsltu_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011010, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmsltu_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmslt_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011011, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmslt_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011100, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmsleu_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011100, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmsleu_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011100, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmsleu_vi.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011101, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmsle_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011101, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmsle_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011101, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmsle_vi.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011110, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmsgtu_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011110, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmsgtu_vi.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011111, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmsgt_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011111, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmsgt_vi.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000100, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vminu_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000100, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vminu_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000101, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmin_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000101, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmin_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000110, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmaxu_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000110, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmaxu_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000111, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmax_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000111, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmax_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100101, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmul_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100101, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmul_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100111, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmulh_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100111, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmulh_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100100, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmulhu_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100100, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmulhu_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100110, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmulhsu_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100110, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmulhsu_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b111011, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vwmul_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b111011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vwmul_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b111000, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vwmulu_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b111000, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vwmulu_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b111010, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vwmulsu_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b111010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vwmulsu_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101101, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmacc_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101101, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmacc_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101111, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vnmsac_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101111, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vnmsac_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101001, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmadd_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmadd_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101011, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vnmsub_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vnmsub_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b111100, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vwmaccu_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b111100, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vwmaccu_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b111101, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vwmacc_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b111101, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vwmacc_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b111111, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vwmaccsu_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b111111, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vwmaccsu_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b111110, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vwmaccus_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100000, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vdivu_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100000, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vdivu_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100001, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vdiv_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vdiv_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100010, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vremu_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vremu_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100011, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vrem_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vrem_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010111, 1'b0, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmerge_vvm.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010111, 1'b0, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmerge_vxm.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010111, 1'b0, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmerge_vim.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010111, 1'b1, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmv_v_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010111, 1'b1, 5'b00000, 5'b?????, 3'b100, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmv_v_x.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010111, 1'b1, 5'b00000, 5'b?????, 3'b011, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmv_v_i.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100000, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vsaddu_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100000, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vsaddu_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100000, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vsaddu_vi.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vsadd_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100001, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vsadd_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100001, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vsadd_vi.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vssubu_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100010, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vssubu_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vssub_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100011, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vssub_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001000, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vaaddu_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001000, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vaaddu_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001001, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vaadd_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vaadd_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001010, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vasubu_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vasubu_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001011, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vasub_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vasub_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100111, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vsmul_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100111, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vsmul_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vssrl_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101010, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vssrl_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101010, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vssrl_vi.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vssra_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101011, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vssra_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101011, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vssra_vi.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101110, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vnclipu_wv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101110, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vnclipu_wx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101110, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vnclipu_wi.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101111, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vnclip_wv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101111, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vnclip_wx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101111, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vnclip_wi.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000000, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vredsum_vs.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000110, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vredmaxu_vs.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000111, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vredmax_vs.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000100, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vredminu_vs.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000101, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vredmin_vs.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000001, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vredand_vs.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000010, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vredor_vs.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000011, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vredxor_vs.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b110000, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vwredsumu_vs.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b110001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vwredsum_vs.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011001, 1'b1, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmand_mm.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011101, 1'b1, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmnand_mm.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011000, 1'b1, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmandn_mm.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011011, 1'b1, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmxor_mm.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011010, 1'b1, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmor_mm.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011110, 1'b1, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmnor_mm.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011100, 1'b1, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmorn_mm.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011111, 1'b1, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmxnor_mm.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010000, 1'b?, 5'b?????, 5'b10000, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vcpop_m.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010000, 1'b?, 5'b?????, 5'b10001, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vfirst_m.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010100, 1'b?, 5'b?????, 5'b00001, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmsbf_m.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010100, 1'b?, 5'b?????, 5'b00011, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmsif_m.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010100, 1'b?, 5'b?????, 5'b00010, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmsof_m.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010100, 1'b?, 5'b?????, 5'b10000, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_viota_m.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010100, 1'b?, 5'b00000, 5'b10001, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vid_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010000, 1'b1, 5'b?????, 5'b00000, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmv_x_s.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010000, 1'b1, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmv_s_x.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001110, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vslideup_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001110, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vslideup_vi.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001111, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vslidedown_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001111, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vslidedown_vi.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001110, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vslide1up_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001111, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vslide1down_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001100, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vrgather_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001110, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vrgatherei16_vv.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001100, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vrgather_vx.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001100, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vrgather_vi.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010111, 1'b1, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vcompress_vm.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100111, 1'b1, 5'b?????, 5'b00000, 3'b011, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmv1r_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100111, 1'b1, 5'b?????, 5'b00001, 3'b011, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmv2r_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100111, 1'b1, 5'b?????, 5'b00011, 3'b011, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmv4r_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100111, 1'b1, 5'b?????, 5'b00111, 3'b011, 5'b?????, 7'b1010111}: cg_rvv_zve32x_vmv8r_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vle8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vle16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vle32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vse8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vse16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vse32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000000, 1'b1, 5'b01011, 5'b?????, 3'b000, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlm_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000000, 1'b1, 5'b01011, 5'b?????, 3'b000, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsm_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlse8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlse16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlse32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsse8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsse16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsse32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vluxei8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vluxei16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vluxei32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vloxei8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vloxei16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vloxei32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsuxei8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsuxei16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsuxei32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsoxei8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsoxei16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsoxei32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000000, 1'b?, 5'b10000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vle8ff_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000000, 1'b?, 5'b10000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vle16ff_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000000, 1'b?, 5'b10000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vle32ff_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlseg2e8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlseg3e8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlseg4e8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlseg5e8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlseg6e8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b110000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlseg7e8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b111000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlseg8e8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlseg2e16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlseg3e16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlseg4e16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlseg5e16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlseg6e16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b110000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlseg7e16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b111000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlseg8e16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlseg2e32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlseg3e32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlseg4e32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlseg5e32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlseg6e32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b110000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlseg7e32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b111000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlseg8e32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsseg2e8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsseg3e8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsseg4e8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsseg5e8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsseg6e8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b110000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsseg7e8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b111000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsseg8e8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsseg2e16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsseg3e16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsseg4e16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsseg5e16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsseg6e16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b110000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsseg7e16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b111000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsseg8e16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsseg2e32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsseg3e32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsseg4e32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsseg5e32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsseg6e32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b110000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsseg7e32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b111000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsseg8e32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001000, 1'b?, 5'b10000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlseg2e8ff_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010000, 1'b?, 5'b10000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlseg3e8ff_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011000, 1'b?, 5'b10000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlseg4e8ff_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100000, 1'b?, 5'b10000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlseg5e8ff_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101000, 1'b?, 5'b10000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlseg6e8ff_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b110000, 1'b?, 5'b10000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlseg7e8ff_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b111000, 1'b?, 5'b10000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlseg8e8ff_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001000, 1'b?, 5'b10000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlseg2e16ff_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010000, 1'b?, 5'b10000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlseg3e16ff_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011000, 1'b?, 5'b10000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlseg4e16ff_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100000, 1'b?, 5'b10000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlseg5e16ff_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101000, 1'b?, 5'b10000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlseg6e16ff_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b110000, 1'b?, 5'b10000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlseg7e16ff_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b111000, 1'b?, 5'b10000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlseg8e16ff_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001000, 1'b?, 5'b10000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlseg2e32ff_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010000, 1'b?, 5'b10000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlseg3e32ff_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011000, 1'b?, 5'b10000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlseg4e32ff_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100000, 1'b?, 5'b10000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlseg5e32ff_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101000, 1'b?, 5'b10000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlseg6e32ff_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b110000, 1'b?, 5'b10000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlseg7e32ff_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b111000, 1'b?, 5'b10000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlseg8e32ff_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlsseg2e8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlsseg3e8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlsseg4e8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlsseg5e8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlsseg6e8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b110010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlsseg7e8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b111010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlsseg8e8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlsseg2e16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlsseg3e16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlsseg4e16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlsseg5e16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlsseg6e16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b110010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlsseg7e16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b111010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlsseg8e16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlsseg2e32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlsseg3e32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlsseg4e32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlsseg5e32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlsseg6e32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b110010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlsseg7e32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b111010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vlsseg8e32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vssseg2e8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vssseg3e8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vssseg4e8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vssseg5e8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vssseg6e8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b110010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vssseg7e8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b111010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vssseg8e8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vssseg2e16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vssseg3e16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vssseg4e16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vssseg5e16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vssseg6e16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b110010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vssseg7e16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b111010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vssseg8e16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vssseg2e32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vssseg3e32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vssseg4e32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vssseg5e32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vssseg6e32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b110010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vssseg7e32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b111010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vssseg8e32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vluxseg2ei8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vluxseg3ei8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vluxseg4ei8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vluxseg5ei8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vluxseg6ei8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b110001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vluxseg7ei8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b111001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vluxseg8ei8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vluxseg2ei16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vluxseg3ei16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vluxseg4ei16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vluxseg5ei16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vluxseg6ei16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b110001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vluxseg7ei16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b111001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vluxseg8ei16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vluxseg2ei32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vluxseg3ei32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vluxseg4ei32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vluxseg5ei32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vluxseg6ei32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b110001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vluxseg7ei32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b111001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vluxseg8ei32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vloxseg2ei8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vloxseg3ei8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vloxseg4ei8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vloxseg5ei8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vloxseg6ei8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b110011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vloxseg7ei8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b111011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vloxseg8ei8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vloxseg2ei16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vloxseg3ei16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vloxseg4ei16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vloxseg5ei16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vloxseg6ei16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b110011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vloxseg7ei16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b111011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vloxseg8ei16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vloxseg2ei32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vloxseg3ei32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vloxseg4ei32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vloxseg5ei32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vloxseg6ei32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b110011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vloxseg7ei32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b111011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vloxseg8ei32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsuxseg2ei8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsuxseg3ei8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsuxseg4ei8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsuxseg5ei8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsuxseg6ei8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b110001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsuxseg7ei8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b111001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsuxseg8ei8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsuxseg2ei16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsuxseg3ei16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsuxseg4ei16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsuxseg5ei16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsuxseg6ei16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b110001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsuxseg7ei16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b111001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsuxseg8ei16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsuxseg2ei32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsuxseg3ei32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsuxseg4ei32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsuxseg5ei32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsuxseg6ei32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b110001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsuxseg7ei32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b111001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsuxseg8ei32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsoxseg2ei8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsoxseg3ei8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsoxseg4ei8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsoxseg5ei8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsoxseg6ei8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b110011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsoxseg7ei8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b111011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsoxseg8ei8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsoxseg2ei16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsoxseg3ei16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsoxseg4ei16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsoxseg5ei16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsoxseg6ei16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b110011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsoxseg7ei16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b111011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsoxseg8ei16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsoxseg2ei32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b010011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsoxseg3ei32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsoxseg4ei32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b100011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsoxseg5ei32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b101011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsoxseg6ei32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b110011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsoxseg7ei32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b111011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vsoxseg8ei32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000000, 1'b1, 5'b01000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vl1re8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001000, 1'b1, 5'b01000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vl2re8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011000, 1'b1, 5'b01000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vl4re8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b111000, 1'b1, 5'b01000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vl8re8_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000000, 1'b1, 5'b01000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vl1re16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001000, 1'b1, 5'b01000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vl2re16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011000, 1'b1, 5'b01000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vl4re16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b111000, 1'b1, 5'b01000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vl8re16_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000000, 1'b1, 5'b01000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vl1re32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001000, 1'b1, 5'b01000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vl2re32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011000, 1'b1, 5'b01000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vl4re32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b111000, 1'b1, 5'b01000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}: cg_rvv_zve32x_vl8re32_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b000000, 1'b1, 5'b01000, 5'b?????, 3'b000, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vs1r_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b001000, 1'b1, 5'b01000, 5'b?????, 3'b000, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vs2r_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b011000, 1'b1, 5'b01000, 5'b?????, 3'b000, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vs4r_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
            {6'b111000, 1'b1, 5'b01000, 5'b?????, 3'b000, 5'b?????, 7'b0100111}: cg_rvv_zve32x_vs8r_v.sample(inst_bin, rvs_if.insts_rvs2cq[i].arch_state.sew, rvs_if.insts_rvs2cq[i].arch_state.lmul, rvs_if.insts_rvs2cq[i].arch_state.xrm, rvs_if.insts_rvs2cq[i].arch_state.vl, rvs_if.insts_rvs2cq[i].arch_state.vstart);
          endcase
        end
      end
    end // if(~rst_n)
  end // forever
end: rvv_zve32x_coverage_sample

// inst count coverage ---------------------------------------------------------
covergroup Cov_rvv_zve32x_inst_count with function sample(input logic [31:0] inst);  cp_inst:
    coverpoint inst {
      wildcard bins vadd_vv         = {{6'b000000, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}};
      wildcard bins vadd_vx         = {{6'b000000, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}};
      wildcard bins vadd_vi         = {{6'b000000, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}};
      wildcard bins vsub_vv         = {{6'b000010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}};
      wildcard bins vsub_vx         = {{6'b000010, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}};
      wildcard bins vrsub_vx        = {{6'b000011, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}};
      wildcard bins vrsub_vi        = {{6'b000011, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}};
      wildcard bins vwaddu_vv       = {{6'b110000, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vwaddu_vx       = {{6'b110000, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}};
      wildcard bins vwsubu_vv       = {{6'b110010, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vwsubu_vx       = {{6'b110010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}};
      wildcard bins vwadd_vv        = {{6'b110001, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vwadd_vx        = {{6'b110001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}};
      wildcard bins vwsub_vv        = {{6'b110011, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vwsub_vx        = {{6'b110011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}};
      wildcard bins vwaddu_wv       = {{6'b110100, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vwaddu_wx       = {{6'b110100, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}};
      wildcard bins vwsubu_wv       = {{6'b110110, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vwsubu_wx       = {{6'b110110, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}};
      wildcard bins vwadd_wv        = {{6'b110101, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vwadd_wx        = {{6'b110101, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}};
      wildcard bins vwsub_wv        = {{6'b110111, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vwsub_wx        = {{6'b110111, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}};
      wildcard bins vzext_vf2       = {{6'b010010, 1'b?, 5'b?????, 5'b00110, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vsext_vf2       = {{6'b010010, 1'b?, 5'b?????, 5'b00111, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vzext_vf4       = {{6'b010010, 1'b?, 5'b?????, 5'b00100, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vsext_vf4       = {{6'b010010, 1'b?, 5'b?????, 5'b00101, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vadc_vvm        = {{6'b010000, 1'b0, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}};
      wildcard bins vadc_vxm        = {{6'b010000, 1'b0, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}};
      wildcard bins vadc_vim        = {{6'b010000, 1'b0, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}};
      wildcard bins vmadc_vvm       = {{6'b010001, 1'b0, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}};
      wildcard bins vmadc_vxm       = {{6'b010001, 1'b0, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}};
      wildcard bins vmadc_vim       = {{6'b010001, 1'b0, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}};
      wildcard bins vmadc_vv        = {{6'b010001, 1'b1, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}};
      wildcard bins vmadc_vx        = {{6'b010001, 1'b1, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}};
      wildcard bins vmadc_vi        = {{6'b010001, 1'b1, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}};
      wildcard bins vsbc_vvm        = {{6'b010010, 1'b0, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}};
      wildcard bins vsbc_vxm        = {{6'b010010, 1'b0, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}};
      wildcard bins vmsbc_vvm       = {{6'b010011, 1'b0, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}};
      wildcard bins vmsbc_vxm       = {{6'b010011, 1'b0, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}};
      wildcard bins vmsbc_vv        = {{6'b010011, 1'b1, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}};
      wildcard bins vmsbc_vx        = {{6'b010011, 1'b1, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}};
      wildcard bins vand_vv         = {{6'b001001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}};
      wildcard bins vand_vx         = {{6'b001001, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}};
      wildcard bins vand_vi         = {{6'b001001, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}};
      wildcard bins vor_vv          = {{6'b001010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}};
      wildcard bins vor_vx          = {{6'b001010, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}};
      wildcard bins vor_vi          = {{6'b001010, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}};
      wildcard bins vxor_vv         = {{6'b001011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}};
      wildcard bins vxor_vx         = {{6'b001011, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}};
      wildcard bins vxor_vi         = {{6'b001011, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}};
      wildcard bins vsll_vv         = {{6'b100101, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}};
      wildcard bins vsll_vx         = {{6'b100101, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}};
      wildcard bins vsll_vi         = {{6'b100101, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}};
      wildcard bins vsrl_vv         = {{6'b101000, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}};
      wildcard bins vsrl_vx         = {{6'b101000, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}};
      wildcard bins vsrl_vi         = {{6'b101000, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}};
      wildcard bins vsra_vv         = {{6'b101001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}};
      wildcard bins vsra_vx         = {{6'b101001, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}};
      wildcard bins vsra_vi         = {{6'b101001, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}};
      wildcard bins vnsrl_vv        = {{6'b101100, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}};
      wildcard bins vnsrl_vx        = {{6'b101100, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}};
      wildcard bins vnsrl_vi        = {{6'b101100, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}};
      wildcard bins vnsra_vv        = {{6'b101101, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}};
      wildcard bins vnsra_vx        = {{6'b101101, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}};
      wildcard bins vnsra_vi        = {{6'b101101, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}};
      wildcard bins vmseq_vv        = {{6'b011000, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}};
      wildcard bins vmseq_vx        = {{6'b011000, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}};
      wildcard bins vmseq_vi        = {{6'b011000, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}};
      wildcard bins vmsne_vv        = {{6'b011001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}};
      wildcard bins vmsne_vx        = {{6'b011001, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}};
      wildcard bins vmsne_vi        = {{6'b011001, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}};
      wildcard bins vmsltu_vv       = {{6'b011010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}};
      wildcard bins vmsltu_vx       = {{6'b011010, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}};
      wildcard bins vmslt_vv        = {{6'b011011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}};
      wildcard bins vmslt_vx        = {{6'b011011, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}};
      wildcard bins vmsleu_vv       = {{6'b011100, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}};
      wildcard bins vmsleu_vx       = {{6'b011100, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}};
      wildcard bins vmsleu_vi       = {{6'b011100, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}};
      wildcard bins vmsle_vv        = {{6'b011101, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}};
      wildcard bins vmsle_vx        = {{6'b011101, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}};
      wildcard bins vmsle_vi        = {{6'b011101, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}};
      wildcard bins vmsgtu_vx       = {{6'b011110, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}};
      wildcard bins vmsgtu_vi       = {{6'b011110, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}};
      wildcard bins vmsgt_vx        = {{6'b011111, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}};
      wildcard bins vmsgt_vi        = {{6'b011111, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}};
      wildcard bins vminu_vv        = {{6'b000100, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}};
      wildcard bins vminu_vx        = {{6'b000100, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}};
      wildcard bins vmin_vv         = {{6'b000101, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}};
      wildcard bins vmin_vx         = {{6'b000101, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}};
      wildcard bins vmaxu_vv        = {{6'b000110, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}};
      wildcard bins vmaxu_vx        = {{6'b000110, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}};
      wildcard bins vmax_vv         = {{6'b000111, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}};
      wildcard bins vmax_vx         = {{6'b000111, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}};
      wildcard bins vmul_vv         = {{6'b100101, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vmul_vx         = {{6'b100101, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}};
      wildcard bins vmulh_vv        = {{6'b100111, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vmulh_vx        = {{6'b100111, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}};
      wildcard bins vmulhu_vv       = {{6'b100100, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vmulhu_vx       = {{6'b100100, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}};
      wildcard bins vmulhsu_vv      = {{6'b100110, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vmulhsu_vx      = {{6'b100110, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}};
      wildcard bins vwmul_vv        = {{6'b111011, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vwmul_vx        = {{6'b111011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}};
      wildcard bins vwmulu_vv       = {{6'b111000, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vwmulu_vx       = {{6'b111000, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}};
      wildcard bins vwmulsu_vv      = {{6'b111010, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vwmulsu_vx      = {{6'b111010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}};
      wildcard bins vmacc_vv        = {{6'b101101, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vmacc_vx        = {{6'b101101, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}};
      wildcard bins vnmsac_vv       = {{6'b101111, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vnmsac_vx       = {{6'b101111, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}};
      wildcard bins vmadd_vv        = {{6'b101001, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vmadd_vx        = {{6'b101001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}};
      wildcard bins vnmsub_vv       = {{6'b101011, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vnmsub_vx       = {{6'b101011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}};
      wildcard bins vwmaccu_vv      = {{6'b111100, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vwmaccu_vx      = {{6'b111100, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}};
      wildcard bins vwmacc_vv       = {{6'b111101, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vwmacc_vx       = {{6'b111101, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}};
      wildcard bins vwmaccsu_vv     = {{6'b111111, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vwmaccsu_vx     = {{6'b111111, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}};
      wildcard bins vwmaccus_vx     = {{6'b111110, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}};
      wildcard bins vdivu_vv        = {{6'b100000, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vdivu_vx        = {{6'b100000, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}};
      wildcard bins vdiv_vv         = {{6'b100001, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vdiv_vx         = {{6'b100001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}};
      wildcard bins vremu_vv        = {{6'b100010, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vremu_vx        = {{6'b100010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}};
      wildcard bins vrem_vv         = {{6'b100011, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vrem_vx         = {{6'b100011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}};
      wildcard bins vmerge_vvm      = {{6'b010111, 1'b0, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}};
      wildcard bins vmerge_vxm      = {{6'b010111, 1'b0, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}};
      wildcard bins vmerge_vim      = {{6'b010111, 1'b0, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}};
      wildcard bins vmv_v_v         = {{6'b010111, 1'b1, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b1010111}};
      wildcard bins vmv_v_x         = {{6'b010111, 1'b1, 5'b00000, 5'b?????, 3'b100, 5'b?????, 7'b1010111}};
      wildcard bins vmv_v_i         = {{6'b010111, 1'b1, 5'b00000, 5'b?????, 3'b011, 5'b?????, 7'b1010111}};
      wildcard bins vsaddu_vv       = {{6'b100000, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}};
      wildcard bins vsaddu_vx       = {{6'b100000, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}};
      wildcard bins vsaddu_vi       = {{6'b100000, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}};
      wildcard bins vsadd_vv        = {{6'b100001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}};
      wildcard bins vsadd_vx        = {{6'b100001, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}};
      wildcard bins vsadd_vi        = {{6'b100001, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}};
      wildcard bins vssubu_vv       = {{6'b100010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}};
      wildcard bins vssubu_vx       = {{6'b100010, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}};
      wildcard bins vssub_vv        = {{6'b100011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}};
      wildcard bins vssub_vx        = {{6'b100011, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}};
      wildcard bins vaaddu_vv       = {{6'b001000, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vaaddu_vx       = {{6'b001000, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}};
      wildcard bins vaadd_vv        = {{6'b001001, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vaadd_vx        = {{6'b001001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}};
      wildcard bins vasubu_vv       = {{6'b001010, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vasubu_vx       = {{6'b001010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}};
      wildcard bins vasub_vv        = {{6'b001011, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vasub_vx        = {{6'b001011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}};
      wildcard bins vsmul_vv        = {{6'b100111, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}};
      wildcard bins vsmul_vx        = {{6'b100111, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}};
      wildcard bins vssrl_vv        = {{6'b101010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}};
      wildcard bins vssrl_vx        = {{6'b101010, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}};
      wildcard bins vssrl_vi        = {{6'b101010, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}};
      wildcard bins vssra_vv        = {{6'b101011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}};
      wildcard bins vssra_vx        = {{6'b101011, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}};
      wildcard bins vssra_vi        = {{6'b101011, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}};
      wildcard bins vnclipu_wv      = {{6'b101110, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}};
      wildcard bins vnclipu_wx      = {{6'b101110, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}};
      wildcard bins vnclipu_wi      = {{6'b101110, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}};
      wildcard bins vnclip_wv       = {{6'b101111, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}};
      wildcard bins vnclip_wx       = {{6'b101111, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}};
      wildcard bins vnclip_wi       = {{6'b101111, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}};
      wildcard bins vredsum_vs      = {{6'b000000, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vredmaxu_vs     = {{6'b000110, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vredmax_vs      = {{6'b000111, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vredminu_vs     = {{6'b000100, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vredmin_vs      = {{6'b000101, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vredand_vs      = {{6'b000001, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vredor_vs       = {{6'b000010, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vredxor_vs      = {{6'b000011, 1'b?, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vwredsumu_vs    = {{6'b110000, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}};
      wildcard bins vwredsum_vs     = {{6'b110001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}};
      wildcard bins vmand_mm        = {{6'b011001, 1'b1, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vmnand_mm       = {{6'b011101, 1'b1, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vmandn_mm       = {{6'b011000, 1'b1, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vmxor_mm        = {{6'b011011, 1'b1, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vmor_mm         = {{6'b011010, 1'b1, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vmnor_mm        = {{6'b011110, 1'b1, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vmorn_mm        = {{6'b011100, 1'b1, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vmxnor_mm       = {{6'b011111, 1'b1, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vcpop_m         = {{6'b010000, 1'b?, 5'b?????, 5'b10000, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vfirst_m        = {{6'b010000, 1'b?, 5'b?????, 5'b10001, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vmsbf_m         = {{6'b010100, 1'b?, 5'b?????, 5'b00001, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vmsif_m         = {{6'b010100, 1'b?, 5'b?????, 5'b00011, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vmsof_m         = {{6'b010100, 1'b?, 5'b?????, 5'b00010, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins viota_m         = {{6'b010100, 1'b?, 5'b?????, 5'b10000, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vid_v           = {{6'b010100, 1'b?, 5'b00000, 5'b10001, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vmv_x_s         = {{6'b010000, 1'b1, 5'b?????, 5'b00000, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vmv_s_x         = {{6'b010000, 1'b1, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b1010111}};
      wildcard bins vslideup_vx     = {{6'b001110, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}};
      wildcard bins vslideup_vi     = {{6'b001110, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}};
      wildcard bins vslidedown_vx   = {{6'b001111, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}};
      wildcard bins vslidedown_vi   = {{6'b001111, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}};
      wildcard bins vslide1up_vx    = {{6'b001110, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}};
      wildcard bins vslide1down_vx  = {{6'b001111, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b1010111}};
      wildcard bins vrgather_vv     = {{6'b001100, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}};
      wildcard bins vrgatherei16_vv = {{6'b001110, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b1010111}};
      wildcard bins vrgather_vx     = {{6'b001100, 1'b?, 5'b?????, 5'b?????, 3'b100, 5'b?????, 7'b1010111}};
      wildcard bins vrgather_vi     = {{6'b001100, 1'b?, 5'b?????, 5'b?????, 3'b011, 5'b?????, 7'b1010111}};
      wildcard bins vcompress_vm    = {{6'b010111, 1'b1, 5'b?????, 5'b?????, 3'b010, 5'b?????, 7'b1010111}};
      wildcard bins vmv1r_v         = {{6'b100111, 1'b1, 5'b?????, 5'b00000, 3'b011, 5'b?????, 7'b1010111}};
      wildcard bins vmv2r_v         = {{6'b100111, 1'b1, 5'b?????, 5'b00001, 3'b011, 5'b?????, 7'b1010111}};
      wildcard bins vmv4r_v         = {{6'b100111, 1'b1, 5'b?????, 5'b00011, 3'b011, 5'b?????, 7'b1010111}};
      wildcard bins vmv8r_v         = {{6'b100111, 1'b1, 5'b?????, 5'b00111, 3'b011, 5'b?????, 7'b1010111}};
      wildcard bins vle8_v          = {{6'b000000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}};
      wildcard bins vle16_v         = {{6'b000000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}};
      wildcard bins vle32_v         = {{6'b000000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}};
      wildcard bins vse8_v          = {{6'b000000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0100111}};
      wildcard bins vse16_v         = {{6'b000000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0100111}};
      wildcard bins vse32_v         = {{6'b000000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0100111}};
      wildcard bins vlm_v           = {{6'b000000, 1'b1, 5'b01011, 5'b?????, 3'b000, 5'b?????, 7'b0000111}};
      wildcard bins vsm_v           = {{6'b000000, 1'b1, 5'b01011, 5'b?????, 3'b000, 5'b?????, 7'b0100111}};
      wildcard bins vlse8_v         = {{6'b000010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}};
      wildcard bins vlse16_v        = {{6'b000010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}};
      wildcard bins vlse32_v        = {{6'b000010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}};
      wildcard bins vsse8_v         = {{6'b000010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}};
      wildcard bins vsse16_v        = {{6'b000010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}};
      wildcard bins vsse32_v        = {{6'b000010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}};
      wildcard bins vluxei8_v       = {{6'b000001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}};
      wildcard bins vluxei16_v      = {{6'b000001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}};
      wildcard bins vluxei32_v      = {{6'b000001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}};
      wildcard bins vloxei8_v       = {{6'b000011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}};
      wildcard bins vloxei16_v      = {{6'b000011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}};
      wildcard bins vloxei32_v      = {{6'b000011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}};
      wildcard bins vsuxei8_v       = {{6'b000001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}};
      wildcard bins vsuxei16_v      = {{6'b000001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}};
      wildcard bins vsuxei32_v      = {{6'b000001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}};
      wildcard bins vsoxei8_v       = {{6'b000011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}};
      wildcard bins vsoxei16_v      = {{6'b000011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}};
      wildcard bins vsoxei32_v      = {{6'b000011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}};
      wildcard bins vle8ff_v        = {{6'b000000, 1'b?, 5'b10000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}};
      wildcard bins vle16ff_v       = {{6'b000000, 1'b?, 5'b10000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}};
      wildcard bins vle32ff_v       = {{6'b000000, 1'b?, 5'b10000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}};
      wildcard bins vlseg2e8_v      = {{6'b001000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}};
      wildcard bins vlseg3e8_v      = {{6'b010000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}};
      wildcard bins vlseg4e8_v      = {{6'b011000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}};
      wildcard bins vlseg5e8_v      = {{6'b100000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}};
      wildcard bins vlseg6e8_v      = {{6'b101000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}};
      wildcard bins vlseg7e8_v      = {{6'b110000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}};
      wildcard bins vlseg8e8_v      = {{6'b111000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}};
      wildcard bins vlseg2e16_v     = {{6'b001000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}};
      wildcard bins vlseg3e16_v     = {{6'b010000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}};
      wildcard bins vlseg4e16_v     = {{6'b011000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}};
      wildcard bins vlseg5e16_v     = {{6'b100000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}};
      wildcard bins vlseg6e16_v     = {{6'b101000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}};
      wildcard bins vlseg7e16_v     = {{6'b110000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}};
      wildcard bins vlseg8e16_v     = {{6'b111000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}};
      wildcard bins vlseg2e32_v     = {{6'b001000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}};
      wildcard bins vlseg3e32_v     = {{6'b010000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}};
      wildcard bins vlseg4e32_v     = {{6'b011000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}};
      wildcard bins vlseg5e32_v     = {{6'b100000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}};
      wildcard bins vlseg6e32_v     = {{6'b101000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}};
      wildcard bins vlseg7e32_v     = {{6'b110000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}};
      wildcard bins vlseg8e32_v     = {{6'b111000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}};
      wildcard bins vsseg2e8_v      = {{6'b001000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0100111}};
      wildcard bins vsseg3e8_v      = {{6'b010000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0100111}};
      wildcard bins vsseg4e8_v      = {{6'b011000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0100111}};
      wildcard bins vsseg5e8_v      = {{6'b100000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0100111}};
      wildcard bins vsseg6e8_v      = {{6'b101000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0100111}};
      wildcard bins vsseg7e8_v      = {{6'b110000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0100111}};
      wildcard bins vsseg8e8_v      = {{6'b111000, 1'b?, 5'b00000, 5'b?????, 3'b000, 5'b?????, 7'b0100111}};
      wildcard bins vsseg2e16_v     = {{6'b001000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0100111}};
      wildcard bins vsseg3e16_v     = {{6'b010000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0100111}};
      wildcard bins vsseg4e16_v     = {{6'b011000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0100111}};
      wildcard bins vsseg5e16_v     = {{6'b100000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0100111}};
      wildcard bins vsseg6e16_v     = {{6'b101000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0100111}};
      wildcard bins vsseg7e16_v     = {{6'b110000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0100111}};
      wildcard bins vsseg8e16_v     = {{6'b111000, 1'b?, 5'b00000, 5'b?????, 3'b101, 5'b?????, 7'b0100111}};
      wildcard bins vsseg2e32_v     = {{6'b001000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0100111}};
      wildcard bins vsseg3e32_v     = {{6'b010000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0100111}};
      wildcard bins vsseg4e32_v     = {{6'b011000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0100111}};
      wildcard bins vsseg5e32_v     = {{6'b100000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0100111}};
      wildcard bins vsseg6e32_v     = {{6'b101000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0100111}};
      wildcard bins vsseg7e32_v     = {{6'b110000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0100111}};
      wildcard bins vsseg8e32_v     = {{6'b111000, 1'b?, 5'b00000, 5'b?????, 3'b110, 5'b?????, 7'b0100111}};
      wildcard bins vlseg2e8ff_v    = {{6'b001000, 1'b?, 5'b10000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}};
      wildcard bins vlseg3e8ff_v    = {{6'b010000, 1'b?, 5'b10000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}};
      wildcard bins vlseg4e8ff_v    = {{6'b011000, 1'b?, 5'b10000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}};
      wildcard bins vlseg5e8ff_v    = {{6'b100000, 1'b?, 5'b10000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}};
      wildcard bins vlseg6e8ff_v    = {{6'b101000, 1'b?, 5'b10000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}};
      wildcard bins vlseg7e8ff_v    = {{6'b110000, 1'b?, 5'b10000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}};
      wildcard bins vlseg8e8ff_v    = {{6'b111000, 1'b?, 5'b10000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}};
      wildcard bins vlseg2e16ff_v   = {{6'b001000, 1'b?, 5'b10000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}};
      wildcard bins vlseg3e16ff_v   = {{6'b010000, 1'b?, 5'b10000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}};
      wildcard bins vlseg4e16ff_v   = {{6'b011000, 1'b?, 5'b10000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}};
      wildcard bins vlseg5e16ff_v   = {{6'b100000, 1'b?, 5'b10000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}};
      wildcard bins vlseg6e16ff_v   = {{6'b101000, 1'b?, 5'b10000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}};
      wildcard bins vlseg7e16ff_v   = {{6'b110000, 1'b?, 5'b10000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}};
      wildcard bins vlseg8e16ff_v   = {{6'b111000, 1'b?, 5'b10000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}};
      wildcard bins vlseg2e32ff_v   = {{6'b001000, 1'b?, 5'b10000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}};
      wildcard bins vlseg3e32ff_v   = {{6'b010000, 1'b?, 5'b10000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}};
      wildcard bins vlseg4e32ff_v   = {{6'b011000, 1'b?, 5'b10000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}};
      wildcard bins vlseg5e32ff_v   = {{6'b100000, 1'b?, 5'b10000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}};
      wildcard bins vlseg6e32ff_v   = {{6'b101000, 1'b?, 5'b10000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}};
      wildcard bins vlseg7e32ff_v   = {{6'b110000, 1'b?, 5'b10000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}};
      wildcard bins vlseg8e32ff_v   = {{6'b111000, 1'b?, 5'b10000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}};
      wildcard bins vlsseg2e8_v     = {{6'b001010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}};
      wildcard bins vlsseg3e8_v     = {{6'b010010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}};
      wildcard bins vlsseg4e8_v     = {{6'b011010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}};
      wildcard bins vlsseg5e8_v     = {{6'b100010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}};
      wildcard bins vlsseg6e8_v     = {{6'b101010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}};
      wildcard bins vlsseg7e8_v     = {{6'b110010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}};
      wildcard bins vlsseg8e8_v     = {{6'b111010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}};
      wildcard bins vlsseg2e16_v    = {{6'b001010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}};
      wildcard bins vlsseg3e16_v    = {{6'b010010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}};
      wildcard bins vlsseg4e16_v    = {{6'b011010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}};
      wildcard bins vlsseg5e16_v    = {{6'b100010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}};
      wildcard bins vlsseg6e16_v    = {{6'b101010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}};
      wildcard bins vlsseg7e16_v    = {{6'b110010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}};
      wildcard bins vlsseg8e16_v    = {{6'b111010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}};
      wildcard bins vlsseg2e32_v    = {{6'b001010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}};
      wildcard bins vlsseg3e32_v    = {{6'b010010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}};
      wildcard bins vlsseg4e32_v    = {{6'b011010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}};
      wildcard bins vlsseg5e32_v    = {{6'b100010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}};
      wildcard bins vlsseg6e32_v    = {{6'b101010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}};
      wildcard bins vlsseg7e32_v    = {{6'b110010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}};
      wildcard bins vlsseg8e32_v    = {{6'b111010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}};
      wildcard bins vssseg2e8_v     = {{6'b001010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}};
      wildcard bins vssseg3e8_v     = {{6'b010010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}};
      wildcard bins vssseg4e8_v     = {{6'b011010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}};
      wildcard bins vssseg5e8_v     = {{6'b100010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}};
      wildcard bins vssseg6e8_v     = {{6'b101010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}};
      wildcard bins vssseg7e8_v     = {{6'b110010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}};
      wildcard bins vssseg8e8_v     = {{6'b111010, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}};
      wildcard bins vssseg2e16_v    = {{6'b001010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}};
      wildcard bins vssseg3e16_v    = {{6'b010010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}};
      wildcard bins vssseg4e16_v    = {{6'b011010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}};
      wildcard bins vssseg5e16_v    = {{6'b100010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}};
      wildcard bins vssseg6e16_v    = {{6'b101010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}};
      wildcard bins vssseg7e16_v    = {{6'b110010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}};
      wildcard bins vssseg8e16_v    = {{6'b111010, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}};
      wildcard bins vssseg2e32_v    = {{6'b001010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}};
      wildcard bins vssseg3e32_v    = {{6'b010010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}};
      wildcard bins vssseg4e32_v    = {{6'b011010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}};
      wildcard bins vssseg5e32_v    = {{6'b100010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}};
      wildcard bins vssseg6e32_v    = {{6'b101010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}};
      wildcard bins vssseg7e32_v    = {{6'b110010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}};
      wildcard bins vssseg8e32_v    = {{6'b111010, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}};
      wildcard bins vluxseg2ei8_v   = {{6'b001001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}};
      wildcard bins vluxseg3ei8_v   = {{6'b010001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}};
      wildcard bins vluxseg4ei8_v   = {{6'b011001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}};
      wildcard bins vluxseg5ei8_v   = {{6'b100001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}};
      wildcard bins vluxseg6ei8_v   = {{6'b101001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}};
      wildcard bins vluxseg7ei8_v   = {{6'b110001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}};
      wildcard bins vluxseg8ei8_v   = {{6'b111001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}};
      wildcard bins vluxseg2ei16_v  = {{6'b001001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}};
      wildcard bins vluxseg3ei16_v  = {{6'b010001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}};
      wildcard bins vluxseg4ei16_v  = {{6'b011001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}};
      wildcard bins vluxseg5ei16_v  = {{6'b100001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}};
      wildcard bins vluxseg6ei16_v  = {{6'b101001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}};
      wildcard bins vluxseg7ei16_v  = {{6'b110001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}};
      wildcard bins vluxseg8ei16_v  = {{6'b111001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}};
      wildcard bins vluxseg2ei32_v  = {{6'b001001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}};
      wildcard bins vluxseg3ei32_v  = {{6'b010001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}};
      wildcard bins vluxseg4ei32_v  = {{6'b011001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}};
      wildcard bins vluxseg5ei32_v  = {{6'b100001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}};
      wildcard bins vluxseg6ei32_v  = {{6'b101001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}};
      wildcard bins vluxseg7ei32_v  = {{6'b110001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}};
      wildcard bins vluxseg8ei32_v  = {{6'b111001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}};
      wildcard bins vloxseg2ei8_v   = {{6'b001011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}};
      wildcard bins vloxseg3ei8_v   = {{6'b010011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}};
      wildcard bins vloxseg4ei8_v   = {{6'b011011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}};
      wildcard bins vloxseg5ei8_v   = {{6'b100011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}};
      wildcard bins vloxseg6ei8_v   = {{6'b101011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}};
      wildcard bins vloxseg7ei8_v   = {{6'b110011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}};
      wildcard bins vloxseg8ei8_v   = {{6'b111011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0000111}};
      wildcard bins vloxseg2ei16_v  = {{6'b001011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}};
      wildcard bins vloxseg3ei16_v  = {{6'b010011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}};
      wildcard bins vloxseg4ei16_v  = {{6'b011011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}};
      wildcard bins vloxseg5ei16_v  = {{6'b100011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}};
      wildcard bins vloxseg6ei16_v  = {{6'b101011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}};
      wildcard bins vloxseg7ei16_v  = {{6'b110011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}};
      wildcard bins vloxseg8ei16_v  = {{6'b111011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0000111}};
      wildcard bins vloxseg2ei32_v  = {{6'b001011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}};
      wildcard bins vloxseg3ei32_v  = {{6'b010011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}};
      wildcard bins vloxseg4ei32_v  = {{6'b011011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}};
      wildcard bins vloxseg5ei32_v  = {{6'b100011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}};
      wildcard bins vloxseg6ei32_v  = {{6'b101011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}};
      wildcard bins vloxseg7ei32_v  = {{6'b110011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}};
      wildcard bins vloxseg8ei32_v  = {{6'b111011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0000111}};
      wildcard bins vsuxseg2ei8_v   = {{6'b001001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}};
      wildcard bins vsuxseg3ei8_v   = {{6'b010001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}};
      wildcard bins vsuxseg4ei8_v   = {{6'b011001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}};
      wildcard bins vsuxseg5ei8_v   = {{6'b100001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}};
      wildcard bins vsuxseg6ei8_v   = {{6'b101001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}};
      wildcard bins vsuxseg7ei8_v   = {{6'b110001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}};
      wildcard bins vsuxseg8ei8_v   = {{6'b111001, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}};
      wildcard bins vsuxseg2ei16_v  = {{6'b001001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}};
      wildcard bins vsuxseg3ei16_v  = {{6'b010001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}};
      wildcard bins vsuxseg4ei16_v  = {{6'b011001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}};
      wildcard bins vsuxseg5ei16_v  = {{6'b100001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}};
      wildcard bins vsuxseg6ei16_v  = {{6'b101001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}};
      wildcard bins vsuxseg7ei16_v  = {{6'b110001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}};
      wildcard bins vsuxseg8ei16_v  = {{6'b111001, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}};
      wildcard bins vsuxseg2ei32_v  = {{6'b001001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}};
      wildcard bins vsuxseg3ei32_v  = {{6'b010001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}};
      wildcard bins vsuxseg4ei32_v  = {{6'b011001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}};
      wildcard bins vsuxseg5ei32_v  = {{6'b100001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}};
      wildcard bins vsuxseg6ei32_v  = {{6'b101001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}};
      wildcard bins vsuxseg7ei32_v  = {{6'b110001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}};
      wildcard bins vsuxseg8ei32_v  = {{6'b111001, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}};
      wildcard bins vsoxseg2ei8_v   = {{6'b001011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}};
      wildcard bins vsoxseg3ei8_v   = {{6'b010011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}};
      wildcard bins vsoxseg4ei8_v   = {{6'b011011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}};
      wildcard bins vsoxseg5ei8_v   = {{6'b100011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}};
      wildcard bins vsoxseg6ei8_v   = {{6'b101011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}};
      wildcard bins vsoxseg7ei8_v   = {{6'b110011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}};
      wildcard bins vsoxseg8ei8_v   = {{6'b111011, 1'b?, 5'b?????, 5'b?????, 3'b000, 5'b?????, 7'b0100111}};
      wildcard bins vsoxseg2ei16_v  = {{6'b001011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}};
      wildcard bins vsoxseg3ei16_v  = {{6'b010011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}};
      wildcard bins vsoxseg4ei16_v  = {{6'b011011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}};
      wildcard bins vsoxseg5ei16_v  = {{6'b100011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}};
      wildcard bins vsoxseg6ei16_v  = {{6'b101011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}};
      wildcard bins vsoxseg7ei16_v  = {{6'b110011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}};
      wildcard bins vsoxseg8ei16_v  = {{6'b111011, 1'b?, 5'b?????, 5'b?????, 3'b101, 5'b?????, 7'b0100111}};
      wildcard bins vsoxseg2ei32_v  = {{6'b001011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}};
      wildcard bins vsoxseg3ei32_v  = {{6'b010011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}};
      wildcard bins vsoxseg4ei32_v  = {{6'b011011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}};
      wildcard bins vsoxseg5ei32_v  = {{6'b100011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}};
      wildcard bins vsoxseg6ei32_v  = {{6'b101011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}};
      wildcard bins vsoxseg7ei32_v  = {{6'b110011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}};
      wildcard bins vsoxseg8ei32_v  = {{6'b111011, 1'b?, 5'b?????, 5'b?????, 3'b110, 5'b?????, 7'b0100111}};
      wildcard bins vl1re8_v        = {{6'b000000, 1'b1, 5'b01000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}};
      wildcard bins vl2re8_v        = {{6'b001000, 1'b1, 5'b01000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}};
      wildcard bins vl4re8_v        = {{6'b011000, 1'b1, 5'b01000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}};
      wildcard bins vl8re8_v        = {{6'b111000, 1'b1, 5'b01000, 5'b?????, 3'b000, 5'b?????, 7'b0000111}};
      wildcard bins vl1re16_v       = {{6'b000000, 1'b1, 5'b01000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}};
      wildcard bins vl2re16_v       = {{6'b001000, 1'b1, 5'b01000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}};
      wildcard bins vl4re16_v       = {{6'b011000, 1'b1, 5'b01000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}};
      wildcard bins vl8re16_v       = {{6'b111000, 1'b1, 5'b01000, 5'b?????, 3'b101, 5'b?????, 7'b0000111}};
      wildcard bins vl1re32_v       = {{6'b000000, 1'b1, 5'b01000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}};
      wildcard bins vl2re32_v       = {{6'b001000, 1'b1, 5'b01000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}};
      wildcard bins vl4re32_v       = {{6'b011000, 1'b1, 5'b01000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}};
      wildcard bins vl8re32_v       = {{6'b111000, 1'b1, 5'b01000, 5'b?????, 3'b110, 5'b?????, 7'b0000111}};
      wildcard bins vs1r_v          = {{6'b000000, 1'b1, 5'b01000, 5'b?????, 3'b000, 5'b?????, 7'b0100111}};
      wildcard bins vs2r_v          = {{6'b001000, 1'b1, 5'b01000, 5'b?????, 3'b000, 5'b?????, 7'b0100111}};
      wildcard bins vs4r_v          = {{6'b011000, 1'b1, 5'b01000, 5'b?????, 3'b000, 5'b?????, 7'b0100111}};
      wildcard bins vs8r_v          = {{6'b111000, 1'b1, 5'b01000, 5'b?????, 3'b000, 5'b?????, 7'b0100111}};
    }
endgroup: Cov_rvv_zve32x_inst_count

initial begin: rvv_zve32x_coverage_sample_inst_count
  logic [31:0] inst_bin;
  Cov_rvv_zve32x_inst_count cg_rvv_zve32x_inst_count= new();
  forever begin
    @(posedge clk);
    if(~rst_n) begin
    end else begin
      for(int i=0; i<`ISSUE_LANE; i++) begin
        if(rvs_if.insts_valid_rvs2cq[i] && rvs_if.insts_ready_cq2rvs[i]) begin
          case(rvs_if.insts_rvs2cq[i].opcode)
            LOAD:  inst_bin = {rvs_if.insts_rvs2cq[i].bits, 7'b0000111};
            STORE: inst_bin = {rvs_if.insts_rvs2cq[i].bits, 7'b0100111};
            RVV:   inst_bin = {rvs_if.insts_rvs2cq[i].bits, 7'b1010111};
          endcase 
          cg_rvv_zve32x_inst_count.sample(inst_bin);
        end
      end
    end // if(~rst_n)
  end // forever
end: rvv_zve32x_coverage_sample_inst_count
