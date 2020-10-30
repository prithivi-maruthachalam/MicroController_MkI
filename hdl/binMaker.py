import os
import sys



program = ["0000_0000_0000",
"101100000001",
"001000100000",
"101100000000",
"001100110000",
"000100000101",
"000000000000",
"000000000000",
"000000000000",
"000000000000"]

def inti(st):
    return int(st,base=2)


program = map(inti,program);

with open('program.bin','rb') as f:
    for i in program:
        print(f.readline())