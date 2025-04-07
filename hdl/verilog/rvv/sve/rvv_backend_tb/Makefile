#!/usr/bin/make  -f

# ------------------------------------------------------------------
# Setting of project
# ------------------------------------------------------------------
RVV_WORKSPACE = $(shell pwd | sed 's/\(\S\+\)\/hdl\/verilog\/rvv/\1/')
scfg ?= rvv_backend
test ?= tb_debug_test
PROJECT_NAME = rvv_backend_tb

# ------------------------------------------------------------------
# path & filelist
# ------------------------------------------------------------------
RVV_ROOT     = $(RVV_WORKSPACE)/hdl/verilog/rvv
DESIGN_PATH  = $(RVV_ROOT)/design
STD_PATH     = $(RVV_ROOT)/common
TB_PATH      = $(RVV_ROOT)/sve/$(PROJECT_NAME)

RTLFILES = $(shell ls $(DESIGN_PATH)/rvv_backend*.sv)
RTLFILES += $(shell ls $(STD_PATH)/*.sv)
RTL_INC  = $(RVV_ROOT)/inc

TBFILES = $(shell ls $(TB_PATH)/hdl/*.sv)
TB_INC  = $(TB_PATH)/include	\
					$(TB_PATH)/src	\
					$(TB_PATH)/env	\
					$(TB_PATH)/tests	\
					$(TB_PATH)/hdl

RTL_INC := $(RTL_INC:%=+incdir+%)
TB_INC := $(TB_INC:%=+incdir+%)

UNUSED = $(DESIGN_PATH)/Aligner.sv	\
				$(DESIGN_PATH)/Aligner_tb.sv	\
				$(DESIGN_PATH)/MultiFifo.sv	\
				$(DESIGN_PATH)/MultiFifo_tb.sv	\
				$(DESIGN_PATH)/rvv_backend_mul_unit.sv	\
				$(DESIGN_PATH)/RvvBackend.sv

UNUSED += $(STD_PATH)/fifo_flopped_2w2r.sv	\
					$(STD_PATH)/fifo_flopped_4w2r.sv	\
					$(STD_PATH)/openFifo8_flopped_2w2r.sv	\
					$(STD_PATH)/openFifo4_flopped_ptr.sv
					

# ------------------------------------------------------------------
# scfg
# ------------------------------------------------------------------
RTL_DEFINE = 
TB_DEFINE = 
ifeq ($(filter $(scfg), rvv_backend	\
												rvv_backend_bringup\
                       ), )
  scfg =  
endif
ifeq ($(scfg), rvv_backend)
	RTL_DEFINE = +define+TB_SUPPORT
	RTL_DEFINE += +define+ASSERT_ON
	RTL_DEFINE += +define+RVV_CONFIG_SVH +define+ISSUE_3_READ_PORT_6
endif
ifeq ($(scfg), rvv_backend_i2rp4)
	RTL_DEFINE = +define+TB_SUPPORT
	RTL_DEFINE += +define+ASSERT_ON
	RTL_DEFINE += +define+RVV_CONFIG_SVH +define+ISSUE_2_READ_PORT_4
endif
ifeq ($(scfg), rvv_backend_i2rp6)
	RTL_DEFINE = +define+TB_SUPPORT
	RTL_DEFINE += +define+ASSERT_ON
	RTL_DEFINE += +define+RVV_CONFIG_SVH +define+ISSUE_2_READ_PORT_6
endif
ifeq ($(scfg), rvv_backend_i3rp6)
	RTL_DEFINE = +define+TB_SUPPORT
	RTL_DEFINE += +define+ASSERT_ON
	RTL_DEFINE += +define+RVV_CONFIG_SVH +define+ISSUE_3_READ_PORT_6
endif
ifeq ($(scfg), rvv_backend_bringup)
	RTL_DEFINE = +define+TB_BRINGUP+TB_SUPPORT
	RTL_DEFINE += +define+ASSERT_ON
	RTLFILES = $(DESIGN_PATH)/rvv_backend.sv
endif

# ------------------------------------------------------------------
# VCS Options
# ------------------------------------------------------------------
DEFINES   = $(RTL_DEFINE) $(TB_DEFINE)
PLUS_ARGS ?= 
BUILD_OPTS =  
SIM_OPTS  =
UVM_TEST ?= $(test)
TB_TOP = rvv_backend_top
#Checking the VCS version
#VCS_VERSION = $(shell vcs -id > vcs_version ; grep "Compiler version" vcs_version | awk -F " " '{print $$5}')
#This variable contains all the UVM-1.0 supported VCS tool versions.
UVM10_SUPP_VCS_VERSNS = E-2011.03 
TIMESCALE = -override_timescale=1ns/1ps
UVM_VERBOSITY ?= UVM_LOW
SIM_TCL ?= $(TB_PATH)/dump_fsdb.tcl
# PARTCOMP = -partcomp -topcfg $(TB_PATH)/$(PROJECT_NAME)_topcfg.v
PARTCOMP =
timeout ?= "1000000000ns,no"
logdir ?= "outfiles"

ifdef seed
	SEED = +ntb_random_seed=$(seed)
else
	SEED = +ntb_random_seed_automatic
endif
ifdef seed
TESTNAME   = $(UVM_TEST)$(atn)"."$(seed)
else
TESTNAME   = $(UVM_TEST)$(atn)
endif
ifeq ($(dump),on)
 	DUMP = -ucli -i $(SIM_TCL)
else
	DUMP = 
endif
ifeq ($(coverage),on)
	COV = -cm cond+line+branch+tgl -cm_dir $(COV_PATH) -cm_name $(TESTNAME)
	DEFINES := $(filter-out +define+TB_SUPPORT, $(DEFINES))
else
	COV = 
endif
ifeq ($(debug),on)
	UVM_DEBUG_COMP =  -kdb -lca +UVM_VERDI_COMPWAVE
	UVM_DEBUG_SIM = +UVM_VERDI_TRACE="UVM_AWARE+RAL+HIRE+COMPWAVE" +UVM_TR_RECORD -gui=verdi
else 
	UVM_DEBUG_COMP = 
	UVM_DEBUG_SIM = 
endif
atn ?=
max_error ?= 1

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

ASSERT_OPTS = -assert global_finish_maxfail=1		\
							-assert set_error_action=display -assert set_error_action=count	\
							-assert set_warning_action=display	\
							-assert set_info_action=display	\
							-assert quiet+quiet1+nopostproc

BUILD_PATH = $(RVV_ROOT)/build/$(scfg)

SIM_PATH	 = $(RVV_ROOT)/$(logdir)/$(scfg)/$(TESTNAME)
COV_PATH   = $(RVV_ROOT)/$(logdir)/$(scfg)/

#Compile command
VCOMP = vcs -full64 -sverilog +define+SV	\
				+nospecify	\
				+vcs+lic+wait	\
				-deraceclockdata +notimingcheck	\
				-debug_access+all	\
				-assert enable_hier	\
				$(TIMESCALE)	\
				$(PLI_OPTS)	\
				$(UVM)	\
				$(COV)	\
				$(UVM_DEBUG_COMP)	\
				-Mupdate -Mdir=$(BUILD_PATH)/csrc	\
				$(PARTCOMP)	\
				-f $(RVV_ROOT)/$(scfg).vlst -top $(TB_TOP)	\
				-o $(BUILD_PATH)/simv	 


#Simulation command
VSIM  = $(BUILD_PATH)/simv	\
				+vcs+lic+wait  \
				$(ASSERT_OPTS)	\
				$(SEED)	\
				$(PLUS_ARGS)	\
				+UVM_TESTNAME=$(UVM_TEST) +UVM_VERBOSITY=$(UVM_VERBOSITY) \
				$(DUMP) $(UVM_DEBUG_SIM)	\
				+UVM_MAX_QUIT_COUNT=$(max_error),NO	\
				+UVM_TIMEOUT=$(timeout)	\
				$(COV)

RTLFILES := $(filter-out $(UNUSED),$(RTLFILES))

# ------------------------------------------------------------------
# CMDs
# ------------------------------------------------------------------
all default: vcs sim 

vcs: vlst mkbuilddir
	@cd $(BUILD_PATH); $(VCOMP) -l $(BUILD_PATH)/vcs.log 
	@echo "Build log: $(BUILD_PATH)/vcs.log"

sim_test:
	@cd $(SIM_PATH); $(VSIM) -l $(SIM_PATH)/test.log
	@echo "Test log: $(SIM_PATH)/test.log"

chk_test:
	@echo "checking test result......"
	@$(RVV_ROOT)/com/check_test.pl check $(UVM_TEST) $(SIM_PATH)/test.log 

cleanup_log:
	@echo "cleaning up test log......"
	@$(RVV_ROOT)/com/check_test.pl clean $(UVM_TEST) $(SIM_PATH)/tb_asm_dump.log

sim: mksimdir sim_test chk_test cleanup_log
	@echo "finised simulation......"

mkbuilddir:
	@echo "making build dir for scfg: $(scfg)"
	# @rm -rf $(BUILD_PATH)
	@mkdir -p $(BUILD_PATH)

mksimdir:
	@echo "creating test simulation dir for test: $(UVM_TEST)"
	@mkdir -p $(SIM_PATH)
	@cp $(scfg).vlst $(SIM_PATH)

list vlst:
	@echo "creating vlst for $(scfg)..."
	@rm -rf $(scfg).vlst
	@echo "$(RTL_INC)" > $(RVV_ROOT)/$(scfg).vlst
	@echo "$(TB_INC)" >> $(RVV_ROOT)/$(scfg).vlst
	@echo "$(DEFINES)" >> $(RVV_ROOT)/$(scfg).vlst
	@echo "$(RTLFILES)" >> $(RVV_ROOT)/$(scfg).vlst
	@echo "$(TBFILES)" >> $(RVV_ROOT)/$(scfg).vlst
	@perl -i -ane 's/\s+/\n/g; s/-(.)\n/-$$1 /g; s,//,/,g; print;' $(RVV_ROOT)/$(scfg).vlst


clean:
	rm -rf $(RVV_ROOT)/build/
	rm -rf $(RVV_ROOT)/outfiles/
	rm -rf *.vlst 

show:
	@echo "WORKSPACE: $(RVV_WORKSPACE)"
	@echo "RTL_DEFINE: $(RTL_DEFINE)"
	@echo "scfg: $(scfg)"
	@echo "SIM_PATH: $(SIM_PATH)"

help:
	@echo "***************************************************************"
	@echo "   Makefile Help for $(PROJECT_NAME) :                         "
	@echo "***************************************************************"
	@echo "  Usage:                                                       "
	@echo "  ------                                                       "
	@echo "  make       Compile and Run the testcase                      "
	@echo "                                                               "
	@echo "  Available targets: all/vcs/sim/help/clean                    "
	@echo "    make help                  [To see the Help]               "
	@echo "  Building options:                                            "
	@echo "    make scfg=xxx vcs    [compile the design]                  "
	@echo "      coverage=on        [enable coverage option]              "
	@echo "  Simulation options:                                          "
	@echo "    make scfg=xxx sim test=xxx [Run simulation]                "
	@echo "      PLUS_ARGS=xxx     [set plusargs]                         "
	@echo "      UVM_VERBOSITY=xxx [set UVM message verbosity level]      "
	@echo "      debug=on          [enable UVM debug options]             "
	@echo "      dump=on           [enable fsdb dump]                     "
	@echo "      coverage=on       [coverage enable]                      "
	@echo "      max_error=xx      [max UVM_ERROR to quit, default 10]    "
	@echo "  Example:                                                     "
	@echo "    sve/rvv_fifo_tb/Makefile scfg=$(scfg) vcs coverage=on      "
	@echo "    sve/rvv_fifo_tb/Makefile scfg=$(scfg) sim UVM_TEST=$(UVM_TEST) UVM_VERBOSITY=UVM_HIGH dump=on coverage=on"
	@echo "***************************************************************"
