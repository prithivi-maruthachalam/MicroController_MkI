//TODO: 2 sepatate w/wout stuff
//TODO: Printing cleanup
//TODO: HALT?


module MicroController(
    input clk,
    input rst
);

    //processor states(stages)
    parameter LOAD = 2'b00,FETCH = 2'b01,DECODE = 2'b10,EXECUTE = 2'b11;

    //for state monitoring and switching
    reg[1:0] currentState, nextState;
    
    //Components
    reg [7:0] PC, Acc, DR;
    reg [11:0] IR;
    reg [3:0] SR;
    reg [7:0] PR;
    wire [3:0] SR_new;
    wire [7:0] DR_new, PC_new;
    wire [11:0] IR_new;
    wire [7:0] PR_new;

    //Control Signals
    wire PC_E, Acc_E, DR_E, IR_E, SR_E, PR_E;
    wire PMem_E, DMem_E, PMem_LE, DMem_WE, ALU_E, MUX1_Sel, MUX2_Sel;
    wire [3:0] ALU_Mode;

    //Wires and ports
    reg [7:0] loadAddr;
    wire [11:0] loadInst; 
    wire [7:0] Adder_Out;
    wire [7:0] ALU_Out, ALU_Op2;

    reg [11:0] temp_program_mem [9:0];

    //flags & resets
    reg load_done;
    reg PC_clr,Acc_clr,SR_clr,DR_clr,IR_clr;    //to reset registers to 0 values

    

    //LOAD code from file into temporary program memory
    initial begin
        $readmemb("/home/prithivi/Projects/priProcessor/mark_I/bitcode.out",temp_program_mem,0,9);
    end


    //Module instantiation
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
        .MUX_IN2(DR),
        .MUX_Sel(MUX2_Sel),
        .MUX_Out(ALU_Op2)
    );

    DMem DMem_main(
        .clk(clk),
        .E(DMem_E),
        .WE(DMem_WE),
        .Addr(IR[3:0]),
        .DataIn(ALU_Out),
        .DataOut(DR_new),
        .PrintOut(PR_new),
        .Print_E(PR_E)
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
        .MUX_IN2(Adder_Out),
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
        .MUX2_Sel(MUX2_Sel),
        .PR_E(PR_E)
    );

/*-------------------------------LOGIC DESCRIPTION----------------------------------------------*/

    //LOAD logic
    always @(posedge clk) begin
        if(rst == 1) begin
            //set load address to top of program memory
            loadAddr <= 0;
            load_done <= 1'b0; 
        end

        else if(PMem_LE == 1) begin
            //move to next load address
            loadAddr <= loadAddr + 1;
            if(loadAddr == 8'd9) begin //check if 9 instructions have been //TODO: Change to n instructions
                loadAddr <= 8'd0;
                load_done <= 1'b1;
                $display("LOAD Complete");
            end 
            else begin
                load_done <= 1'b0;
            end
        end
    end

    //assign value to current instruction to be loaded
    assign loadInst = temp_program_mem[loadAddr];

    //State determination
    /*
        Move to the required state at every positive edge of clock 
    */
    always @(posedge clk) begin
        if(rst == 1) begin
            currentState <= LOAD;
        end
        else begin
            currentState <= nextState;
        end
    end

    //Stages and stage transition
    /*
        Determine nextState to switch to during positive edge of clock
    */
    always @(*) begin
        PC_clr = 0;
        Acc_clr = 0;
        SR_clr = 0;
        DR_clr = 0;
        IR_clr = 0;

        case(currentState)
            LOAD: begin
                //Check if LOADing is complete
                if(load_done == 1) begin
                    nextState = FETCH;
                    PC_clr = 1;
                    Acc_clr = 1;
                    SR_clr = 1;
                    DR_clr = 1;
                    IR_clr = 1;
                    $display("Setting transition to fetch state\n");
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

    //visible register logic (PC, Acc, SR)
    /*
        - Clear(zero) when reset or during LOAD stage(clr flags)
        - Update to required value at positive edge of clock if enabled
    */
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

    //Invisible Register logic (DR, IR)
    /*
        - Clear at reset not required - value determined by address lines to PMem & DMem
        - Clear(zero) during LOAD stage(clr flags)
        - Update to required value at positive edge of clock if enabled
    */
    always @(posedge clk) begin
        if(DR_E == 1'd1)
            DR <= DR_new;
        else if(DR_clr == 1)
            DR <= 8'd0;

        if(IR_E == 1'd1)
            IR <= IR_new;
        else if(IR_clr == 1)
            IR <= 12'd0;    

        PR <= PR_new;
    end

    //For debugging
    always @(posedge clk) begin
        case(currentState)
            2'b00:$strobe("TIME:%0t\t::\tCurrent State: LOAD",$time);
            2'b01:$strobe("TIME:%0t\t::\tCurrent State: FETCH",$time);
            2'b10:$strobe("TIME:%0t\t::\tCurrent State: DECODE",$time);
            2'b11:$strobe("TIME:%0t\t::\tCurrent State: EXECUTE",$time);
        endcase
        //$strobe("TIME:%0t\t::\tZ(SR[3]):%b\tC(SR[2]):%b\tS(SR[1]):%d\tO(SR[0]):%d\t",$time,SR[3],SR[2],SR[1],SR[0]);
        $strobe("TIME:%0t\t::\tPC: %b (%d)\tPC_E:%b",$time,PC,PC,PC_E);
        $strobe("TIME:%0t\t::\tIR: %b (%d)\tIR_E:%b",$time,IR,IR,IR_E);
        $strobe("TIME:%0t\t::\tDR: %b (%d)\tDR_E:%b\t[%h]",$time,DR,DR,DR_E,DR);
        $strobe("TIME:%0t\t::\tDMem_print: %b (%d)\tPR_E:%b\t[%h]",$time,PR,PR,PR_E,PR);
        $strobe("TIME:%0t\t::\tAcc: %b (%d)\tAcc_E:%b\t[%h]",$time,Acc,Acc,Acc_E,Acc);
        $strobe();
    end 
endmodule
