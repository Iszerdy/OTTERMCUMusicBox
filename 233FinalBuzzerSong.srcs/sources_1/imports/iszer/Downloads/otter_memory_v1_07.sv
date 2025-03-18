`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: J. Callenes, P. Hummel
//
// Create Date: 01/27/2019 08:37:11 AM
// Module Name: OTTER_mem
// Project Name: Memory for OTTER RV32I RISC-V
// Tool Versions: Xilinx Vivado 2019.2
// Description: 64k Memory, dual access read single access write. Designed to
//              purposely utilize BRAM which requires synchronous reads and write
//              ADDR1 used for Program Memory Instruction. Word addressable so it
//              must be adapted from byte addresses in connection from PC
//              ADDR2 used for data access, both internal and external memory
//              mapped IO. ADDR2 is byte addressable.
//              RDEN1 and EDEN2 are read enables for ADDR1 and ADDR2. These are
//              needed due to synchronous reading
//              MEM_SIZE used to specify reads as byte (0), half (1), or word (2)
//              MEM_SIGN used to specify unsigned (1) vs signed (0) extension
//              IO_IN is data from external IO and synchronously buffered
//
// Memory OTTER_MEMORY (
//    .MEM_CLK   (),
//    .MEM_RDEN1 (),
//    .MEM_RDEN2 (),
//    .MEM_WE2   (),
//    .MEM_ADDR1 (),
//    .MEM_ADDR2 (),
//    .MEM_DIN2  (),
//    .MEM_SIZE  (),
//    .MEM_SIGN  (),
//    .IO_IN     (),
//    .IO_WR     (),
//    .MEM_DOUT1 (),
//    .MEM_DOUT2 ()  );
//
// Revision:
// Revision 0.01 - Original by J. Callenes
// Revision 1.02 - Rewrite to simplify logic by P. Hummel
// Revision 1.03 - changed signal names, added instantiation template
// Revision 1.04 - added defualt to write case statement
// Revision 1.05 - changed MEM_WD to MEM_DIN2, changed default to save nothing
// Revision 1.06 - removed typo in instantiation template
// Revision 1.07 - remove unused wordAddr1 signal
//
//////////////////////////////////////////////////////////////////////////////////
                                                                                                                             
  module Memory (
    input MEM_CLK,
    input MEM_RDEN1,   
    input MEM_RDEN2,   
    input MEM_WE2,         
    input [13:0] MEM_ADDR1, 
    input [31:0] MEM_ADDR2, 
    input [31:0] MEM_DIN2,  
    input [1:0] MEM_SIZE,  
    input MEM_SIGN,        
    input [31:0] IO_IN,    
    output logic IO_WR,    
    output logic [31:0] MEM_DOUT1,  
    output logic [31:0] MEM_DOUT2); 
    
    logic [13:0] wordAddr2;
    logic [31:0] memReadWord, ioBuffer, memReadSized;
    logic [1:0] byteOffset;
    logic weAddrValid;     
       
    (* rom_style="{distributed | block}" *)
    (* ram_decomp = "power" *) logic [31:0] memory [0:16383];
    
    initial begin
        $readmemh("Song.mem", memory, 0, 16383);
    end
    
    assign wordAddr2 = MEM_ADDR2[15:2];
    assign byteOffset = MEM_ADDR2[1:0];   

    always_ff @(posedge MEM_CLK) begin
      if(MEM_RDEN2)
        ioBuffer <= IO_IN;
    end
    always_ff @(posedge MEM_CLK) begin
    
      if (weAddrValid == 1) begin     
        case({MEM_SIZE,byteOffset})
            4'b0000: memory[wordAddr2][7:0]   <= MEM_DIN2[7:0];     
            4'b0001: memory[wordAddr2][15:8]  <= MEM_DIN2[7:0];
            4'b0010: memory[wordAddr2][23:16] <= MEM_DIN2[7:0];
            4'b0011: memory[wordAddr2][31:24] <= MEM_DIN2[7:0];
            4'b0100: memory[wordAddr2][15:0]  <= MEM_DIN2[15:0];    
            4'b0101: memory[wordAddr2][23:8]  <= MEM_DIN2[15:0];
            4'b0110: memory[wordAddr2][31:16] <= MEM_DIN2[15:0];
            4'b1000: memory[wordAddr2]        <= MEM_DIN2;        
        endcase
      end
      if (MEM_RDEN1)                       
        MEM_DOUT1 <= memory[MEM_ADDR1];

      if (MEM_RDEN2)                       
        memReadWord <= memory[wordAddr2];
    end
       
    always_comb begin
      case({MEM_SIGN,MEM_SIZE,byteOffset})
        5'b00011: memReadSized = {{24{memReadWord[31]}},memReadWord[31:24]};  
        5'b00010: memReadSized = {{24{memReadWord[23]}},memReadWord[23:16]};
        5'b00001: memReadSized = {{24{memReadWord[15]}},memReadWord[15:8]};
        5'b00000: memReadSized = {{24{memReadWord[7]}},memReadWord[7:0]};
                                    
        5'b00110: memReadSized = {{16{memReadWord[31]}},memReadWord[31:16]}; 
        5'b00101: memReadSized = {{16{memReadWord[23]}},memReadWord[23:8]};
        5'b00100: memReadSized = {{16{memReadWord[15]}},memReadWord[15:0]};
            
        5'b01000: memReadSized = memReadWord;           
        5'b10011: memReadSized = {24'd0,memReadWord[31:24]};    
        5'b10010: memReadSized = {24'd0,memReadWord[23:16]};
        5'b10001: memReadSized = {24'd0,memReadWord[15:8]};
        5'b10000: memReadSized = {24'd0,memReadWord[7:0]};
               
        5'b10110: memReadSized = {16'd0,memReadWord[31:16]};   
        5'b10101: memReadSized = {16'd0,memReadWord[23:8]};
        5'b10100: memReadSized = {16'd0,memReadWord[15:0]};
            
        default:  memReadSized = 32'b0;    
      endcase
    end
     always_comb begin
      if(MEM_ADDR2 >= 32'h00010000) begin
        IO_WR = MEM_WE2; 
        MEM_DOUT2 = ioBuffer; 
        weAddrValid = 0;               
      end
      else begin
        IO_WR = 0;          
        MEM_DOUT2 = memReadSized;   
        weAddrValid = MEM_WE2;  
      end
    end    
 endmodule
