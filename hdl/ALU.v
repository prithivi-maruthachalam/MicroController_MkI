//Purely Combinational Circuit

module ALU(
    input E,                //ALU Enable Port - ALU.E
    input [3:0] Mode,       //Mode is set by the Control Unit
    input [3:0] CFlags,     //Current status of the 4 flags from the Status Register
    input [7:0] Operand1, Operand2,

    output [3:0] flags,     //Flag values to be output to the Status Register
    output [7:0] Out        //The output of the ALU computation, connected to DMem.DI
);

    wire Z,S,O;
    reg CarryOut;           //Reg because it needs to be assigned inside the sequential block
    reg [7:0] ALU_Out;
    reg [7:0] real_Op1, real_Op2;

    always @(*) begin       //Do this everytime any input changes; beacuse ALU is combinational
        case(Mode)          //Mode is set by the control unit
            4'b0000: begin
                {CarryOut, ALU_Out} = Operand1 + Operand2;          //Arithmetic Addition
                real_Op1 = Operand1;
                real_Op2 = Operand2;                
            end
            4'b0001: begin
                real_Op1 = Operand1;
                real_Op2 = (~Operand2 + 1);
                {CarryOut, ALU_Out} = real_Op1 + real_Op2;     //Arithmetic Subtraction
            end
            4'b0010: ALU_Out = Operand1;                            //Assignment(Buffer)
            4'b0011: ALU_Out = Operand2;                            //Assignment(Buffer)
            4'b0100: ALU_Out = Operand1 & Operand2;                 //Bitwise AND
            4'b0101: ALU_Out = Operand1 | Operand2;                 //Bitwise OR
            4'b0110: ALU_Out = Operand1 ^ Operand2;                 //Bitwise XOR
            4'b0111: begin
                real_Op1 = Operand2;
                real_Op2 = (~Operand1 + 1); 
                {CarryOut, ALU_Out} = real_Op2 + real_Op1;          //Arithmetic Subtraction               
            end
            
            4'b1000: begin
                {CarryOut, ALU_Out} =  8'h1 + Operand2;             //Increment
                real_Op1 = 8'h1;
                real_Op2 = Operand2;
            end
            4'b1001: begin
                real_Op1 = Operand2;
                real_Op2 = 8'b11111111;
                {CarryOut, ALU_Out} = real_Op1 + real_Op2;               //Decrement
            end
            
            //Shifting
            4'b1010: ALU_Out = (Operand2 << Operand1[2:0]) | (Operand2 >> (8 - Operand1[2:0]));
            4'b1011: ALU_Out = (Operand2 >> Operand1[2:0]) | (Operand2 << (8 - Operand1[2:0]));
            4'b1100: ALU_Out = Operand2 << Operand1[2:0];
            4'b1101: ALU_Out = Operand2 >> Operand1[2:0];
            4'b1110: ALU_Out = Operand2 >>> Operand1[2:0];

            4'b1111: begin
                {CarryOut, ALU_Out} = 8'h0 - Operand2;
                real_Op1 = 8'h0;
                real_Op2 = (~Operand2 + 1);                
            end
            
            default: ALU_Out = Operand2;
        endcase
    end

    //assign O = ALU_Out[7] ^ ALU_Out[6];
    assign O = (!real_Op1[7] & !real_Op2[7] & !CarryOut & ALU_Out[7]) | (real_Op2[7] & real_Op2[7] & CarryOut & !ALU_Out[7]);
    assign Z = (ALU_Out == 0)? 1'b1 : 1'b0;
    assign S = ALU_Out[7];
    assign flags = {Z, CarryOut, S, O};
    assign Out = ALU_Out;
    assign reals = {real_Op1, real_Op2};

endmodule

