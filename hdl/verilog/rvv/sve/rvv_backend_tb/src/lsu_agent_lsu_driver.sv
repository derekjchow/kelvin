`ifndef LSU_DRIVER__SV
`define LSU_DRIVER__SV

typedef class lsu_transaction;
typedef class lsu_driver;

`uvm_analysis_imp_decl(_lsu_inst)

class lsu_driver extends uvm_driver # (lsu_transaction);

  parameter int MAX_SEG = 8;
  typedef virtual lsu_interface v_if; 
  v_if lsu_if;
  
  uvm_analysis_imp_lsu_inst #(rvs_transaction,lsu_driver) inst_imp; 
  uvm_analysis_port #(lsu_transaction, lsu_driver) lsu_ap;
  uvm_analysis_port #(trap_info_transaction, lsu_driver) trap_ap;

  rvs_transaction inst_queue[$];
  lsu_transaction uops_rx_queue[$];
  lsu_transaction uops_tx_queue[$];

  rvv_mem mem;
  
  bit trap_en = 0;
  bit always_trap = 0;
  delay_mode_pkg::delay_mode_e       delay_mode_rvv2lsu;
  delay_mode_pkg::delay_mode_e       delay_mode_lsu2rvv;

  `uvm_component_utils_begin(lsu_driver)
  `uvm_component_utils_end

  extern function new(string name = "lsu_driver", uvm_component parent = null); 
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  extern virtual function void final_phase(uvm_phase phase);

  extern protected virtual task tx_driver();
  extern protected virtual task rx_driver();
  extern protected virtual task lsu_process();

  // receive & decode inst from rvs
  extern function void write_lsu_inst(rvs_transaction inst_tr);
  extern function int lsu_uop_decode(ref rvs_transaction inst_tr);
  extern protected function void lsu_uop_gen_delay(ref lsu_transaction uop_tr);
  extern protected function void lsu_uop_gen_trap(ref lsu_transaction uop_tr);

endclass: lsu_driver

function lsu_driver::new(string name = "lsu_driver", uvm_component parent = null);
  super.new(name, parent);
endfunction: new

function void lsu_driver::build_phase(uvm_phase phase);
  super.build_phase(phase);
  inst_imp = new("inst_imp", this);
  lsu_ap = new("lsu_ap", this);
  trap_ap = new("trap_ap", this);
  mem = new("lsu_mem", this);

  if(uvm_config_db#(delay_mode_pkg::delay_mode_e)::get(this, "", "delay_mode_rvv2lsu", delay_mode_rvv2lsu)) begin
    `uvm_info(get_type_name(), $sformatf("delay_mode_rvv2lsu of delay_mode_rvv2lsu is set to %s.", delay_mode_rvv2lsu.name()), UVM_LOW)
  end else begin
    delay_mode_rvv2lsu = delay_mode_pkg::NORMAL;
    `uvm_info(get_type_name(), $sformatf("delay_mode_rvv2lsu of is delay_mode_rvv2lsu set to %s.", delay_mode_rvv2lsu.name()), UVM_LOW)
  end

  if(uvm_config_db#(delay_mode_pkg::delay_mode_e)::get(this, "", "delay_mode_lsu2rvv", delay_mode_lsu2rvv)) begin
    `uvm_info(get_type_name(), $sformatf("delay_mode_lsu2rvv of is delay_mode_lsu2rvv set to %s.", delay_mode_lsu2rvv.name()), UVM_LOW)
  end else begin
    delay_mode_lsu2rvv = delay_mode_pkg::NORMAL;
    `uvm_info(get_type_name(), $sformatf("delay_mode_lsu2rvv of delay_mode_lsu2rvv is set to %s.", delay_mode_lsu2rvv.name()), UVM_LOW)
  end

  if(uvm_config_db#(bit)::get(this, "", "trap_en",trap_en)) begin
    `uvm_info(get_type_name(), $sformatf("Trap_en of lsu_driver is set to %0d.", trap_en), UVM_LOW)
  end else begin
    trap_en = 0;
    `uvm_info(get_type_name(), $sformatf("Trap_en of lsu_driver is set to %0d.", trap_en), UVM_LOW)
  end
  if(uvm_config_db#(bit)::get(this, "", "always_trap",always_trap)) begin
    `uvm_info(get_type_name(), $sformatf("Trap_en of lsu_driver is set to %0d.", always_trap), UVM_LOW)
  end else begin
    always_trap = 0;
    `uvm_info(get_type_name(), $sformatf("Trap_en of lsu_driver is set to %0d.", always_trap), UVM_LOW)
  end

endfunction: build_phase

function void lsu_driver::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  if(!uvm_config_db#(v_if)::get(this, "", "lsu_if", lsu_if)) begin
    `uvm_fatal("NO_CONN", "Virtual port not connected to the actual interface instance");   
  end
endfunction: connect_phase

task lsu_driver::run_phase(uvm_phase phase);
  super.run_phase(phase);
  fork 
    tx_driver();
    // lsu_process();
    rx_driver();
  join
endtask: run_phase

task lsu_driver::rx_driver();
  int stride_temp;
  int indexed_stride [$];
  lsu_transaction uop_tr;
  bit pre_uop_have_delay;
  forever begin
    @(negedge lsu_if.clk);
    if(~lsu_if.rst_n) begin
      indexed_stride.delete();
      uops_rx_queue.delete();
    end else begin
      foreach(uops_rx_queue[uop_idx]) begin
        uop_tr = new();
        uop_tr = uops_rx_queue[uop_idx];
        if(uop_tr.lsu_slot_addr_valid == 1 && uop_tr.kind == LOAD) begin
          // Send result before strobe info accepted. 
          if(uop_tr.uop_rx_sent != 1) begin
            uop_tr.uop_rx_sent = 1'b1;
            `uvm_info("LSU_DRV",$sformatf("Sent unit-stride/const-stride load with vm==1 uop to uops_tx_queue ahead:\n%s",uop_tr.sprint()),UVM_HIGH)
            uops_tx_queue.push_back(uop_tr);
          end else begin
            // Do nothing for sent uop. Wait for rvv2lsu handshake to pop.
          end
        end else begin
          // To make sure load/store is in-order executed
          break;
        end
      end
      lsu_process();
    end

    @(posedge lsu_if.clk);
    if(~lsu_if.rst_n) begin
      for(int i=0; i<`NUM_LSU; i++) begin
        lsu_if.uop_lsu_ready_lsu2rvv[i] <= '0;
      end
    end else begin
      for(int i=0; i<`NUM_LSU; i++) begin: rx_driver_logic_part
        if(uops_rx_queue.size() > 0) begin
          if(lsu_if.uop_lsu_ready_lsu2rvv[i] && lsu_if.uop_lsu_valid_rvv2lsu[i]) begin
            uop_tr = new();
            uop_tr = uops_rx_queue.pop_front();
            `uvm_info("LSU_DRV",$sformatf("Begin to accept vreg info to update uops_queque[%0d]:\n%s",i,uop_tr.sprint()),UVM_HIGH)
`ifdef TB_SUPPORT
            if(lsu_if.uop_lsu_rvv2lsu[i].uop_pc !== uop_tr.uop_pc) begin
              `uvm_error("LSU_DRV", $sformatf("uop_pc mismatch: lsu=0x%8x, dut=0x%8x", uop_tr.uop_pc, lsu_if.uop_lsu_rvv2lsu[i].uop_pc))
              continue;
            end
`endif
            // update address for indexed-stride from vidx_data
            if(uop_tr.is_indexed == 1) begin
              if(lsu_if.uop_lsu_rvv2lsu[i].vidx_valid !== 1) begin
                `uvm_error("LSU_DRV", "Uop is indexed but vidx_valid is not")
                continue;
              end else if(uop_tr.lsu_slot_addr_valid === 1) begin
                `uvm_fatal("TB_ISSUE", "Decode error")
                continue;
              end else if(uop_tr.vidx_vreg_idx !== lsu_if.uop_lsu_rvv2lsu[i].vidx_addr) begin
                `uvm_error("LSU_DRV", $sformatf("vidx_addr mismatch: lsu=%0d, dut=%0d", uop_tr.vidx_vreg_idx, lsu_if.uop_lsu_rvv2lsu[i].vidx_addr))
                continue;
              end else begin
                `uvm_info("LSU_DRV", $sformatf("Got vreg[%0d]=0x%16x from dut.", lsu_if.uop_lsu_rvv2lsu[i].vidx_addr, lsu_if.uop_lsu_rvv2lsu[i].vidx_data), UVM_HIGH);
                for(int byte_idx=uop_tr.vidx_vreg_byte_head; byte_idx<uop_tr.vidx_vreg_byte_tail; byte_idx += uop_tr.vidx_vreg_eew/8) begin
                  case(uop_tr.vidx_vreg_eew)
                    // For indexed-stride, the stride from vrf should be zero-extended to `XLEN.
                    EEW8 : stride_temp = $unsigned(lsu_if.uop_lsu_rvv2lsu[i].vidx_data[byte_idx*8 +: 8 ]);
                    EEW16: stride_temp = $unsigned(lsu_if.uop_lsu_rvv2lsu[i].vidx_data[byte_idx*8 +: 16]);
                    EEW32: stride_temp = $unsigned(lsu_if.uop_lsu_rvv2lsu[i].vidx_data[byte_idx*8 +: 32]);
                  endcase
                  indexed_stride.push_back(stride_temp);
                  `uvm_info("LSU_DRV", $sformatf("byte[%0d]: push stride=0x%8x to indexed_stride(size: %0d).", byte_idx, stride_temp, indexed_stride.size()), UVM_HIGH)
                end
                for(int byte_idx=uop_tr.data_vreg_byte_head; byte_idx<uop_tr.data_vreg_byte_tail; byte_idx++) begin
                  if(byte_idx % (uop_tr.data_vreg_eew/8) == 0) begin 
                    stride_temp = indexed_stride.pop_front();
                    `uvm_info("LSU_DRV", $sformatf("byte[%0d]: pop stride=0x%8x from indexed_stride(size: %0d).", byte_idx, stride_temp, indexed_stride.size()), UVM_HIGH)
                  end
                  `uvm_info("LSU_DRV", $sformatf("byte[%0d]: base=0x%8x, stride=0x%8x.", byte_idx, uop_tr.lsu_slot_addr[byte_idx], stride_temp), UVM_HIGH)
                  uop_tr.lsu_slot_addr[byte_idx] += stride_temp;

                end
                uop_tr.lsu_slot_addr_valid = 1;
              end
            end

            // take store data from vregfile_read_data
            if(uop_tr.kind == lsu_transaction::STORE) begin
              if(lsu_if.uop_lsu_rvv2lsu[i].vregfile_read_valid !== 1) begin
                `uvm_fatal("LSU_DRV", "Uop is store but vregfile_read_valid is 0")
                continue;
              end else if(uop_tr.lsu_slot_data_valid === 1) begin
                `uvm_fatal("TB_ISSUE", "Decode error")
                continue;
              end else if(uop_tr.data_vreg_idx !== lsu_if.uop_lsu_rvv2lsu[i].vregfile_read_addr) begin
                `uvm_fatal("TB_ISSUE", $sformatf("vregfile_read_addr mismatch: lsu=%0d, dut=%0d", uop_tr.data_vreg_idx, lsu_if.uop_lsu_rvv2lsu[i].vregfile_read_addr))
                continue;
              end else begin
                for(int byte_idx=uop_tr.data_vreg_byte_head; byte_idx<uop_tr.data_vreg_byte_tail; byte_idx++) begin
                  uop_tr.lsu_slot_data[byte_idx] = lsu_if.uop_lsu_rvv2lsu[i].vregfile_read_data[byte_idx*8 +: 8];
                end
                uop_tr.lsu_slot_data_valid = 1;
              end
            end

            // take strobe from v0_data
            if(uop_tr.vm === 0) begin
              if(lsu_if.uop_lsu_rvv2lsu[i].v0_valid !== 1) begin
                `uvm_fatal("LSU_DRV", "Uops need v0_data but v0_valid is 0")
                continue;
              end else begin
                `uvm_info("LSU_DRV", $sformatf("uop_pc:0x%8x, v0_data=0x%016x", uop_tr.uop_pc, lsu_if.uop_lsu_rvv2lsu[i].v0_data), UVM_HIGH)
                uop_tr.lsu_slot_strobe = lsu_if.uop_lsu_rvv2lsu[i].v0_data;
                uop_tr.lsu_slot_addr_valid = 1;
              end
            end else begin
              if(lsu_if.uop_lsu_rvv2lsu[i].v0_valid === 0) begin
                `uvm_fatal("LSU_DRV", "RVV should always send v0_data to lsu.")
                continue;
              end else if(uop_tr.lsu_slot_strobe !== lsu_if.uop_lsu_rvv2lsu[i].v0_data) begin
                `uvm_error("LSU_DRV", $sformatf("uop_pc:0x%8x, uop_index:0x%8x, v0_data mismatch. lsu=0x%4x, dut=0x%4x",
                                                 uop_tr.uop_pc, uop_tr.uop_index, uop_tr.lsu_slot_strobe, lsu_if.uop_lsu_rvv2lsu[i].v0_data))
              end
            end

            if(uop_tr.uop_rx_sent != 1) begin
              uop_tr.uop_rx_sent = 1'b1;
              uops_tx_queue.push_back(uop_tr);
              `uvm_info("LSU_DRV",$sformatf("Sent uop to uops_tx_queue:\n%s",uop_tr.sprint()),UVM_HIGH)
            end
            `uvm_info("LSU_DRV",$sformatf("Finished accepting vreg info and updating uops_queque[%0d]:\n%s",i,uop_tr.sprint()),UVM_HIGH)
          end
        end
      end: rx_driver_logic_part

      pre_uop_have_delay = 0;
      for(int i=0; i<`NUM_LSU; i++) begin
        if(i < uops_rx_queue.size()) begin 
          if(pre_uop_have_delay) begin
            lsu_if.uop_lsu_ready_lsu2rvv[i] <= 1'b0; 
          end else if(uops_rx_queue[i].rvv2lsu_delay != 0) begin
            lsu_if.uop_lsu_ready_lsu2rvv[i] <= 1'b0; 
            uops_rx_queue[i].rvv2lsu_delay--;
            pre_uop_have_delay = 1;
          end else begin
            lsu_if.uop_lsu_ready_lsu2rvv[i] <= 1'b1; 
            pre_uop_have_delay = 0;
          end
        end else begin
          lsu_if.uop_lsu_ready_lsu2rvv[i] <= 1'b0; 
        end
      end
    end
  end // forever
endtask: rx_driver

task lsu_driver::lsu_process();
  logic [7:0] data_temp;
  trap_info_transaction trap_tr;
//  forever begin
//    @(negedge lsu_if.clk);
//    if(~lsu_if.rst_n) begin
//    end else begin
      foreach(uops_tx_queue[uop_idx]) begin
        if(uops_tx_queue[uop_idx].lsu2rvv_delay != 0) begin
          uops_tx_queue[uop_idx].lsu2rvv_delay--;
          break;
        end
        if(uops_tx_queue[uop_idx].trap_occured == 1) begin
          if(uops_tx_queue[uop_idx].uop_done == 0) begin
            `uvm_info("LSU_DRV",$sformatf("uops_tx_queue[%0d] got a trap:\n%s",uop_idx,uops_tx_queue[uop_idx].sprint()),UVM_HIGH)
            trap_tr = new("trap_tr");
            trap_tr.trap_pc = uops_tx_queue[uop_idx].uop_pc;
            trap_tr.vstart  = uops_tx_queue[uop_idx].vstart;
            trap_tr.uop_idx = uops_tx_queue[uop_idx].uop_index;
            trap_ap.write(trap_tr);
            uops_tx_queue[uop_idx].uop_done = 1;
          end
          break;
        end else begin
          `uvm_info("LSU_DRV",$sformatf("process uops_tx_queue[%0d]:\n%s",uop_idx,uops_tx_queue[uop_idx].sprint()),UVM_HIGH)
          case(uops_tx_queue[uop_idx].kind)
            lsu_transaction::LOAD: begin
              if(uops_tx_queue[uop_idx].lsu_slot_addr_valid === 0) begin
                `uvm_fatal("TB_ISSUE", "LSU decode err.")
                break;
              end else if(uops_tx_queue[uop_idx].uop_done == 0) begin
                for(int byte_idx=uops_tx_queue[uop_idx].data_vreg_byte_head; byte_idx<uops_tx_queue[uop_idx].data_vreg_byte_tail; byte_idx++) begin
                  if(uops_tx_queue[uop_idx].lsu_slot_strobe[byte_idx] === 1'b1) begin
                    mem.pc = uops_tx_queue[uop_idx].uop_pc;
                    mem.load_byte(data_temp, uops_tx_queue[uop_idx].lsu_slot_addr[byte_idx]);
                    uops_tx_queue[uop_idx].lsu_slot_data[byte_idx] = data_temp;
                  end else begin
                    uops_tx_queue[uop_idx].lsu_slot_data[byte_idx] = 'x;
                  end
                end
                uops_tx_queue[uop_idx].lsu_slot_data_valid = 1;
                uops_tx_queue[uop_idx].uop_done = 1;
                `uvm_info("LSU_DRV",$sformatf("uops_tx_queue[%0d] load uop done:\n%s",uop_idx,uops_tx_queue[uop_idx].sprint()),UVM_HIGH)
              end else begin
                `uvm_info("LSU_DRV",$sformatf("uops_tx_queue[%0d] aleady done:\n%s",uop_idx,uops_tx_queue[uop_idx].sprint()),UVM_HIGH)
              end
            end
            lsu_transaction::STORE: begin
              if(uops_tx_queue[uop_idx].lsu_slot_addr_valid === 0) begin
                `uvm_fatal("TB_ISSUE", "LSU decode err.")
                break;
              end else if(uops_tx_queue[uop_idx].uop_done == 0) begin
                for(int byte_idx=uops_tx_queue[uop_idx].data_vreg_byte_head; byte_idx<uops_tx_queue[uop_idx].data_vreg_byte_tail; byte_idx++) begin
                  if(uops_tx_queue[uop_idx].lsu_slot_strobe[byte_idx] === 1'b1) begin
                    data_temp = uops_tx_queue[uop_idx].lsu_slot_data[byte_idx];
                    mem.pc = uops_tx_queue[uop_idx].uop_pc;
                    mem.store_byte(data_temp, uops_tx_queue[uop_idx].lsu_slot_addr[byte_idx]);
                  end else begin
                    data_temp = 'x;
                  end
                end
                uops_tx_queue[uop_idx].uop_done = 1;
                `uvm_info("LSU_DRV",$sformatf("uops_tx_queue[%0d] store uop done:\n%s",uop_idx,uops_tx_queue[uop_idx].sprint()),UVM_HIGH)
              end else begin
                `uvm_info("LSU_DRV",$sformatf("uops_tx_queue[%0d] aleady done:\n%s",uop_idx,uops_tx_queue[uop_idx].sprint()),UVM_HIGH)
              end
            end
          endcase
        end // trap
      end // foreach(uops_tx_queue[uop_idx])
//     end
//   end // forever
endtask: lsu_process

task lsu_driver::tx_driver();
  lsu_transaction uop_tr;
  bit has_trap;
  int trap_pc;
  int trap_uop_index;
  forever begin
    @(posedge lsu_if.clk);
    if(~lsu_if.rst_n) begin
      uops_tx_queue.delete();
      inst_queue.delete();
      for(int i=0; i<`NUM_LSU; i++) begin
        lsu_if.uop_lsu_valid_lsu2rvv[i] <= '0;
        lsu_if.uop_lsu_lsu2rvv[i]       <= 'x;
      end
      lsu_if.trap_valid_rvs2rvv <= 1'b0;
    end else begin
      if(lsu_if.trap_ready_rvv2rvs === 1'b1 && lsu_if.trap_valid_rvs2rvv === 1'b1) begin
        uop_tr = new("uop_tr");
        uop_tr = uops_tx_queue.pop_front();
        `uvm_info("LSU_DRV", $sformatf("trap accepted, pop uop from uops_tx_queue:%s\n", uop_tr.sprint()),UVM_HIGH)
        uops_rx_queue.delete();
        uops_tx_queue.delete();
        inst_queue.delete();
      end
      for(int i=0; i<`NUM_LSU; i++) begin
        if(lsu_if.uop_lsu_valid_lsu2rvv[i] === 1'b1 && lsu_if.uop_lsu_ready_rvv2lsu[i] === 1'b1) begin
          uop_tr = new("uop_tr");
          uop_tr = uops_tx_queue.pop_front();
          `uvm_info("LSU_DRV", $sformatf("lsu2rvv handshake done, pop uop from uops_tx_queue:%s\n", uop_tr.sprint()),UVM_HIGH)
          if(uop_tr.is_last_uop) begin 
            inst_queue.pop_front();
          end
        end
      end

      // lsu2rvv ports
      for(int i=0; i<`NUM_LSU; i++) begin
        if(i<uops_tx_queue.size()) begin
          if(uops_tx_queue[i].uop_done && !uops_tx_queue[i].trap_occured) begin
            `uvm_info("LSU_DRV",$sformatf("Assign uops_tx_queue[%0d] to lsu2rvv port:\n%s",i,uops_tx_queue[i].sprint()),UVM_HIGH)
            lsu_if.uop_lsu_valid_lsu2rvv[i] <= '1;
`ifdef TB_SUPPORT
            lsu_if.uop_lsu_lsu2rvv[i].uop_pc <= uops_tx_queue[i].uop_pc;
            lsu_if.uop_lsu_lsu2rvv[i].uop_index <= uops_tx_queue[i].uop_index;
`endif
            if(uops_tx_queue[i].kind == lsu_transaction::LOAD) begin
              lsu_if.uop_lsu_lsu2rvv[i].vregfile_write_valid  <= 1'b1;
              lsu_if.uop_lsu_lsu2rvv[i].vregfile_write_addr   <= uops_tx_queue[i].data_vreg_idx;
              lsu_if.uop_lsu_lsu2rvv[i].vregfile_write_data   <= uops_tx_queue[i].lsu_slot_data;
              lsu_if.uop_lsu_lsu2rvv[i].lsu_vstore_last       <= 1'bx;
            end
            if(uops_tx_queue[i].kind == lsu_transaction::STORE) begin
              lsu_if.uop_lsu_lsu2rvv[i].vregfile_write_valid  <= 1'bx;
              lsu_if.uop_lsu_lsu2rvv[i].vregfile_write_addr   <= 'x;
              lsu_if.uop_lsu_lsu2rvv[i].vregfile_write_data   <= 'x;
              lsu_if.uop_lsu_lsu2rvv[i].lsu_vstore_last       <= 1'b1;
            end
          end else begin
            lsu_if.uop_lsu_valid_lsu2rvv[i] <= '0;
          end
        end else begin
          lsu_if.uop_lsu_valid_lsu2rvv[i] <= '0;
          lsu_if.uop_lsu_lsu2rvv[i]       <= 'x;
        end
      end

      // trap ports
      has_trap = 0;
      for(int i=0; i<`NUM_LSU + 1; i++) begin
        if(i<uops_tx_queue.size()) begin
          if(uops_tx_queue[i].uop_done && uops_tx_queue[i].trap_occured) begin
            has_trap       = 1;
            trap_pc        = uops_tx_queue[i].uop_pc;
            trap_uop_index = uops_tx_queue[i].uop_index;
            `uvm_info("LSU_DRV", $sformatf("Assign uops_tx_queue[%0d] to trap port:\n%s", i, uops_tx_queue[i].sprint()), UVM_HIGH)
          end
        end
      end
      if(has_trap) begin
        lsu_if.trap_valid_rvs2rvv <= 1'b1;
        lsu_if.trap_pc            <= trap_pc;
        lsu_if.trap_uop_index     <= trap_uop_index;
      end else begin
        lsu_if.trap_valid_rvs2rvv <= 1'b0;
        lsu_if.trap_pc            <= 'x;
        lsu_if.trap_uop_index     <= 'x;
      end

    end
  end
endtask : tx_driver

function void lsu_driver::write_lsu_inst(rvs_transaction inst_tr);
  if(inst_tr.inst_type inside {LD, ST}) begin
    `uvm_info("LSU_DRV",$sformatf("LSU driver got inst_tr:\n%s",inst_tr.sprint()),UVM_HIGH)
    inst_queue.push_back(inst_tr);
    lsu_uop_decode(inst_tr);
  end
endfunction

function int lsu_driver::lsu_uop_decode(ref rvs_transaction inst_tr);
  lsu_transaction uop_tr; // segment max is 3
  // vtype decode
  int elm_idx_max;
  int lsu_nf;
  int seg_num;
  int evl;
  int vstart;
  int uop_vstart[MAX_SEG];

  int  data_eew;
  real data_emul;
  int  vidx_eew;
  real vidx_emul;
  int  eew_max;
  real emul_max;

  // uop info
  int uops_num;
  int data_vreg_idx_base;
  int vidx_vreg_idx_base;
  int data_vreg_idx_last;
  int vidx_vreg_idx_last;
  int elm_per_uop;
  int elm_idx_head[MAX_SEG]; // elm pointer
  int elm_idx_tail[MAX_SEG]; // elm pointer
  int data_byte_idx[MAX_SEG];
  int vidx_byte_idx[MAX_SEG];
  int seg_idx;
  int switch_seg;
  int seg_switch_gap; // num of bytes per data vreg

  // load/store addres info
  int addr;
  int addr_base, const_stride;

// Decode ---------------------------------------------------------------------- 
  `uvm_info("LSU_DRV","Start decode vtype",UVM_HIGH)

  addr_base   = inst_tr.rs1_data;
  evl         = inst_tr.evl;
  vstart      = inst_tr.vstart;
  lsu_nf      = inst_tr.lsu_nf;

  eew_max     = inst_tr.eew_max;
  emul_max    = inst_tr.emul_max;

  elm_idx_max = inst_tr.elm_idx_max;
  seg_num     = inst_tr.seg_num;

  uops_num    = int'($ceil(emul_max)) * (seg_num);
  elm_per_uop = `VLEN / eew_max;

  case(inst_tr.inst_type)
    LD: begin
      data_eew  = inst_tr.dest_eew;
      vidx_eew  = inst_tr.src2_eew;
      data_emul = inst_tr.dest_emul;
      vidx_emul = inst_tr.src2_emul;
    end
    ST: begin
      data_eew  = inst_tr.src3_eew;
      vidx_eew  = inst_tr.src2_eew;
      data_emul = inst_tr.src3_emul;
      vidx_emul = inst_tr.src2_emul;
    end
  endcase
  case(inst_tr.lsu_mop) 
    LSU_US   : begin
      case(inst_tr.lsu_umop)
        MASK: begin
          const_stride = (lsu_nf+1) * data_eew/8;
        end
        WHOLE_REG: begin
          const_stride = data_eew/8;
        end
        default: begin
          const_stride = (lsu_nf+1) * data_eew/8;
        end
      endcase
    end
    LSU_CS  : begin
      const_stride = inst_tr.rs2_data;
    end
    LSU_UI, 
    LSU_OI: begin
      const_stride = 0;
    end      
  endcase
  
  if(inst_tr.inst_type == LD) begin
    data_vreg_idx_base = inst_tr.dest_idx;
    data_vreg_idx_last = inst_tr.dest_idx + (seg_num) * int'($ceil(data_emul)) - 1;
    vidx_vreg_idx_base = inst_tr.src2_idx;
    vidx_vreg_idx_last = inst_tr.src2_idx + int'($ceil(vidx_emul)) - 1;
  end else if(inst_tr.inst_type == ST) begin
    data_vreg_idx_base = inst_tr.src3_idx;
    data_vreg_idx_last = inst_tr.src3_idx + (seg_num) * int'($ceil(data_emul)) - 1;
    vidx_vreg_idx_base = inst_tr.src2_idx;
    vidx_vreg_idx_last = inst_tr.src2_idx + int'($ceil(vidx_emul)) - 1;
  end else begin
    `uvm_fatal("TB_ISSUE", "Decode inst_tr which is not load/store in lsu_driver.")
  end
  `uvm_info("LSU_DRV", $sformatf("eew_max=%0d, emul_max=%.2f, elm_idx_max=%0d", eew_max, emul_max, elm_idx_max), UVM_HIGH)

// Uops Gen --------------------------------------------------------------------
  `uvm_info("LSU_DRV","Start gen uops",UVM_HIGH)  
  if(data_emul < 1) begin
    seg_switch_gap = data_emul * `VLENB;
  end else begin
    seg_switch_gap = `VLENB;
  end

  for(int seg_idx=0; seg_idx<seg_num; seg_idx++) begin
    elm_idx_head[seg_idx]  = 0;
    elm_idx_tail[seg_idx]  = elm_per_uop;
    data_byte_idx[seg_idx] = 0;
    vidx_byte_idx[seg_idx] = 0;
    uop_vstart[seg_idx]    = vstart;
  end
  seg_idx = 0;
  for(int uops_idx=0; uops_idx<uops_num; uops_idx++) begin
    `uvm_info("LSU_DRV","Gen new uop",UVM_HIGH)
    uop_tr = new();
    `uvm_info("LSU_DRV", $sformatf("seg_idx           = %0d\n", seg_idx      ), UVM_HIGH)
    `uvm_info("LSU_DRV", $sformatf("seg_switch_gap    = %0d\n", seg_switch_gap), UVM_HIGH)
    `uvm_info("LSU_DRV", $sformatf("elm_idx_head[%0d] = %0d\n", seg_idx, elm_idx_head[seg_idx]), UVM_HIGH)
    `uvm_info("LSU_DRV", $sformatf("elm_idx_tail[%0d] = %0d\n", seg_idx, elm_idx_tail[seg_idx]), UVM_HIGH)

    lsu_uop_gen_delay(uop_tr);
    lsu_uop_gen_trap(uop_tr);

    uop_tr.inst_string = inst_tr.asm_string;
    if(inst_tr.inst_type == LD) begin
      uop_tr.kind = lsu_transaction::LOAD;
    end else if(inst_tr.inst_type == ST) begin
      uop_tr.kind = lsu_transaction::STORE;
    end else begin
      `uvm_fatal("TB_ISSUE", "Decode inst_tr which is not load/store in lsu_driver.")
    end
    uop_tr.uop_pc               = inst_tr.pc;
    uop_tr.uop_index            = uops_idx;

    uop_tr.is_last_uop          = (uops_idx == uops_num-1) ? 1: 0;
    uop_tr.is_indexed           = (inst_tr.lsu_mop inside {LSU_UI, LSU_OI}) ? 1 : 0;
    uop_tr.total_uops_num       = uops_num;
    uop_tr.base_addr            = addr_base;
    uop_tr.vstart               = uop_vstart[seg_idx];

    uop_tr.vm                   = inst_tr.vm;
    uop_tr.lsu_slot_strobe      = '0;
    
    uop_tr.data_vreg_valid      = 1;
    uop_tr.data_vreg_idx        = data_vreg_idx_base + elm_idx_head[seg_idx] * (data_eew/8) / `VLENB + seg_idx * int'($ceil(data_emul));
    uop_tr.data_vreg_eew        = data_eew; 
    uop_tr.data_vreg_byte_head  = data_byte_idx[seg_idx];

    uop_tr.vidx_vreg_valid      = (inst_tr.lsu_mop inside {LSU_UI, LSU_OI}) ? 1 : 0;
    uop_tr.vidx_vreg_idx        = vidx_vreg_idx_base + elm_idx_head[seg_idx] * (vidx_eew/8) / `VLENB; 
    uop_tr.vidx_vreg_eew        = vidx_eew; 
    uop_tr.vidx_vreg_byte_head  = vidx_byte_idx[seg_idx];

    for(int elm_idx=elm_idx_head[seg_idx]; elm_idx<elm_idx_tail[seg_idx]; elm_idx++) begin
      if(elm_idx == vstart) begin
        uop_tr.data_vreg_byte_head = vstart * data_eew / 8 %`VLENB;
        uop_tr.vidx_vreg_byte_head = vstart * vidx_eew / 8 %`VLENB;
      end
      if(elm_idx >= vstart && elm_idx < evl) begin
        for(int byte_idx=0; byte_idx<data_eew/8; byte_idx++) begin
          addr = addr_base + const_stride * elm_idx + data_eew / 8 * seg_idx + byte_idx;
          uop_tr.lsu_slot_addr[data_byte_idx[seg_idx]] = addr;
          uop_tr.lsu_slot_strobe[data_byte_idx[seg_idx]] = 1'b1;
          data_byte_idx[seg_idx]++;
        end
        vidx_byte_idx[seg_idx] += vidx_eew/8;
      end else begin
        data_byte_idx[seg_idx] += data_eew/8;
        vidx_byte_idx[seg_idx] += vidx_eew/8;
      end
      if(elm_idx >= vstart) begin
        uop_vstart[seg_idx]++;
      end
    end // elm-loop

    uop_tr.data_vreg_byte_tail = data_byte_idx[seg_idx];
    uop_tr.vidx_vreg_byte_tail = vidx_byte_idx[seg_idx];

    if(inst_tr.lsu_mop inside {LSU_US, LSU_CS} && inst_tr.vm == 1) begin
      uop_tr.lsu_slot_addr_valid = 1;
    end
    `uvm_info("LSU_DRV",$sformatf("Decode uop_tr to uops_rx_queque:\n%s",uop_tr.sprint()),UVM_HIGH)
    uops_rx_queue.push_back(uop_tr);

    `uvm_info("LSU_DRV", $sformatf("data_byte_idx[%0d] = %0d\n", seg_idx, data_byte_idx[seg_idx]), UVM_HIGH)

    switch_seg = data_byte_idx[seg_idx] >= seg_switch_gap;
    
    data_byte_idx[seg_idx] = (data_byte_idx[seg_idx] % `VLENB);
    vidx_byte_idx[seg_idx] = (vidx_byte_idx[seg_idx] % `VLENB);

    elm_idx_head[seg_idx] += elm_per_uop;
    elm_idx_tail[seg_idx] += elm_per_uop;

    if(switch_seg) begin
      if(seg_idx == seg_num-1) begin
        seg_idx = 0;
      end else begin
        seg_idx += 1;
      end
    end
  end // uop-loop
  `uvm_info("LSU_DRV","Decode done",UVM_HIGH)
endfunction: lsu_uop_decode

function void lsu_driver::lsu_uop_gen_delay(ref lsu_transaction uop_tr);        // Gen delay
  case(delay_mode_rvv2lsu)
    delay_mode_pkg::SLOW: begin
      uop_tr.c_rvv2lsu_delay.constraint_mode(0);
      assert(uop_tr.randomize(rvv2lsu_delay) with {
        rvv2lsu_delay dist {
          [1:50] :/ 20,
          [50:100] :/ 80
        };
      });
    end
    delay_mode_pkg::NORMAL: begin
      assert(uop_tr.randomize(rvv2lsu_delay) with {
        rvv2lsu_delay dist {
          [0:10] :/ 50,
          [10:20] :/ 30,
          [20:50] :/ 20
        };
      });
    end
    delay_mode_pkg::FAST: begin
      assert(uop_tr.randomize(rvv2lsu_delay) with {
        rvv2lsu_delay dist {
          0      := 80,
          [1:5]  :/ 15,
          [5:20] :/ 5
        };
      });
    end
  endcase
  case(delay_mode_lsu2rvv)
    delay_mode_pkg::SLOW: begin
      uop_tr.c_lsu2rvv_delay.constraint_mode(0);
      assert(uop_tr.randomize(lsu2rvv_delay) with {
        lsu2rvv_delay dist {
          [1:50] :/ 20,
          [50:100] :/ 80
        };
      });
    end
    delay_mode_pkg::NORMAL: begin
      assert(uop_tr.randomize(lsu2rvv_delay) with {
        lsu2rvv_delay dist {
          [0:10] :/ 50,
          [10:20] :/ 30,
          [20:50] :/ 20
        };
      });
    end
    delay_mode_pkg::FAST: begin
      assert(uop_tr.randomize(lsu2rvv_delay) with {
        lsu2rvv_delay dist {
          0      := 80,
          [1:5]  :/ 15,
          [5:20] :/ 5
        };
      });
    end
  endcase
endfunction: lsu_uop_gen_delay

function void lsu_driver::lsu_uop_gen_trap(ref lsu_transaction uop_tr);
  // Gen trap
  if(trap_en) begin
    if(always_trap) begin
      assert(uop_tr.randomize(trap_occured) with {
        trap_occured == 1;
      });
    end else begin
      assert(uop_tr.randomize(trap_occured) with {
        trap_occured dist {
          // 0 := 99,
          0 := 9,
          1 := 1
        };
      });
    end
  end else begin
    assert(uop_tr.randomize(trap_occured) with {
      trap_occured == 0;
    });
  end
endfunction: lsu_uop_gen_trap

function void lsu_driver::final_phase(uvm_phase phase);
  super.final_phase(phase);
  if(inst_queue.size()>0) begin
    `uvm_error("FINAL_CHECK", "inst_queue in LSU wasn't empty!")
    foreach(inst_queue[idx]) begin
      `uvm_error("FINAL_CHECK",inst_queue[idx].sprint())
    end
  end
  if(uops_rx_queue.size()>0) begin
    `uvm_error("FINAL_CHECK", "uops_rx_queue in LSU wasn't empty!")
    foreach(uops_rx_queue[idx]) begin
      `uvm_error("FINAL_CHECK",uops_rx_queue[idx].sprint())
    end
  end
  if(uops_tx_queue.size()>0) begin
    `uvm_error("FINAL_CHECK", "uops_tx_queue in LSU wasn't empty!")
    foreach(uops_tx_queue[idx]) begin
      `uvm_error("FINAL_CHECK",uops_tx_queue[idx].sprint())
    end
  end
endfunction: final_phase 
`endif // LSU_DRIVER__SV

