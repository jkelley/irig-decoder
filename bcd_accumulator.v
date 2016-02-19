module bcd_accumulator (
                    input [2:0]      bcd_bit_idx ,
                    input [1:0]      bcd_digit_idx ,
                    input            bcd_bit,
                    input [4:0]      ts_select,
                    input            clk,
                    input            accum_rst,
                    output reg [5:0] ts_second,
                    output reg [5:0] ts_minute,
                    output reg [4:0] ts_hour,
                    output reg [8:0] ts_day,
                    output reg [6:0] ts_year);

    // Timestamp selection for BCD decoding
    localparam TS_SELECT_SECOND = 5'b00001,
      TS_SELECT_MINUTE = 5'b00010,
      TS_SELECT_HOUR = 5'b00100,
      TS_SELECT_DAY = 5'b01000,
      TS_SELECT_YEAR = 5'b10000;

    // Decode the BCD bit into a value
    wire [8:0]                        value;

    bcd_decoder bd1(.bcd_bit_idx(bcd_bit_idx),
                    .bcd_digit_idx(bcd_digit_idx),
                    .bcd_bit(bcd_bit),
                    .value(value));

    always @(posedge clk) begin
        if (accum_rst) begin
            ts_second <= 6'b0;
            ts_minute <= 6'b0;
            ts_hour <= 5'b0;
            ts_day <= 9'b0;
            ts_year <= 7'b0;
        end
        else begin
            // Mux the decoded output into the correct timestamp
            // and accumulate the sum
            case (ts_select)
              TS_SELECT_SECOND:
                ts_second <= ts_second + value;
              TS_SELECT_MINUTE:
                ts_minute <= ts_minute + value;
              TS_SELECT_HOUR:
                ts_hour <= ts_hour + value;
              TS_SELECT_DAY:
                ts_day <= ts_day + value;
              TS_SELECT_YEAR:
                ts_year <= ts_year + value;
            endcase
        end
    end
    
endmodule
