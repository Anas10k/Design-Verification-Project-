`include "Agent.sv"
`include "Scoreboard.sv"
class Environment extends uvm_env;
  
  Agent      agent;
  Scoreboard scb; 
  
  `uvm_component_utils(Environment)
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    agent = Agent::type_id::create("agent", this);
    scb  = Scoreboard::type_id::create("scb", this); 
  endfunction : build_phase
  
  function void connect_phase(uvm_phase phase);
    agent.monitor.item_collected_port.connect(scb.item_collected_export);
  endfunction : connect_phase

endclass : Environment
