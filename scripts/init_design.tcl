set max_core 16

##########################################################
#source design setup file
##########################################################

source -echo ../scripts/design_setup.tcl

set REPORT_QOR 0;

set CURRENT_STEP "init_design"

sh mkdir ../reports/$CURRENT_STEP
sh mkdir ../outputs/$CURRENT_STEP

##########################################################
#creating design_library
##########################################################

set target_library $LINK_LIBRARY
set link_library $LINK_LIBRARY

create_lib -technology $TECH_FILE -ref_libs $REFERENCE_LIBRARY $DESIGN_NAME


##########################################################
# READING VERILOG NETLIST FILE
##########################################################

read_verilog $VERILOG_NETLIST_FILES

current_design ${DESIGN_NAME}

link_design


########################################################## 
UPF FILE 
##########################################################

if {[file exists [which $UPF_SUPPLEMENTAL_FILE]]} {

  set_app_options -name mv.upf.enable_golden_upf -value true
}

if {[file exists [which $UPF_FILE]]} {
	load_upf $UPF_FILE

## For golden UPF flow only (if supplemental UPF is provided): read
#supplemental UPF file

if {[file exists [which $UPF_SUPPLEMENTAL_FILE]]} {

	load_upf -supplemental $UPF_SUPPLEMENTAL_FILE

} elseif {$UPF_SUPPLEMENTAL_FILE != ""} {

puts "Error: UPF_SUPPLEMENTAL_FILE($UPF_SUPPLEMENTAL_FILE) is invalid. Please correct it."

}

puts "Info: Running commit_upf"
commit_upf

} elseif {$UPF_FILE != ""} {
puts "Error: UPF file($UPF_FILE) is invalid. Please correct it."
}




###############################################################################
# 		  Timing and Design Constarints 
###############################################################################


##########################################################
# PARASITICTS FILE 
##########################################################

source -echo ../scripts/TCL_PARASITIC_SETUP_FILE.tcl

get_parasitic_techs

########################################################## 
#[MCMM] 
##########################################################

source -echo $TCL_MCMM_SETUP_FILE


report_pvt

##############################################################################
#		TECHNOLOGY SETUP - NDR and matal layer information
##############################################################################



##########################################################
# CTS_NDR 
##########################################################

source -echo ../scripts/cts_ndr.tcl


##########################################################
# Site_Symmetry
##########################################################

get_site_defs

set_attribute [get_site_defs unit] symmetry X

get_attribute [get_site_defs unit] symmetry 


##########################################################
#Routing Layers 
##########################################################
set_attribute [get_layers {M2 M4 M6 M8}] routing_direction vertical
set_attribute [get_layers {M1 M5 M7 M9}] routing_direction horizontal

get_attribute [get_layers {M0 M2 M4 M6 M8}] routing_direction
get_attribute [get_layers {M1 M3 M5 M7 M8}] routing_direction


##########################################################
#Reports for CTS_NDR 
#########################################################


report_routing_rules -verbose > $REPORTS_DIR/$CURRENT_STEP/routing_rules.txt	
report_clock_routing_rules  > $REPORTS_DIR/$CURRENT_STEP/clock_routing_rules.txt
report_clock_settings > $REPORTS_DIR/$CURRENT_STEP/clock_setting.txt


###############################################################
#Lib cell usage restrictions 
################################################################

source -echo "../scripts/set_lib_cell_purpose.tcl" 

set_attribute [get_lib_cells *AO*] dont_use -value true

#set_app_var simplified_verification_mode true
# Define the verification setup file for Formality
set_svf ${OUTPUTS_DIR}/${DESIGN_NAME}.mapped.svf

##################################################################
## Sanity checks and QoR Report	
###################################################################
if {$REPORT_QOR} {
	redirect ../reports/${CURRENT_STEP}/qor {source ../scripts/report_qor.tcl}
}

report_msg -summary
print_message_info -ids * -summary

#echo [date] > ../init_design
save_block -as init_design
save_lib
close_block -force
close_lib
exit