# Ouros on Real Digital AUP-ZU3
# Top module: system_wrapper
#
# Board pins:
#   BTN0 / PL_USER_PB0  = AB6
#   LD0  / PL_USER_LED0 = AF5
#
# GPIO are active-high and use LVCMOS12.

# -----------------------------------------------------------------------------
# BTN0 -> Ouros start
# -----------------------------------------------------------------------------
set_property PACKAGE_PIN AB6 [get_ports start_0]
set_property IOSTANDARD LVCMOS12 [get_ports start_0]

# -----------------------------------------------------------------------------
# Ouros done -> LD0
# -----------------------------------------------------------------------------
set_property PACKAGE_PIN AF5 [get_ports done_0]
set_property IOSTANDARD LVCMOS12 [get_ports done_0]

# -----------------------------------------------------------------------------
# Bitstream
# -----------------------------------------------------------------------------
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]