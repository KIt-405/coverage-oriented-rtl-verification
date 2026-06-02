class scoreboard #(parameter DATA_WIDTH = 8, parameter DEPTH = 16);
    mailbox mon2scb;
    
    bit [DATA_WIDTH-1:0] ref_fifo[$]; 
    int match_count = 0;
    int error_count = 0;

    function new(mailbox mon2scb);
        this.mon2scb = mon2scb;
    endfunction

    task main();
        transaction #(DATA_WIDTH) trans;
        forever begin
            mon2scb.get(trans);
            
            // 1. Emulate & Verify Read Operations
            if (trans.rd_en && !(ref_fifo.size() == 0)) begin
                bit [DATA_WIDTH-1:0] expected_data;
                expected_data = ref_fifo.pop_front();
                
                if (trans.data_out === expected_data) begin
                    match_count++;
                end else begin
                    // Upgraded to $error for proper EDA logging tool tracking
                    $error("[SCB_ERROR] Data Mismatch! Expected: 0x%0h, Got: 0x%0h", expected_data, trans.data_out);
                    error_count++;
                end
            end

            // 2. Emulate Write Operations
            if (trans.wr_en && !(ref_fifo.size() == DEPTH)) begin
                ref_fifo.push_back(trans.data_in);
            end

            // 3. New Industry Check: Validate DUT Status Flags!
            if (trans.full !== (ref_fifo.size() == DEPTH)) begin
                $error("[SCB_ERROR] Full Flag Mismatch! Model Expected: %b, DUT Got: %b", (ref_fifo.size() == DEPTH), trans.full);
                error_count++;
            end

            if (trans.empty !== (ref_fifo.size() == 0)) begin
                $error("[SCB_ERROR] Empty Flag Mismatch! Model Expected: %b, DUT Got: %b", (ref_fifo.size() == 0), trans.empty);
                error_count++;
            end
        end
    endtask
endclass
