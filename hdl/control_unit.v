module Control_Unit(
    input [1:0] stage,
    input [11:0] IR,
    input [3:0] SR,

    output reg [3:0] ALU_Mode,
    output reg PC_E, Acc_E, SR_E, IR_E, DR_E, PMem_E, PMem_LE, DMem_E, DMem_WE, ALU_E, MUX1_Sel, MUX2_Sel 
);

    //processor states(stages)
    parameter LOAD = 2'b00,
            FETCH = 2'b01,
            DECODE = 2'b10,
            EXECUTE = 2'b11;

    always @(*) begin
        //Init all control signals to 0
        PC_E = 0;
        Acc_E = 0;
        SR_E = 0;
        IR_E = 0;
        DR_E = 0;
        PMem_E = 0;
        PMem_LE = 0;
        DMem_E = 0;
        DMem_WE = 0;
        ALU_E = 0;
        ALU_Mode = 4'd0;
        MUX1_Sel = 0;
        MUX2_Sel = 0;

        //LOAD stage - should be here once processor turns on
        if(stage == LOAD) begin
            //set Enable and Load Enable bits of Program Memory so that it is ready receive data
            PMem_LE = 1;
            PMem_E = 1;
        end

        else if(stage == FETCH) begin
            //Enabe the instruction register so that the instruction can be put in it
            //Enable the program memory, but keep it's load enable off so that the instruction can be read
            IR_E = 1;
            PMem_E = 1;
        end

        else if(stage == DECODE) begin
            //If one of the operands is from memory and other is from accumulator
            if(IR[11:9] == 3'b001) begin
                //enable the data register and the data memory
                DR_E = 1;
                DMem_E = 1;
            end
            else begin
                //disable data register and data memory
                DR_E = 0;
                DMem_E = 0;
            end
        end

        else if(stage == EXECUTE) begin
            //If operands are accumulator and value given in instruction
            if(IR[11] == 1) begin
                PC_E = 1;
                Acc_E = 1;
                SR_E = 1;
                ALU_E = 1;
                ALU_Mode = IR[10:8]; //MSB will be padded with 0
                MUX1_Sel = 1;
                MUX2_Sel = 0;
            end

            //jmp instructions
            else if(IR[10] == 1) begin
                PC_E = 1;
                MUX1_Sel = SR[IR[9:8]];
            end

            //Operands are 1 from accumulator and other from Memory (bit 8 determined write to same memeory or accumulator)
            else if(IR[9] == 1) begin
                PC_E = 1;
                Acc_E = IR[8];
                SR_E = 1;
                ALU_E = 1;
                DMem_WE = !IR[8];
                DMem_E = !IR[8];
                ALU_Mode = IR[7:4];
            end

            //NOP
            else if(IR[8] == 0) begin
                PC_E = 1;
                MUX1_Sel = 1;
            end

            //0001 -- simply connect PC to Adder
            else begin
                PC_E = 1;
                MUX1_Sel = 0;
            end
        end
    end

endmodule