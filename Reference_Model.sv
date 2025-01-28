module ReferenceModel(
    input clk,
    input reset,
    input [1:0] command,
    input [79:0] data_in,
    input [7:0] compressed_in,
    output reg [7:0] compressed_out,
    output reg [79:0] decompressed_out,
    output reg [1:0] response
);

reg [79:0] dictionary_memory[255:0];
integer i;

initial begin
    for (i = 0; i < 256; i = i + 1) begin
        dictionary_memory[i] = 80'b0;
    end
end

reg [7:0] current_index = 0;

always @(posedge clk) begin
    if (reset) begin
        for (i = 0; i < 256; i = i + 1) begin
            dictionary_memory[i] = 80'b0;
        end
        current_index = 0;
        compressed_out = 0;
        decompressed_out = 0;
        response = 2'b00;
    end else begin
        case (command)
            2'b01: begin
                integer found = 0;
                for (i = 0; i <= current_index; i = i + 1) begin
                    if (data_in == dictionary_memory[i]) begin
                        compressed_out = i[7:0];
                        response = 2'b01;
                        found = 1;
                        break;
                    end
                end
                if (found == 0 && current_index < 255) begin
                    dictionary_memory[current_index] = data_in;
                    compressed_out = current_index;
                    current_index = current_index + 1;
                    response = 2'b01;
                end else if (found == 0) begin
                    response = 2'b11;
                end
            end
            2'b10: begin
                if (compressed_in <= current_index) begin
                    decompressed_out = dictionary_memory[compressed_in];
                    response = 2'b10;
                end else begin
                    response = 2'b11;
                end
            end
            default: begin
                response = 2'b11;
            end
        endcase
    end
end

endmodule
