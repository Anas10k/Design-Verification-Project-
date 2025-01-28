class Test extends BaseTest;

  `uvm_component_utils(Test)
  
  Seq seq;
  Environment env;

  function new(string name = "Test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    seq = Seq::type_id::create("seq");// Create  sequence
    if (!$cast(env, super.testEnv)) begin
      `uvm_fatal("CAST_FAIL", "Failed to cast env to type Environment")
    end
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    seq.start(env.agent.sequencer);
    phase.drop_objection(this);
    phase.phase_done.set_drain_time(this, 50);
  endtask : run_phase

endclass : Test