
interface ex_if #(
      int RAM_WIDTH = 16
      , int PU_COUNT = 7
   )(input clk
      , input rst);

`ifdef EX_USE_SIGNAL_ARRAY
   //  wr_data bus signal 
   logic[RAM_WIDTH-1:0] wr_data[PU_COUNT];
   
   //  wr_n_rd bus signal
   logic                               wr_n_rd[PU_COUNT];
`else

   //  wr_data bus signal 
   logic[((PU_COUNT * RAM_WIDTH)-1):0] wr_data;
   
   //  wr_n_rd bus signal
   logic[(PU_COUNT - 1):0]             wr_n_rd;
`endif 
   
   
endinterface
