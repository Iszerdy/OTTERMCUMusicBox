`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/28/2025 06:52:39 PM
// Design Name: 
// Module Name: RegisterFile
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module RegisterFile(
    input logic clk, en,
    input logic [4:0] adr1, adr2, w_adr,
    input logic [31:0] w_data,
    output logic [31:0] rs1, rs2
    );
    // Create a 32x32 memory module
    logic [31:0] registers  [0:31];

    // Initialize the memory to be all 0s
    initial begin
       int i;
        for (i=0; i<32; i++) begin
            registers[i] = 0;
        end
    end
    
    // synchronously write values
    always_ff @(posedge clk) begin  
        if ((en == 1) && (w_adr != 0)) begin// only write when en is high and is not register x0
            registers[w_adr] <= w_data;
        end
    end
    // asychrounoulsy read values
    assign rs1 = registers[adr1];
    assign rs2 = registers[adr2];
    
endmodule
