`include "Interface.sv"
`include "BaseTest.sv"
`include "Test.sv"
`include "ReferenceModel.sv"

module testbench;

  bit clk;ف
  bit reset;

  always #5 clk = ~clk;

  initial begin
    reset = 1;
    #5 reset = 0;
  end

  Interface intf(clk, reset);

  // DUT instance
  compression_decompression #(.DICTIONARY_DEPTH(256)) dut (
    .clk(intf.clk),
    .reset(intf.reset),
    .command(intf.command),
    .data_in(intf.data_in),
    .compressed_in(intf.compressed_in),
    .compressed_out(intf.compressed_out),
    .decompressed_out(intf.decompressed_out),
    .response(intf.response)
  );

  BaseTest test;
  
  initial begin
    uvm_config_db#(virtual Interface)::set(null, "*", "vif", intf);
    $dumpfile("dump.vcd");
    $dumpvars();
  end

  initial begin
    run_test();
  end

endmodule
