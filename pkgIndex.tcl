# $Format: "package ifneeded interface 0.$ProjectMajorVersion$ \\"$
package ifneeded interface 0.8 \
[subst -nocommands {
	namespace eval ::interface {}
	set ::interface::dir [list $dir]
	source [file join [list $dir] lib/interface.tcl]
	lappend auto_path [file join [list $dir] lib]
}]