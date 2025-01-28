interface Interface(input logic clk, reset);
  
  logic [1:0] command;
  logic [79:0] data_in;
  logic [7:0] compressed_in;
  logic [7:0] compressed_out;
  logic [79:0] decompressed_out;
  logic [1:0] response;
  logic [79:0] dictionaryMemory [0:255];
  logic [7:0] index;
  logic foundFlag;
  logic fullFlag;

  clocking driver @(posedge clk);
    default input #1 output #1;
    output command;
    output data_in;
    output compressed_in;
    input  compressed_out;
    input  decompressed_out;
    input response;
    output dictionaryMemory;
    output index;
    output foundFlag;
    output fullFlag;
  endclocking
  
  modport DRIVER  (clocking driver, input clk, reset);
    
  clocking monitor @(posedge clk);
    default input #1 output #1;
    input command;
    input data_in;
    input compressed_in;
    input compressed_out;
    input decompressed_out;
    input response;
    input dictionaryMemory;
    input index;
    input foundFlag;
    input fullFlag;
  endclocking
  
  modport MONITOR (clocking monitor, input clk, reset);
  
endinterface
