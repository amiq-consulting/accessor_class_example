

//`include "ex_if.sv"

package ex_pkg;
   
   `include "uvm_macros.svh"
   import uvm_pkg::*;
   
   // definition of the accessor class
   `include "ex_if_accessor.svh"
   
   // definition of the bus agent
   `include "ex_bus_agent.svh"
   
   // definition of a simple test
   `include "ex_test.svh"
   
endpackage  
