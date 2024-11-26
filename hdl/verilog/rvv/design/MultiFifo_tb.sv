// Copyright 2024 Google LLC
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

class MultiFifoTransaction;
  rand logic [3:0][31:0] data;
  rand logic [2:0] valid;  // Number of elements that producer is enqueuing
  rand logic [2:0] ready;  // Number of elements that consumer is dequeuing.

  constraint valid_limit { valid < 4; };
  constraint ready_limit { ready < 4; };
endclass

class MultiFifoTransactionGenerator;
  rand MultiFifoTransaction transaction;
  mailbox gen2driv;
  int n;
  event finished;

  function new(mailbox gen2driv, int n, event finished);
    this.gen2driv = gen2driv;
    this.n = n;
    this.finished = finished;
  endfunction

  task generate_transactions();
    repeat(n) begin
      transaction = new();
      if( !transaction.randomize() ) $fatal("Gen:: trans randomization failed");
      gen2driv.put(transaction);
    end
    -> finished;
  endtask
endclass

interface MultiFifoInterface(input logic clk, rstn);
  logic [2:0] valid_in;
  logic [3:0][31:0] data_in;
  logic [4:0] fill_level;
  logic [3:0][31:0] data_out;
  logic [2:0] ready_out;

  clocking driver_cb @(posedge clk);
    default input negedge output negedge;
    input fill_level, data_out;
    output valid_in, data_in, ready_out;
  endclocking

  modport DRIVER (clocking driver_cb, input clk, rstn);

endinterface

class MultiFifoDriver;
  virtual MultiFifoInterface multififo_iface;
  mailbox gen2driv;
  mailbox enqueued;
  mailbox dequeued;

  MultiFifoTransaction transaction;
  int n_transactions_processed;

  logic [2:0] enqueued_fired;  // Number of elements to enqueue
  logic [2:0] dequeued_fired;  // Number of elements to enqueue
  logic [4:0] fill_level;
  logic [3:0][31:0] data_out;

  function new(virtual MultiFifoInterface multififo_iface,
               mailbox gen2driv,
               mailbox enqueued,
               mailbox dequeued);
    this.multififo_iface = multififo_iface;
    this.gen2driv = gen2driv;
    this.enqueued = enqueued;
    this.dequeued = dequeued;
  endfunction

  task reset;
    wait(!multififo_iface.rstn);
    $display("Reset started.");
    multififo_iface.DRIVER.driver_cb.valid_in <= 0;
    multififo_iface.DRIVER.driver_cb.data_in <= 0;
    multififo_iface.DRIVER.driver_cb.ready_out <= 0;
    wait(multififo_iface.rstn);
    $display("Finished resetting.");
  endtask

  task record_enqueue_dequeue;
  endtask

  task drive;
    forever begin
      $display("Running iteration ", n_transactions_processed);
      gen2driv.get(transaction);

      @(negedge multififo_iface.DRIVER.clk);

      fill_level = multififo_iface.DRIVER.driver_cb.fill_level;
      data_out = multififo_iface.DRIVER.driver_cb.data_out;

      enqueued_fired = (transaction.valid < (16 - fill_level)) ?
          transaction.valid : 16 - fill_level;
      dequeued_fired = (transaction.ready > fill_level) ?
          fill_level : transaction.ready;

      multififo_iface.DRIVER.driver_cb.valid_in <= enqueued_fired;
      multififo_iface.DRIVER.driver_cb.data_in <= transaction.data;
      multififo_iface.DRIVER.driver_cb.ready_out <= dequeued_fired;

      // Put enqueued and dequeued elements into checker mailboxes
      for (int i = 0; i < 4; i++) begin
        if (i < transaction.valid && i < enqueued_fired) begin
          // $display("Enqueuing ", transaction.data[i]);
          enqueued.put(transaction.data[i]);
        end
      end

      for (int o = 0; o < 4; o++) begin
        if (o < dequeued_fired && o < transaction.ready) begin
          // $display("Dequeuing ", data_out[o]);
          dequeued.put(data_out[o]);
        end
      end

      n_transactions_processed++;

      @(posedge multififo_iface.DRIVER.clk);
    end
  endtask

endclass

class MultiFifoComparator;
  mailbox enqueued;
  mailbox dequeued;
  int n_transactions_processed = 0;

  logic [31:0] enqueued_elem;
  logic [31:0] dequeued_elem;

  function new(mailbox enqueued,
               mailbox dequeued);
    this.enqueued = enqueued;
    this.dequeued = dequeued;
  endfunction

  task check;
    forever begin
      enqueued.get(enqueued_elem);
      dequeued.get(dequeued_elem);
      if (enqueued_elem != dequeued_elem) begin
        $display("Error: expected ", enqueued_elem, " got ", dequeued_elem);
      end
      n_transactions_processed++;
    end
  endtask
endclass

class MultiFifoEnvironment;
  localparam ITERATIONS = 512;

  MultiFifoTransactionGenerator gen;
  MultiFifoDriver driv;
  MultiFifoComparator comparator;
  mailbox gen2driv;
  mailbox enqueued;
  mailbox dequeued;
  event gen_ended;

  virtual MultiFifoInterface multififo_iface;

  function new(virtual MultiFifoInterface multififo_iface);
    this.multififo_iface = multififo_iface;

    gen2driv = new();
    enqueued = new();
    dequeued = new();
    gen = new(gen2driv, ITERATIONS, gen_ended);
    driv = new(multififo_iface, gen2driv, enqueued, dequeued);
    comparator = new(enqueued, dequeued);
  endfunction

  task setup();
    driv.reset();
  endtask

  task test();
    fork
      gen.generate_transactions();
      driv.drive();
      comparator.check();
    join_any
  endtask

  task teardown();
    wait(gen_ended.triggered);
    wait(driv.n_transactions_processed == ITERATIONS);
  endtask

  task run;
    setup();
    test();
    teardown();
    $finish;
  endtask
endclass;

program MultiFifoTest(MultiFifoInterface multififo_iface);
  MultiFifoEnvironment env;
  initial begin
    env = new(multififo_iface);
    env.run();
  end
endprogram

module MultiFifo_tb();
  logic clk;
  logic rstn;

  MultiFifoInterface multififo_iface(clk, rstn);

  typedef logic[31:0] MyInt;
  MultiFifo#(.T (MyInt), .N (4), .MAX_CAPACITY (16))
  dut(
    .clk(multififo_iface.clk),
    .rstn(multififo_iface.rstn),
    .valid_in(multififo_iface.valid_in),
    .data_in(multififo_iface.data_in),
    .fill_level(multififo_iface.fill_level),
    .data_out(multififo_iface.data_out),
    .ready_out(multififo_iface.ready_out)
  );

  // Clock and reset
  initial begin
    rstn = 0;
    clk = 0;
    #5
    clk = 1;
    #5
    clk = 0;
    rstn = 1;

    forever
      #5 clk = ~clk;
  end

  MultiFifoTest test(multififo_iface);
endmodule
