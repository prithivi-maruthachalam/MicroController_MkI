//Chooses between incrementing the Program Counter and jump to another instruction
module MUX(
    input [7:0] MUX_IN1,
    input [7:0] MUX_IN2, 
    input MUX_Sel,
    output [7:0] MUX_Out
);
    assign MUX_Out = (MUX_Sel == 1) ? MUX_IN1 : MUX_IN2;
endmodule