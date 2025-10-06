#!/usr/bin/make  -f
#
# Template for Makefile

################################################################################
PROJECT_NAME = rvv_fifo
################################################################################

DESIGN_ROOT = /workspace/IDC_IPDCD_ZSPHW01/perforce/cn9399/RVV_perforce_dk/RISCV/coralnpu_RVV/hdl/verilog/rvv
RTL_PATH = $(DESIGN_ROOT)/common
#RTLFILES = $(shell ls ../../common/*.sv)
RTLFILES := $(RTL_PATH)/fifo_flopped.sv \
	         $(RTL_PATH)/edff_2d.sv \
	         $(RTL_PATH)/edff.sv
RTL_INC   = +incdir+$(RTL_PATH)

TB = $(DESIGN_ROOT)/sve/rvv_fifo_tb
INCL      = +incdir+$(TB)/include+$(TB)/src+$(TB)/env+$(TB)/tests+$(TB)/hdl

################################################################################

######################define different configuration############################
scfg ?=
ifeq ($(filter $(scfg), basefifo \
                      basefifo_depth4 \
                      basefifo_data64_depth16 \
		      fifo_2w2r \
                       ), )
  scfg =  
endif
ifeq ($(scfg), basefifo)
   RTL_DEFINE = +define+DEPTH_8 +define+DWIDTH_32 +define+HALFFULL_HALF
endif
ifeq ($(scfg), basefifo_depth4)
   RTL_DEFINE = +define+DEPTH_4 +define+DWIDTH_32 +define+HALFFULL_HALF
endif
ifeq ($(scfg), basefifo_data64_depth16)
   RTL_DEFINE = +define+DEPTH_16 +define+DWIDTH_64
endif
ifeq ($(scfg), fifo_2w2r)
   RTL_DEFINE = +define+DEPTH_8 +define+DWIDTH_32 +define+FIFO_2W2R
	RTLFILES += $(RTL_PATH)/fifo_flopped_2w2r.sv
endif
ifeq ($(scfg), fifo_4w2r)
   RTL_DEFINE = +define+DEPTH_8 +define+DWIDTH_32 +define+FIFO_4W2R
	RTLFILES += $(RTL_PATH)/fifo_flopped_4w2r.sv
endif
################################################################################
BUILD_PATH = $(DESIGN_ROOT)/build/$(scfg)
SIM_PATH  = $(DESIGN_ROOT)/outfiles/$(scfg)/$(UVM_TEST)

DEFINES   = 
PLUS_ARGS = 
BUILD_OPTS =  
SIM_OPTS  = -l simv.log
TEST = rvv_fifo_test 
# ToDo: Top level dut file
DUT = 
#Checking the VCS version
#VCS_VERSION = $(shell vcs -id > vcs_version ; grep "Compiler version" vcs_version | awk -F " " '{print $$5}')
#This variable contains all the UVM-1.0 supported VCS tool versions.
SEED      ?= +ntb_random_seed_automatic
TIMESCALE = -timescale=1ns/1ps
UVM_VERBOSITY ?= UVM_LOW
UVM_TEST  ?= rvv_fifo_test
ifdef dump
   DUMP =  +dump 
else
	DUMP = 
endif

ifdef coverage
	COV = -cm cond+line+branch+tgl 
else
endif

DEBUG = 
ifdef debug
	DEBUG = +UVM_OBJECTION_TRACE
endif

#### VCS and UVM checking
ifdef VCS_HOME
 ifneq ($(VCS_VERSION),$(filter $(VCS_VERSION),$(UVM10_SUPP_VCS_VERSNS)))
  VCS_VERS_WARNING = 1
 endif  
 ifndef UVM_HOME
  UVM = -ntb_opts uvm 
 else
  UVM = -debug_pp +incdir+$(UVM_HOME)/src $(UVM_HOME)/src/uvm_pkg.sv ${UVM_HOME}/src/dpi/uvm_dpi.cc -CFLAGS -DVCS 
 endif
else
 ERR_STATUS = 1
endif

PLI_OPTS = -P ${NOVAS_HOME}/share/PLI/VCS/LINUX64/novas.tab ${NOVAS_HOME}/share/PLI/VCS/LINUX64/pli.a

BUILD_OPTS = -full64 -sverilog +define+SV $(UVM) $(RTL_INC) $(INCL) $(DEFINES) $(PLI_OPTS) $(PLUS_ARGS)

all default: check clean comp run

vcs: vlst mkdir
	@cd $(BUILD_PATH); vcs $(BUILD_OPTS)\
	$(RTL_DEFINE) \
	+vcs+lic+wait  \
   -debug_access+all \
	-file $(DESIGN_ROOT)/$(scfg).vlst \
	-o $(BUILD_PATH)/simv \
	-l vcs.log \
	$(COV) \
	$(TIMESCALE)

sim_test:
	@cd $(SIM_PATH);  $(BUILD_PATH)/simv -l test.log \
	$(RTL_DEFINE) \
	+vcs+lic+wait  \
	$(SEED) $(COV) +UVM_TESTNAME=$(UVM_TEST) +UVM_VERBOSITY=$(UVM_VERBOSITY) $(DUMP) $(DEBUG) \
	$(TIMESCALE)

chk_test:
	@echo "checking test result......"
	@$(DESIGN_ROOT)/com/check_test.pl check $(UVM_TEST) $(SIM_PATH)/test.log

sim: mktest sim_test chk_test
	@echo "finised simulation......"

mkdir:
	@echo "making simulation dir for scfg: $(scfg)"
	@rm -rf $(BUILD_PATH)
	@mkdir -p $(BUILD_PATH)

mktest:
	@echo "creating test simulation dir for test: $(UVM_TEST)"
	@mkdir -p $(DESIGN_ROOT)/outfiles
	@mkdir -p $(DESIGN_ROOT)/outfiles/$(scfg)
	@mkdir -p $(DESIGN_ROOT)/outfiles/$(scfg)/$(UVM_TEST)

vlst:
	@echo "creating vlst for rvv_fifo..."
	@rm -rf $(scfg).vlst
	@echo "$(RTL_INC)" > $(scfg).vlst
	@echo "$(INCL)" >> $(scfg).vlst
	@echo "$(RTL_DEFINE)" >> $(scfg).vlst
	@echo "$(TB)/hdl/rvv_fifo_top.sv" >> $(scfg).vlst
	@echo "$(RTLFILES)" >> $(scfg).vlst


clean:
	rm -rf simv* csrc
	rm -rf vc_hdrs.h .vcsmx_rebuild *.log
	rm -rf work/* *.svshell vcs_version

report:
	@echo "RTL_DEFINE: $(RTL_DEFINE)"
	@echo "scfg: $(scfg)"
help:
	@echo "****************************************************************"
	@echo "***   Makefile Help for rvv_fifo VIP :  					    ***"
	@echo "****************************************************************"
	@echo "*  Usage:                                                   *"
	@echo "*  ------                                                   *"
	@echo "*  make       Compile and Run the testcase                  *"
	@echo "*                                                           *"
	@echo "*  Available targets: vcs/sim/help/clean                    *"
	@echo "*  make help  			[To see the Help]                    *"
	@echo "*  Building options:                    							 *"
	@echo "*  make scfg=xxx vcs  	[compile the design]                 *"
	@echo "*  coverage=on  			[enable coverage option]             *"
	@echo "*  Simulation options:                    						 *"
	@echo "*  make scfg=xxx sim 	[Run simulation]                     *"
	@echo "*  UVM_TEST=xxx   		[To pass the name of the UVM test]   *"
	@echo "*  UVM_VERBOSITY=xxx   [set UVM message verbosity level]    *"
	@echo "*  debug=on   			[enable UVM debug options]           *"
	@echo "*  dump=on   				[enable fsdb dump]               	 *"
	@echo "*  dump=on   				[enable fsdb dump]               	 *"
	@echo "*  coverage=on   		[coverage enable]               		 *"
	@echo "*  example:                           							 *"
	@echo "*  sve/rvv_fifo_tb/Makefile scfg=fifo_4w2r vcs coverage=on  *"
	@echo "*  bsb sve/rvv_fifo_tb/Makefile scfg=fifo_4w2r UVM_TEST=rvv_fifo_bringup_test sim UVM_VERBOSITY=UVM_HIGH dump=on coverage=on"
	@echo "****************************************************************"
