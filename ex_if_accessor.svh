

// data vector. [63:0] was chosen to support maximum footprint
typedef logic[63:0] l64_q_t[$];
// wr_n_rd or similar 1b vectors
typedef logic       l1_q_t[$];

`ifdef EX_USE_UVMO_ACCESSOR

// abstract accessor class
virtual class ex_if_accessor_base extends uvm_object;

   function new(input string name="ex_if_accessor_base");
      super.new(name);
   endfunction
`else

interface class ex_if_accessor_base;
   // returns the name of the class
   pure virtual function string get_name();
`endif
   // get cell_width function
   pure virtual function int get_ram_width_p();
   // get cell_count_log function
   pure virtual function int get_pu_count_p();

   // task which waits for a number of clock posedge
   pure virtual task posedge_clock(int unsigned a_period=1);
   // task which waits for posedge of reset
   pure virtual task posedge_reset();
   // task which waits for negedge of reset
   pure virtual task negedge_reset();

   // task which sets the data_out signal
   pure virtual task set_wr_data(l64_q_t data);
   // function which gets the data_out signal
   pure virtual function l64_q_t get_wr_data();

   // task which sets the write_enable signal
   pure virtual task set_wr_n_rd(l1_q_t write_enable);
   // function which gets the write_enable signal
   pure virtual function l1_q_t get_wr_n_rd();

endclass

`ifdef EX_USE_UVMO_ACCESSOR
// implementation of the accessor class
class ex_if_accessor#(int RAM_WIDTH = 16, int PU_COUNT = 7) extends ex_if_accessor_base;
`else 
class ex_if_accessor#(int RAM_WIDTH = 16, int PU_COUNT = 7) implements ex_if_accessor_base;
   string m_name;
   
   virtual function string get_name();
      return m_name;
   endfunction 
   
`endif
   // instance of virtual interface
   virtual interface ex_if#(RAM_WIDTH, PU_COUNT) vif;

   // constructor
   function new(input string name="ex_if_accessor", input virtual interface ex_if#(RAM_WIDTH, PU_COUNT) a_vif);
      `ifdef EX_USE_UVMO_ACCESSOR
      super.new(name);
      `else 
      m_name=name;
      `endif
      vif = a_vif;
   endfunction

   /**
    * Returns RAM_WIDTH parameter
    * @return RAM_WIDTH parameter 
    */ 
   virtual function int get_ram_width_p();
      return RAM_WIDTH;
   endfunction

   /**
    * Returns PU_COUNT parameter
    * @return PU_COUNT parameter 
    */
   virtual function int get_pu_count_p();
      return PU_COUNT;
   endfunction

   // task which waits for a number of clock posedge
   virtual task posedge_clock(int unsigned a_period=1);
      repeat(a_period)@(posedge vif.clk);
   endtask

   // task which waits for posedge of reset
   virtual task posedge_reset();
      @(posedge vif.rst);
   endtask

   // task which waits for negedge of reset
   virtual task negedge_reset();
      @(negedge vif.rst);
   endtask

   /**
    * This task sets the wr_data signal
    * @param data - the value of wr_data signal 
    */
   virtual task set_wr_data(l64_q_t data);
      `ifdef EX_USE_SIGNAL_ARRAY
      foreach(data[idx])
         vif.wr_data[idx] <= data[idx][RAM_WIDTH-1:0];
      `else
      logic[(PU_COUNT*RAM_WIDTH-1):0] adata = 0;
      foreach(data[idx])
         adata[(((idx+1)*RAM_WIDTH)-1)-:RAM_WIDTH] = data[idx][RAM_WIDTH-1:0];
      vif.wr_data <= adata;
      `endif
   endtask
   
   /**
    * This function returns the wr_data signal 
    * @return This function returns the wr_data signal 
    */
   virtual function l64_q_t get_wr_data();
      logic[63:0] get_data_result[] = new[PU_COUNT];
      foreach(get_data_result[idx])
         `ifdef EX_USE_SIGNAL_ARRAY
            get_data_result[idx] = vif.wr_data[idx];
         `else
            get_data_result[idx] = vif.wr_data[(((idx+1)*RAM_WIDTH)-1)-:RAM_WIDTH];
         `endif
      return get_data_result;
   endfunction

   /**
    * 
    * @param write_enable -  
    */
   virtual task set_wr_n_rd(l1_q_t write_enable);
      `ifdef EX_USE_SIGNAL_ARRAY
      foreach(write_enable[idx])
         vif.wr_n_rd[idx] <= write_enable[idx];
      `else
      logic[PU_COUNT-1:0] adata = 0;
      foreach(write_enable[idx])
         adata[idx] = write_enable[idx];
      vif.wr_n_rd <= adata;
      `endif
   endtask

   // function which gets the write_enable signal
   virtual function l1_q_t get_wr_n_rd();
      logic get_valid_result[] = new[PU_COUNT];
      foreach(get_valid_result[idx])
         `ifdef EX_USE_SIGNAL_ARRAY
         get_valid_result[idx] = vif.wr_n_rd[idx];
         `else
         get_valid_result[idx] = vif.wr_n_rd[idx-:1];
         `endif
      return get_valid_result;
   endfunction

endclass
