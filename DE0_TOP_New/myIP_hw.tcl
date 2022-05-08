# TCL File Generated by Component Editor 13.1
# Sun May 08 21:20:24 BST 2022
# DO NOT MODIFY


# 
# myIP "myIP" v1.0
#  2022.05.08.21:20:24
# 
# 

# 
# request TCL package from ACDS 13.1
# 
package require -exact qsys 13.1


# 
# module myIP
# 
set_module_property DESCRIPTION ""
set_module_property NAME myIP
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME myIP
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL AUTO
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL Accelerator
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
add_fileset_file accelerator.vhdl VHDL PATH ../../../Documents/accelerator/accelerator.vhdl TOP_LEVEL_FILE
add_fileset_file accelerator_pkg.vhdl VHDL PATH ../../../Documents/accelerator/accelerator_pkg.vhdl

add_fileset SIM_VERILOG SIM_VERILOG "" ""
set_fileset_property SIM_VERILOG TOP_LEVEL Accelerator
set_fileset_property SIM_VERILOG ENABLE_RELATIVE_INCLUDE_PATHS false
add_fileset_file accelerator_pkg.vhdl VHDL PATH ../../../Documents/accelerator/accelerator_pkg.vhdl
add_fileset_file accelerator_tb.vhdl VHDL PATH ../../../Documents/accelerator/accelerator_tb.vhdl


# 
# parameters
# 


# 
# display items
# 


# 
# connection point clock
# 
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true
set_interface_property clock EXPORT_OF ""
set_interface_property clock PORT_NAME_MAP ""
set_interface_property clock CMSIS_SVD_VARIABLES ""
set_interface_property clock SVD_ADDRESS_GROUP ""

add_interface_port clock clk clk Input 1


# 
# connection point reset
# 
add_interface reset reset end
set_interface_property reset associatedClock clock
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED true
set_interface_property reset EXPORT_OF ""
set_interface_property reset PORT_NAME_MAP ""
set_interface_property reset CMSIS_SVD_VARIABLES ""
set_interface_property reset SVD_ADDRESS_GROUP ""

add_interface_port reset reset_n reset_n Input 1


# 
# connection point PORTDRIVER
# 
add_interface PORTDRIVER avalon end
set_interface_property PORTDRIVER addressUnits WORDS
set_interface_property PORTDRIVER associatedClock clock
set_interface_property PORTDRIVER associatedReset reset
set_interface_property PORTDRIVER bitsPerSymbol 8
set_interface_property PORTDRIVER burstOnBurstBoundariesOnly false
set_interface_property PORTDRIVER burstcountUnits WORDS
set_interface_property PORTDRIVER explicitAddressSpan 0
set_interface_property PORTDRIVER holdTime 0
set_interface_property PORTDRIVER linewrapBursts false
set_interface_property PORTDRIVER maximumPendingReadTransactions 0
set_interface_property PORTDRIVER readLatency 0
set_interface_property PORTDRIVER readWaitTime 1
set_interface_property PORTDRIVER setupTime 0
set_interface_property PORTDRIVER timingUnits Cycles
set_interface_property PORTDRIVER writeWaitTime 0
set_interface_property PORTDRIVER ENABLED true
set_interface_property PORTDRIVER EXPORT_OF ""
set_interface_property PORTDRIVER PORT_NAME_MAP ""
set_interface_property PORTDRIVER CMSIS_SVD_VARIABLES ""
set_interface_property PORTDRIVER SVD_ADDRESS_GROUP ""

add_interface_port PORTDRIVER AS_read read Input 1
add_interface_port PORTDRIVER AS_writedata writedata Input 32
add_interface_port PORTDRIVER AS_readdata readdata Output 32
add_interface_port PORTDRIVER AS_write write Input 1
add_interface_port PORTDRIVER AS_address address Input 5
set_interface_assignment PORTDRIVER embeddedsw.configuration.isFlash 0
set_interface_assignment PORTDRIVER embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment PORTDRIVER embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment PORTDRIVER embeddedsw.configuration.isPrintableDevice 0


# 
# connection point conduit_end
# 
add_interface conduit_end conduit end
set_interface_property conduit_end associatedClock clock
set_interface_property conduit_end associatedReset reset
set_interface_property conduit_end ENABLED true
set_interface_property conduit_end EXPORT_OF ""
set_interface_property conduit_end PORT_NAME_MAP ""
set_interface_property conduit_end CMSIS_SVD_VARIABLES ""
set_interface_property conduit_end SVD_ADDRESS_GROUP ""

add_interface_port conduit_end drivers export Output 6

