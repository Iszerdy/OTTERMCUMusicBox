`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/11/2025 11:59:16 AM
// Design Name: 
// Module Name: BranchAddrGen
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


module BranchAddrGen(
    input logic [31:0] PC, jtype_imm, btype_imm, itype_imm, rs1,
    output logic [31:0] jal, branch, jalr
    );
    assign branch = PC + btype_imm;
    assign jal = PC + jtype_imm;
    assign jalr = rs1 + itype_imm;
endmodule
