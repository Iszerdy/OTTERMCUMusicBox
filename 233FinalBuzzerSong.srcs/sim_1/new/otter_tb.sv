`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/12/2025 10:06:58 AM
// Design Name: 
// Module Name: otter_tb
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
module tb_otter;
    // Testbench signals
    reg         CLK;
    reg         BTNL;
    reg         BTNC;
    reg  [15:0] SWITCHES;
    wire [15:0] LEDS;
    wire [7:0]  CATHODES;
    wire [3:0]  ANODES;
    wire        SPEAKER;
    
    // Instantiate the modified OTTER top-level with speaker I/O
    OTTER_Wrapper uut (
        .CLK(CLK),
        .BTNL(BTNL),
        .BTNC(BTNC),
        .SWITCHES(SWITCHES),
        .LEDS(LEDS),
        .CATHODES(CATHODES),
        .ANODES(ANODES),
        .SPEAKER(SPEAKER)
    );
    
    // Clock generation: 10 ns period (100 MHz)
    initial begin
       CLK = 0;
       forever #5 CLK = ~CLK;
    end
    
    // Stimulus: release reset, then after a short delay, press BTNL.
initial begin
   // Assert reset (BTNC) for the first 20 ns
   BTNC = 1;
   #20;
   BTNC = 0;
   BTNL     = 0;
   SWITCHES = 16'h0000;
   
   // Wait a bit then simulate button press etc.
   #100;
   BTNL = 1;
   #200000;
   BTNL = 0;
   SWITCHES = 16'h0000;
   
   // Let simulation run long enough to see the LED and speaker activity
   #1000000;
   SWITCHES = 16'h0001;
   # 10000;
   BTNL = 1;
   # 20000;
   BTNL = 0;
   #10000000
   SWITCHES = 16'h0002;
   #1000;
   BTNL = 1;
   # 20000;
   BTNL = 0;
   #1000000;
end

    
    // Monitor BTNL and Speaker output
    initial begin
       $monitor("Time: %0t | BTNL: %b | Speaker: %b", $time, BTNL, SPEAKER);
    end
endmodule