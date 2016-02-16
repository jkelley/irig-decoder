`timescale 1 ns / 100 ps

module irig_testbench();
    
    localparam MARK = 3'b100;
    localparam D1 = 3'b010;
    localparam D0 = 3'b001;

    // Instantiate the DUT
    irig i1(.clk_10mhz(clk_10mhz),
            .irigb(irigb),
            .pps(pps),
            .rst(rst));
    
    // Inputs to the DUT
    reg clk_10mhz;
    reg rst;
    reg irig_b;
    
    // Output of the DUT
    wire pps;
    
    // Reset
    initial begin
        clk_10mhz = 1'b0;
        irigb = 1'b0;
        rst = 1'b1;
        
        // Reset goes low
        #120 rst = 1'b0;        
        #100;

        // Some garbage bits
        irig_bit(D0);
        irig_bit(D1);

        // End of second
        irig_bit(MARK);

        // Start of second
        irig_bit(MARK);

        // seconds
        irig_bit(D1);
        irig_bit(D1);
        irig_bit(D0);
        //...
        
        $stop;
end

always
  #100 clk_10mhz = ~clk_10mhz;

task irig_bit;
    input [2:0] ib; // mark, 1, 0
    begin
        @(posedge clk_10mhz);
        irigb = 1'b1;
        case (ib)
          D0:   #2000500 irigb = 1'b0;
          D1:   #5000500 irigb = 1'b0;
          MARK: #8000500 irigb = 1'b0;
        endcase            
    end

endmodule
