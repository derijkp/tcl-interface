# This file provides for an alternative loading of extensions
# based on directory.
# in order to load the given package, this file is sourced
# When this script is sourced, the variable $dir must contain the
# full path name of the xtensions directory.

namespace eval ::interface {}
set ::interface::dir $dir
source [file join $dir lib interface.tcl]
lappend auto_path [file join $dir lib]
extension provide interface 1.0.0
