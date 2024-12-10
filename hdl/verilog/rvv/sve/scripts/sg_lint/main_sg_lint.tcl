#!SPYGLASS_PROJECT_FILE
#===============================================
set RTL_TOP         $env(TOP)
set RTL_FILE_LIST   $env(LINT_DIR)/filelist.f
#set WAIVE           sg_setup/VIVANTE_VIP_LINT_waiver.awl             
#===============================================
## new_project build -force
close_project -force
new_project lint -projectwdir $env(LINT_DIR)/sg_run_results -force
##Data Import Section
read_file -type sourcelist $RTL_FILE_LIST
#read_file -type awl        $WAIVE
set_option top $RTL_TOP

##Common Options Section
set_option language_mode mixed
set_option designread_disable_flatten no
set_option dw no
set_option enableSV yes
set_option enableSV09 yes
set_option libext { .sv .svh }
set_option mthresh 16384
set_option sgsyn_loop_limit 8000
set_option abstract_file_name_style short
set_option auto_save no
#set_option ignoredu {}
set_option sdc2sgdc no

##Goal Setup Section
current_methodology           $SPYGLASS_HOME/GuideWare/latest/block/rtl_handoff
current_goal  $env(GOALS)

set_parameter check_lrm_and_natural_width yes
set_parameter use_lrm_width yes

run_goal
save_project
exit -force

