namespace eval interface {}
namespace eval interfaces {}
# $Format: "set ::interface::version 0.$ProjectMajorVersion$"$
set ::interface::version 0.8
package provide interface $::interface::version

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

proc interface::test {description script expected args} {
	variable errors
	variable skipped
	variable testleak
	upvar object object
	upvar interface interface
	upvar version version
	upvar opt opt
	if {![info exists testleak]} {set testleak 0}
	foreach arg $args {set options($arg) 1}
	set name $interface-$version
	set conditions [array names options {skipon *}]
	if {[llength $conditions]} {
		foreach condition $conditions {
			if {[expr [lindex $condition 1]]} {
				logskip $name $description $condition
				return
			}
		}
	}
	if {[info exists options(error)]} {set causeerror 1} else {set causeerror 0}
	set e "testing $name: $description"
	if ![info exists ::env(TCL_TEST_ONLYERRORS)] {display $e}
	set code "upvar object object\nupvar interface interface\nupvar version version\nupvar opt opt\n"
	append code $script
	proc ::interface::tools__try {} $code
	set error [catch {::interface::tools__try} result]
	if $causeerror {
		if !$error {
			if [info exists ::env(TCL_TEST_ONLYERRORS)] {display "-- test $name: $description --"}
			logerror $name $description "test should cause an error\nresult is \n$result"
			return
		}	
	} else {
		if $error {
			if [info exists ::env(TCL_TEST_ONLYERRORS)] {display "-- test $name: $description --"}
			logerror $name $description "test caused an error\nerror is \n$result\n"
			return
		}
	}
	
	if {[info exists options(regexp)]} {
		set compar [regexp $expected $result]
		set errorbetween {should match (regexp)}
	} elseif {[info exists options(match)]} {
		set compar [string match $expected $result]
		set errorbetween {should match}
	} else {
		set compar [expr {"$result"=="$expected"}]
		set errorbetween {should be}
	}
	if {!$compar} {
		if [info exists ::env(TCL_TEST_ONLYERRORS)] {display "-- test $f: $description --"}
		logerror $name $description "error: result is:\n$result\n$errorbetween\n$expected"
	}
	if $testleak {
		set line1 [lindex [split [exec ps l [pid]] "\n"] 1]
		time {set error [catch {tools__try $object} result]} $testleak
		set line2 [lindex [split [exec ps l [pid]] "\n"] 1]
		if {([lindex $line1 6] != [lindex $line2 6])||([lindex $line1 7] != [lindex $line2 7])} {
			if {![info exists options(noleak)]} {
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

proc interface::logerror {interface description errormessage} {
	variable errors
	display $errormessage
	lappend errors [list $interface $description $errormessage]
}

proc interface::logskip {interface description condition} {
	variable skipped
	display "** skipped $interface: $description ([lindex $condition 1])"
	lappend skipped [list $interface $description $condition]
}

proc interface::testsummarize {} {
	variable errors
	variable skipped
	if [info exists errors] {
		global currenttest
		if [info exists currenttest] {
			set error "***********************\nThere were errors in testfile $currenttest"
		} else {
			set error "***********************\nThere were errors in the tests"
		}
		foreach line $errors {
			foreach {interface descr errormessage} $line break
			append error "\n$interface: $descr  ----------------------------"
			append error "\n$errormessage"
		}
		# display $error
		if {[info exists skipped]} {
			append error "\n***********************\nskipped [llength $skipped]"
		}
		return -code error $error
	} elseif {[info exists skipped]} {
		set result "All tests ok (skipped [llength $skipped])"
	} else {
		set result "All tests ok"
	}
	puts $result
	return $result
}

proc interface::testend {} {
	variable errors
	variable skipped
	if [info exists errors] {
		return [llength $errors]
	} else {
		return 0
	}
}

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
			variable testleak
			upvar opt opt
			upvar object object
			upvar interfaces interfaces
			array set opt $options
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
			if {$len != 1} {
				error "wrong # args: should be \"interface versions interface\""
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
		testclear {
			variable error
			variable skip
			catch {unset error}
			catch {unset skip}
			return
		}
		testsummarize {
			if {$len == 1} {
				error "wrong # args: should be \"interface testsummarize\""
			}
			set code [catch {::interface::testsummarize} result]
			return -code $code $result
		}
	}
}

namespace eval interface {namespace export interface}
namespace import interface::interface

