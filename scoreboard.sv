class Scoreboard extends uvm_scoreboard;

    virtual Interface intf;
    
    Transaction pkt_qu[$];
    uvm_analysis_imp#(Transaction, Scoreboard) item_collected_export;
    `uvm_component_utils(Scoreboard)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        item_collected_export = new("item_collected_export", this);
        
        if (!uvm_config_db#(virtual Interface)::get(this, "", "vif", intf)) begin
            `uvm_fatal("NO_VIF", "Virtual interface not found in configuration database")
        end
    endfunction : build_phase
    
    virtual function void write(Transaction pkt);
        pkt_qu.push_back(pkt);
    endfunction : write
    
    task reference_model(input Transaction pkt,
                          output logic [7:0] compressed_out,
                          output logic [79:0] decompressed_out,
                          output logic [1:0] response);
        static logic [79:0] dictionaryMemory [0:255];
        static logic [7:0] index = 0;
        static logic foundFlag = 1'b0;
        static logic fullFlag = 1'b0;
    
        if (pkt.command == 2'b00) begin
            for (int i = 0; i < 256; i = i + 1) begin
                dictionaryMemory[i] = 80'b0;
            end
            index = 8'd0;
            response = 2'b00; 
        end else if (pkt.command == 2'b01) begin
            foundFlag = 1'b0;
            for (int i = 0; i < index; i = i + 1) begin
                if (pkt.data_in == dictionaryMemory[i]) begin
                    compressed_out = i;
                    response = 2'b01; 
                    foundFlag = 1'b1;
                end
            end
            if (!foundFlag) begin
                if (index == 8'd255) begin
                    dictionaryMemory[index] = pkt.data_in;
                    compressed_out = index;
                    fullFlag = 1'b1;
                    response = 2'b01; 
                end else begin
                    dictionaryMemory[index] = pkt.data_in;
                    compressed_out = index;
                    index = index + 1;
                    response = 2'b01; 
                end
            end
        end else if (pkt.command == 2'b10) begin
            if (pkt.compressed_in <= index) begin
                decompressed_out = dictionaryMemory[pkt.compressed_in];
                if (decompressed_out == 80'hx)
                    response = 2'b11; 
                else
                    response = 2'b10; 
            end else begin
                response = 2'b11; 
            end
        end else begin
            response = 2'b11; 
        end
    endtask : reference_model
    
    virtual task run_phase(uvm_phase phase);
        Transaction comp_decomp_pkt;
        logic [7:0] compressed_out;
        logic [79:0] decompressed_out;
        logic [1:0] response;
    
        forever begin
            wait(pkt_qu.size() > 0);
            comp_decomp_pkt = pkt_qu.pop_front();
    
            reference_model(comp_decomp_pkt, compressed_out, decompressed_out, response);
    
            #1;
            
            if (comp_decomp_pkt.command == 2'b01) begin
                if (comp_decomp_pkt.compressed_out === compressed_out) begin
                    `uvm_info(get_type_name(), $sformatf("Compression Match: Expected: %0h, Actual: %0h", compressed_out, comp_decomp_pkt.compressed_out), UVM_LOW)
                end else begin
                    `uvm_error(get_type_name(), $sformatf("Compression Mismatch: Expected: %0h, Actual: %0h", compressed_out, comp_decomp_pkt.compressed_out))
                end
                if (comp_decomp_pkt.response === response) begin
                    `uvm_info(get_type_name(), $sformatf("Response Match: Expected: %0h, Actual: %0h", response, comp_decomp_pkt.response), UVM_LOW)
                end else begin
                    `uvm_error(get_type_name(), $sformatf("Response Mismatch: Expected: %0h, Actual: %0h", response, comp_decomp_pkt.response))
                end
            end
    
            if (comp_decomp_pkt.command == 2'b10) begin
                if (comp_decomp_pkt.decompressed_out === decompressed_out) begin
                    `uvm_info(get_type_name(), $sformatf("Decompression Match: Expected: %0h, Actual: %0h", decompressed_out, comp_decomp_pkt.decompressed_out), UVM_LOW)
                end else begin
                    `uvm_error(get_type_name(), $sformatf("Decompression Mismatch: Expected: %0h, Actual: %0h", decompressed_out, comp_decomp_pkt.decompressed_out))
                end
                if (comp_decomp_pkt.response === response) begin
                    `uvm_info(get_type_name(), $sformatf("Response Match: Expected: %0h, Actual: %0h", response, comp_decomp_pkt.response), UVM_LOW)
                end else begin
                    `uvm_error(get_type_name(), $sformatf("Response Mismatch: Expected: %0h, Actual: %0h", response, comp_decomp_pkt.response))
                end
            end
        end
    endtask : run_phase

endclass : Scoreboard
