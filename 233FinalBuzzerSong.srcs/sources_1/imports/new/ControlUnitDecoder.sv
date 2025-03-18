`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/22/2025 01:07:58 PM
// Design Name: 
// Module Name: ControlUnitDecoder
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
module ControlUnitDecoder(
    input  logic       br_eq, br_lt, br_ltu,    // branch conditions
    input  logic [6:0] opcode,                  // instruction opcode
    input  logic       func7,                   // function bit for R-type
    input  logic [2:0] func3,                   // function field for immediate and CSR
    input  logic       int_taken,               // interrupt active flag
    output logic [3:0] alu_fun,                 // ALU operation select
    output logic [1:0] alu_srcA,                // ALU source A select
    output logic [2:0] alu_srcB,                // ALU source B select
    output logic [2:0] PCSource,                // Next PC source select
    output logic [1:0] rf_wr_sel                // Register file write select
);

    // RISC-V opcode definitions
    localparam [6:0] LUI    = 7'b0110111;  // load upper immediate
    localparam [6:0] AUIPC  = 7'b0010111;  // add upper immediate to PC
    localparam [6:0] JAL    = 7'b1101111;  // jump and link
    localparam [6:0] JALR   = 7'b1100111;  // jump and link register
    localparam [6:0] LOAD   = 7'b0000011;  // load from memory
    localparam [6:0] OP_IMM = 7'b0010011;  // immediate ALU operations
    localparam [6:0] BRANCH = 7'b1100011;  // conditional branch
    localparam [6:0] STORE  = 7'b0100011;  // store to memory
    localparam [6:0] RTYPE  = 7'b0110011;  // register ALU operations
    localparam [6:0] SYS    = 7'b1110011;  // system instructions (CSR and mret)

    always_comb begin
        alu_fun   = 4'b0000;      // default ALU function
        alu_srcA  = 2'b00;        // default ALU source A
        alu_srcB  = 3'b000;       // default ALU source B
        PCSource  = 3'b000;       // default next PC select
        rf_wr_sel = 2'b00;        // default write select

        if (int_taken) begin
            PCSource = 3'b100;    // jump to mtvec when interrupt active
        end 
        else begin
            case (opcode)
                LUI: begin // 0110111
                    alu_fun   = 4'b1001;   // LUI-copy operation
                    alu_srcA  = 2'b01;     // use immediate value
                    PCSource  = 3'b000;    // PC+4 path
                    rf_wr_sel = 2'b11;     // write ALU result
                end

                AUIPC: begin // 0010111
                    alu_fun   = 4'b0000;   // add operation
                    PCSource  = 3'b000;    // PC+4 path
                    alu_srcA  = 2'b01;     // use immediate value
                    alu_srcB  = 3'b011;    // add immediate to PC
                    rf_wr_sel = 2'b11;     // write result
                end

                JAL: begin // 1101111
                    PCSource  = 3'b011;    // jump target for JAL
                    rf_wr_sel = 2'b00;     // write return address
                end

                JALR: begin // 1100111  
                    PCSource  = 3'b001;    // jump target for JALR
                    rf_wr_sel = 2'b00;     // write return address
                end

                LOAD: begin // 0000011
                    alu_srcA  = 2'b00;     // use base register
                    alu_srcB  = 3'b001;    // use immediate offset
                    alu_fun   = 4'b0000;   // add for address calc
                    PCSource  = 3'b000;    // PC+4 path
                    rf_wr_sel = 2'b10;     // select memory data
                end

                OP_IMM: begin // 0010011
                    alu_srcA  = 2'b00;     // use register value
                    alu_srcB  = 3'b001;    // use immediate value
                    PCSource  = 3'b000;    // PC+4 path
                    rf_wr_sel = 2'b11;     // write ALU result
                    case (func3)
                        3'b000: alu_fun = 4'b0000; // ADDI
                        3'b010: alu_fun = 4'b0010; // SLTI
                        3'b011: alu_fun = 4'b0011; // SLTIU
                        3'b100: alu_fun = 4'b0100; // XORI
                        3'b110: alu_fun = 4'b0110; // ORI
                        3'b111: alu_fun = 4'b0111; // ANDI
                        3'b001: alu_fun = 4'b0001; // SLLI
                        3'b101: begin
                            if (func7)
                                alu_fun = 4'b1101; // SRAI
                            else
                                alu_fun = 4'b0101; // SRLI
                        end
                        default: alu_fun = 4'b0000; // default ADDI
                    endcase
                end

                RTYPE: begin // 0110011
                    alu_srcA  = 2'b00;     // use register value
                    alu_srcB  = 3'b000;    // use register value
                    rf_wr_sel = 2'b11;     // write ALU result
                    PCSource  = 3'b000;    // PC+4 path
                    case (func3)
                        3'b000: begin
                            if (func7)
                                alu_fun = 4'b1000; // SUB
                            else
                                alu_fun = 4'b0000; // ADD
                        end
                        3'b001: alu_fun = 4'b0001; // SLL
                        3'b010: alu_fun = 4'b0010; // SLT
                        3'b011: alu_fun = 4'b0011; // SLTU
                        3'b100: alu_fun = 4'b0100; // XOR
                        3'b101: begin
                            if (func7)
                                alu_fun = 4'b1101; // SRA
                            else
                                alu_fun = 4'b0101; // SRL
                        end
                        3'b110: alu_fun = 4'b0110; // OR
                        3'b111: alu_fun = 4'b0111; // AND
                        default: alu_fun = 4'b0000; // default ADD
                    endcase
                end

                BRANCH: begin // 1100011
                    case (func3)
                        3'b000: if (br_eq)   PCSource = 3'b010; // BEQ
                        3'b001: if (!br_eq)  PCSource = 3'b010; // BNE
                        3'b100: if (br_lt)   PCSource = 3'b010; // BLT
                        3'b101: if (!br_lt)  PCSource = 3'b010; // BGE
                        3'b110: if (br_ltu)  PCSource = 3'b010; // BLTU
                        3'b111: if (!br_ltu) PCSource = 3'b010; // BGEU
                        default: PCSource = 3'b000;
                    endcase
                    rf_wr_sel = 2'b00;    // no write for branch
                end

                STORE: begin // 0100011
                    alu_srcA = 2'b00;     // use base register
                    alu_srcB = 3'b010;    // use immediate offset
                    alu_fun  = 4'b0000;   // add for address calc
                    PCSource = 3'b000;    // PC+4 path
                end

                SYS: begin // 1110011
                    case (func3)
                        3'b001: begin   // csrrw
                            alu_fun   = 4'b1001; // use lui-copy for CSR
                            alu_srcA  = 2'b00;   // select rs1 value
                            PCSource  = 3'b000;  // PC+4 path
                            rf_wr_sel = 2'b01;   // write CSR read value
                        end
                        3'b010: begin   // csrrs
                            alu_fun   = 4'b0110; // OR for CSR set
                            alu_srcA  = 2'b00;   // use rs1
                            alu_srcB  = 3'b100;  // select CSR value
                            PCSource  = 3'b000;  // PC+4 path
                            rf_wr_sel = 2'b01;   // write CSR read value
                        end
                        3'b011: begin   // csrrc
                            alu_fun   = 4'b0111; // AND for CSR clear
                            alu_srcA  = 2'b10;   // use inverted rs1
                            alu_srcB  = 3'b100;  // select CSR value
                            PCSource  = 3'b000;  // PC+4 path
                            rf_wr_sel = 2'b01;   // write CSR read value
                        end
                        3'b000: begin   // mret
                            PCSource  = 3'b101; // load mepc value
                            rf_wr_sel = 2'b00;  // do not write register
                        end
                        default: begin  
                            alu_fun   = 4'b0000; 
                            alu_srcA  = 2'b00;
                            alu_srcB  = 3'b000;
                            PCSource  = 3'b000;
                            rf_wr_sel = 2'b00;
                        end
                    endcase
                end

                default: begin
                    PCSource  = 3'b000;
                    alu_srcA  = 2'b00;
                    alu_srcB  = 3'b000;
                    rf_wr_sel = 2'b00;
                    alu_fun   = 4'b0000;
                end
            endcase
        end
    end
endmodule

