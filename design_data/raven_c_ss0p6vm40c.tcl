set_parasitic_parameters -early_spec min_Tlu -late_spec min_Tlu -corners ss0p6vm40c

set_temperature -40 -corners ss0p6vm40c

set_voltage 0.60 -object_list VDD  -corners ss0p6vm40c

set_voltage 0.60 -object_list VDDh  -corners ss0p6vm40c

set_voltage 0.00 -object_list VSS