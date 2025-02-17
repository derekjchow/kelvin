`ifndef RVV_COV__SV
`define RVV_COV__SV

class rvv_cov extends uvm_component;
  event cov_event;
  rvs_transaction tr;
  uvm_analysis_imp #(rvs_transaction, rvv_cov) cov_export;
  `uvm_component_utils(rvv_cov)

  typedef virtual rvv_intern_interface v_if4;
  v_if4 rvv_intern_if;
 
  function new(string name, uvm_component parent);
    super.new(name,parent);
    cg_trans = new;
    cg_waw = new();
    cov_export = new("Coverage Analysis",this);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    if(!uvm_config_db#(v_if4)::get(this, "", "rvv_intern_if", rvv_intern_if)) begin
      `uvm_fatal("COV/NOVIF", "No virtual interface specified for this agent instance")
    end
  endfunction: build_phase
  virtual function void connect_phase(uvm_phase phase);
  endfunction: connect_phase

  virtual task main_phase(uvm_phase phase);
    fork
      vidx_eq_check();
    join
  endtask: main_phase

// rvs_transaction cov -----------------------------------------------
  virtual function write(rvs_transaction tr);
     this.tr = tr;
     -> cov_event;
  endfunction: write

  covergroup cg_trans @(cov_event);
     // coverpoint tr.kind;
     // ToDo: Add required coverpoints, coverbins
  endgroup: cg_trans

// WAW cov -----------------------------------------------------------
  event rob2rt_cov_event;
  
  logic [`NUM_RT_UOP-1:0] [`NUM_RT_UOP-1:0] vidx_eq;

  task vidx_eq_check();
    forever begin
      @(posedge rvv_intern_if.clk);
      if(~rvv_intern_if.rst_n) begin
      end else begin
        vidx_eq = '0;
        if(|(rvv_intern_if.rob2rt_write_valid & rvv_intern_if.rt2rob_write_ready)) begin
          for(int i=0; i<`NUM_RT_UOP; i++) begin
            for(int j=0; j<`NUM_RT_UOP; j++) begin
              vidx_eq[i][j] = ((rvv_intern_if.rob2rt_write_data[i].w_type === 1'b0) && rvv_intern_if.rob2rt_write_data[i].w_valid) && 
                              ((rvv_intern_if.rob2rt_write_data[j].w_type === 1'b0) && rvv_intern_if.rob2rt_write_data[j].w_valid) &&
                              (rvv_intern_if.rob2rt_write_data[i].w_index === rvv_intern_if.rob2rt_write_data[j].w_index);
            end
          end
          -> rob2rt_cov_event;
        end
      end
    end
  endtask: vidx_eq_check

  covergroup cg_waw @(rob2rt_cov_event);
    WAW:
      coverpoint {vidx_eq[3][2], vidx_eq[3][1], vidx_eq[3][0], vidx_eq[2][1], vidx_eq[2][0], vidx_eq[1][0]} {
        bins waw4 = {6'b1_1_1_1_1_1  //  3 &  2 &  1  &  0
                    };        

        bins waw3 = {6'b1_1_0_1_0_0, //  3 &  2 &  1  & !0
                     6'b1_0_1_0_1_0, //  3 &  2 & !1  &  0
                     6'b0_1_1_0_0_1, //  3 & !2 &  1  &  0
                     6'b0_0_0_1_1_1  // !3 &  2 &  1  &  0
                    };

        bins waw2_1 = {6'b1_0_0_0_0_0, //  3 &  2 & !1  & !0
                       6'b0_1_0_0_0_0, //  3 & !2 &  1  & !0
                       6'b0_0_1_0_0_0, //  3 & !2 & !1  &  0
                       6'b0_0_0_1_0_0, // !3 &  2 &  1  & !0
                       6'b0_0_0_0_1_0, // !3 &  2 & !1  &  0
                       6'b0_0_0_0_0_1  // !3 & !2 &  1  &  0
                      };

        bins waw2_2 = {6'b1_0_0_0_0_1,//  3 &  2 ,  1  &  0
                       6'b0_1_0_0_1_0,//  3 &  1 ,  2  &  0
                       6'b0_0_1_1_0_0 //  3 &  0 ,  2  &  1
                      };
                    
        bins waw1 = {6'b0_0_0_0_0_0
                    };

        illegal_bins misc = default;

      }
  endgroup

endclass: rvv_cov

`endif // RVV_COV__SV

