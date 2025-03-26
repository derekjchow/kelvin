`ifndef RVV_MEM__SV
`define RVV_MEM__SV

//------------------------------------------------------------------------------
// CLASS: mem_transaction
//    
// Record memory byte access informations.
//------------------------------------------------------------------------------
class mem_transaction extends uvm_sequence_item;
// Members ---------------------------------------------------------------------
  int pc;
  typedef enum {LOAD, STORE} kinds_e;
  kinds_e kind;

  int unsigned addr;
  logic [7:0] data;

// UVM Marocs ------------------------------------------------------------------
  `uvm_object_utils_begin(mem_transaction) 
    `uvm_field_int(pc,UVM_ALL_ON)
    `uvm_field_enum(kinds_e,kind,UVM_ALL_ON)
    `uvm_field_int(addr,UVM_ALL_ON)
    `uvm_field_int(data,UVM_ALL_ON)
  `uvm_object_utils_end

// Methods ---------------------------------------------------------------------
  function new(string name = "mem_tr");
  endfunction: new

endclass: mem_transaction

//------------------------------------------------------------------------------
// CLASS: rvv_mem
//------------------------------------------------------------------------------
class rvv_mem extends uvm_component;
// Members ---------------------------------------------------------------------
  parameter MEM_BUS_WIDHT='d32;
  typedef logic [MEM_BUS_WIDHT-1:0] mem_max_t;
  bit wrap_mode = 1;
  int unsigned mem_addr_lo;
  int unsigned mem_addr_hi;
  byte mem[int unsigned];

  int pc;

// TLM -------------------------------------------------------------------------
  uvm_analysis_port #(mem_transaction, rvv_mem) mem_ap;

// Phases ----------------------------------------------------------------------
  function new(string name = "rvv_mem", uvm_component parent = null, bit wrap_mode_en = 1);
    super.new(name, parent);
    wrap_mode   = wrap_mode_en;
    mem_addr_lo = 32'h0000_0000;
    mem_addr_hi = 32'h0000_0010;
    mem_ap      = new("mem_ap", this);
  endfunction: new

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
  endtask: run_phase

// Methods ---------------------------------------------------------------------
  function bit set_mem_range(int unsigned mem_base, int unsigned mem_size);
    mem_addr_lo = mem_base;
    mem_addr_hi = mem_base + mem_size - 1;
    return 0;
  endfunction: set_mem_range
  function void set_mem(int unsigned addr, logic [7:0] value);
    mem[addr] = value;
  endfunction: set_mem
  function logic [7:0] get_mem(int unsigned addr);
    return mem[addr];
  endfunction: get_mem

  task load_byte(
    output logic [7:0] data, 
    input int unsigned addr 
    ); 
    int unsigned addr_temp;
    mem_transaction mem_tr;
    if(!(addr inside {[mem_addr_lo:mem_addr_hi]})) begin
      if(wrap_mode) begin
        addr_temp = addr % (mem_addr_hi - mem_addr_lo + 1) + mem_addr_lo;
        `uvm_info($sformatf("%s/MEM",this.get_name()), $sformatf("Wrap address from @0x%8x to @0x%8x.", addr, addr_temp), UVM_HIGH)
        addr = addr_temp;
        data = this.mem[addr];
        `uvm_info($sformatf("%s/MEM",this.get_name()), $sformatf("Load 0x%2x from @0x%8x", data, addr), UVM_HIGH)
        mem_tr      = new("mem_tr");
        mem_tr.pc   = pc;
        mem_tr.kind = mem_transaction::LOAD;
        mem_tr.addr = addr;
        mem_tr.data = data;
        mem_ap.write(mem_tr);
      end else begin
        `uvm_error($sformatf("%s/MEM",this.get_name()), $sformatf("Access @0x%8x is out of memory range.", addr))
      end
    end else begin
      data = this.mem[addr];
      `uvm_info($sformatf("%s/MEM",this.get_name()), $sformatf("Load 0x%2x from @0x%8x", data, addr), UVM_HIGH)
      mem_tr = new("mem_tr");
        mem_tr.pc   = pc;
      mem_tr.kind = mem_transaction::LOAD;
      mem_tr.addr = addr;
      mem_tr.data = data;
      mem_ap.write(mem_tr);
    end
  endtask: load_byte
  
  task store_byte(
    input logic [7:0] data, 
    input int unsigned addr
    ); 
    int unsigned addr_temp;
    mem_transaction mem_tr;
    if(!(addr inside {[mem_addr_lo:mem_addr_hi]})) begin
      if(wrap_mode) begin
        addr_temp = addr % (mem_addr_hi - mem_addr_lo + 1) + mem_addr_lo;
        `uvm_info($sformatf("%s/MEM",this.get_name()), $sformatf("Wrap address from @0x%8x to @0x%8x.", addr, addr_temp), UVM_HIGH)
        addr = addr_temp;
        this.mem[addr] = data;
        mem_tr      = new("mem_tr");
        mem_tr.pc   = pc;
        mem_tr.kind = mem_transaction::STORE;
        mem_tr.addr = addr;
        mem_tr.data = data;
        mem_ap.write(mem_tr);
      end else begin
        `uvm_error($sformatf("%s/MEM",this.get_name()), $sformatf("Access @0x%8x is out of memory range.", addr))
      end
    end else begin
      `uvm_info($sformatf("%s/MEM",this.get_name()), $sformatf("Store 0x%2x to @0x%8x", data, addr), UVM_HIGH)
      this.mem[addr] = data;
      mem_tr      = new("mem_tr");
      mem_tr.pc   = pc;
      mem_tr.kind = mem_transaction::STORE;
      mem_tr.addr = addr;
      mem_tr.data = data;
      mem_ap.write(mem_tr);
    end
  endtask: store_byte

  task load_from_mem(
    output mem_max_t load_data, 
    input int unsigned address, 
    input int unsigned byte_size
    ); 
    
    int unsigned addr_temp;
    logic [7:0]  data_temp;
    load_data = 'x;
    for(int byte_cnt=0; byte_cnt<byte_size; byte_cnt++) begin
      addr_temp = (address+byte_cnt);
      data_temp = 'x;
      load_byte(data_temp, addr_temp);
      load_data[byte_cnt*8 +: 8] = data_temp;
    end
    `uvm_info($sformatf("%s/MEM",this.get_name()),$sformatf("Load %0d bytes 0x%x from @0x%8x", byte_size, load_data, addr_temp), UVM_LOW)
  endtask: load_from_mem

  task store_to_mem(
    input mem_max_t store_data,
    input int unsigned address, 
    input int unsigned byte_size
    ); 
        
    int unsigned addr_temp;
    logic [7:0]  data_temp;
    for(int byte_cnt=0; byte_cnt<byte_size; byte_cnt++) begin
      addr_temp = (address+byte_cnt);
      data_temp = 'x;
      data_temp = store_data[byte_cnt*8 +: 8];
      store_byte(data_temp, addr_temp);
    end
    `uvm_info($sformatf("%s/MEM",this.get_name()),$sformatf("Store %0d bytes 0x%x to @0x%8x", byte_size, store_data, addr_temp), UVM_LOW)
  endtask: store_to_mem
endclass
`endif
