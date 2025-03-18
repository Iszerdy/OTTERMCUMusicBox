`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/20/2025 01:30:44 PM
// Design Name: 
// Module Name: MUXPC
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
module MUXPC(
    input logic [31:0] next_addr, jalr, branch, jal, mtvec, mepc,
    input logic [2:0] pc_sel,
    output logic [31:0] pc_din
    );  
    
    always_comb begin
        case (pc_sel)
            3'b000: pc_din = next_addr; 
            3'b001: pc_din = jalr; 
            3'b010: pc_din = branch;
            3'b011: pc_din = jal; 
            3'b100: pc_din = mtvec;
            3'b101: pc_din = mepc; 
            default: pc_din = 32'b0; 
         endcase
   end
endmodule
/*        case (pc_sel)
            3'b000: pc_din = next_addr; //Default: increase PC by 4
            3'b001: pc_din = jalr; //Jump to new instruction from a jalr
            3'b010: pc_din = branch; //Jump to new instruction from a branch
            3'b011: pc_din = jal; //Jump to new instruction from jal
            3'b100: pc_din = mtvec; //Jump to interrupt serivce routine
            3'b101: pc_din = mepc; //Return from an interrupt service routine
            default: pc_din = 32'b0; //Baseline if no valid selection enabled
         endcase*/