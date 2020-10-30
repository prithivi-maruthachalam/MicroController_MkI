//Chooses between incrementing the Program Counter and jump to another instruction
module MUX1(
    input [7:0] MUX1_IN1,   //Connected to instruction register[7:0]
    input [7:0] MUX1_IN2,   // Conencted to PC_Adder Output
    input MUX1_Sel,    // Connected to control unit
    output [7:0] MUX1_Out    //Connected to program counter
);
    assign MUX1_Out = (MUX1_Sel == 1) ? MUX1_IN1 : MUX1_IN2;
endmodule