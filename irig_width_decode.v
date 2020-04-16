module irig_width_decode (
                          input      clk,
                          input      irigb,
                          output reg irig_mark,
                          output reg irig_d0,
                          output reg irig_d1,
                          input      rst
                          );
    
    
    // 10MHz clock and 10kHz IRIG-B
    // Width encoding of the three states
    localparam CYCLES_ZERO = 17'd20000;
    localparam CYCLES_ONE  = 17'd50000;
    localparam CYCLES_MARK = 17'd80000;
    
    // Clock cycles in an IRIG bit
    reg [16:0]                       clk_cnt = 17'b0;
    reg                              irigb_last = 1'b0;
    
    always @(posedge clk) begin
        if (rst) begin
            clk_cnt <= 17'b0;
            irigb_last = 1'b0;
            irig_d0 <= 1'b0;
            irig_d1 <= 1'b0;
            irig_mark <= 1'b0;
        end else begin
            // Check widths at irig falling edge and produce one-cycle pulse
            irig_mark <= (clk_cnt >= CYCLES_MARK) && !irigb && irigb_last && !irig_mark;
            irig_d1   <= (clk_cnt >= CYCLES_ONE) && (clk_cnt < CYCLES_MARK) && !irigb && irigb_last && !irig_d1;
            irig_d0   <= (clk_cnt >= CYCLES_ZERO) && (clk_cnt < CYCLES_ONE) && !irigb && irigb_last && !irig_d0;
            
            // Reset count on rising edge of irig bit
            if (irigb && !irigb_last)
              clk_cnt <= 17'b0;
            else
              clk_cnt <= clk_cnt+17'b1;
            irigb_last <= irigb;
        end
    end
    
endmodule
