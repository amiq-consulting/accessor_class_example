

class ex_bus_agent extends uvm_component;
   `uvm_component_utils(ex_bus_agent)

   // accessor class handle
   ex_if_accessor_base vif;
   
   // a flag to make the distinction between driver and monitor
   bit is_driver;
   
   // command type
   typedef enum {READ=0, WRITE=1, OTHER} ex_op_type;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction


   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (is_driver)
         EX_VIF_WR_ACCESSOR_ERR: assert(uvm_config_db#(ex_if_accessor_base)::get(null, "", "vif_wr_accessor", vif)) else
         `uvm_error("EX_VIF_WR_ACCESSOR_ERR", "Couldn't find vif_wr_accessor!")
      else
         EX_VIF_RD_ACCESSOR_ERR: assert(uvm_config_db#(ex_if_accessor_base)::get(null, "", "vif_rd_accessor", vif)) else
         `uvm_error("EX_VIF_RD_ACCESSOR_ERR", "Couldn't find vif_rd_accessor!")
   endfunction


   task run_phase(uvm_phase phase);
      super.run_phase(phase);
      fork
         if (!is_driver) monitor();
         if (is_driver) drive();
      join_none
   endtask

   // the driving task
   task drive();
      integer nof_cells = vif.get_pu_count_p();
      integer dly;
      l1_q_t wr_en_1, wr_en_0;
      l64_q_t data;
      for(integer i = 0; i < nof_cells; i++) begin
         wr_en_1.push_back(1);
         wr_en_0.push_back(0);
      end
      vif.set_wr_n_rd(wr_en_0);
      vif.posedge_reset();
      vif.negedge_reset();
      forever begin
         void'(std::randomize(dly) with { dly inside {[0:10]}; });
         vif.posedge_clock(dly);
         void'(std::randomize(data) with {data.size() == nof_cells; foreach(data[idx]) data[idx] != 0; } );
         vif.set_wr_data(data);
         vif.set_wr_n_rd(wr_en_1);
         print_data(data);
         vif.posedge_clock(1);
         vif.set_wr_n_rd(wr_en_0);
      end
   endtask

   // the monitoring task
   task monitor();
      l64_q_t data;
      l1_q_t wnr;
      vif.posedge_reset();
      vif.negedge_reset();
      forever begin
         vif.posedge_clock(1);
         wnr=vif.get_wr_n_rd();
         case (operation_kind(wnr))
            WRITE: begin
               check_wnr_consistency(wnr, 1);
               data = vif.get_wr_data();
               print_data(data);
            end
            READ : begin
               check_wnr_consistency(wnr, 0);
            end
            default : ;
         endcase
      end
   endtask



   /**
    * Searches for a 1 in the wnr vector
    * @param wnr - the wnr collected from the bus
    * @return returns operation type
    */
   function ex_op_type operation_kind(l1_q_t wnr);
      operation_kind = OTHER;
      foreach(wnr[idx]) begin
         if (wnr[idx] === 0) begin
            operation_kind = READ;
            break;
         end
         if (wnr[idx] === 1) begin
            operation_kind = WRITE;
            break;
         end
      end
   endfunction

   /**
    * Checks if wnr vector is consistent: if there is a 1/0 checks that all vector elements are 1/0
    * @param wnr - the wnr collected from the bus
    */
   function void check_wnr_consistency(l1_q_t wnr, logic val);
      foreach(wnr[idx]) begin
         EX_WNR_CONSISTENCY_ERR: assert (wnr[idx] === val) else
            `uvm_error("EX_WNR_CONSISTENCY_ERR", $sformatf("Element %d of the vector is not %x!", idx, val))
      end
   endfunction

   /**
    * 
    * @param data - data retrieved from the bus 
    */
   function void print_data(l64_q_t data);
      string message="Data is: ";
      foreach(data[idx])
         message=$sformatf("%s %x", message, data[idx]);
      `uvm_info(get_name(), message, UVM_LOW)
   endfunction

endclass
