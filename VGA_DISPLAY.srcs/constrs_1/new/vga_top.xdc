create_clock -period 10.000 -name clk [get_ports sys_clk]

set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports sys_clk]
set_property -dict {PACKAGE_PIN C2 IOSTANDARD LVCMOS33} [get_ports sys_rst_n]
#set_property -dict {PACKAGE_PIN D9 IOSTANDARD LVCMOS33} [get_ports key_in]
set_property -dict {PACKAGE_PIN A9 IOSTANDARD LVCMOS33} [get_ports rx]
#set_property -dict {PACKAGE_PIN D10 IOSTANDARD LVCMOS33} [get_ports tx]

# J17 J18 K15 J15 R0~R3
set_property -dict {PACKAGE_PIN J17 IOSTANDARD LVCMOS33} [get_ports {vga_rgb[0]}]
set_property -dict {PACKAGE_PIN J18 IOSTANDARD LVCMOS33} [get_ports {vga_rgb[1]}]
set_property -dict {PACKAGE_PIN K15 IOSTANDARD LVCMOS33} [get_ports {vga_rgb[2]}]
set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33} [get_ports {vga_rgb[3]}]

# U14 V14 T13 U13 G0~G3
set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVCMOS33} [get_ports {vga_rgb[4]}]
set_property -dict {PACKAGE_PIN V14 IOSTANDARD LVCMOS33} [get_ports {vga_rgb[5]}]
set_property -dict {PACKAGE_PIN T13 IOSTANDARD LVCMOS33} [get_ports {vga_rgb[6]}]
set_property -dict {PACKAGE_PIN U13 IOSTANDARD LVCMOS33} [get_ports {vga_rgb[7]}]

# E15 E16 D15 C15 B0~B3 
set_property -dict {PACKAGE_PIN E15 IOSTANDARD LVCMOS33} [get_ports {vga_rgb[8]}]
set_property -dict {PACKAGE_PIN E16 IOSTANDARD LVCMOS33} [get_ports {vga_rgb[9]}]
set_property -dict {PACKAGE_PIN D15 IOSTANDARD LVCMOS33} [get_ports {vga_rgb[10]}]
set_property -dict {PACKAGE_PIN C15 IOSTANDARD LVCMOS33} [get_ports {vga_rgb[11]}]

# U12 V12 V10 V11 HS VS NC NC
set_property -dict {PACKAGE_PIN U12 IOSTANDARD LVCMOS33} [get_ports {hsync}]
set_property -dict {PACKAGE_PIN V12 IOSTANDARD LVCMOS33} [get_ports {vsync}]
