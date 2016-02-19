module irig(input clk_10mhz,
			input         irigb,
            output        pps,
            output [8:0]  ts_day,
            output [6:0]  ts_year,
            output [16:0] ts_sec_day,
            input         rst);
    
    wire           irig_d0, irig_d1, irig_mark;

    irig_width_decode id(.clk(clk_10mhz),
                         .irigb(irigb),
                         .irig_mark(irig_mark),
                         .irig_d0(irig_d0),
                         .irig_d1(irig_d1),
                         .rst(rst));
    
    irig_timestamp it(.clk(clk_10mhz),
                      .irig_d0(irig_d0),
                      .irig_d1(irig_d1),
                      .irig_mark(irig_mark),
                      .pps(pps),
                      .ts_day(ts_day),
                      .ts_year(ts_year),
                      .ts_sec_day(ts_sec_day),
                      .rst(rst));
   
endmodule

            
