#
# nodes: 30, max conn: 1, send rate: 1, seed: 1
#
#
# 1 connecting to 2 at time 2.5568388786897245
#

# GPSR routing agent settings
for {set i 0} {$i < $opt(nn)} {incr i} {
    $ns_ at 0.00002 "$ragent_($i) turnon"
    #$ns_ at 20.0 "$ragent_($i) neighborlist"
#    $ns_ at 30.0 "$ragent_($i) turnoff"
}

#$ns_ at 0.00002 "$ragent_(28) startSink 10.0"
$ns_ at 0.00002 "$ragent_(29) startSink 10.0"

set udp_(0) [new Agent/UDP]
$ns_ attach-agent $node_(28) $udp_(0)
set null_(0) [new Agent/Null]
$ns_ attach-agent $node_(29) $null_(0)
set cbr_(0) [new Application/Traffic/CBR]
$cbr_(0) set packetSize_ 512
$cbr_(0) set interval_ 1
$cbr_(0) set random_ 1
$cbr_(0) set maxpkts_ 10000
$cbr_(0) attach-agent $udp_(0)
$ns_ connect $udp_(0) $null_(0)
$ns_ at 0.5568388786897245 "$cbr_(0) start"
#
#Total sources/connections: 1/1
#
