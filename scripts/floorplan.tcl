########################################################
#floorplan
########################################################
open_lib raven_soc.dlib

open_block init_design/

set max_core 16

source -echo ../scripts/design_setup.tcl 

set REPORT_QOR 1;

set CURRENT_STEP "floorplan";

########################################################
#copy_block -to floorplan
########################################################

copy_block -to floorplan
current_block floorplan
link_block

########################################################
#svf
########################################################
set_svf $OUTPUTS_DIR/$DESIGN_NAME.$CURRENT_STEP.svf


########################################################
#initialize floorplan
########################################################

initialize_floorplan -core_utilization 0.5 -side_ratio {5 5} -core_offset {10}

#######################################################
#port placement
#######################################################

set_block_pin_constraints -self -allowed_layers {M1 M4} -sides {2 3}

place_pins -ports [get_ports -filter {direction == in}]


set_block_pin_constraints -self -allowed_layers {M1 M4} -sides {4 1}

place_pins -ports [get_ports -filter {direction == out}]


#######################################################
#tracks
#######################################################

remove_track -layer M1

create_track -layer M1 -coord 1.111 -space 0.037

report_track

######################################################
#boundary_cells
######################################################
create_boundary_cells -top_boundary_cells saed14rvt_ss0p6v125c/SAEDRVT14_CAPT2 -bottom_boundary_cells saed14rvt_ss0p6v125c/SAEDRVT14_CAPT2

create_boundary_cells -left_boundary_cell saed14rvt_ss0p6v125c/SAEDRVT14_CAPB2 -right_boundary_cell saed14rvt_ss0p6v125c/SAEDRVT14_CAPB2
connect_pg_net

check_legality

save_block -as floorplan

save_lib

exit