//Increments the program counter by 1
//Fully combinational

module PC_adder(
    input [7:0] PC_In,      //connected to the PC
    output [7:0] PC_Out     //connected to MUX1.In2
);

    assign PC_Out = PC_In + 1;

endmodule