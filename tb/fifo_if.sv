interface fifo_if #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 16
) (input logic clk);

    logic                  rst_n;
    logic                  wr_en;
    logic                  rd_en;
    logic [DATA_WIDTH-1:0] data_in;
    logic [DATA_WIDTH-1:0] data_out;
    logic                  full;
    logic                  empty;
    logic [$clog2(DEPTH):0] room_avail; 

    property p_no_overflow;
        @(posedge clk) disable iff (!rst_n)
        (full && wr_en) |-> ##1 (full);
    endproperty
    assert property (p_no_overflow) else $error("[SVA_ERROR] Overflow condition! Write attempted while FIFO is full.");


    property p_no_underflow;
        @(posedge clk) disable iff (!rst_n)
        (empty && rd_en) |-> ##1 (empty);
    endproperty
    assert property (p_no_underflow) else $error("[SVA_ERROR] Underflow condition! Read attempted while FIFO is empty.");


    property p_reset_state;
        @(posedge clk) $fell(rst_n) |=> (empty && !full && (room_avail == DEPTH));
    endproperty
    assert property (p_reset_state) else $error("[SVA_ERROR] Reset state failure. FIFO parameters did not clear.");

endinterface
