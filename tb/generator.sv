class generator #(parameter DATA_WIDTH = 8);
    transaction #(DATA_WIDTH) trans; 
    mailbox gen2drv;
    event   drv_done;
    int     loop_count;

    function new(mailbox gen2drv, event drv_done, int loop_count = 1000);
        this.gen2drv    = gen2drv;
        this.drv_done   = drv_done;
        this.loop_count = loop_count; 
    endfunction

    task main();
        repeat (loop_count) begin
            trans = new();
            if (!trans.randomize()) $fatal("[GEN_FATAL] Randomization failed!");
            gen2drv.put(trans);
            @(drv_done); 
        end
    endtask
endclass
