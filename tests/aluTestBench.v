module ALU_test;
    reg [7:0] tA, tB;
    wire [7:0] tO;
    wire [3:0] StatusRegisters;
    wire [3:0] initStatus, tMode;
    wire tE;
    //wire [15:0] t_reals;

    ALU alu1(.E(tE), .Mode(tMode), .Cflags(initStatus),
        .Operand1(tA), .Operand2(tB), .flags(StatusRegisters),
        .Out(tO)/*,.reals(t_reals)*/
    );

    assign tMode = 4'b1001;
    assign tE = 1;
    assign initStatus = 4'b0000;

    initial begin
        tB <= -128;
        tA <= 110;
        #5
        $finish;
    end

    always @(tO) begin
        $strobe("OperandA: %b\tOperandB: %b\t Output: %b",tA,tB,tO);
        //$strobe("Real_OpA: %b\tReal_OpB: %b\t Output: %b",t_reals[15:8],t_reals[7:0],tO);
        $strobe("OperandA: %d\tOperandB: %d\t Output: %d",tA,tB,tO);
        //$strobe("Real_OpA: %d\tReal_OpB: %d\t Output: %d",t_reals[15:8],t_reals[7:0], tO);
        $strobe("StatusRegisters: Z: %b\tC: %b\tS: %b\tO: %b\n", StatusRegisters[3], StatusRegisters[2], StatusRegisters[1], StatusRegisters[0]);
    end
endmodule