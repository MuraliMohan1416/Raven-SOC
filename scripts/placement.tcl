open_lib $DESIGN_NAME.dlib

set_host_options -max_cores 16

source -echo ../scripts/design_setup.tcl

set REPORT_QOR 2

set PREVIOUS_STEP "powerplan";

set CURRENT_STEP "placement";

sh mkdir ../outputs/$CURRENT_STEP

sh mkdir ../reports/$CURRENT_STEP

#set_app_options -name formality.svf.integrate_in_ndm -value true

open_block $PREVIOUS_STEP

copy_block -from $PREVIOUS_STEP  -to $CURRENT_STEP

current_block $CURRENT_STEP

link_block
####################################################
#lib cell purpose
####################################################


set_vsdc ${OUTPUTS_DIR}/${DESIGN_NAME}.${CURRENT_STEP}.vsdc


## Set active scenarios for the step (please include CTS and hold scenarios for CCD)
if {$PLACE_OPT_ACTIVE_SCENARIO_LIST != ""} {
	set_scenario_status -active false [get_scenarios -filter active]
	set_scenario_status -active true $PLACE_OPT_ACTIVE_SCENARIO_LIST
}

current_scenario $PLACE_OPT_ACTIVE_SCENARIO_LIST;

## Adjustment file for modes/corners/scenarios/models to applied to each step (optional)
source  $TCL_MODE_CORNER_SCENARIO_MODEL_ADJUSTMENT_FILE; # -optional -print "TCL_MODE_CORNER_SCENARIO_MODEL_ADJUSTMENT_FILE"

if {[sizeof_collection [get_scenarios -filter "hold && active"]] == 0} {
	puts "RM-warning: No active hold scenario is found. Recommended to enable hold scenarios here such that CCD skewing can consider them." 
	puts "RM-info: Please activate hold scenarios for place_opt if they are available." 
}

save_block

save_lib

##################################################################
#options for cell density and coarse placement
##################################################################

set_app_options -name place.coarse.max_density -value 0.4

set_app_options -name place.coarse.continue_on_missing_scandef -value true

##################################################################
#IO Buffers
##################################################################

catch {add_buffer [get_nets -of [get_ports]] [get_lib_cells */*SAEDLVT*BUF_20]}

##################################################################
#magnetic_placement
##################################################################
magnet_placement [get_ports *]

set_attribute [get_cells *CAP*] physical_status fixed

set_attribute [get_cells eco_cell*] physical_status fixed


##################################################################
#placement
##################################################################
set_app_options -name top_level.continue_flow_on_check_hier_design_errors -value true

create_placement -congestion

save_lib

check_legality -verbose

set_attribute [get_lib_cells *lvt*/*] threshold_voltage_group LVT

set_threshold_voltage_group_type -type low_vt  LVT

set_multi_vth_constraint -low_vt_percentage 8 -cost cell_count

place_opt 

save_block

check_legality -verbose


create_abstract  -read_only

create_frame -block_all true

save_lib

close_block -force

close_lib