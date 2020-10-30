module MicroController(
    input clk,
    input rst
);

    //processor states(stages)
    parameter LOAD = 2'b00,
            FETCH = 2'b01,
            DECODE = 2'b10,
            EXECUTE = 2'b11;

    reg[1:0] currentState, nextState;
    
    //Components
    reg [7:0] PC, Acc, DR;
    reg [11:0] IR;
    reg [3:0] SR;
    wire [3:0] SR_new;
    wire [7:0] DR_new, PC_new;
    wire [11:0] IR_new;

    //Control Signals
    wire PC_E, Acc_E, DR_E, IR_E, SR_E;
    wire PMem_E, DMem_E, PMem_LE, DMem_WE, ALU_E, MUX1_Sel, MUX2_Sel;
    wire [3:0] ALU_Mode;

    //Wires and ports
    reg [7:0] loadAddr; //For PMem
    wire [11:0] loadInst; //For PMem
    wire Adder_Out;
    wire ALU_Out, ALU_Op2;

    reg [11:0] temp_program_mem [9:0];

    //flags
    reg load_done;
    reg PC_clr,Acc_clr,SR_clr,DR_clr,IR_clr;

    //LOAD
    initial begin
        $readmemb("program.bin",temp_program_mem,0,9);
    end

    ALU ALU_main(
        .Operand1(Acc),
        .Operand2(ALU_Op2),
        .E(ALU_E),
        .Mode(ALU_Mode),
        .CFlags(SR),
        .flags(SR_new),
        .Out(ALU_Out)
    );

    MUX MUX2_main(
        .MUX_IN1(IR[7:0]),
        .MUX_IN1(DR),
        .MUX_Sel(MUX2_Sel),
        .MUX_Out(ALU_Op2)
    );

    DMem DMem_main(
        .clk(clk),
        .E(DMem_E),
        .WE(DMem_WE),
        .Addr(IR[3:0]),
        .DataIn(ALU_Out),
        .DataOut(DR_new)
    );

    PMem PMem_main(
        .clk(clk),
        .E(PMem_E),
        .LoadE(PMem_LE),
        .Addr(PC),
        .Instruction(IR_new),
        .LoadAddr(loadAddr),
        .LoadInstruction(loadInst)
    );

    PC_adder incrementer(
        .PC_In(PC),
        .PC_Out(Adder_Out)
    );

    MUX MUX1_main(
        .MUX_IN1(IR[7:0]),
        .MUX_IN1(Adder_Out),
        .MUX_Sel(MUX1_Sel),
        .MUX_Out(PC_new)
    );

    ControlUnit ControlUnit_main(
        .stage(currentState),
        .IR(IR),
        .SR(SR),
        .ALU_Mode(ALU_Mode),
        .PC_E(PC_E),
        .Acc_E(Acc_E),
        .SR_E(SR_E),
        .IR_E(IR_E),
        .DR_E(DR_E),
        .PMem_E(PMem_E),
        .PMem_LE(PMem_LE),
        .DMem_E(DMem_E),
        .DMem_WE(DMem_WE),
        .ALU_E(ALU_E),
        .MUX1_Sel(MUX1_Sel),
        .MUX2_Sel(MUX2_Sel)
    );

    //LOAD logic
    always @(posedge clk) begin
        if(rst == 1) begin
            //start loading program from top
            load_addr <= 0;
            load_done <= 1'b0;
        end

        else if(PMem_LE == 1) begin
            load_addr <= load_addr + 1;
            if(load_addr == 8'd9) begin //check if 9 instructions have been loaded
                load_addr <= 8'd0;
                load_done <= 1'b1;
            end 
            else begin
                load_done <= 1'b0;
            end
        end
    end

    assign loadInst = program_mem[load_addr];

    //State determination
    always @(posedge clk) begin
        if(rst == 1) begin
            currentState <= LOAD;
        end
        else begin
            currentState <= nextState;
        end
    end

    always @(*) begin
        PC_clr = 0;
        Acc_clr = 0;
        SR_clr = 0;
        DR_clr = 0;
        IR_clr = 0;

        case(currentState)
            LOAD: begin
                if(load_done == 1) begin
                    nextState = FETCH;
                    PC_clr = 1;
                    Acc_clr = 1;
                    SR_clr = 1;
                    DR_clr = 1;
                    IR_clr = 1;
                end
                else begin
                    nextState = LOAD;
                end
            end
            
            FETCH: begin
                nextState = DECODE;
            end 

            DECODE: begin
                nextState = EXECUTE;
            end

            EXECUTE: begin
                nextState = FETCH;
            end
        endcase
    end

    //visible register logic
    always @(posedge clk) begin
        if(rst == 1) begin
            PC <= 8'd0;
            Acc <= 8'd0;
            SR <= 4'd0;
        end
        else begin
            if(PC_E == 1'd1)
                PC <= PC_new;
            else if(PC_clr == 1)
                PC <= 8'd0;

            if(Acc_E == 1'd1)
                Acc <= ALU_Out;
            else if(Acc_clr == 1)
                Acc <= 8'd0;

            if(SR_E == 1'd1)
                SR <= SR_new;
            else if(SR_clr == 1)
                SR <= 4'd0;
        end
    end

    //Invisible Register logic
    always @(posedge clk) begin
        if(DR_E == 1'd1)
            DR <= DR_new;
        else if(DR_clr == 1)
            DR <= 8'd0;

        if(IR_E == 1'd1)
            IR <= IR_new;
        else if(IR_clr == 1)
            IR <= 12'd0;    
    end 
endmodule
