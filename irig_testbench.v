`timescale 1 ns / 100 ps

module irig_testbench();
    
    localparam MARK = 3'b100;
    localparam D1 = 3'b010;
    localparam D0 = 3'b001;

    // Inputs to the DUT
    reg clk_10mhz;
    reg rst;
    reg irigb;
 
    // Output of the DUT
    wire pps;    
    wire [5:0] ts_second;
    wire [5:0] ts_minute;
    wire [4:0] ts_hour;
    wire [8:0] ts_day;
    wire [6:0] ts_year;
    wire [16:0] ts_sec_day;
    
    // Instantiate the DUT
    irig i1(.clk_10mhz(clk_10mhz),
            .rst(rst),
            .irigb(irigb),
            .pps(pps),
            .ts_second(ts_second),
            .ts_minute(ts_minute),
            .ts_hour(ts_hour),
            .ts_day(ts_day),
            .ts_year(ts_year),
            .ts_sec_day(ts_sec_day));
            
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
        irig_bit(MARK);
        irig_bit(D1);
        irig_bit(D0);

        // End of second
        irig_bit(MARK);

        // Now send a full stream
        irig_timestamp();

        // Start of next one...
        irig_bit(MARK);

        $stop;
    end

    always
      #50 clk_10mhz = ~clk_10mhz;

    // Send a full timestamp
    task irig_timestamp;        
        begin
            // Frame identifier
            irig_bit(MARK); // 00

            // Seconds: 42 = 100_0010
            // only 8 bits here
            irig_bitstream(9'bx10000010);

            // Minutes: 59 = _101_1001
            irig_bit(MARK); // 09
            irig_bitstream(9'b010101001);
            
            // Hours: 17 = __01_0111
            irig_bit(MARK); // 19
            irig_bitstream(9'b000100111);

            // Day of year 293 (93) = 1001_0011 
            irig_bit(MARK); // 29
            irig_bitstream(9'b100100011);

            // Day of year 293 (2) = _______10
            // Tenth of seconds unused
            irig_bit(MARK); // 39
            irig_bitstream(9'b000000010);

            // Year 16 = 0001_0110
            irig_bit(MARK); // 49
            irig_bitstream(9'b000100110);

            // Unused
            irig_bit(MARK); // 59
            irig_bitstream(9'b0);
            irig_bit(MARK); // 69
            irig_bitstream(9'b0);

            // Seconds in day
            // 17:59:42 = 64782 = _01111110100001110
            irig_bit(MARK); // 79
            irig_bitstream(9'b100001110);
            irig_bit(MARK); // 89
            irig_bitstream(9'b001111110);
            irig_bit(MARK); // 99            
          end
    endtask // irig_timestamp

    // Send a stream of IRIG bits
    // 'x' means skip completely FIX ME?
    task irig_bitstream;
        input [8:0] s;
        begin
        repeat (9) 
          begin
            case (s[0])
              1'b1:
                irig_bit(D0);
              1'b0:
                irig_bit(D1);
            endcase // case (s[0])
            s = s >> 1'b1;
          end 
        end
    endtask
              
    // Send a single width-encoded bit
    task irig_bit;
        input [2:0] ib; // mark, 1, 0
        begin
            @(posedge clk_10mhz);
            irigb = 1'b1;
            case (ib)
              D0: 
                begin
                    #2000500 irigb = 1'b0;
                    #7999500;
                end
              D1:
                begin
                    #5000500 irigb = 1'b0;
                    #4999500;
                end
              MARK:
                begin 
                    #8000500 irigb = 1'b0;
                    #2999500;
                end
            endcase            
        end
    endtask

endmodule
