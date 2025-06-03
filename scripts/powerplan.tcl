set_host_options -max_cores 16

source -echo ../scripts/design_setup.tcl

##########################################################
#initialize
##########################################################
set REPORT_QOR 1

set CURRENT_STEP "powerplan"

sh mkdir ../outputs/$CURRENT_STEP

sh mkdir ../reports/$CURRENT_STEP


set PREVIOUS_STEP "floorplan"

open_lib $DESIGN_LIBRARY.ndm

copy_block -from $PREVIOUS_STEP -to $CURRENT_STEP

current_block $CURRENT_STEP


link_block

##########################################################
#svf
##########################################################
set_svf $OUTPUTS_DIR/$CURRENT_STEP/powerplan.svf

##########################################################
#cell restriction
##########################################################

set_attribute [get_lib_cells *TIE*] dont_touch -value false

set_lib_cell_purpose -include optimization [get_lib_cell *TIE*]

set_attribute [get_lib_cells *CK*] dont_use -value false

set_lib_cell_purpose -include optimization [get_lib_cells *CK*]


##########################################################
#powerplan
##########################################################
remove_pg_strategies -all
remove_pg_patterns -all
remove_pg_regions -all
remove_pg_via_master_rules -all
remove_pg_strategy_via_rules -all
remove_routes -net_types {power ground} -ring -stripe -macro_pin_connect -lib_cell_pin_connect > /dev/null
connect_pg_net



set all_macros [get_cells -hierarchical -filter "is_soft_macro && !is_physical_only"]
set hm(raven_soc) [get_cells -filter "is_soft_macro==true" -physical_context {simpleuart spimemio}]
set hm(top) [remove_from_collection $all_macros $hm(raven_soc)]

create_keepout_margin -outer {5 5 5 5}  $all_macros

create_pg_ring_pattern P_HM_ring -horizontal_layer M5 -horizontal_width {1} -vertical_layer M6 -vertical_width {1} -vertical_spacing {1}  -horizontal_spacing {1} -corner_bridge false
set_pg_strategy S_HM_ring_risc -macros simpleuart -pattern { {pattern: P_HM_ring} {nets: {VDD VSS}} {offset: {2 2}} }
set_pg_strategy_via_rule S_ring_vias -via_rule { \
	{{{strategies: {S_HM_ring_risc}} {layers: {M9}}} {existing: {strap }}{via_master: {default}}} \
	{{{strategies: {S_HM_ring_risc}} {layers: {M8}}} {existing: {strap }}{via_master: {default}}} \
}
compile_pg -strategies {S_HM_ring_risc} -via_rule S_ring_vias

create_pg_ring_pattern P_HM_ring2 -horizontal_layer M5 -horizontal_width {1} -vertical_layer M6 -vertical_width {1} -vertical_spacing {1}  -horizontal_spacing {0.5} -corner_bridge false
set_pg_strategy S_HM_ring_risc2 -macros spimemio -pattern { {pattern: P_HM_ring2} {nets: {VDD VSS}} {offset: {1 1}} }
set_pg_strategy_via_rule S_ring_vias2 -via_rule { \
	{{{strategies: {S_HM_ring_risc}} {layers: {M5}}} {existing: {strap }}{via_master: {default}}} \
	{{{strategies: {S_HM_ring_risc}} {layers: {M6}}} {existing: {strap }}{via_master: {default}}} \
}
compile_pg -strategies {S_HM_ring_risc2} -via_rule S_ring_vias2

create_pg_macro_conn_pattern P_HM_pin -pin_conn_type scattered_pin -layers {M5 M4}
set_pg_strategy S_HM_risc_pins -macros $hm(raven_soc) -pattern { {pattern: P_HM_pin} {nets: {VSS VDD}} 

compile_pg -strategies {S_HM_risc_pins}

######################################################################################
create_pg_ring_pattern ring_pattern -horizontal_layer M9 \
   -horizontal_width {1.2} -horizontal_spacing {1} \
   -vertical_layer M8 -vertical_width {1.2} -vertical_spacing {1}\
   -corner_bridge true

set_pg_strategy core_ring \
   -pattern {{name: ring_pattern} {nets: {VDD VSS}} {offset: {1 1}}} -core\
   -extension {{{side:1} {nets:VDD VSS} {direction: B} {stop:design_boundary_and_generate_pin}}}

compile_pg -strategies {core_ring} 

##########################################################
#messh
##########################################################

create_pg_mesh_pattern P_top_two \
	-layers { \
		{ {horizontal_layer: M9} {width: 2} {spacing: interleaving} {pitch: 20} {offset: 1} {trim : true} } \
		{ {vertical_layer: M8}   {width: 2} {spacing: interleaving} {pitch: 20} {offset: 1} {trim : true} } \
		} \
	-via_rule { {intersection: adjacent} {via_master : default} }

set_pg_strategy router_top \
	-voltage_areas DEFAULT_VA \
	-pattern   { {name: P_top_two} {nets:{VDD VSS}} {offset:1} } \
	-extension { {nets: VDD VSS} {direction: T B L R}{stop:pad_ring} } \
          -blockage {{nets: VDD VSS} {macros_with_keepout: {spimemio simpleuart}}}
          
compile_pg -strategies {router_top}

#########################################################################################################

#				creating Lower Mesh

######################################################################################################### 

create_pg_mesh_pattern M2_mesh \
	-layers {{{vertical_layer: M2} {width: 0.09}  {track_alignment: track} {spacing: interleaving}{pitch:10} {trim:true}}\
                   {{horizontal_layer: M3} {width: 0.09} {spacing: interleaving} {track_alignment: track}{pitch:10} {trim:true}}}\
	-via_rule { {intersection: adjacent} {via_master : default} }

set_pg_strategy router_low_mesh\
	-voltage_areas DEFAULT_VA \
	-pattern {{name:M2_mesh}{nets: VDD VSS} {offset:0.5}}\
          -blockage {{nets: VDD VSS} {macros:{simpleuart spimemio}}}

	
compile_pg -strategies {router_low_mesh}

#########################################################################################################

#			       creating Rail

#########################################################################################################

create_pg_std_cell_conn_pattern P_std_cell_rail -layers M1

set_pg_strategy M1_vddl_rail \
	-voltage_areas DEFAULT_VA\
	-pattern {{pattern: P_std_cell_rail}{nets: VDD VSS}} \
          -blockage {{nets: VDD VSS} {macros_with_keepout: {spimemio simpleuart}}}


set_pg_strategy_via_rule rail_via_rule -via_rule \
                         {{intersection: adjacent} {via_master: default}}

compile_pg -strategies {M1_vddl_rail} -via_rule rail_via_rule

##########################################################
#verification
##########################################################

check_pg_connectivity

check_pg_drc

##################################################################
## Sanity checks and QoR Report	
###################################################################
set CURRENT_STEP "init_design"

if {$REPORT_QOR} {
	redirect ../reports/init_design  {source ../scripts/report_qor.tcl}
}

####################################################################
save_block
save_lib
close_block -force
close_lib