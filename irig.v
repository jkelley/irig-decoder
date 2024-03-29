//
// IRIG-B decoder for WR-LEN White Rabbit node
//
// Given a 10 MHz clock and unmodulated IRIG-B
// input, provides binary timestamp indicating
// the absolute time and a PPS signal.
//
// John Kelley
// WIPAC / Univ. of Wisconsin-Madison
// jkelley@icecube.wisc.edu
//
module irig(input         clk, // 10MHz GPS clock (can be async to IRIG-B stream)
            input         rst,
            input         irigb,
            output        pps,
            output [5:0]  ts_second,
            output [5:0]  ts_minute,
            output [4:0]  ts_hour,
            output [8:0]  ts_day,
            output [6:0]  ts_year,
            output [16:0] ts_sec_day,
            output [3:0]  state);
    
    wire                  irig_d0;
    wire                  irig_d1;
    wire                  irig_mark;
    wire                  pps_gate;
    wire [2:0]            ts_select;
    wire                  ts_finish;
    wire [4:0]            bit_idx;
    wire [1:0]            digit_idx;
    wire                  bit_value;
    wire [3:0]            state_o;

    // Decode the IRIG-B width-encoded bits
    // into data 0, data 1, and mark signals
    irig_width_decode id1(.clk(clk),
                          .rst(rst),
                          .irigb(irigb),
                          .irig_mark(irig_mark),
                          .irig_d0(irig_d0),
                          .irig_d1(irig_d1));

    // Lock onto and track the IRIG-B "states"
    // separated by mark signals.  Grab the BCD and binary
    // bit values and send them to the timestamp block.
    irig_state is1(.clk(clk),
                   .rst(rst),
                   .irig_d0(irig_d0),
                   .irig_d1(irig_d1),
                   .irig_mark(irig_mark),
                   .pps_gate(pps_gate),
                   .ts_select(ts_select),
                   .ts_finish(ts_finish),
                   .bit_idx(bit_idx),
                   .digit_idx(digit_idx),
                   .bit_value(bit_value),
                   .state_o(state_o));

    // From the BCD and binary bit values, generate
    // the timestamps of the previous whole second
    irig_timestamp it1(.clk(clk),
                       .rst(rst),
                       .bit_idx(bit_idx),
                       .digit_idx(digit_idx),
                       .bit_value(bit_value),
                       .ts_select(ts_select),
                       .ts_finish(ts_finish),
                       .ts_second(ts_second),
                       .ts_minute(ts_minute),
                       .ts_hour(ts_hour),
                       .ts_day(ts_day),
                       .ts_year(ts_year),
                       .ts_sec_day(ts_sec_day));

    // PPS signal is generated by gating the IRIG signal
    // during the start marker.  Technically this should be a
    // negedge-registered signal, but it is directly
    // generated from the change in the IRIG signal itself
    // so will be set up in time. 
    assign pps = irigb & pps_gate;

    // State debug output
    assign state = state_o;

endmodule


