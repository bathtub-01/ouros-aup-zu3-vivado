# Ouros AUP-ZU3: recreate the Vivado 2025.1 project from repository sources.
# Usage (from any working directory):
#   vivado -mode batch -source /path/to/repo/scripts/create_project.tcl
# This script creates build/ouros-zu3/ouros-zu3.xpr under the repository.

set repo_root [file normalize [file join [file dirname [info script] ] ..]]
set project_name ouros-zu3
set project_dir [file join $repo_root build $project_name]
set project_file [file join $project_dir ${project_name}.xpr]
set fpga_part xczu3eg-sfvc784-2-e
set board_part realdigital.org:aup-zu3-8gb:part0:1.0

if {[file exists $project_file]} {
    error "Project already exists: $project_file. Open it, or remove build/ to recreate."
}

# The generated block design needs the original AUP-ZU3 board definition.
# This is a user-installed board file, not part of this repository.
if {[llength [get_board_parts -quiet $board_part]] == 0} {
    error "Missing board part $board_part. Install the AUP-ZU3 board files for Vivado 2025.1."
}

set rtl [concat \
    [lsort [glob -nocomplain -directory [file join $repo_root uart] *.sv]] \
    [lsort [glob -nocomplain -directory [file join $repo_root uart] *.v]]]
if {[llength $rtl] == 0} {
    error "No generated Verilog/SystemVerilog files in $repo_root/uart"
}
foreach required {OurosFpgaWrapper.v UartIoControllerFpgaWrapper.v} {
    if {![file isfile [file join $repo_root uart $required]]} {
        error "Missing module-reference wrapper: uart/$required"
    }
}
set memories [list]
foreach memory {comb.mem heap.mem} {
    set path [file join $repo_root uart $memory]
    if {![file isfile $path]} {
        error "Missing FPGA program image: uart/$memory"
    }
    lappend memories $path
}
set xdc [file join $repo_root constraints ouros_aup_zu3.xdc]
if {![file isfile $xdc]} {
    error "Missing constraints: $xdc"
}

create_project $project_name $project_dir -part $fpga_part
set_property board_part $board_part [current_project]
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property use_inline_hdl_ip true [current_project]

# Reference, rather than import/copy, the committed sources. The memory files
# must be visible to synthesis and simulation because the RTL uses $readmemh.
add_files -norecurse -fileset sources_1 $rtl
foreach f $memories {
    set mem_file [add_files -norecurse -fileset sources_1 $f]
    set_property file_type {Memory File} $mem_file
}
add_files -norecurse -fileset constrs_1 $xdc
update_compile_order -fileset sources_1

# This file is the ONLY copy of the exported system block design. It creates
# the PS, AXI SmartConnect, reset, Ouros, UART controller and address map.
source [file join $repo_root scripts block_design.tcl]
set bd [get_files -quiet system.bd]
if {[llength $bd] != 1} {
    error "Expected block_design.tcl to create exactly one system.bd"
}

# Generated wrapper is a project BUILD PRODUCT, not a committed source.
set wrapper [make_wrapper -files $bd -top]
add_files -norecurse -fileset sources_1 $wrapper
set_property top system_wrapper [get_filesets sources_1]
set_property top_auto_set 0 [get_filesets sources_1]
update_compile_order -fileset sources_1

# Use normal synthesis/implementation runs. Do NOT restore the old local
# incremental DCP, which was not included in the source archive.
set_property strategy {Vivado Synthesis Defaults} [get_runs synth_1]
set_property strategy {Vivado Implementation Defaults} [get_runs impl_1]
# Project changes are saved automatically to the new .xpr.
puts "INFO: Project ready: $project_file"
