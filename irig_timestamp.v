module irig_timestamp(
                      input             clk,
                      input             rst,
                      input [2:0]       ts_select,
                      input             ts_finish,
                      input [4:0]       bit_idx ,
                      input [1:0]       digit_idx ,
                      input             bit_value,
                      output reg [5:0]  ts_second,
                      output reg [5:0]  ts_minute,
                      output reg [4:0]  ts_hour,
                      output reg [8:0]  ts_day,
                      output reg [6:0]  ts_year,
                      output reg [16:0] ts_sec_day);
        
    // Timestamp selection
    localparam TS_SELECT_SECOND = 3'd1,
      TS_SELECT_MINUTE = 3'd2,
      TS_SELECT_HOUR = 3'd3,
      TS_SELECT_DAY = 3'd4,
      TS_SELECT_YEAR = 3'd5,
      TS_SELECT_SEC_DAY = 3'd6;

    // Internal registers for accumulation
    reg [5:0]                           ts_second_int;
    reg [5:0]                           ts_minute_int;
    reg [4:0]                           ts_hour_int;
    reg [8:0]                           ts_day_int;
    reg [6:0]                           ts_year_int;
    reg [16:0]                          ts_sec_day_int;

    // Reset the internal accumulators once finished
    // and outputs are registered
    reg                                 ts_reset;
    
    // Decode the BCD bit into a value
    wire [8:0]                        value;

    bcd_decoder bd1(.bcd_bit_idx(bit_idx),
                    .bcd_digit_idx(digit_idx),
                    .bcd_bit(bit_value),
                    .value(value));

    always @(posedge clk) begin
        if (rst | ts_reset) begin
            if (rst) begin
                ts_second <= 6'b0;
                ts_minute <= 6'b0;
                ts_hour <= 5'b0;
                ts_day <= 9'b0;
                ts_year <= 7'b0;
                ts_sec_day <= 17'b0;
            end
            ts_second_int <= 6'b0;
            ts_minute_int <= 6'b0;
            ts_hour_int <= 5'b0;
            ts_day_int <= 9'b0;
            ts_year_int <= 7'b0;
            ts_sec_day_int <= 17'b0;
            ts_reset <= 1'b0;
        end
        else if (ts_finish & ~ts_reset) begin
            // Finished decoding -- transfer to output registers
            // and hold there until next second
            ts_second <= ts_second_int;
            ts_minute <= ts_minute_int;
            ts_hour <= ts_hour_int;
            ts_day <= ts_day_int;
            ts_year <= ts_year_int;
            ts_sec_day <= ts_sec_day_int;
            ts_reset <= 1'b1;
        end
        else begin
            // Mux the decoded output into the correct timestamp
            // and accumulate the sum
            case (ts_select)
              TS_SELECT_SECOND:
                ts_second_int <= ts_second_int + value[5:0];
              TS_SELECT_MINUTE:
                ts_minute_int <= ts_minute_int + value[5:0];
              TS_SELECT_HOUR:
                ts_hour_int <= ts_hour_int + value[4:0];
              TS_SELECT_DAY:
                ts_day_int <= ts_day_int + value;
              TS_SELECT_YEAR:
                ts_year_int <= ts_year_int + value[6:0];
              TS_SELECT_SEC_DAY:
                // This field is a normal binary stream
                ts_sec_day_int <= ts_sec_day_int | (bit_value << bit_idx);
            endcase
        end
    end
    
endmodule
