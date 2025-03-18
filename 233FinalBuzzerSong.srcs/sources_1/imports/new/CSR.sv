`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/04/2025 03:41:21 PM
// Design Name: 
// Module Name: CSR
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
module CSR(
    input CLK,
    input RST,
    input MRET_EXEC,        //- indicates MCU executing mret instruction
    input INT_TAKEN,        //- indicates FSM is in interrupt cycle
    input [11:0] ADDR,      //- CSR register address
    input [31:0] PC,        //- program counter value
    input [31:0] WD,        //- data to be written to CSR
    input WR_EN,            //- write enable signal for CSR writes
    output logic [31:0] RD,              //- register data read from CSR
    output logic [31:0] CSR_MEPC,      //- return from interrupt addr
    output logic [31:0] CSR_MTVEC,     //- interrupt vector address
    output logic CSR_MSTATUS_MIE         //- interrupt enable bit in CSR[mstatus]
    );
   
    // Internal registers
    logic [31:0] csr_mtvec, csr_mepc, csr_mstatus;

    always_ff @(posedge CLK) begin
        if (RST) begin   //Reseting returns all registers to 0
            csr_mtvec   <= 32'b0;
            csr_mepc    <= 32'b0;
            csr_mstatus <= 32'b0;
        end
        
         if (WR_EN) begin  // Write to registers
            case (ADDR)
                12'h300: csr_mstatus <= WD;  
                12'h341: csr_mepc    <= WD;  
                12'h305: csr_mtvec   <= WD;    
                default: ;
            endcase
        end
                
         if (MRET_EXEC) begin 
           csr_mstatus[3] <= csr_mstatus[7];
           csr_mstatus[7] <=0;
        end
        
         if (CSR_MSTATUS_MIE) begin                  // Checking for interrupts 
            if (INT_TAKEN) begin 
                csr_mepc <= PC;                     // Save current PC Count
                csr_mstatus[7] <= csr_mstatus[3];   // Save bit 3 of mstatus to bit 7 and set to 0

                csr_mstatus[3] <=0;
            end
        end
    end

    // Output assignments
    always_comb begin
            case (ADDR)
                12'h300: RD = csr_mstatus; 
                12'h341: RD = csr_mepc;    
                12'h305: RD = csr_mtvec;    
                default: RD = 32'b0;          
            endcase
   
        // Drive the outputs directly from registers
        CSR_MSTATUS_MIE = csr_mstatus[3];    
        CSR_MEPC        = csr_mepc;                    
        CSR_MTVEC       = csr_mtvec;                             
    end
endmodule

 