set_parasitic_parameters -late_spec max_Tlu -early_spec min_Tlu -corners ss0p6v125c

set_temperature -40 -corners ss0p6v125c

set_voltage 0.60 -object_list VDD -corner ss0p6v125c
set_voltage 0.60 -object_list VDDh -corner ss0p6v125c
set_voltage 0.00 -object_list VSS