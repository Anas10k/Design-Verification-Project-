// Base sequence class
class Sequence extends uvm_sequence#(Transaction);
  
  `uvm_object_utils(Sequence)
  
  function new(string name = "Sequence");
    super.new(name);
  endfunction
  
  `uvm_declare_p_sequencer(Sequencer)
  
  virtual task body();
    repeat(10) begin
      Transaction req = Transaction::type_id::create("req");
      wait_for_grant();
      req.randomize();
      send_request(req);
      wait_for_item_done();
    end 
  endtask
endclass

// Compression sequence with diverse data_in constraint
class compression_sequence extends uvm_sequence#(Transaction);
  `uvm_object_utils(compression_sequence)
  
  function new(string name = "compression_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat (10) begin
      Transaction req = Transaction::type_id::create("req");
      `uvm_do_with(req, {
        req.command == 2'b01; 
        req.data_in inside {80'h0, 80'hFFFFFFFFFFFFFFFFFFFF, 80'h123456789ABCDEF01234, 80'hFEDCBA9876543210FEDC};
      })
      start_item(req);
      finish_item(req);
    end
  endtask
endclass

// Decompression sequence for testing invalid index
class decompression_sequence extends uvm_sequence#(Transaction);
  `uvm_object_utils(decompression_sequence)
  
  function new(string name = "decompression_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat (10) begin
      Transaction req = Transaction::type_id::create("req");
      `uvm_do_with(req, {
        req.command == 2'b10;
        req.compressed_in inside {8'h0, 8'hFF, 8'h2}; // Including invalid index FF
      })
      start_item(req);
      finish_item(req);
    end
  endtask
endclass

// Boundary condition sequence
class boundary_sequence extends uvm_sequence#(Transaction);
  `uvm_object_utils(boundary_sequence)

  function new(string name = "boundary_sequence");
    super.new(name);
  endfunction

  virtual task body();
    repeat (10) begin
      Transaction req = Transaction::type_id::create("req");
      `uvm_do_with(req, {
        req.command == 2'b01;
        req.data_in inside {80'h0, 80'hFFFFFFFFFFFFFFFFFFFF}; // Boundary values
      })
      start_item(req);
      finish_item(req);
    end
  endtask
endclass

// Invalid command sequence
class invalid_command_sequence extends uvm_sequence#(Transaction);
  `uvm_object_utils(invalid_command_sequence)

  function new(string name = "invalid_command_sequence");
    super.new(name);
  endfunction

  virtual task body();
    repeat (10) begin
      Transaction req = Transaction::type_id::create("req");
      `uvm_do_with(req, {
        req.command inside {2'b11}; // Invalid command
      })
      start_item(req);
      finish_item(req);
    end
  endtask
endclass

// Enhanced compression sequence with more diverse data_in values
class enhanced_compression_sequence extends uvm_sequence#(Transaction);
  `uvm_object_utils(enhanced_compression_sequence)

  function new(string name = "enhanced_compression_sequence");
    super.new(name);
  endfunction

  virtual task body();
    repeat (20) begin
      Transaction req = Transaction::type_id::create("req");
      `uvm_do_with(req, {
        req.command == 2'b01;
        req.data_in inside {80'h0, 80'hFFFFFFFFFFFFFFFFFFFF, 80'h123456789ABCDEF01234, 80'hFEDCBA9876543210FEDC, 
                            80'hAAAAAAAAAAAAAAAAAAAA, 80'h55555555555555555555};
      })
      start_item(req);
      finish_item(req);
    end
  endtask
endclass

// Mixed sequence with corrected constraints
class mixed_sequence extends uvm_sequence#(Transaction);
  `uvm_object_utils(mixed_sequence)

  function new(string name = "mixed_sequence");
    super.new(name);
  endfunction

  virtual task body();
    repeat (10) begin
      Transaction req = Transaction::type_id::create("req");
      `uvm_do_with(req, {
        req.command inside {2'b00, 2'b01, 2'b10, 2'b11};
        req.data_in inside {80'h0, 80'hFFFFFFFFFFFFFFFFFFFF, 80'h123456789ABCDEF01234, 80'hFEDCBA9876543210FEDC, 
                            80'hAAAAAAAAAAAAAAAAAAAA, 80'h55555555555555555555};
        req.compressed_in inside {8'h00, 8'hFF, 8'hAA, 8'h55};
      })
      start_item(req);
      finish_item(req);
    end
  endtask
endclass

// More complex sequence with diverse data_in values and commands
class complex_sequence extends uvm_sequence#(Transaction);
  `uvm_object_utils(complex_sequence)

  function new(string name = "complex_sequence");
    super.new(name);
  endfunction

  virtual task body();
    repeat (20) begin
      Transaction req = Transaction::type_id::create("req");
      `uvm_do_with(req, {
        req.command inside {2'b00, 2'b01, 2'b10, 2'b11};
        req.data_in inside {80'h0, 80'hFFFFFFFFFFFFFFFFFFFF, 80'h123456789ABCDEF01234, 80'hFEDCBA9876543210FEDC, 
                            80'hAAAAAAAAAAAAAAAAAAAA, 80'h55555555555555555555, 80'h00000000000000000001, 80'h80000000000000000000};
        req.compressed_in inside {8'h00, 8'hFF, 8'hAA, 8'h55, 8'h01, 8'h80};
      })
      start_item(req);
      finish_item(req);
    end
  endtask
endclass


// Combining sequence that uses compression and decompression
class Seq extends uvm_sequence#(Transaction);
  `uvm_object_utils(Seq)
   
  compression_sequence comp_seq1;
  compression_sequence comp_seq2;
  decompression_sequence decomp_seq1;
  boundary_sequence b_seq;
  invalid_command_sequence inv_cmd_seq;
  enhanced_compression_sequence enh_comp_seq;
  mixed_sequence mix_seq;
  complex_sequence comp_seq;

  function new(string name = "Seq");
    super.new(name);
  endfunction
  
  virtual task body();
    comp_seq1 = compression_sequence::type_id::create("comp_seq1");
    comp_seq2 = compression_sequence::type_id::create("comp_seq2");
    decomp_seq1 = decompression_sequence::type_id::create("decomp_seq1");
    b_seq = boundary_sequence::type_id::create("b_seq");
    inv_cmd_seq = invalid_command_sequence::type_id::create("inv_cmd_seq");
    enh_comp_seq = enhanced_compression_sequence::type_id::create("enh_comp_seq");
    mix_seq = mixed_sequence::type_id::create("mix_seq");
    comp_seq = complex_sequence::type_id::create("comp_seq");

    `uvm_do(comp_seq1);
    `uvm_do(comp_seq2);
    `uvm_do(decomp_seq1);
    `uvm_do(b_seq);
    `uvm_do(inv_cmd_seq);
    `uvm_do(enh_comp_seq);
    `uvm_do(mix_seq);
    `uvm_do(comp_seq);
  endtask
endclass
