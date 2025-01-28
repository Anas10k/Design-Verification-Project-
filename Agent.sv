`include "transaction.sv"
`include "Sequencer.sv"
`include "Sequence.sv"
`include "Driver.sv"
`include "Monitor.sv"

class Agent extends uvm_agent;

  Driver    driver;
  Sequencer sequencer;
  Monitor   monitor;

  `uvm_component_utils(Agent)
  
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    monitor = Monitor::type_id::create("monitor", this);

    if(get_is_active() == UVM_ACTIVE) begin
      driver    = Driver::type_id::create("driver", this);
      sequencer = Sequencer::type_id::create("sequencer", this);
    end
  endfunction : build_phase
  
  function void connect_phase(uvm_phase phase);
    if(get_is_active() == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
  endfunction : connect_phase

endclass : Agent
