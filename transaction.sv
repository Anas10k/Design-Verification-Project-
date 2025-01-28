class Transaction extends uvm_sequence_item;
  rand logic [1:0] command;
  rand logic [79:0] data_in;
  rand logic [7:0] compressed_in;
  rand logic [1:0] response;
  logic reset;
  logic [79:0] dictionaryMemory [0:255];
  logic [7:0] index;
  logic foundFlag;
  logic fullFlag;
  logic [7:0] compressed_out;
  logic [79:0] decompressed_out;
  logic [7:0] expected_compressed_out;
  logic [79:0] expected_decompressed_out;
  logic [1:0] expected_response;

  `uvm_object_utils_begin(Transaction)
    `uvm_field_int(command, UVM_ALL_ON)
    `uvm_field_int(data_in, UVM_ALL_ON)
    `uvm_field_int(compressed_in, UVM_ALL_ON)
    `uvm_field_int(response, UVM_ALL_ON)
    `uvm_field_int(reset, UVM_ALL_ON)
    `uvm_field_sarray_int(dictionaryMemory, UVM_ALL_ON)
    `uvm_field_int(index, UVM_ALL_ON)
    `uvm_field_int(foundFlag, UVM_ALL_ON)
    `uvm_field_int(fullFlag, UVM_ALL_ON)
    `uvm_field_int(compressed_out, UVM_ALL_ON)
    `uvm_field_int(decompressed_out, UVM_ALL_ON)
    `uvm_field_int(expected_compressed_out, UVM_ALL_ON)
    `uvm_field_int(expected_decompressed_out, UVM_ALL_ON)
    `uvm_field_int(expected_response, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "Transaction");
    super.new(name);
  endfunction

  // Include all possible command values
  constraint cmd_constr { command inside {2'b00, 2'b01, 2'b10, 2'b11}; }
endclass
