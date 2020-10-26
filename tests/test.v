module ALU_test;
    wire [3:0] tA;
    reg [3:0] tB;

    assign tA = 4'b1010;

    initial begin
        tB <= !tA;
        #5
        $finish;
    end

    always @(tB) begin
        $strobe("A: %b\tB:%b", tA, tB);
    end
endmodule