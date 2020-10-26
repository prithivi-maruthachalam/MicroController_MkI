//Chooses between incrementing the Program Counter and jump to another instruction
module MUX1(
    input [7:0] MUX1_IN1,   //Connected to instruction register
    input [7:0] MUX1_IN2,   // Conencted to PC_Adder Output
    input [7:0] MUX_Sel,    // Connected to control unit
    output [7:0] MUX_Out    //
);
    assign MUX_Out = (MUX_Sel == 1) ? MUX1_IN1 : MUX1_IN2;
endmodule