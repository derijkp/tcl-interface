namespace eval interface {}
namespace eval interfaces {}
package provide interface 0.1
set ::interface::version 0.1

namespace eval interfaces {}

proc ::interface::fields {data args} {
	set result ""
	if {[llength $args]} {
		set data [eval {::interface::data $data} $args]
	}
	foreach {key value} $data {
		lappend result $key
	}
	return $result
}

proc ::interface::data {data args} {
	foreach field $args {
		set result ""
		foreach {key value} $data {
			if {[string equal $key $field]} {
				set data $value
				set result $value
				break
			}
		}
	}
	return $result
}

proc interface::putsvars args {
	foreach arg $args {
		puts [list set $arg [uplevel set $arg]]
	}
	puts "\n"
}

proc interface::testerror {cmd expected} {
	if ![catch {uplevel $cmd} result] {
		error "cmd should cause an error"
	}
	if {"$result" != "$expected"} {
		error "error message is \"$result\"\nshould be \"$expected\""
	}
	return 1
}

proc interface::display {e} {
	puts $e
}

proc interface::test {description script expected {causeerror 0} args} {
	variable errors
	variable testleak
	upvar object object
	upvar interface interface
	upvar version version
	upvar opt opt
	set name $interface-$version
	set e "testing $name: $description"
	if ![info exists ::env(TCL_TEST_ONLYERRORS)] {display $e}
	set code "upvar object object\nupvar interface interface\nupvar version version\nupvar opt opt\n"
	append code $script
	proc ::interface::tools__try {} $code
	set error [catch {::interface::tools__try} result]
	if $causeerror {
		if !$error {
			if [info exists ::env(TCL_TEST_ONLYERRORS)] {display "-- test $name: $description --"}
			set e "test should cause an error\nresult is \n$result"
			display $e
			lappend errors "$name:$description" "test should cause an error\nresult is \n$result"
			return
		}	
	} else {
		if $error {
			if [info exists ::env(TCL_TEST_ONLYERRORS)] {display "-- test $name: $description --"}
			set e "test caused an error\nerror is \n$result\n"
			display $e
			lappend errors "$name:$description" "test caused an error\nerror is \n$result\n"
			return
		}
	}
	if {"$result"!="$expected"} {
		if [info exists ::env(TCL_TEST_ONLYERRORS)] {display "-- test $name: $description --"}
		set e "error: result is:\n$result\nshould be\n$expected"
		display $e
		lappend errors "$name:$description" $e
	}
	if $testleak {
		set line1 [lindex [split [exec ps l [pid]] "\n"] 1]
		time {set error [catch {tools__try $object} result]} $testleak
		set line2 [lindex [split [exec ps l [pid]] "\n"] 1]
		if {([lindex $line1 6] != [lindex $line2 6])||([lindex $line1 7] != [lindex $line2 7])} {
			if {"$args" != "noleak"} {
				if [info exists ::env(TCL_TEST_ONLYERRORS)] {display "-- test $name: $description --"}
				puts "possible leak:"
				puts $line1
				puts $line2
				puts "\n"
			}
		}
	}
	return
}

proc interface::testsummarize {} {
	variable errors
	if [info exists errors] {
		global currenttest
		if [info exists currenttest] {
			set error "***********************\nThere were errors in testfile $currenttest"
		} else {
			set error "***********************\nThere were errors in the tests"
		}
		foreach {test err} $errors {
			append error "\n$test  ----------------------------"
			append error "\n$err"
		}
		# display $error
		return -code error $error
		unset errors
	} else {
		puts "All tests ok"
		return "All tests ok"
	}
}

proc interface::starttest {} {
	variable errors
	variable testleak
	catch {unset errors}
	
	if $testleak {
		test test {initialise all memory for testing with leak detection} {
			set try 1
		} 1 0 noleak
	}
}

#proc ::interface::options {name list} {
#	variable options
#	set knowns ""
#	foreach {variable key default} $list {
#		variable $variable
#		lappend knowns $key
#		if {[info exists options($key)]} {
#			set $variable $options($key)
#			unset options($key)
#		} else {
#			set $variable $default
#		}
#	}
#	set unknowns [array names options]
#	if {[llength $unknowns]} {
#		error "unknown options [join $unknowns ,] for testing interface $name: must be one or more of [join $knowns ,]"
#	}
#}

proc interface::implement {interface version docfile options cmd arg} {
	switch $cmd {
		doc {
			set file $docfile
			set f [open $file]
			set data [read $f]
			close $f
			return -code return $data
		}
		interface {
			if {[llength $arg]} {
				if {[string equal [lindex $arg 0] interface]} {
					return -code return $::interface::version
				} else {
					return -code error "interfaces::$interface-$version does not support interface [lindex $arg 0]"
				}
			} else {
				return -code return [list interface $::interface::version]
			}
		}
		test {
			variable errors
			variable testleak
			upvar opt opt
			upvar object object
			upvar interfaces interfaces
			array set opt $options
			catch {unset errors}
			set len [llength $arg]
			if {$len < 1} {
				error "wrong # args: should be \"interfaces::$interface-$version test object ?options?\""
			}
			uplevel set interface $interface
			uplevel set version $version
			set object [lindex $arg 0]
			array set opt [lrange $arg 1 end]
			if [info exists opt(-testleak)] {
				set testleak $opt(-testleak)
				unset opt(-testleak)
			} else {
				set testleak 0
			}
		}
	}
}

proc ::interface::doc {args} {
}


proc ::interface::getcmd {interface} {
	if {![string equal [info commands ::interfaces::$interface] ""]} {
		return ::interfaces::$interface
	}
	if {[auto_load ::interfaces::$interface]} {
		return ::interfaces::$interface
	}
	set versions [interface versions $interface]
	if {![llength $versions]} {
		error "interface \"$interface\" not found"
	}
	return ::interfaces::$interface-[lindex $versions end]
}

proc interface::interface {cmd args} {
	set len [llength $args]
	set interface [lindex $args 0]
	switch $cmd {
		list {
			auto_load interfaces::notpresent
			if {$len == 0} {
				set pattern ::interfaces::*
			} elseif {$len == 1} {
				set pattern ::interfaces::[lindex $args 0]
			} else {
				error "wrong # args: should be \"interface list ?pattern?\""
			}
			foreach el [info commands $pattern] {
				set interfaces([string range $el 14 end]) 1
			}
			foreach el [array names ::auto_index $pattern] {
				set interfaces([string range $el 14 end]) 1
			}
			return [array names interfaces]
		}
		versions {
			if {$len != !} {
				error "wrong # args: should be \"interface list interface\""
			}
			set list {}
			foreach el [::interface::interface list $interface-*] {
				regexp -- {-([0-9.]+)$} $el temp version
				lappend list $version
			}
			return [lsort -dictionary $list]
		}
		doc {
			if {$len < 1} {
				error "wrong # args: should be \"interface doc interface\""
			}
			set ifcmd [::interface::getcmd $interface]
			return [$ifcmd doc]
		}
		test {
			if {$len < 2} {
				error "wrong # args: should be \"interface test interface object ?options?\""
			}
			set object [lindex $args 1]
			set ifcmd [::interface::getcmd $interface]
			eval $ifcmd test $object [lrange $args 2 end]
		}
	}
}

namespace eval interface {namespace export interface}
namespace import interface::interface

