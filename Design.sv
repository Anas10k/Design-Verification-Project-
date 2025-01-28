
module compression_decompression #(
  //Parameters
    parameter DICTIONARY_DEPTH = 256
) (
    // Input Ports
    input logic        clk,
    input logic        reset,
    input logic [ 1:0] command,
    input logic [79:0] data_in,       // 80 bit Input Data to be compressed
    input logic [ 7:0] compressed_in, // 8 bit Input Data to be decompressed

    // Output Ports
    output logic [ 7:0] compressed_out,    // 8 Output Output compressed data
    output logic [79:0] decompressed_out,
    output logic [ 1:0] response           // the status of the output
);


  logic [79:0] dictionary_memory[DICTIONARY_DEPTH-1:0];  // chip’s internal memory
  logic [31:0] index_reg;
  bit data_in_found;
  int data_index;
  int first_empty_index;


  always @(posedge clk or posedge reset) begin

    first_empty_index = find_first_empty();  // temp variable so we use blocking.

    // Either we reset the design.
    if (reset == 1) begin
      foreach (dictionary_memory[i]) dictionary_memory[i] <= 0;
      index_reg <= 0;
      compressed_out <= 0;
      decompressed_out <= 0;
      response <= 0;
      data_in_found <= 0;

      // Or we check if there is data in the dictionary_memory.
    end else begin
      data_in_found = 0;  // Initialize to 0 before the loop
      data_index = 0;     // Initialize data_index
      for (int i = 0; i < DICTIONARY_DEPTH; i++) begin
        if (dictionary_memory[i] == data_in) begin
          data_in_found = 1;
          data_index = i;  // Store the index of the found element
          break;
        end
      end

      case (command)
        2'b00:  /*No operation*/ 
        begin
          response <= 2'b00;
        end
        2'b01:  /*Compression*/ 
        begin
          if (data_in_found == 1) begin
            compressed_out <= data_index;
            response <= 2'b01;
          end else begin
            if (index_reg == DICTIONARY_DEPTH) begin
              response <= 2'b11;
            end else begin
              dictionary_memory[first_empty_index] <= data_in;
              compressed_out <= first_empty_index;
              index_reg <= index_reg + 1;
              response <= 2'b01;
            end
          end
        end
        2'b10:  /*Decompression*/ 
        begin
          if (compressed_in <= first_empty_index) begin
            decompressed_out <= dictionary_memory[compressed_in];
            response <= 2'b10;
          end else response <= 2'b11;
        end
        2'b11:  /*Invalid command, report an error*/
        response <= 2'b11;  // error

      endcase

    end
  end

  // Function to find the index of the first empty element
  function int find_first_empty;
    for (int i = 0; i < DICTIONARY_DEPTH; i++) begin
      if (dictionary_memory[i] == 0) begin
        return i;
      end
    end
    // If no empty element is found, return -1
    return -1;
  endfunction
endmodule
