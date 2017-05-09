
`timescale 1ns / 1ps

`ifndef EX_PU_COUNT
    `define EX_PU_COUNT 8
`endif

`ifndef EX_RAM_WIDTH
    `define EX_RAM_WIDTH 16
`endif
// next define selects if the abstract accessor class inherits uvm_object or is defined as a interface class
//`define EX_USE_UVMO_ACCESSOR

// next define selects if the parameterizable signals are defined as an array of signals or as a 1-dimensional logic vector
//`define EX_USE_SIGNAL_ARRAY

`include "ex_if.sv"
`include "ex_pkg.sv"

module ex_top();

   `include "uvm_macros.svh"
   import uvm_pkg::*;
   import ex_pkg::*;

   //  set clock
   reg clk;
   initial begin
      clk = 0;
      forever begin
         #5 clk <= ~clk;
      end
   end

   //  set reset
   reg rst;
   initial begin
      /** One initial reset */
      rst <= 0;
      @(posedge clk);
      rst <= 1;
      repeat(5) @(posedge clk);
      rst<=0;
   end

`ifdef EX_USE_SIGNAL_ARRAY
   wire[`EX_RAM_WIDTH-1:0] wr_data[`EX_PU_COUNT];
   wire                    wr_en[`EX_PU_COUNT];
`else
   wire[`EX_PU_COUNT*`EX_RAM_WIDTH-1:0] wr_data;
   wire[`EX_PU_COUNT-1:0] wr_en;
`endif

   // the interface used by driver agent
   ex_if#(.RAM_WIDTH(`EX_RAM_WIDTH), .PU_COUNT(`EX_PU_COUNT)) ex_if_wr_i (.clk(clk), .rst(rst));
   assign wr_data = ex_if_wr_i.wr_data;
   assign wr_en   = ex_if_wr_i.wr_n_rd;

   // the interface used by monitor agent
   ex_if#(.RAM_WIDTH(`EX_RAM_WIDTH), .PU_COUNT(`EX_PU_COUNT)) ex_if_rd_i (.clk(clk), .rst(rst));
   assign ex_if_rd_i.wr_data = wr_data;
   assign ex_if_rd_i.wr_n_rd = wr_en;

   initial begin
      // create the accessor class instance used by driver agent
      automatic ex_if_accessor#(.RAM_WIDTH(`EX_RAM_WIDTH), .PU_COUNT(`EX_PU_COUNT)) if_wr_accessor = new("ex_if_wr_accessor", ex_if_wr_i);
      // create the accessor class instance used by monitor agent
      automatic ex_if_accessor#(.RAM_WIDTH(`EX_RAM_WIDTH), .PU_COUNT(`EX_PU_COUNT)) if_rd_accessor = new("ex_if_rd_accessor", ex_if_rd_i);
      
      // pass the accessor class to the ve. notice the parameterization of uvm_config_db by the abstract accessor class 
      uvm_config_db#(ex_if_accessor_base)::set(null, "", "vif_wr_accessor", if_wr_accessor);
      uvm_config_db#(ex_if_accessor_base)::set(null, "", "vif_rd_accessor", if_rd_accessor);

      run_test("ex_test");
   end

endmodule
