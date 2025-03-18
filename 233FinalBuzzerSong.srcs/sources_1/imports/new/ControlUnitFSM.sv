`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/22/2025 01:08:55 PM
// Design Name: 
// Module Name: ControlUnitFSM
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

module ControlUnitFSM(
    input rst,                    
    input logic intr, clk,        // MCU interrupt signal
    input logic [6:0] opcode,     // 7-bit opcode from the instruction
    input logic [2:0] func3,      // 3-bit function field used for CSR and branch instructions
    output logic PCWrite,         // Update the Program Counter
    output logic regWrite,        // Enable register file write
    output logic memWE2,          // Enable data memory write (write enable)
    output logic memRDEN1,        // Enable instruction memory read
    output logic memRDEN2,        // Enable data memory read
    output logic reset,           // Control signal passed to other modules for reset behavior
    output logic csr_we,          // Write enable for CSR registers
    output logic int_taken,       // Interrupt is being serviced
    output logic mret_exec        // Mret (return from interrupt) is being executed
);

    // Define FSM states for instruction control
    typedef enum logic [2:0] {
        INIT = 0,     
        FETCH = 1,    
        EXEC = 2,     
        WRITEBACK = 3, 
        INTERRUPT = 4  
    } state_t;
    
    state_t state = INIT, next_state;  // Current and next state of the FSM

    // RISC-V opcode definitions for instruction decoding
    localparam [6:0] LUI    = 7'b0110111;
    localparam [6:0] AUIPC  = 7'b0010111;
    localparam [6:0] JAL    = 7'b1101111;
    localparam [6:0] JALR   = 7'b1100111;
    localparam [6:0] LOAD   = 7'b0000011;
    localparam [6:0] OP_IMM = 7'b0010011;
    localparam [6:0] BRANCH = 7'b1100011;
    localparam [6:0] STORE  = 7'b0100011;
    localparam [6:0] RTYPE  = 7'b0110011;
    localparam [6:0] SYS    = 7'b1110011;

    always_ff @(posedge clk) begin 
        if (rst) begin
            state <= INIT;  // On reset, initialize to INIT state.
        end else begin
            state <= next_state;  // Otherwise, transition to computed next state.
        end
    end

    always_comb begin 
        // Default values for all control signals.
        reset = 1'b0;
        memRDEN1 = 1'b0;
        memRDEN2 = 1'b0;
        PCWrite = 1'b0;
        regWrite = 1'b0;
        memWE2 = 1'b0;
        int_taken = 1'b0;
        csr_we = 1'b0;
        mret_exec = 1'b0;
        
        case (state)
            INIT: begin   // System initialization
                if (intr) begin
                    next_state = INTERRUPT;  
                end else begin
                    next_state = FETCH;     
                end
                reset = 1'b1;       // Assert reset control signal to other modules.
                PCWrite = 1'b0;    
                regWrite = 1'b0;    
                memWE2 = 1'b0;      
                memRDEN1 = 1'b0;    
                memRDEN2 = 1'b0;  
            end
            FETCH: begin   // Fetch an instruction from memory
                if (intr) begin
                    next_state = INTERRUPT;  
                end else begin
                    next_state = EXEC;      
                end
                PCWrite = 1'b0; 
                regWrite = 1'b0; 
                memWE2 = 1'b0;   
                memRDEN1 = 1'b1; // Enable read from instruction memory.
                memRDEN2 = 1'b0; 
            end
            EXEC: begin // Execute the fetched instruction
                PCWrite = 1'b1;  // Allow PC update (e.g. PC+4 or branch target).
                if (intr) begin
                    next_state = INTERRUPT;  
                end else begin
                    next_state = FETCH;      
                end
                case (opcode)
                  LUI: begin
                    // Only write register
                    regWrite = 1'b1;
                    memWE2   = 1'b0;
                    memRDEN1 = 1'b0;
                    memRDEN2 = 1'b0;
                  end
                  AUIPC: begin
                    // Add immediate to PC and write result to register
                    regWrite = 1'b1;
                  end
                  JAL: begin
                    // Write return address to register
                    regWrite = 1'b1;
                  end
                  JALR: begin
                    // Write return address to register
                    regWrite = 1'b1;
                 end
                  LOAD: begin
                    memRDEN2 = 1'b1; // Enable data memory read.
                    PCWrite  = 1'b0;
                    regWrite = 1'b0; 
                    memWE2   = 1'b0;
                    memRDEN1 = 1'b0;
                    next_state = WRITEBACK; // Transition to WRITEBACK for load
                  end
                  OP_IMM: begin
                    regWrite = 1'b1;
                  end
                  BRANCH: begin
                    // No register file write
                    regWrite = 1'b0;
                    memWE2   = 1'b0;
                    memRDEN1 = 1'b0;
                    memRDEN2 = 1'b0;
                  end
                  STORE: begin
                    //Write data from register to memory
                    regWrite = 1'b0;  // Do not update register file
                    memWE2   = 1'b1;  // Enable data memory write
                    memRDEN1 = 1'b0; 
                    memRDEN2 = 1'b0;
                  end
                  RTYPE: begin
                    // Register-register ALU operations
                    regWrite = 1'b1;
                  end
                  SYS: begin
                    case (func3)
                        3'b001: begin 
                            // csrrw: update register with old CSR value
                            PCWrite   = 1'b1; 
                            regWrite  = 1'b1; 
                            memWE2    = 1'b0;
                            memRDEN1  = 1'b1; 
                            memRDEN2  = 1'b0; 
                            reset     = 1'b0; 
                            csr_we    = 1'b1;  // Enable CSR write operation
                            int_taken = 1'b0; 
                            mret_exec = 1'b0; 
                        end
                        3'b010: begin   
                            // csrrs: Read CSR and set specified bits
                            PCWrite   = 1'b1; 
                            regWrite  = 1'b1; 
                            memWE2    = 1'b0; 
                            memRDEN1  = 1'b1; 
                            memRDEN2  = 1'b0; 
                            reset     = 1'b0; 
                            csr_we    = 1'b1; 
                            int_taken = 1'b0; 
                            mret_exec = 1'b0; 
                        end
                        3'b011: begin   
                            // csrrc: Read CSR and clear specified bits
                            PCWrite   = 1'b1; 
                            regWrite  = 1'b1; 
                            memWE2    = 1'b0; 
                            memRDEN1  = 1'b1; 
                            memRDEN2  = 1'b0; 
                            reset     = 1'b0; 
                            csr_we    = 1'b1; 
                            int_taken = 1'b0;
                            mret_exec = 1'b0;
                        end
                        3'b000: begin
                            // mret: Return from interrupt; restore state from CSR
                            PCWrite   = 1'b1; 
                            regWrite  = 1'b0;  // Do not update register file on mret
                            memWE2    = 1'b0; 
                            memRDEN1  = 1'b1; 
                            memRDEN2  = 1'b0; 
                            reset     = 1'b0; 
                            csr_we    = 1'b0; 
                            int_taken = 1'b0; 
                            mret_exec = 1'b1; // Activate mret execution to restore interrupt state
                        end
                        default: begin
                            // Default: no operation
                            PCWrite   = 1'b0;
                            regWrite  = 1'b0;
                            memWE2    = 1'b0;
                            memRDEN1  = 1'b0;
                            memRDEN2  = 1'b0;
                            reset     = 1'b0;
                            csr_we    = 1'b0;
                            int_taken = 1'b0;
                            mret_exec = 1'b0;
                        end
                    endcase
                  end
                endcase
            end
            WRITEBACK: begin  // Used for completing LOAD instructions
                if (intr) begin
                    next_state = INTERRUPT; 
                end else begin    
                    next_state = FETCH;     
                end
                PCWrite = 1'b1;  // Update PC as part of write-back
                regWrite = 1'b1; // Write the loaded data to the register file
                memRDEN2 = 1'b0; 
            end
            INTERRUPT: begin // Handles external interrupts
                int_taken = 1'b1; // Signal that an interrupt is being serviced
                csr_we = 1'b1;    // Enable CSR write (for saving PC and status)
                PCWrite = 1'b1;   // Update PC to jump to the interrupt vector
                next_state = FETCH; // After interrupt handling, return to FETCH
            end
        endcase
    end
endmodule
