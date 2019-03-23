
# GPSR routing agent settings
for {set i 0} {$i < $opt(nn)} {incr i} {
    $ns_ at 0.00002 "$ragent_($i) turnon"
    $ns_ at 0.5 "$ragent_($i) neighborlist"
#    $ns_ at 30.0 "$ragent_($i) turnoff"
}

$ns_ at 0.00002 "$ragent_(28) startSink 10.0"
#$ns_ at 0.00002 "$ragent_(29) startSink 10.0"
#$ns_ at 10.5 "$ragent_(89) startSink 10.0"


# GPSR routing agent dumps
$ns_ at 25.0 "$ragent_(28) sinklist"


# Upper layer agents/applications behavior
set null_(1) [new Agent/Null]
$ns_ attach-agent $node_(29) $null_(1)

set udp_(1) [new Agent/UDP]
$ns_ attach-agent $node_(28) $udp_(1)

set cbr_(1) [new Application/Traffic/CBR]
$cbr_(1) set packetSize_ 32
$cbr_(1) set interval_ 1.0
$cbr_(1) set random_ 1
$cbr_(1) attach-agent $udp_(1)
$ns_ connect $udp_(1) $null_(1)
$ns_ at 0.5 "$cbr_(1) start"
$ns_ at 180.0 "$cbr_(1) stop" 
