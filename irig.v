module irig(input clk_10mhz,
				input  irigb,
            output pps,
            input rst);
    
    wire           irig_d0, irig_d1, irig_mark;
    
    irig_width_decode id(.clk(clk_10mhz),
                         .irigb(irigb),
                         .irig_mark(irig_mark),
                         .irig_d0(irig_d0),
                         .irig_d1(irig_d1),
                         .rst(rst));
    
    irig_timestamp it(.clk(clk_10mhz),
                      .irigb(irigb),
                      .irig_d0(irig_d0),
                      .irig_d1(irig_d1),
                      .irig_mark(irig_mark),
                      .pps(pps),
                      .rst(rst));
   
endmodule

            
