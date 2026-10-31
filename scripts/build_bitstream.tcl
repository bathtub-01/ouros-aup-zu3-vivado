# Run after scripts/create_project.tcl, from any working directory:
#   vivado -mode batch -source scripts/build_bitstream.tcl
set repo_root [file normalize [file join [file dirname [info script]] ..]]
set project_file [file join $repo_root build ouros-zu3 ouros-zu3.xpr]
if {![file isfile $project_file]} {
    error "Project not found: $project_file. Run scripts/create_project.tcl first."
}
open_project $project_file
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1

set run_dir [get_property DIRECTORY [get_runs impl_1]]
set built_bit [file join $run_dir system_wrapper.bit]
if {![file isfile $built_bit]} {
    error "Implementation did not produce $built_bit; inspect impl_1 logs."
}

set boot_dir [file join $repo_root build boot]
file mkdir $boot_dir
file copy -force $built_bit [file join $boot_dir ouros.bit]
open_run impl_1
write_hw_platform -fixed -include_bit -force [file join $boot_dir ouros.xsa]
puts "INFO: Generated $boot_dir/ouros.bit and $boot_dir/ouros.xsa"
