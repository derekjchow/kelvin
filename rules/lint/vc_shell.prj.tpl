set search_path ". $search_path"

# Setting the vcstatic platform to run vc spyglass lint
set_app_var enable_lint true

# Running the rtl_handoff lint_rtl template  (All the rules all picked from this file)
source $::env(VC_STATIC_HOME)/auxx/monet/tcl/GuideWare/block/rtl_handoff/lint/lint_rtl.tcl

## GuideWare rules for formal-aware lint
source $::env(VC_STATIC_HOME)/auxx/monet/tcl/GuideWare/block/rtl_handoff/lint/lint_functional_rtl.tcl

configure_lint_tag -enable -tag {{LINT_TAGS}} -goal {GOAL}
configure_lint_setup -goal {GOAL}

set analyze_skip_translate_body false

define_design_lib WORK -path ./WORK/VCS

## Reading the filelist and elaborating the design
analyze -format verilog { -f ./{F_FILE} } -vcs { -work WORK  -sv=2009 -assert svaext -Xspyglass_pragma=synopsys -Xspyglass_pragma=pragma -p1800_macro_expansion   }

# Configure blackboxed designs and files
set blackbox_designs {{BLACKBOX_DESIGNS}}
set blackbox_files {{BLACKBOX_FILES}}
set_blackbox -designs $blackbox_designs
set_blackbox_file -files $blackbox_files

# Elaborate the desired module
elaborate {MODULE_TO_LINT}

check_lint

set waive_tags {{WAIVE_TAGS}}
for {set i 0} {$i < [llength $waive_tags]} {incr i} {
  set tag [lindex $waive_tags $i]
  if {$i == 0} {
    waive_violation -app Lint -add waiver1 -tag $tag
  } else {
    waive_violation -app Lint -append waiver1 -tag $tag
  }
}

set errors [get_violation_info -severity {fatal error}]
if {($errors) > 0} {
  puts "Lint failed"
  report_violations -list -report {all}

  exit 1
}

# Report the Lint violations
report_violations -verbose -report {all} -no_summary -include_waived -file {REPORT_VIOLATIONS_FILE}

exit 0