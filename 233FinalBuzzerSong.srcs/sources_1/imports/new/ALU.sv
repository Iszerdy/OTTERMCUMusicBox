`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/04/2025 10:47:22 AM
// Design Name: 
// Module Name: ALU
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


module ALU(
    input logic [31:0] srcA, srcB,
    input logic [3:0] alu_fun,
    output logic [31:0] alu_result
    );
    
    always_comb begin
        case (alu_fun)
            4'b0000: alu_result = srcA + srcB; //ADD
            4'b1000: alu_result = srcA - srcB; //SUB
            4'b0110: alu_result = srcA | srcB; //OR
            4'b0111: alu_result = srcA & srcB; //AND
            4'b0100: alu_result = srcA ^ srcB; //XOR
            4'b0101: alu_result = srcA >> srcB[4:0]; //SRL
            4'b0001: alu_result = srcA << srcB[4:0]; //SLL
            4'b1101: alu_result = $signed(srcA) >>> srcB[4:0]; //SRA
            4'b0010: alu_result = ($signed(srcA) < $signed(srcB)) ? 32'b1: 32'b0; //SLT
            4'b0011: alu_result = (srcA < srcB) ? 32'b1: 32'b0; //SLTU
            4'b1001: alu_result = srcA; //LUI-COPY
            default: alu_result = 32'b0;
         endcase
    end
endmodule
