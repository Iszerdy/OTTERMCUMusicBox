`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/20/2025 01:33:27 PM
// Design Name: 
// Module Name: RegisterPC
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


module RegisterPC(
    input logic clk, 
    input logic pc_rst, 
    input logic pc_we, 
    input logic [31:0] pc_din,
    output logic [31:0] pc_count
    ); 
    always_ff @(posedge clk) begin  
        if (pc_rst)
            pc_count <= 32'b0; //Reset PC to 0
        else if (pc_we)
            pc_count <= pc_din; //Load new value into PC
    end
endmodule
