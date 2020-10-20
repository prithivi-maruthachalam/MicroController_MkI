//Purely Combinational Circuit

module ALU(
    input E,                //ALU Enable Port - ALU.E
    input [3:0] Mode,       //Mode is set by the Control Unit
    input [3:0] Cflags,     //Current status of the 4 flags from the Status Register
    input [7:0] Operand1, Operand2,

    output [3:0] flags,     //Flag values to be output to the Status Register
    output [7:0] Out        //The output of the ALU computation, connected to DMem.DI
);

    wire Z,S,O;
    reg CarryOut;           //Reg because it needs to be assigned inside the sequential block
    reg [7:0] ALU_Out;

    always @(*) begin       //Do this everytime any input changes; beacuse ALU is combinational
        case(Mode)          //Mode is set by the control unit
            4'b0000: {CarryOut, ALU_Out} = Operand1 + Operand2;     //Arithmetic Addition
            4'b0001: begin                                          //Arithmetic Subtraction
                ALU_Out = Operand1 - Operand2;                      /*This negation is done beacuse the MSB is 0 for positive numbers and 1 for negative ones in the 2's complement version*/
                CarryOut = !ALU_Out[7];                             //Not relevant for signed arithmetic
            end
            
            4'b0010: ALU_Out = Operand1;                            //Assignment(Buffer)
            4'b0011: ALU_Out = Operand2;                            //Assignment(Buffer)
            4'b0100: ALU_Out = Operand1 & Operand2;                 //Bitwise AND
            4'b0101: ALU_Out = Operand1 | Operand2;                 //Bitwise OR
            4'b0110: ALU_Out = Operand1 ^ Operand2;                 //Bitwise XOR
            4'b0111: begin                                          //Arithmetic Subtraction
                ALU_Out = Operand2 - Operand1; 
                CarryOut = !ALU_Out[7];                             //Not relevant for signed arithmetic
            end
            
            4'b1000: {CarryOut, ALU_Out} = Operand2 + 8'h1;         //Increment
            4'b1001: begin                                          //Decrement
                ALU_Out = Operand2-8'h1;        
                CarryOut = !ALU_Out[7];
            end
            
            //Shifting
            4'b1010: ALU_Out = (Operand2 << Operand1[2:0]) | (Operand2 >> (8 - Operand1[2:0]));
            4'b1011: ALU_Out = (Operand2 >> Operand1[2:0]) | (Operand2 << (8 - Operand1[2:0]));
            4'b1100: ALU_Out = Operand2 << Operand1[2:0];
            4'b1101: ALU_Out = Operand2 >> Operand1[2:0];
            4'b1110: ALU_Out = Operand2 >>> Operand1[2:0];

            4'b1111: begin
                ALU_Out = 8'h0 - Operand2;
                CarryOut = !ALU_Out[7];
            end

            default: ALU_Out = Operand2;
        endcase
    end

    assign O = ALU_Out[7] ^ ALU_Out[6];
    assign Z = (ALU_Out == 0)? 1'b1 : 1'b0;
    assign S = ALU_Out[7];
    assign flags = {Z, CarryOut, S, O};
    assign Out = ALU_Out;

endmodule

