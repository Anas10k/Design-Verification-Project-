class Monitor extends uvm_monitor;

  `uvm_component_utils(Monitor)

  virtual Interface vif;
  Transaction trans_collected;
  uvm_analysis_port #(Transaction) item_collected_port;

  covergroup cg_trans;
    option.per_instance = 1;

    cp_command: coverpoint trans_collected.command;
    cp_data_in: coverpoint trans_collected.data_in;
    cp_compressed_in: coverpoint trans_collected.compressed_in;
    cp_compressed_out: coverpoint trans_collected.compressed_out;
    cp_decompressed_out: coverpoint trans_collected.decompressed_out;
    cp_response: coverpoint trans_collected.response;

    // Add additional coverpoints for edge cases
    cp_data_in_edge: coverpoint trans_collected.data_in { bins max_value = {80'hFFFFFFFFFFFFFFFFFFFF}; }
    cp_compressed_in_edge: coverpoint trans_collected.compressed_in { bins min_value = {8'h0}; }

    cross_command_data_in: cross trans_collected.command, trans_collected.data_in;
    cross_compression: cross trans_collected.command, trans_collected.compressed_out, trans_collected.response;
    cross_decompression: cross trans_collected.command, trans_collected.decompressed_out, trans_collected.response;
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    trans_collected = Transaction::type_id::create("trans_collected");
    item_collected_port = new("item_collected_port", this);
    cg_trans = new();
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual Interface)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", {"virtual interface must be set for: ", get_full_name(), ".vif"});
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      @(posedge vif.clk);
      wait(vif.command != 2'b00);

      // Capture the transaction information
      trans_collected.command = vif.command;
      trans_collected.data_in = vif.data_in;
      trans_collected.compressed_in = vif.compressed_in;

      if (vif.command == 2'b01) begin // Compression operation
        @(posedge vif.clk);
        trans_collected.compressed_out = vif.compressed_out;
        trans_collected.response = vif.response; // Capture response
      end else if (vif.command == 2'b10) begin // Decompression operation
        @(posedge vif.clk);
        trans_collected.decompressed_out = vif.decompressed_out;
        trans_collected.response = vif.response; // Capture response
      end

      // Sample the covergroup
      cg_trans.sample();

      // Display coverage information
      $display("Coverage = %0.2f%%", cg_trans.get_inst_coverage());

      // Send the collected transaction to the analysis port
      item_collected_port.write(trans_collected);
    end 
  endtask : run_phase

endclass : Monitor
