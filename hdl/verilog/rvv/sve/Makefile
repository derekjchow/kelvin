#!/usr/bin/make -f

TOP  = rvv
KELVIN_PATH = 
TBBUILD = build

DESIGN_PATH = $(PWD)/design/
STD_PATH = $(PWD)/common/

TESTBENCH_PATH = $(PWD)/sve/

LINT_DIR = $(PWD)/lint_test
LINT_SCRIPT_DIR = $(PWD)/scripts/sg_lint
GOALS   = lint/lint_rtl
export GOALS
export TOP
export LINT_DIR
# ------------------------------------------------------------------
#  Tools used by script
# ------------------------------------------------------------------

SIMULATOR = vcs
LINTTOOL = spyglass
MKDIR   = mkdir -p
MV      = mv


# generate design filelist
DESIGNLST = rvv.f
STDLIST = common.f
TESTBENCHLST = rvv_tb.f

design_list:
	@find $(DESIGN_PATH) -name '*.sv' -o -name '*.svh' > $(TBBUILD)/$(DESIGNLST)

std_list:
	@find $(STD_PATH) -name '*.sv' -o -name '*.svh' > $(TBBUILD)/$(STDLIST)

testbench_list:
	@find $(TESTBENCH_PATH) -name '*.sv' -o -name '*.svh' > $(TBBUILD)/$(TESTBENCHLST)

filelist: std_list design_list testbench_list
	@cat $(TBBUILD)/$(STDLIST) > $(TBBUILD)/sim.f
	#@cat $(TBBUILD)/$(DESIGNLST) >> $(TBBUILD)/sim.f
	#@cat $(TBBUILD)/$(TESTBENCHLST) >> $(TBBUILD)/sim.f

# lint check for RTL code
SGPRJ   = $(PWD)/sve/spyglass.prj
WORKPRJ = $(TBBUILD)/$(LINTTOOL)/work.prj

lint: 
	mkdir -p $(LINT_DIR); mkdir -p $(LINT_DIR)/RPT; mkdir -p $(LINT_DIR)/CSV;
	cp -rf $(LINT_SCRIPT_DIR)/filelist.f $(LINT_SCRIPT_DIR)/main_sg_lint.tcl $(LINT_DIR)/;
	#Add inc files
	sed -i "1i +incdir+$(PWD)/../inc" $(LINT_DIR)/filelist.f;
	#Add all common files
	ls $(PWD)/../common/* >1.txt; sed -i "2r 1.txt" $(LINT_DIR)/filelist.f; rm -rf 1.txt;
	#Add all design files
	#ls $(PWD)/../design/* >2.txt; sed -i "2r 2.txt" $(LINT_DIR)/filelist.f; rm -rf 2.txt;
	#Add user speficied files
	ls $(PWD)/../design/rvv_backend_retire.sv >2.txt; sed -i "2r 2.txt" $(LINT_DIR)/filelist.f; rm -rf 2.txt;
	ls $(PWD)/../design/rvv_backend_vrf.sv >2.txt; sed -i "2r 2.txt" $(LINT_DIR)/filelist.f; rm -rf 2.txt;
	ls $(PWD)/../design/rvv_backend_vrf_reg.sv >2.txt; sed -i "2r 2.txt" $(LINT_DIR)/filelist.f; rm -rf 2.txt;
	cd $(LINT_DIR);
	sg_shell -tcl $(LINT_DIR)/main_sg_lint.tcl;  echo "Lint Done";
	cp -rf $(LINT_DIR)/sg_run_results/lint/consolidated_reports/$(TOP)_lint_lint_rtl/* $(LINT_DIR)/RPT/;

lint_vcs: filelist
	-@test -d $(TBBUILD)/$(SIMULATOR). || ($(MKDIR) $(TBBUILD)/$(SIMULATOR); echo "$(MKDIR) $(TBBUILD)/$(SIMULATOR)")
	$(SIMULATOR) -c -full64 -sverilog -f $(TBBUILD)/sim.f -top $(TOP) -l $(TBBUILD)/$(SIMULATOR)/vcs.log

# Synthesis
