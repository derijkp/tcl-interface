# documentation to be returned
# this is just placed here to keep everything in one file for simplicity
# It will usually be placed in a file in a doc directory, so it can also be 
# used to generate man pages, etc
set stackdock {
	<manpage package="interface" title="stack_interface" id="stack_interface" cat="stack">
	<namesection>
	<name>stack_interface</name>
	<desc>description of the stack interface</desc>
	</namesection>
	<section>
	<title>DESCRIPTION</title>
	a very simple demonstration interface
	</section>
	<section>
	<title>THE STACK INTERFACE</title>
	<commandlist>
	<commanddef>
	<command><cmd>objectName</cmd> <method>clear</method></command>
	<desc>clear the stack</desc>
	</commanddef>
	<commanddef>
	<command><cmd>objectName</cmd> <method>push</method> <m>value</m> ?<m>value</m> ...?</command>
	<desc>push value(s) on the stack</desc>
	</commanddef>
	<commanddef>
	<command><cmd>objectName</cmd> <method>pop</method></command>
	<desc>get values from the stack</desc>
	</commanddef>
	</commandlist>
	</section>
	<keywords>
	<keyword>stack_interface</keyword>
	</keywords>
	</manpage>
}

# interface definition
package require interface
proc ::interfaces::stack-1.0 {option args} {
	set interface stack
	set version 1.0
	switch $option {
		interface {
			# This is an interface defining object, so it supports the interface interface
			# This code will advertise this fact
			if {[llength $arg]} {
				if {[string equal [lindex $args 0] interface]} {
					return 0.8
				} else {
					error "::interfaces::$interface-$version does not support interface interface"
				}
			} else {
				return [list interface 0.8]
			}
		}
		doc {
			# return xml documentation
			return $::stackdock
		}
		test {
			# run some tests on an object supposed to support the interface
			set len [llength $args]
			if {$len < 1} {
				error "wrong # args: should be \"interfaces::$interface-$version test object ?options?\""
			}
			set object [lindex $args 0]
			array set opt [lrange $args 1 end]
			# the testleak is needed due to a small bug in the interface::test routine
			set ::interface::testleak 0
			interface::test {interface match} {
				$object interface stack
			} $version
			interface::test {push and pop} {
				$object clear
				$object push 1
				$object pop
			} 1
			interface::test {push, push and pop} {
				$object clear
				$object push 1
				$object push 2
				$object pop
			} 2
			interface::test {stack empty error} {
				$object clear
				$object pop
				$object pop
			} {stack empty} error
			# more test should follow
			interface::testend
		}
	}
}

# implementation of "object" implementing the interface
# this is of course just a test case for demonstrating interfaces,
# and not a real object, nor a good or even reasonable implementation
proc stack1 {option args} {
	global stack1_data
	switch $option {
		clear {
			set stack1_data {}
		}
		push {
			eval lappend stack1_data $args
		}
		pop {
			if {![llength $stack1_data]} {
				error "stack empty"
			}
			set result [lindex $stack1_data end]
			set stack1_data [lrange $stack1_data 0 end-1]
			return $result
		}
		interface {
			set interfaces {stack 1.0 nop 0.0}
			if {[llength $args]} {
				set reqinterface [lindex $args 0]
				foreach {interface version} $interfaces {
					if {[string equal $reqinterface $interface]} {
						return $version
					}
				}
				error "stack1 does not support interface $reqinterface"
			} else {
				return $interfaces
			}
		}
	}
}

# test if stack1 does indeed comply with the stack-1.0 interface
interface test stack-1.0 stack1
# return documentation
interface doc stack-1.0

