filepath = 'dsdv.tcl'
output = open("dsdv-update.tcl","w") 
init_trip = []
trip = []
x = 0
y = 0
z = 0  
cnt = 0
with open(filepath) as fp:  
   while True:
		line = fp.readline()
		arr = line.split()
		if not line:
			break
		if len(arr) == 0:
			break
		if "$node_" in arr[0]:
			cnt += 1
			print arr
			if arr[2] == "X_":
				x = arr[3]
			if arr[2] == "Y_":
				y = arr[3]
			if arr[2] == "Z_":
				z = arr[3]
			output.write(line)
			if cnt == 3:
				print line
				init_trip.append('$ns_ at 0.0 "'+arr[0]+' setdest '+x+' '+y+' '+z+'"\n')
				cnt = 0
		else:
			trip.append(line)


output.write("$node_(28) set X_ 0.000000000000\n")
output.write("$node_(28) set Y_ 1000.000000000000\n")
output.write("$node_(28) set Z_ 0.000000000000\n")
output.write("$node_(29) set X_ 1000.000000000000\n")
output.write("$node_(29) set Y_ 0.000000000000\n")
output.write("$node_(29) set Z_ 0.000000000000\n")
for x in init_trip:
	output.write(x)
for x in trip:
	output.write(x)
output.close()
