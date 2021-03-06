//Activated at positive edge of clock signal

module DMem(
    input clk,
    input E,
    input WE,
    input [3:0] Addr,
    input [7:0] DataIn,
    input Print_E,

    output [7:0] DataOut,
    output [7:0] PrintOut
);

    reg [7:0] data_memory [255:0];

    always @(posedge clk) begin
        if(E == 1 && WE == 1)           //Write the Data Input to Data Address
            data_memory[Addr] <= DataIn; 
    end

    assign DataOut = (E == 1) ? data_memory[Addr] : 0;  //If enabled put the value at Address in Data Out
    assign PrintOut = (Print_E == 1)? data_memory[Addr] : 8'dx; //If print is enables, output the value at print address at PrintOut
endmodule


