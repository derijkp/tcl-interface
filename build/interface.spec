Summary:	interfaces for Tcl
Name:		interface
Version:	0.8.1
Release:	1
Copyright:	BSD
Group:	Development/Languages/Tcl
Source:	interface-0.8.1.src.tar.gz
URL: http://rrna.uia.ac.be/interface
Packager: Peter De Rijk <derijkp@uia.ua.ac.be>
Requires: tcl >= 8.3.2
Prefix: /usr
%description
The interface package contains some tools to work with "interfaces" in Tcl.
In Tcl "objects" can be created in many ways: in C, in Tcl or in any of the Tcl OO
extensions. The term object is used loosely here for each compound command: a command with 
subcommands (methods).
An interface is a set of (related) methods that provide a predefined functionality.
An object implements an interface if it supports all the methods in the interface the 
proper way. It can advertise this fact via the interface subcommand. Of course, one 
object can support multiple interfaces.

%prep
%setup -n interface

%build
cd build
./configure --prefix=/usr
make clean
make

%install
cd build
make install

%files
%doc README
%doc /usr/man/mann/interface.n
%doc /usr/man/mann/interface_interface.n
/usr/lib/interface0.8
