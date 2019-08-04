#!/usr/bin/python3

import sys

print('Number of arguments:', len(sys.argv), 'arguments.')
print('Arguement List:', str(sys.argv))

if(len(sys.argv) != 3):
    print("Error: need to 2 args")
    print("Arg1: input file")
    print("Arg2: output files location with prefix")

inFileStr = sys.argv[1]
outFileStr = sys.argv[2]

#inFile = open(inFileStr, "r");

outFile0 = open(outFileStr + "/mem0.bin", "wb");
outFile1 = open(outFileStr + "/mem1.bin", "wb");
outFile2 = open(outFileStr + "/mem2.bin", "wb");
outFile3 = open(outFileStr + "/mem3.bin", "wb");

cnt = 0
with open(inFileStr, "rb") as inFile:
    char = 1 #inFile.read(1)
    while char:
        char = inFile.read(1)
        if(char):
            if(cnt % 4 == 0):
                print(3)
                outFile3.write(char)
            elif(cnt % 4 == 1):
                print(2)
                outFile2.write(char)
            elif(cnt % 4 == 2):
                print(1)
                outFile1.write(char)
            else:
                print(0)
                outFile0.write(char)
            cnt += 1
        
    
print(cnt)





