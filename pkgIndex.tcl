package ifneeded interface 0.1 [subst -nocommands {
	namespace eval ::interface {}
	set ::interface::dir $dir
	source [file join $dir lib/interface.tcl]
	lappend auto_path [file join $dir lib]
}]