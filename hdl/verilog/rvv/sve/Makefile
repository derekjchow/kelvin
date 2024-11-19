#!/usr/bin/make -f

TOPMODULE  = rvv
KELVIN_PATH = 
TBBUILD = build

DESIGN_PATH = $(PWD)/design/
STD_PATH = $(PWD)/../common/

TESTBENCH_PATH = $(PWD)/sve/

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
GOALS   = lint/lint_rtl
SGPRJ   = $(PWD)/sve/spyglass.prj
WORKPRJ = $(TBBUILD)/$(LINTTOOL)/work.prj

lint: filelist
	-@test -d $(TBBUILD)/$(LINTTOOL). || ($(MKDIR) $(TBBUILD)/$(LINTTOOL); echo "$(MKDIR) $(TBBUILD)/$(LINTTOOL)")
	@echo "   ------------------------------ "
	@echo "   Running Lint checker on the RTL "
	@echo "   ------------------------------ "
	@cp $(SGPRJ) $(WORKPRJ)
	@sed -i 's/filelist/$(TBBUILD)\/sim.f/g' $(WORKPRJ)
	@sed -i 's/builddir/$(TBBUILD)\/$(LINTTOOL)/g' $(WORKPRJ)
	@sed -i 's/topmodule/$(TOPMODULE)/g' $(WORKPRJ)
	-$(LINTTOOL) -goals $(GOALS) -project $(WORKPRJ) -batch
	-@$(MV) spyglass.out $(TBBUILD)/$(LINTTOOL)
	-@$(MV) dashboard.log $(TBBUILD)/$(LINTTOOL)
	-@$(MV) datasheet.log $(TBBUILD)/$(LINTTOOL)
	-@$(MV) goals_summary.log $(TBBUILD)/$(LINTTOOL)

lint_vcs: filelist
	-@test -d $(TBBUILD)/$(SIMULATOR). || ($(MKDIR) $(TBBUILD)/$(SIMULATOR); echo "$(MKDIR) $(TBBUILD)/$(SIMULATOR)")
	$(SIMULATOR) -c -full64 -sverilog -f $(TBBUILD)/sim.f -top $(TOPMODULE) -l $(TBBUILD)/$(SIMULATOR)/vcs.log

# Synthesis
