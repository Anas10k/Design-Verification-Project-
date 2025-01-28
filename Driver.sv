class Driver extends uvm_driver#(Transaction);
  `uvm_component_utils(Driver)
  
  virtual Interface vif;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual Interface)::get(this, "", "vif", vif))
       `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction: build_phase
  
  task run_phase(uvm_phase phase);
    Transaction req;
    forever begin
      seq_item_port.get_next_item(req);
      // Drive the DUT with the data from the sequence item
      vif.command <= req.command;
      vif.data_in <= req.data_in;
      vif.compressed_in <= req.compressed_in;
      @(posedge vif.clk);
      // Complete the item after one cycle
      seq_item_port.item_done();
    end
  endtask : run_phase
endclass : Driver
