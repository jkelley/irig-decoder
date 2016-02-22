# irig-decoder

A Verilog [IRIG-B](https://en.wikipedia.org/wiki/IRIG_timecode) decoder
intended for use with the WR-LEN [White
Rabbit](http://www.whiterabbitsolution.com/) timing node. 

Provided a 10 MHz clock and unmodulated (width-encoded) IRIG-B input, provides
binary timestamps indicating the absolute time and a PPS signal.

TO DO:
- Add timestamp validity output?  
- Enhance testbench with multiple seconds; add automatic output checking
- Add error checking in state machine (unlock/relock)
- Add PPS-only mode, possibly with autodetection
