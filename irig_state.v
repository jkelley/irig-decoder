module irig_state (
                   input            clk,
                   input            rst,
                   input            irig_d0,
                   input            irig_d1,
                   input            irig_mark,
                   output reg       pps_gate, 
                   output reg       ts_finish,
                   output reg [2:0] ts_select,
                   output reg [4:0] bit_idx,
                   output reg [1:0] digit_idx,
                   output reg       bit_value);

    // State machine states
    localparam ST_UNLOCKED = 4'd0,
      ST_PRELOCK  = 4'b1,
      ST_START    = 4'd2,
      ST_SECOND   = 4'd3,
      ST_MINUTE   = 4'd4,
      ST_HOUR     = 4'd5,
      ST_DAY      = 4'd6,
      ST_DAY2     = 4'd7,
      ST_YEAR     = 4'd8,
      ST_UNUSED1  = 4'd9,
      ST_UNUSED2  = 4'd10,
      ST_SEC_DAY  = 4'd11,
      ST_SEC_DAY2 = 4'd12;

    // Timestamp selection
    localparam TS_SELECT_SECOND = 3'd1,
      TS_SELECT_MINUTE = 3'd2,
      TS_SELECT_HOUR = 3'd3,
      TS_SELECT_DAY = 3'd4,
      TS_SELECT_YEAR = 3'd5,
      TS_SELECT_SEC_DAY = 3'd6;

    // Count of the IRIG bits within a state
    reg [3:0]                       irig_cnt;

    // PPS generation internal signal
    // Output is registered version
    reg                             pps_en;
    
    // Current and next state machine state
    reg [3:0]                       state, next_state;

    // Registers
    always @(posedge clk) begin
        if (rst) begin
            state <= ST_UNLOCKED;
            pps_gate <= 1'b0;
            irig_cnt <= 4'b0;
        end
        else begin
            state <= next_state;
            pps_gate <= pps_en;

            // Count the IRIG bits received between every MARK
            if (irig_mark)
              irig_cnt <= 4'b0;
            else 
              irig_cnt <= irig_cnt + (irig_d0 | irig_d1);
        end
    end

    // IRIG decoding state machine
    // FIX ME add checks that cause loss of lock
    always @(*) begin
        next_state = state;
        pps_en = 1'b0;
        ts_finish = 1'b0;
        ts_select = 3'b0;
          bit_idx = 4'b0;
          digit_idx = 2'b0;
          bit_value = 1'b0;
        case (state)
          ST_UNLOCKED: begin
              if (irig_mark)
                next_state = ST_PRELOCK;
          end
          ST_PRELOCK: begin
              if (irig_mark)
                next_state = ST_SECOND;
              else if (irig_d0 || irig_d1)
                next_state = ST_UNLOCKED;          
          end
          ST_START: begin              
              pps_en = 1'b1;
              if (irig_mark) begin
                  next_state = ST_SECOND;
              end
          end
          ST_SECOND: begin
              ts_select = TS_SELECT_SECOND;
              bit_idx = (irig_cnt > 4'd4) ? irig_cnt-4'd5 : irig_cnt;
              digit_idx = (irig_cnt > 4'd4) ? 2'b1 : 2'b0;
              bit_value = irig_d1 && !(irig_cnt == 4'd4);                

              if (irig_mark)
                next_state = ST_MINUTE;
          end
          ST_MINUTE: begin
              ts_select = TS_SELECT_MINUTE;
              bit_idx = (irig_cnt > 4'd4) ? irig_cnt-4'd5 : irig_cnt;
              digit_idx = (irig_cnt > 4'd4) ? 2'b1 : 2'b0;
              bit_value = irig_d1 && !(irig_cnt == 4'd4) && !(irig_cnt == 4'd8);

              if (irig_mark)
                next_state = ST_HOUR;
          end       
          ST_HOUR: begin
              ts_select = TS_SELECT_HOUR;
              bit_idx = (irig_cnt > 4'd4) ? irig_cnt-4'd5 : irig_cnt;
              digit_idx = (irig_cnt > 4'd4) ? 2'b1 : 2'b0;
              bit_value = irig_d1 && !(irig_cnt == 4'd4) && !(irig_cnt >= 4'd8);

              if (irig_mark)
                next_state = ST_DAY;
          end
          ST_DAY: begin
              ts_select = TS_SELECT_DAY;
              bit_idx = (irig_cnt > 4'd4) ? irig_cnt-4'd5 : irig_cnt;
              digit_idx = (irig_cnt > 4'd4) ? 2'd1 : 2'd0;
              bit_value = irig_d1 && !(irig_cnt == 4'd4);

              if (irig_mark)
                next_state = ST_DAY2;
          end
          ST_DAY2: begin
              ts_select = TS_SELECT_DAY;
              bit_idx = irig_cnt;
              digit_idx = 2'd2;
              bit_value = irig_d1 && !(irig_cnt > 4'd1);

              if (irig_mark)
                next_state = ST_YEAR;
          end
          ST_YEAR: begin
              ts_select = TS_SELECT_YEAR;
              bit_idx = (irig_cnt > 4'd4) ? irig_cnt-4'd5 : irig_cnt;
              digit_idx = (irig_cnt > 4'd4) ? 2'd1 : 2'd0;
              bit_value = irig_d1 && !(irig_cnt == 4'd4);

              if (irig_mark)
                next_state = ST_UNUSED1;
          end
          ST_UNUSED1: begin
              if (irig_mark)
                next_state = ST_UNUSED2;
          end
          ST_UNUSED2: begin
              if (irig_mark)
                next_state = ST_SEC_DAY;
          end
          ST_SEC_DAY: begin
              ts_select = TS_SELECT_SEC_DAY;
              bit_idx = irig_cnt;
              bit_value = irig_d1;
              if (irig_mark)
                next_state = ST_SEC_DAY2;
          end
          ST_SEC_DAY2: begin
              ts_select = TS_SELECT_SEC_DAY;
              bit_idx = irig_cnt+5'd9;
              bit_value = irig_d1;
              if (irig_mark) begin
                  next_state = ST_START;
                  pps_en = 1'b1;
                  ts_finish = 1'b1;
              end
          end
        endcase
    end
    
endmodule
