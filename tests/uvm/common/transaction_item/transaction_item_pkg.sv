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
// Package: transaction_item_pkg
// Description: Package holding common transaction item definitions.
//----------------------------------------------------------------------------
package transaction_item_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Define parameters locally or assume they are globally defined/passed
  // These might ideally come from a central configuration package later
  parameter int unsigned AWIDTH = 32;
  parameter int unsigned DWIDTH = 128;
  parameter int unsigned IDWIDTH = 6;
  parameter int unsigned USERWIDTH = 0;

  //--------------------------------------------------------------------------
  // Class: axi_transaction
  // Description: Defines an AXI transaction item
  //--------------------------------------------------------------------------
  typedef enum logic [1:0] {
    AXI_READ  = 2'b01,
    AXI_WRITE = 2'b10,
    AXI_RDWR  = 2'b11 // Could be used for modeling exclusive access etc.
  } axi_txn_type_e;

  // Helper enum for burst type (defined outside class for broader use)
  typedef enum logic [1:0] {
      AXI_BURST_FIXED = 2'b00,
      AXI_BURST_INCR  = 2'b01,
      AXI_BURST_WRAP  = 2'b10,
      AXI_BURST_RSVD  = 2'b11
  } axi_burst_type_e;

  class axi_transaction extends uvm_sequence_item;

    // Transaction type
    rand axi_txn_type_e txn_type;

    // Address Phase Fields
    rand logic [IDWIDTH-1:0]   id;
    rand logic [AWIDTH-1:0]  addr;
    rand logic [7:0]         len;   // Burst length (0=1 beat, 1=2 beats.. 255=256 beats)
    rand logic [2:0]         size;  // Transfer size (e.g., 3'b100 = 16 bytes if DWIDTH=128)
    rand axi_burst_type_e   burst;  // Burst type (FIXED, INCR, WRAP)
    rand logic               lock;
    rand logic [3:0]         cache;
    rand logic [2:0]         prot;
    rand logic [3:0]         qos;
    rand logic [3:0]         region;

    // Data Phase Fields
    rand logic [DWIDTH-1:0] data[$]; // Queue for data
    rand logic [DWIDTH/8-1:0] strb[$]; // Queue for strobes

    // Response Phase Fields (Captured by monitor or sequence)
    logic [1:0]         resp; // BRESP or RRESP

    // Constraints
    constraint c_burst_len {
      if (txn_type == AXI_WRITE) {
          data.size() == len + 1;
          strb.size() == len + 1;
      }
      len <= 255;
      size <= $clog2(DWIDTH/8);
    }
    constraint c_valid_type { txn_type inside {AXI_READ, AXI_WRITE}; }

    // UVM automation fields
    `uvm_object_utils_begin(axi_transaction)
      `uvm_field_enum(axi_txn_type_e, txn_type, UVM_DEFAULT)
      `uvm_field_int(id, UVM_DEFAULT)
      `uvm_field_int(addr, UVM_DEFAULT | UVM_HEX)
      `uvm_field_int(len, UVM_DEFAULT)
      `uvm_field_int(size, UVM_DEFAULT)
      `uvm_field_enum(axi_burst_type_e, burst, UVM_DEFAULT)
      `uvm_field_int(lock, UVM_DEFAULT)
      `uvm_field_int(cache, UVM_DEFAULT | UVM_HEX)
      `uvm_field_int(prot, UVM_DEFAULT)
      `uvm_field_int(qos, UVM_DEFAULT)
      `uvm_field_int(region, UVM_DEFAULT)
      `uvm_field_queue_int(data, UVM_DEFAULT | UVM_HEX) // Use queue int macro
      `uvm_field_queue_int(strb, UVM_DEFAULT | UVM_HEX) // Use queue int macro
      `uvm_field_int(resp, UVM_DEFAULT | UVM_NOCOMPARE)
    `uvm_object_utils_end

    // Constructor
    function new(string name = "axi_transaction");
      super.new(name);
    endfunction

  endclass : axi_transaction

  //--------------------------------------------------------------------------
  // Class: irq_transaction
  // Description: Defines a transaction item for IRQ/TE control signals
  //--------------------------------------------------------------------------
  class irq_transaction extends uvm_sequence_item;

    // Control fields
    rand bit drive_irq;
    rand bit irq_level;
    rand bit drive_te;
    rand bit te_level;

    `uvm_object_utils_begin(irq_transaction)
      `uvm_field_int(drive_irq, UVM_DEFAULT)
      `uvm_field_int(irq_level, UVM_DEFAULT)
      `uvm_field_int(drive_te, UVM_DEFAULT)
      `uvm_field_int(te_level, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "irq_transaction");
      super.new(name);
    endfunction

  endclass : irq_transaction

endpackage : transaction_item_pkg
