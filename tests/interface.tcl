#!/bin/sh
# the next line restarts using wish \
exec tclsh "$0" "$@"
puts "source [info script]"

package require interface

interface testclear

interface test interface-$::interface::version interfaces::interface-$::interface::version \
	-interface interface -version $::interface::version

interface testsummarize
