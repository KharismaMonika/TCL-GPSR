with open(r'skenario.tcl', 'r') as infile, open(r'dsdv.tcl', 'w') as outfile:
    data = infile.read();
    data = data.replace("-","")
    outfile.write(data)