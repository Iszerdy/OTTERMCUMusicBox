`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/20/2025 01:31:26 PM
// Design Name: 
// Module Name: TopLevelPC
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


module TopLevelPC(
    input logic clk, pc_rst, pc_we,
    input logic [2:0] pc_sel,
    input logic [31:0] jalr, branch, jal, mtvec, mepc,
    output logic [31:0] pc_count,
    output logic [31:0] next_addr
    );
    logic [31:0] pc_din;
    assign next_addr = pc_count + 32'b100; //compute addition for next sequential instruction 
    MUXPC muxpc (.next_addr(next_addr), .jalr(jalr), .branch(branch), .jal(jal), .mtvec(mtvec), .mepc(mepc), .pc_sel(pc_sel), .pc_din(pc_din)); //Instantiate the MUX to find next PC value   
    RegisterPC rpc (.clk(clk), .pc_rst(pc_rst), .pc_we(pc_we), .pc_din(pc_din), .pc_count(pc_count));    //Instantiate the PC

endmodule
