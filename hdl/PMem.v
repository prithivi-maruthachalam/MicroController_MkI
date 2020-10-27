module PMem(
    input clk,
    input E,
    input LoadE,
    input [7:0] Addr,
    output [11:0] Instruction,
    input [7:0] LoadAddr,
    input [11:0] LoadInstruction 
);

    reg [11:0] program_memory [255:0];

    always @(posedge clk)   begin
        if(LoadE == 1) begin
            program_memory[LoadAddr] <= LoadInstruction;
        end
    end

    assign Instruction = (E == 1) ? program_memory[Addr] : 0;

endmodule