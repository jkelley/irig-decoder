module irig_width_decode (
	                      input      clk,
	                      input      irig,
	                      output reg irig_mark,
	                      output reg irig_d0,
	                      output reg irig_d1,
	                      input      reset
                          );
    
    
    // 10MHz clock and 10kHz IRIG-B
    // Width encoding of the three states
    localparam CYCLES_ZERO = 17'd20000;
    localparam CYCLES_ONE  = 17'd50000;
    localparam CYCLES_MARK = 17'd80000;
    
    // Clock cycles in an IRIG bit
    reg [16:0]                       clk_cnt = 17'b0;
    reg                              irig_last = 1'b0;
    
    always @(posedge clk) begin
	    if (reset) begin
		    clk_cnt <= 17'b0;
		    irig_last = 1'b0;
		    irig_d0 <= 1'b0;
		    irig_d1 <= 1'b0;
		    irig_mark <= 1'b0;
	    end else begin
		    // Check widths at irig falling edge and produce one-cycle pulse
		    irig_mark <= (clk_cnt >= CYCLES_MARK) && !irig && irig_last && !irig_mark;
		    irig_d0   <= (clk_cnt >= CYCLES_ONE)  && !irig && irig_last && !irig_d0;
		    irig_d1   <= (clk_cnt >= CYCLES_ZERO) && !irig && irig_last && !irig_d1;
		    
		    // Reset count on rising edge of irig bit
		    if (irig && !irig_last)
			  clk_cnt <= 17'b0;
		    else
			  clk_cnt <= clk_cnt+1;
		    irig_last <= irig;
	    end
    end
    
endmodule
