module irig(input clk_10mhz,
            input  irig,
            output pps,
            intput reset);
    
    wire           irig_d0, irig_d1, irig_mark;
    
    irig_width_decode id(.clk(clk_10mhz),
                         .irig(irig),
                         .irig_mark(irig_mark),
                         .irig_d0(irig_d0),
                         .irig_d1(irig_d1),
                         .reset(reset));
    
    irig_timestamp it(.clk(clk_10mhz),
                      .irig_d0(irig_d0),
                      .irig_d1(irig_d1),
                      .irig_mark(irig_mark),
                      .pps(pps),
                      .reset(reset));
   
endmodule

            
