interface
=========
  Tcl interfaces
  by Peter De Rijk (Universiteit Antwerpen) 

What is the interface package
-----------------------------

The interface package contains some tools to work with "interfaces" in Tcl.
In Tcl "objects" can be created in many ways: in C, in Tcl or in any of the Tcl OO
extensions. The term object is used loosely here for each compound command: a command with 
subcommands (methods).

An interface is a set of (related) methods that provide a predefined functionality.
An object implements an interface if it supports all the methods in the interface the 
proper way. It can advertise this fact via the interface subcommand. Of course, one 
object can support multiple interfaces.

An interface is defined by the creation of an object in the interfaces namespace, 
that supports the "interface" interface. (don't you just love self referential definitions?).
This interface defining object must have a name consisting of the interface name and its version number 
seperated by a hyphen. It should have a doc method that returns the description of the
interface in XML format (TMML), and a test method that can be used to test a given object for 
compliance. The test method takes the object to be tested as a first argument, optionally 
followed by a number of options.

You get the man page of the interface commmand at 
[https://derijkp.github.io/tcl-interface/html/interface.html](https://derijkp.github.io/tcl-interface/html/interface.html)
and a definition of the interface interface at 
[https://derijkp.github.io/tcl-interface/html/interface_interface.html](https://derijkp.github.io/tcl-interface/html/interface_interface.html)

Installation
------------
You should be able to obtain the latest version of interface via www on url
https://github.com/derijkp/tcl-interface

The extension can be installed using the command:
./build/install_simple.tcl <installdir>
where <installdir> is the directory in which the package will be installed (should be visisble to Tcl)

You can also use the configure method typical for installing Tcl packages (but not neccessary as it does not contain a compiled component)
./configure
make
make install

The configure command has several options that can be examined using
/configure --help

How to contact me
-----------------
I will do my best to reply as fast as I can to any problems, etc.
However, the development of interface is not my only task,
which is why my response might not be always as fast as you would
like.

Peter.DeRijk@uantwerpen.be

Peter De Rijk
VIB - UAntwerp Center for Molecular Neurology
Universiteitsplein 1
B-2610 Antwerp

Legalities
----------

interface is Copyright Peter De Rijk, University of Antwerp (UA), 2000
The following terms apply to all files associated with the software unless 
explicitly disclaimed in individual files.

The author hereby grant permission to use, copy, modify, distribute,
and license this software and its documentation for any purpose, provided
that existing copyright notices are retained in all copies and that this
notice is included verbatim in any distributions. No written agreement,
license, or royalty fee is required for any of the authorized uses.
Modifications to this software may be copyrighted by their authors
and need not follow the licensing terms described here, provided that
the new terms are clearly indicated on the first page of each file where
they apply.

IN NO EVENT SHALL THE AUTHORS OR DISTRIBUTORS BE LIABLE TO ANY PARTY
FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES
ARISING OUT OF THE USE OF THIS SOFTWARE, ITS DOCUMENTATION, OR ANY
DERIVATIVES THEREOF, EVEN IF THE AUTHORS HAVE BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

THE AUTHORS AND DISTRIBUTORS SPECIFICALLY DISCLAIM ANY WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.  THIS SOFTWARE
IS PROVIDED ON AN "AS IS" BASIS, AND THE AUTHORS AND DISTRIBUTORS HAVE
NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR
MODIFICATIONS.
