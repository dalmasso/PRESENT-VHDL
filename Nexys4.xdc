
# Artix-7 XC7A100T-1CSG324C 

# Clock
set_property PACKAGE_PIN E3 [get_ports Clk_100]
set_property IOSTANDARD LVCMOS33 [get_ports Clk_100]

# Reset
set_property PACKAGE_PIN E16 [get_ports Reset]
set_property IOSTANDARD LVCMOS33 [get_ports Reset]

# Attack trigger
#set_property PACKAGE_PIN B13 [get_ports trigger]
#set_property IOSTANDARD LVCMOS33 [get_ports trigger]

# UART
set_property PACKAGE_PIN C4 [get_ports RX]
set_property IOSTANDARD LVCMOS33 [get_ports RX]
set_property PACKAGE_PIN D4 [get_ports TX]
set_property IOSTANDARD LVCMOS33 [get_ports TX]

# Pblock implementations
create_pblock pblock_CRYPTO
add_cells_to_pblock [get_pblocks pblock_CRYPTO] [get_cells -quiet [list CRYPTO]]
resize_pblock [get_pblocks pblock_CRYPTO] -add {SLICE_X28Y76:SLICE_X51Y99}


create_pblock pblock_CTRL
add_cells_to_pblock [get_pblocks pblock_CTRL] [get_cells -quiet [list UART1]]
add_cells_to_pblock [get_pblocks pblock_CTRL] [get_cells -quiet [list CLOCKCTRL]]
resize_pblock [get_pblocks pblock_CTRL] -add {SLICE_X52Y76:SLICE_X57Y99}