#!/bin/sh
# the next line restarts using wish \
exec tclsh "$0" "$@"
puts "source [info script]"

package require interface

interface testclear

interface test interface-0.1 interfaces::interface-0.1 \
	-interface interface -version 0.1

interface testsummarize
