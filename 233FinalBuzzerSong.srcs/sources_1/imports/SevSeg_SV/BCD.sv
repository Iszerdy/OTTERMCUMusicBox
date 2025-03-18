`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Paul Hummel
//
// Module Name: BCD
// Target Devices: Used for displaying decimal on a 4 digit 7 segment display
// Description: Conversts a 16-bit value into 4 digit binary coded decimal
//              The full 16-bit range intput cannot be converted because the
//              output is limited to 4 digiets. Anything above 4 digiets gets
//              truncated so 12345 is output as 2345
//
// Revision:
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////


module BCD(
    input [15:0] HEX,
    output logic [3:0] THOUSANDS,
    output logic [3:0] HUNDREDS,
    output logic [3:0] TENS,
    output logic [3:0] ONES
    );
    
    int i;
 
    always_comb begin
        THOUSANDS = 4'h0; // default all digits to 0
        HUNDREDS = 4'h0;
        TENS = 4'h0;
        ONES = 4'h0;
        
        // iterate through each bit, starting with MSB (bit 15)
        for (i=15; i>=0; i=i-1) begin
            
            // check for place values of 5 or greater
            if (THOUSANDS >= 5)
                THOUSANDS = THOUSANDS + 3;
            if (HUNDREDS >= 5)
                HUNDREDS = HUNDREDS + 3;
            if (TENS >= 5)
                TENS = TENS + 3;
            if (ONES >= 5)
                ONES = ONES + 3;
            
            // shift bits to the left
            THOUSANDS = {THOUSANDS[2:0],HUNDREDS[3]};
            HUNDREDS = {HUNDREDS[2:0],TENS[3]};
            TENS = {TENS[2:0],ONES[3]};
            ONES = {ONES[2:0],HEX[i]};
       end
   end
      
endmodule
