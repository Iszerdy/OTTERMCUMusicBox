# This file is a general .xdc for the Basys3 rev B board
# To use it in a project:
# - uncomment the lines corresponding to used pins
# - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

#-----------------------------------------------------------------------------
#-
#-  Modification History
#-
#-  v1.01 (07-01-2018): (james mealy) added comments for anodes & segments 
#-  v1.02 (11-10-2019): (james mealy) removed comments, swapped segment indexes
#-  v1.03 (11-12-2019): (james mealy) swapped anode indexes
#-
#-
#-------------------------------------------------------------------------------

# Clock signal
set_property PACKAGE_PIN W5 [get_ports CLK]							
	set_property IOSTANDARD LVCMOS33 [get_ports CLK]
  
# Switches
set_property PACKAGE_PIN V17 [get_ports {SWITCHES[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {SWITCHES[0]}]
set_property PACKAGE_PIN V16 [get_ports {SWITCHES[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {SWITCHES[1]}]
set_property PACKAGE_PIN W16 [get_ports {SWITCHES[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {SWITCHES[2]}]
set_property PACKAGE_PIN W17 [get_ports {SWITCHES[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {SWITCHES[3]}]
set_property PACKAGE_PIN W15 [get_ports {SWITCHES[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {SWITCHES[4]}]
set_property PACKAGE_PIN V15 [get_ports {SWITCHES[5]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {SWITCHES[5]}]
set_property PACKAGE_PIN W14 [get_ports {SWITCHES[6]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {SWITCHES[6]}]
set_property PACKAGE_PIN W13 [get_ports {SWITCHES[7]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {SWITCHES[7]}]
set_property PACKAGE_PIN V2 [get_ports {SWITCHES[8]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {SWITCHES[8]}]
set_property PACKAGE_PIN T3 [get_ports {SWITCHES[9]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {SWITCHES[9]}]
set_property PACKAGE_PIN T2 [get_ports {SWITCHES[10]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {SWITCHES[10]}]
set_property PACKAGE_PIN R3 [get_ports {SWITCHES[11]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {SWITCHES[11]}]
set_property PACKAGE_PIN W2 [get_ports {SWITCHES[12]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {SWITCHES[12]}]
set_property PACKAGE_PIN U1 [get_ports {SWITCHES[13]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {SWITCHES[13]}]
set_property PACKAGE_PIN T1 [get_ports {SWITCHES[14]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {SWITCHES[14]}]
set_property PACKAGE_PIN R2 [get_ports {SWITCHES[15]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {SWITCHES[15]}]
 

# LEDs
set_property PACKAGE_PIN U16 [get_ports {LEDS[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LEDS[0]}]
set_property PACKAGE_PIN E19 [get_ports {LEDS[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LEDS[1]}]
set_property PACKAGE_PIN U19 [get_ports {LEDS[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LEDS[2]}]
set_property PACKAGE_PIN V19 [get_ports {LEDS[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LEDS[3]}]
set_property PACKAGE_PIN W18 [get_ports {LEDS[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LEDS[4]}]
set_property PACKAGE_PIN U15 [get_ports {LEDS[5]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LEDS[5]}]
set_property PACKAGE_PIN U14 [get_ports {LEDS[6]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LEDS[6]}]
set_property PACKAGE_PIN V14 [get_ports {LEDS[7]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LEDS[7]}]
set_property PACKAGE_PIN V13 [get_ports {LEDS[8]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LEDS[8]}]
set_property PACKAGE_PIN V3 [get_ports {LEDS[9]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LEDS[9]}]
set_property PACKAGE_PIN W3 [get_ports {LEDS[10]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LEDS[10]}]
set_property PACKAGE_PIN U3 [get_ports {LEDS[11]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LEDS[11]}]
set_property PACKAGE_PIN P3 [get_ports {LEDS[12]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LEDS[12]}]
set_property PACKAGE_PIN N3 [get_ports {LEDS[13]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LEDS[13]}]
set_property PACKAGE_PIN P1 [get_ports {LEDS[14]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LEDS[14]}]
set_property PACKAGE_PIN L1 [get_ports {LEDS[15]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LEDS[15]}]
	
	
#7 segment display
set_property -dict { PACKAGE_PIN U7   IOSTANDARD LVCMOS33 } [get_ports { CATHODES[0] }];
set_property -dict { PACKAGE_PIN V5   IOSTANDARD LVCMOS33 } [get_ports { CATHODES[1] }];
set_property -dict { PACKAGE_PIN U5   IOSTANDARD LVCMOS33 } [get_ports { CATHODES[2] }];
set_property -dict { PACKAGE_PIN V8   IOSTANDARD LVCMOS33 } [get_ports { CATHODES[3] }];
set_property -dict { PACKAGE_PIN U8   IOSTANDARD LVCMOS33 } [get_ports { CATHODES[4] }];
set_property -dict { PACKAGE_PIN W6   IOSTANDARD LVCMOS33 } [get_ports { CATHODES[5] }];
set_property -dict { PACKAGE_PIN W7   IOSTANDARD LVCMOS33 } [get_ports { CATHODES[6] }];
set_property -dict { PACKAGE_PIN V7   IOSTANDARD LVCMOS33 } [get_ports { CATHODES[7] }];


set_property PACKAGE_PIN U2 [get_ports {ANODES[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {ANODES[0]}]
set_property PACKAGE_PIN U4 [get_ports {ANODES[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {ANODES[1]}]
set_property PACKAGE_PIN V4 [get_ports {ANODES[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {ANODES[2]}]
set_property PACKAGE_PIN W4 [get_ports {ANODES[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {ANODES[3]}]


#Buttons
set_property PACKAGE_PIN U18 [get_ports BTNC]						
	set_property IOSTANDARD LVCMOS33 [get_ports BTNC]
set_property PACKAGE_PIN W19 [get_ports BTNL]						
	set_property IOSTANDARD LVCMOS33 [get_ports BTNL]

#Speaker Output
set_property PACKAGE_PIN J1 [get_ports {SPEAKER}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {SPEAKER}]
	
