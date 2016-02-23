module bcd_decoder (
                    input [2:0]      bcd_bit_idx ,
                    input [1:0]      bcd_digit_idx ,
                    input            bcd_bit,
                    output [8:0] value);

    // Combinatorial BCD decoder
    //   bcd_bit_idx: index of binary bit in the BCD digit
    //   bcd_digit_idx: index of digit (i.e. power of 10)
    
    reg [6:0]                    bcd_multiplier;
    
    always @(*) begin
        case (bcd_digit_idx)
          2'd0:
            bcd_multiplier = 7'd1;
          2'd1:
            bcd_multiplier = 7'd10;
          2'd2:
            bcd_multiplier = 7'd100;
          default:
            bcd_multiplier = 7'd0;
          endcase
    end

    assign value = (bcd_bit << bcd_bit_idx) * bcd_multiplier;

endmodule
