// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//----------------------------------------------------------------------------
// Package: coralnpu_axi_slave_agent_pkg
// Description: Package for the CoralNPU AXI Slave Agent components.
//----------------------------------------------------------------------------
package coralnpu_axi_slave_agent_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import transaction_item_pkg::*;

  //--------------------------------------------------------------------------
  // Class: coralnpu_axi_slave_model
  //--------------------------------------------------------------------------
  class coralnpu_axi_slave_model extends uvm_component;
    `uvm_component_utils(coralnpu_axi_slave_model)
    virtual coralnpu_axi_slave_if.TB_SLAVE_MODEL vif;

    function new(string name = "coralnpu_axi_slave_model",
                 uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual coralnpu_axi_slave_if.TB_SLAVE_MODEL)::get(
          this, "", "vif", vif)) begin
        `uvm_fatal(get_type_name(),
                   "Virtual interface 'vif' not found for TB_SLAVE_MODEL")
      end
    endfunction

    virtual task run_phase(uvm_phase phase);
      vif.tb_slave_cb.awready <= 1'b0;
      vif.tb_slave_cb.wready  <= 1'b0;
      vif.tb_slave_cb.arready <= 1'b0;
      vif.tb_slave_cb.bvalid  <= 1'b0;
      vif.tb_slave_cb.rvalid  <= 1'b0;
      vif.tb_slave_cb.bresp   <= 2'b00; // OKAY
      vif.tb_slave_cb.rresp   <= 2'b00; // OKAY
      vif.tb_slave_cb.rdata   <= '0;    // Return 0 data
      fork
        handle_writes();
        handle_reads();
      join_none
    endtask

    // Slave agent: No internal memory model implemented. Incoming write data
    //              is not stored or processed by this agent.
    protected virtual task handle_writes();
      logic [IDWIDTH-1:0] current_bid; // Store ID for response
      forever begin
        // Wait for write address
        vif.tb_slave_cb.awready <= 1'b0;
        @(vif.tb_slave_cb iff vif.tb_slave_cb.awvalid);
        current_bid = vif.tb_slave_cb.awid;
        `uvm_info(get_type_name(),
                  $sformatf("Slave Rcvd AW: Addr=0x%h ID=%0d",
                            vif.tb_slave_cb.awaddr, current_bid), UVM_HIGH)
        vif.tb_slave_cb.awready <= 1'b1;
        @(vif.tb_slave_cb);
        vif.tb_slave_cb.awready <= 1'b0;

        vif.tb_slave_cb.wready <= 1'b0;
        @(vif.tb_slave_cb iff vif.tb_slave_cb.wvalid);
        vif.tb_slave_cb.wready <= 1'b1;
        @(vif.tb_slave_cb);
        vif.tb_slave_cb.wready <= 1'b0;

        // Send write response (OKAY)
        @(vif.tb_slave_cb);
        vif.tb_slave_cb.bvalid <= 1'b1; // Assert valid
        vif.tb_slave_cb.bresp  <= 2'b00; // OKAY
        vif.tb_slave_cb.bid    <= current_bid; // Respond with stored AWID

        do @(vif.tb_slave_cb); while (!vif.tb_slave_cb.bready);

        @(vif.tb_slave_cb);
        vif.tb_slave_cb.bvalid <= 1'b0;
        `uvm_info(get_type_name(),
                  $sformatf("Slave Sent BResp OKAY ID=%0d", current_bid),
                  UVM_HIGH)
      end
    endtask

    // Slave agent: No internal memory model. Read operations will return a
    //              fixed value of zero.
    protected virtual task handle_reads();
      logic [IDWIDTH-1:0] current_rid; // Store ID for response
      forever begin
        // Wait for read address
        vif.tb_slave_cb.arready <= 1'b0;
        @(vif.tb_slave_cb iff vif.tb_slave_cb.arvalid);
        current_rid = vif.tb_slave_cb.arid;
        `uvm_info(get_type_name(),
                  $sformatf("Slave Rcvd AR: Addr=0x%h ID=%0d",
                            vif.tb_slave_cb.araddr, current_rid), UVM_HIGH)
        vif.tb_slave_cb.arready <= 1'b1;
        @(vif.tb_slave_cb);
        vif.tb_slave_cb.arready <= 1'b0;

        // Send read data/response (OKAY, Zero Data)
        // TODO: Add burst handling based on ARLEN
        @(vif.tb_slave_cb);
        vif.tb_slave_cb.rvalid <= 1'b1; // Assert valid
        vif.tb_slave_cb.rresp  <= 2'b00; // OKAY
        vif.tb_slave_cb.rdata  <= '0;    // Return 0 data
        vif.tb_slave_cb.rid    <= current_rid;
        vif.tb_slave_cb.rlast  <= 1'b1; // Assume single beat

        do @(vif.tb_slave_cb); while (!vif.tb_slave_cb.rready);

        @(vif.tb_slave_cb);
        vif.tb_slave_cb.rvalid <= 1'b0;
        vif.tb_slave_cb.rlast  <= 1'b0; // Deassert RLAST
        `uvm_info(get_type_name(),
                  $sformatf("Slave Sent RData Zero OKAY ID=%0d", current_rid),
                  UVM_HIGH)
      end
    endtask
  endclass

  //--------------------------------------------------------------------------
  // Class: coralnpu_axi_slave_agent
  //--------------------------------------------------------------------------
  class coralnpu_axi_slave_agent extends uvm_agent;
    `uvm_component_utils(coralnpu_axi_slave_agent)
    coralnpu_axi_slave_model slave_model;

    function new(string name = "coralnpu_axi_slave_agent",
                 uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      slave_model = coralnpu_axi_slave_model::type_id::create("slave_model",
                                                             this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
    endfunction
  endclass

endpackage : coralnpu_axi_slave_agent_pkg
