

class ex_test extends uvm_test;
   `uvm_component_utils(ex_test)
   
   ex_bus_agent driver;
   ex_bus_agent monitor;

   function new (string name, uvm_component parent);
      super.new(name,parent);
   endfunction

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      
      driver = new("driver", this);
      driver.is_driver = 1;
      
      monitor = new("monitor", this);
      monitor.is_driver = 0;
   endfunction

   task run_phase(uvm_phase phase);
      super.run_phase(phase);
      // run some time and stop   
      phase.raise_objection(this);
      #1us;
      phase.drop_objection(this);
   endtask

endclass
