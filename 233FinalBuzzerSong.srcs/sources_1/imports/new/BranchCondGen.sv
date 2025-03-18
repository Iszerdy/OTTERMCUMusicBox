`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/11/2025 11:54:49 AM
// Design Name: 
// Module Name: BranchCondGen
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


module BranchCondGen(
    input logic [31:0] rs1, rs2,
    output logic br_eq, br_lt, br_ltu
    );
    assign br_eq = (rs1 == rs2) ? 1 : 0;
    assign br_ltu = (rs1 < rs2) ? 1 : 0;
    assign br_lt = (($signed(rs1)) < ($signed(rs2))) ? 1 : 0;
endmodule
