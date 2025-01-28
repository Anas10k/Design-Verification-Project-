`include "Environment.sv" 

class BaseTest extends uvm_test;
  `uvm_component_utils(BaseTest)
  
  Environment testEnv;
  
  function new(string name = "BaseTest", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    testEnv = Environment::type_id::create("testEnv", this); 
    
  endfunction : build_phase

endclass : BaseTest
