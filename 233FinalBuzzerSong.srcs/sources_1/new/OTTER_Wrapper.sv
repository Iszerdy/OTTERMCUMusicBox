`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: J. Calllenes
//           P. Hummel
//
// Create Date: 01/20/2019 10:36:50 AM
// Module Name: OTTER_Wrapper
// Target Devices: OTTER MCU on Basys3
// Description: OTTER_WRAPPER with Switches, LEDs, and 7-segment display
//
// Revision:
// Revision 0.01 - File Created
// Revision 0.02 - Updated MMIO Addresses, signal names
/////////////////////////////////////////////////////////////////////////////

module OTTER_Wrapper(
   input CLK,
   input BTNL,
   input BTNC,
   input [15:0] SWITCHES,
   output logic [15:0] LEDS,
   output [7:0] CATHODES,
   output [3:0] ANODES,
   output SPEAKER
   );
       
    localparam SWITCHES_AD = 32'h11000000;
    localparam LEDS_AD    = 32'h11000020; 
    localparam SSEG_AD    = 32'h11000040;
    localparam SPEAKER_AD  = 32'h11000060;

   logic clk_50 = 0;
    
   logic [31:0] IOBUS_out, IOBUS_in, IOBUS_addr;
   logic s_reset, IOBUS_wr;
   logic [15:0] r_SSEG;
   
   logic intr_signal;
   logic [7:0]  speaker_note;
    

   debounce_one_shot db_inst(
      .CLK(clk_50),
      .BTN(BTNL),
      .DB_BTN(intr_signal)
    );
   OTTERMCU CPU (.RST(s_reset), .INTR(intr_signal), .CLK(clk_50),
                   .IOBUS_IN(IOBUS_in), .IOBUS_WR(IOBUS_wr), .IOBUS_OUT(IOBUS_out),
                  .IOBUS_ADDR(IOBUS_addr));

   SevSegDisp SSG_DISP (.DATA_IN(r_SSEG), .CLK(clk_50), .MODE(1'b0),
                       .CATHODES(CATHODES), .ANODES(ANODES));
   
   always_ff @(posedge CLK) begin
       clk_50 <= ~clk_50;
   end

   assign s_reset = BTNC;
    
   SpeakerDriver spkr (
         .Note(speaker_note),
         .CLK(clk_50),
         .SPEAKER(SPEAKER)
    );
   

   always_comb begin
        case(IOBUS_addr)
            SWITCHES_AD: IOBUS_in = {16'b0,SWITCHES};
            default:     IOBUS_in = 32'b0;    
        endcase
    end
   
    always_ff @ (posedge clk_50) begin
        if(IOBUS_wr)
            case(IOBUS_addr)
                LEDS_AD: LEDS   <= IOBUS_out[15:0];
                SSEG_AD: r_SSEG <= IOBUS_out[15:0];
                SPEAKER_AD:  speaker_note <= IOBUS_out[7:0];
            endcase
    end
endmodule
