# $Format: "package ifneeded interface $ProjectMajorVersion$.$ProjectMinorVersion$ \\"$
package ifneeded interface 1.0 \
[subst -nocommands {
	namespace eval ::interface {}
	set ::interface::dir [list $dir]
	source [file join [list $dir] lib/interface.tcl]
	lappend auto_path [file join [list $dir] lib]
}]
