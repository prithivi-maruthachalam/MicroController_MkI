#!/usr/bin/env python3
import os
import re
import argparse

parser = argparse.ArgumentParser(description="Assemble a .p file into a binary for the tiny_MCU")
parser.add_argument('inFile',
                    metavar='InputFilePath',
                    type = str,
                    help = "Path to the .p file",
)
parser.add_argument('-o',
                    '--outFile',
                    metavar='OutputFilePath',
                    type = str,
                    default = "bitcode.out",
                    help = "Path to the .p file"
)

args = parser.parse_args()

#Constants
FILENAME = args.inFile
OUT_FILENAME = args.outFile
INSTRUCTION_SIZE = 12

#file access
readfile = open(FILENAME, "r")
LINES = readfile.readlines()
readfile.close()

writefile = open(OUT_FILENAME, "w")

#instruction tables
IM_commons = {
    "ADD" : '0000',
    "SUB" : '0001',
    "RSUB": '0111',
    "MOV" : '0011',
    "AND" : '0100',
    "OR"  : '0101',
    "XOR" : '0110'
}

JMPS = {
    "JZ" : '0111',
    "JC" : '0110',
    "JS" : '0101',
    "JO" : '0100',
    "GOTO" : "0001"
}

labels = dict()

def get_num(token):
    token = token.replace("[","").strip("]").replace("mem","")
    return int(token)

lineNumber = 0
for line in LINES:
    bits = ['0'] * INSTRUCTION_SIZE
    line = line.replace("\n","")
    line = line.strip()

    tokens = line.split(" ")
    tokens = list(filter(lambda x: (x != "") and (not(x.startswith('//'))),tokens))
    #print(tokens)
    if(not len(tokens)):
        continue

    if(tokens[0] == "NOP"):
        pass

    if tokens[0] in IM_commons.keys():
        try:
            #operation with immediate value
            I_val = int(tokens[2])
            bits[0] = "1"
            bits[1],bits[2],bits[3] = list(IM_commons[tokens[0]])[-3:] 
            bits[4],bits[5],bits[6],bits[7],bits[8],bits[9],bits[10],bits[11] = list(format((I_val%256),'08b'))
            ##I val as remaining bits
        except (ValueError, IndexError):
            #operation with memory
            bits[0],bits[1],bits[2] = list("001")
            if tokens[1] == "Acc":
                bits[3] = "1"
                mem_addr = get_num(tokens[2])
                bits[8],bits[9],bits[10],bits[11] = list(format(mem_addr%16,'04b'))
            else:
                bits[3] = "0"
                mem_addr = get_num(tokens[1])
                bits[8],bits[9],bits[10],bits[11] = list(format(mem_addr%16,'04b'))

            if tokens[0] == "MOV":
                bits[4],bits[5],bits[6],bits[7] = (bits[0],bits[1],bits[2],bits[3])
            else:
                bits[4],bits[5],bits[6],bits[7] = list(IM_commons[tokens[0]])
    elif tokens[0] in JMPS.keys():
        if len(tokens) != 2:
            raise Exception("Jump type isntruction takes one argument") 
        bits[0],bits[1],bits[2],bits[3] = list(JMPS[tokens[0]]) 
        if(tokens[1] not in labels.keys()):
            raise Exception("Label '" + tokens[1] + "' is not defined")
        else:
            bits[4],bits[5],bits[6],bits[7],bits[8],bits[9],bits[10],bits[11] = list(format((labels[tokens[1]]%256),'08b'))
    elif tokens[0] == "label":
        labels[tokens[1]] = lineNumber


    toWrite = ''
    i = 0 
    while(i <= INSTRUCTION_SIZE - 4):
        toWrite += (''.join(bits[i:i+4]))
        toWrite += "_"
        i += 4 
    toWrite = toWrite.strip("_")
    toWrite += "\n"

    writefile.write(toWrite)


    #print(toWrite,end="\n")
    
    lineNumber += 1
    



writefile.close()