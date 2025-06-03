##########################################################################################
# Script: TCL_PARASITIC_SETUP_FILE.tcl (example)
# Version: U-2022.12-SP4
# Copyright (C) 2014-2023 Synopsys, Inc. All rights reserved.
##########################################################################################

##############################################################################################
# The following is a sample script to read two TLU+ files, 
# which you can expand to accomodate your design.
##############################################################################################

########################################
## Variables
########################################
## Parasitic tech files for read_parasitic_tech command; expand the section as needed
set parasitic1				"min_Tlu" ;# name of parasitic tech model 1
set tluplus_file($parasitic1)           "/home1/14_nmts/14_nmts/tech/star_rc/min/saed14nm_1p9m_Cmin.tluplus" ;# TLU+ files to read for parasitic 1
set layer_map_file($parasitic1)         "/home1/14_nmts/14_nmts/tech/star_rc/saed14nm_tf_itf_tluplus.map" ;# layer mapping file between ITF and tech for parasitic 1

set parasitic2				"max_Tlu" ;# name of parasitic tech model 2
set tluplus_file($parasitic2)           "/home1/14_nmts/14_nmts/tech/star_rc/max/saed14nm_1p9m_Cmax.tluplus" ;# TLU+ files to read for parasitic 2
set layer_map_file($parasitic2)         "/home1/14_nmts/14_nmts/tech/star_rc/saed14nm_tf_itf_tluplus.map" ;# layer mapping file between ITF and tech for parasitic 2

########################################
## Read parasitic files
########################################
## Read in the TLUPlus files first.
#  Later on in the corner constraints, you can then refer to these parasitic models.
foreach p [array name tluplus_file] {  
	puts "RM-info: read_parasitic_tech -tlup $tluplus_file($p) -layermap $layer_map_file($p) -name $p"
	read_parasitic_tech -tlup $tluplus_file($p) -layermap $layer_map_file($p) -name $p
}