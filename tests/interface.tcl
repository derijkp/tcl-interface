#!/bin/sh
# the next line restarts using wish \
exec tclsh "$0" "$@"
puts "source [info script]"

package require interface

interface test interface-0.1 interfaces::interface-0.1 \
	-interface interface -version 0.1


if 0 {
	set interface interface-0.1
	
	interface::interface list interface-*
	
	interface doc interface-0.1
	interface doc dbi
	interface versions dbi
	
	
	package require interface
	package require dbi
	interface list
	
	
	set option test
	set args {interfaces::interface-0.1 -interface interface -version 0.1}
	
	interface list
	interface commands dbi0.1
	interface arguments dbi0.1 exec
	interface definition dbi0.1
	interface description dbi0.1
	
	
	set data [interface dbi 0.1]
	interface::data $data subcommands exec
	interface::fields $data subcommands exec
}
