
# GPSR routing agent settings
for {set i 0} {$i < $opt(nn)} {incr i} {
    $ns_ at 0.00002 "$ragent_($i) turnon"
    $ns_ at 0.5 "$ragent_($i) neighborlist"
#    $ns_ at 30.0 "$ragent_($i) turnoff"
}

$ns_ at 1.0 "$ragent_(0) startSink 10.0"
$ns_ at 0.5 "$ragent_(89) startSink 10.0"


# GPSR routing agent dumps
$ns_ at 25.0 "$ragent_(24) sinklist"


set udp_(3) [new Agent/UDP]
$ns_ attach-agent $node_(1) $udp_(3)

set null_(3) [new Agent/Null]
$ns_ attach-agent $node_(89) $null_(3)

set cbr_(3) [new Application/Traffic/CBR]
$cbr_(3) set packetSize_ 32
$cbr_(3) set interval_ 2.0
$cbr_(3) set random_ 1
#    $cbr_(3) set maxpkts_ 2
$cbr_(3) attach-agent $udp_(3)
$ns_ connect $udp_(3) $null_(3)
$ns_ at 1.0 "$cbr_(3) start"
$ns_ at 150.0 "$cbr_(3) stop" 
