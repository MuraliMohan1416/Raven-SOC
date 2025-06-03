set_host_options -max_cores 4

source -echo ../scripts/design_setup.tcl

set REPORT_QOR 3;

set PREVIOUS_STEP "placement";

set CURRENT_STEP "cts";

sh mkdir ../outputs/$CURRENT_STEP

sh mkdir ../reports/$CURRENT_STEP

#set_app_options -name formality.svf.integrate_in_ndm -value true

copy_block -from $PREVIOUS_STEP  -to $CURRENT_STEP 

current_block $CURRENT_STEP  

set_svf ${OUTPUTS_DIR}/${DESIGN_NAME}.${CURRENT_STEP}.svf


if {$CLOCK_OPT_CTS_ACTIVE_SCENARIO_LIST != ""} {
	set_scenario_status -active false [get_scenarios -filter active]
	set_scenario_status -active true $CLOCK_OPT_CTS_ACTIVE_SCENARIO_LIST
}

## Adjustment file for modes/corners/scenarios/models to applied to each step (optional)
source  $TCL_MODE_CORNER_SCENARIO_MODEL_ADJUSTMENT_FILE; # -optional -print "TCL_MODE_CORNER_SCENARIO_MODEL_ADJUSTMENT_FILE"

if {[sizeof_collection [get_scenarios -filter "hold && active"]] == 0} {
	puts "RM-warning: No active hold scenario is found. Recommended to enable hold scenarios here such that CCD skewing can consider them." 
	puts "RM-info: Please activate hold scenarios for place_opt if they are available." 
}

################################################################
#variable
#################################################################

set_app_options -name cts.common.user_instance_name_prefix -value clock_opt_cts_
set_app_options -name cts.common.user_instance_name_prefix -value clock_opt_cts_opt_
set_app_options  -name cts.common.max_fanout -value 32

########################################################
#clock_opt
########################################################
clock_opt -from build_clock -to build_clock
clock_opt -from route_clock -to route_clock
clock_opt -from final_opto -to final_opto

connect_pg_net

####################################################################

#if {REPORT_QOR} {
#    redirect ../reports/${CURRENT_STEP}/qor {source ../scripts/report_qor.tcl}
#}

save_block

create_abstract  -read_only

create_frame -block_all true

save_lib

close_block -force

close_lib