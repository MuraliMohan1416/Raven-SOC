open_lib $DESIGN_NAME.ndm

set_host_options -max_cores 4

source -echo ../scripts/design_setup.tcl

set REPORT_QOR 4;

set PREVIOUS_STEP "cts";

set CURRENT_STEP "routing";

sh mkdir ../outputs/$CURRENT_STEP

sh mkdir ../reports/$CURRENT_STEP

#set_app_options -name formality.svf.integrate_in_ndm -value true

open_block $PREVIOUS_STEP

copy_block -from $PREVIOUS_STEP  -to $CURRENT_STEP 

current_block $CURRENT_STEP  

set_svf ${OUTPUTS_DIR}/${DESIGN_NAME}.${CURRENT_STEP}.svf


if {$ROUTE_AUTO_ACTIVE_SCENARIO_LIST  != ""} {
	set_scenario_status -active false [get_scenarios -filter active]
	set_scenario_status -active true $ROUTE_AUTO_ACTIVE_SCENARIO_LIST 
}

## Adjustment file for modes/corners/scenarios/models to applied to each step (optional)
source  $TCL_MODE_CORNER_SCENARIO_MODEL_ADJUSTMENT_FILE; # -optional -print "TCL_MODE_CORNER_SCENARIO_MODEL_ADJUSTMENT_FILE"

if {[sizeof_collection [get_scenarios -filter "hold && active"]] == 0} {
	puts "RM-warning: No active hold scenario is found. Recommended to enable hold scenarios here such that CCD skewing can consider them." 
	puts "RM-info: Please activate hold scenarios for place_opt if they are available." 
}

#########################################################33
# variables
###########################################################

set_app_options -name route.detail.timing_driven  -value true

set_app_options -name route.detail.timing_driven  -value true

set_app_options -name route.track.crosstalk_driven -value true

set_app_options -name route.common.global_min_layer_mode -value allow_pin_connection

set_app_options -name route.common.global_max_layer_mode -value soft

set_app_options -name time.si_enable_analysis -value true

set_ignored_layers -max_routing_layer M8 -min_routing_layer M2

##########################################################################
# routing CTS flow
##########################################################################
check_lvs

route_auto -max_detail_route_iterations 30

route_opt

route_eco -max_detail_route_iterations 30

save_block

save_lib