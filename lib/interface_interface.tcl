package require interface

# $Format: "proc ::interfaces::interface-$ProjectMajorVersion$.$ProjectMinorVersion$ {option args} {"$
proc ::interfaces::interface-1.0 {option args} {
	interface::implement interface $::interface::version [file join $::interface::dir doc xml interface_interface.xml] {
		-interface notdefined
		-version notdefined
		-testtest 1
		-testobject {}
		-testoptions notdefined
	} $option $args

	# test should never be tested for interfaces::interface-$::interface::version, otherwise we'll end up
	# in andless recursion
	if {[string equal $object interfaces::interface-$::interface::version]} {
		set opt(-testtest) 0
	}
	if {$opt(-testtest)} {
		if {[string equal $opt(-testobject) ""]} {
			error "option -testobject is mandatory"
		}
		if {[string equal $opt(-testoptions) notdefined]} {
			error "option -testoptions is mandatory"
		}
	}
	
	# test interface command
	# ----------------------

	interface::test {interface match} {
		$object interface $opt(-interface)
	} $opt(-version)

	interface::test {interface error} {
		$object interface test-12134
	} "$object does not support interface test-12134" error

	interface::test {interface list} {
		upvar interface interface
		set list [$object interface]
		set pos [lsearch $list $opt(-interface)]
		lrange $list $pos [expr {$pos+1}]
	} [list $opt(-interface) $opt(-version)]

	# interface methods
	# -----------------
	
	interface::test {doc method} {
		# should test for correct xml here, not done yet
		catch {$object doc}
	} 0

	if {$opt(-testtest)} {
		interface::test {test method} {
			# We can only test for existence of the test method,
			# as we don't havethe options can vary too widely, and may be mandatory,
			$object test {$opt(-testobject)} $opt(-testoptions)
		} {All tests ok}
	}
	interface::testend
}
