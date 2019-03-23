# ======================================================================
# Define options
# ======================================================================
set opt(chan)		Channel/WirelessChannel
set opt(prop)		Propagation/TwoRayGround
set opt(netif)		Phy/WirelessPhy
set opt(mac)		Mac/802_11
set opt(ifq)		Queue/DropTail/PriQueue	;# for dsdv
set opt(ll)		LL
set opt(ant)            Antenna/OmniAntenna

set opt(cp)		"cbr_aldo3.tcl"

set opt(sc)		"grid_aldo3.tcl"

set opt(ifqlen)		50		;# max packet in ifq
set opt(nn)		90		;# number of nodes
set opt(seed)		0.0
set opt(stop)		250.0		;# simulation time

set opt(rp)             gpsr		;# routing protocol script (dsr or dsdv)
set opt(lm)             "off"		;# log movement
set opt(x)       	605		;# x coordinate of topology
set opt(y)      	507		 ;# y coordinate of topology
set stopTime      	199.00
set opt(lm)             "off"		;# log movement

# ======================================================================

LL set mindelay_		50us
LL set delay_			25us
LL set bandwidth_		0	;# not used

Agent/Null set sport_		0
Agent/Null set dport_		0

Agent/CBR set sport_		0
Agent/CBR set dport_		0

Agent/TCPSink set sport_	0
Agent/TCPSink set dport_	0

Agent/TCP set sport_		0
Agent/TCP set dport_		0
Agent/TCP set packetSize_	1460

Queue/DropTail/PriQueue set Prefer_Routing_Protocols    1

# unity gain, omni-directional antennas
# set up the antennas to be centered in the node and 1.5 meters above it
Antenna/OmniAntenna set X_ 0
Antenna/OmniAntenna set Y_ 0
Antenna/OmniAntenna set Z_ 1.5
Antenna/OmniAntenna set Gt_ 1.0
Antenna/OmniAntenna set Gr_ 1.0

# Initialize the SharedMedia interface with parameters to make
# it work like the 914MHz Lucent WaveLAN DSSS radio interface
Phy/WirelessPhy set CPThresh_ 10.0
Phy/WirelessPhy set CSThresh_ 1.559e-11
Phy/WirelessPhy set RXThresh_ 3.652e-10
Phy/WirelessPhy set Rb_ 2*1e6
Phy/WirelessPhy set freq_ 914e+6 
Phy/WirelessPhy set L_ 1.0


# The transimssion radio range 
#Phy/WirelessPhy set Pt_ 6.9872e-4    ;# ?m
Phy/WirelessPhy set Pt_ 8.5872e-4    ;# 40m
#Phy/WirelessPhy set Pt_ 1.33826e-3   ;# 50m
#Phy/WirelessPhy set Pt_ 7.214e-3     ;# 100m
#Phy/WirelessPhy set Pt_ 0.2818       ;# 250m
# ======================================================================

# Agent/GPSR setting
Agent/GPSR set planar_type_  1   ;#1=GG planarize, 0=RNG planarize
Agent/GPSR set hello_period_   5.0 ;#Hello message period

# ======================================================================

proc usage { argv0 }  {
	puts "Usage: $argv0"
	puts "\tmandatory arguments:"
	puts "\t\t\[-x MAXX\] \[-y MAXY\]"
	puts "\toptional arguments:"
	puts "\t\t\[-cp conn pattern\] \[-sc scenario\] \[-nn nodes\]"
	puts "\t\t\[-seed seed\] \[-stop sec\] \[-tr tracefile\]\n"
}


proc getopt {argc argv} {
	global opt
	lappend optlist cp nn seed sc stop tr x y

	for {set i 0} {$i < $argc} {incr i} {
		set arg [lindex $argv $i]
		if {[string range $arg 0 0] != "-"} continue

		set name [string range $arg 1 end]
		set opt($name) [lindex $argv [expr $i+1]]
	}
}

proc log-movement {} {
    global logtimer ns_ ns

    set ns $ns_
    source ~/Downloads/ns-allinone-2.35/ns-2.35/tcl/mobility/timer.tcl
    Class LogTimer -superclass Timer
    LogTimer instproc timeout {} {
	global opt node_;
	for {set i 0} {$i < $opt(nn)} {incr i} {
	    $node_($i) log-movement
	}
	$self sched 0.1
    }

    set logtimer [new LogTimer]
    $logtimer sched 0.1
}

source ~/Downloads/ns-allinone-2.35/ns-2.35/tcl/lib/ns-bsnode.tcl
source ~/Downloads/ns-allinone-2.35/ns-2.35/tcl/mobility/com.tcl

getopt $argc $argv

if { $opt(x) == 0 || $opt(y) == 0 } {
	usage $argv0
	exit 1
}

if {$opt(seed) > 0} {
	puts "Seeding Random number generator with $opt(seed)\n"
	ns-random $opt(seed)
}

#
# Initialize Global Variables
#
set ns_		[new Simulator]
set chan	[new $opt(chan)]
set prop	[new $opt(prop)]
set topo	[new Topography]

set tracefd   [open aldo3.tr w]
$ns_ trace-all  $tracefd

set namfile [open aldo3.nam w]
$ns_ namtrace-all-wireless $namfile $opt(x) $opt(y)

$topo load_flatgrid $opt(x) $opt(y)

$prop topography $topo

#
# Create God
#
set god_ [create-god $opt(nn)]


#
#  Create the specified number of nodes $opt(nn) and "attach" them
#  the channel.
#  Each routing protocol script is expected to have defined a proc
#  create-mobile-node that builds a mobile node and inserts it into the
#  array global $node_($i)
#

$ns_ node-config -adhocRouting gpsr \
                 -llType $opt(ll) \
                 -macType $opt(mac) \
                 -ifqType $opt(ifq) \
                 -ifqLen $opt(ifqlen) \
                 -antType $opt(ant) \
                 -propType $opt(prop) \
                 -phyType $opt(netif) \
                 -channelType $opt(chan) \
                 -topoInstance $topo \
                 -agentTrace ON \
                 -routerTrace ON \
                 -macTrace ON \
                 -movementTrace ON 

source ~/Downloads/ns-allinone-2.35/ns-2.35/gpsr/gpsr.tcl

for {set i 0} {$i < $opt(nn) } {incr i} {
    gpsr-create-mobile-node $i
    $node_($i) namattach $namfile
}


#
# Source the Connection and Movement scripts
#
if { $opt(cp) == "" } {
	puts "*** NOTE: no connection pattern specified."
        set opt(cp) "none"
} else {
	puts "Loading connection pattern..."
	source $opt(cp)
}

for {set i 0} {$i < $opt(nn)} {incr i} {

    # 20 defines the node size in nam, must adjust it according to your scenario
    # The function must be called after mobility model is defined
    $node_($i) random-motion 0 ;
    $ns_ initial_node_pos $node_($i) 20
    $ns_ color $node_($i) blue
}



if { $opt(sc) == "" } {
	puts "*** NOTE: no scenario file specified."
        set opt(sc) "none"
} else {
	puts "Loading scenario file..."
	source $opt(sc)
	puts "Load complete..."
}

#
# Tell all the nodes when the simulation ends
#
for {set i 0} {$i < $opt(nn) } {incr i} {
    $ns_ at $opt(stop).000000001 "$node_($i) reset";
}
$ns_ at $opt(stop).00000001 "puts \"NS EXITING...\" ; $ns_ halt"

puts $tracefd "M 0.0 nn $opt(nn) x $opt(x) y $opt(y) rp $opt(rp)"
puts $tracefd "M 0.0 sc $opt(sc) cp $opt(cp) seed $opt(seed)"
puts $tracefd "M 0.0 prop $opt(prop) ant $opt(ant)"

puts "Starting Simulation..."

proc finish {} {
    global ns_ tracefd namfile
    $ns_ flush-trace
    close $tracefd
    close $namfile
    exit 0
}

$ns_ at $opt(stop) "finish"

$ns_ run

