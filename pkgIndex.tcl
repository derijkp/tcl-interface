# $Format: "package ifneeded interface 0.$ProjectMajorVersion$ \\"$
package ifneeded interface 0.8 \
[subst -nocommands {
	namespace eval ::interface {}
	set ::interface::dir $dir
	source [file join $dir lib/interface.tcl]
	lappend auto_path [file join $dir lib]
}]