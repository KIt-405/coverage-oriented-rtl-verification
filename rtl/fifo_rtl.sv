module fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 16
)(
    input  logic                    clk,
    input  logic                    rst_n,
    input  logic                    wr_en,
    input  logic                    rd_en,
    input  logic [DATA_WIDTH-1:0]   data_in,
    output logic [DATA_WIDTH-1:0]   data_out,
    output logic                    full,
    output logic                    empty,
    output logic [$clog2(DEPTH):0]  room_avail
);

    logic [DATA_WIDTH-1:0] mem [DEPTH];
    
    logic [$clog2(DEPTH)-1:0] wr_ptr;
    logic [$clog2(DEPTH)-1:0] rd_ptr;
    logic [$clog2(DEPTH):0]   count;

    assign empty = (count == 0);
    assign full  = (count == DEPTH);
    assign room_avail = DEPTH - count;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr   <= '0;
            rd_ptr   <= '0;
            count    <= '0;
            data_out <= '0;
        end else begin
            case ({wr_en && !full, rd_en && !empty})
                2'b10: begin 
                    mem[wr_ptr] <= data_in;
                    wr_ptr      <= wr_ptr + 1;
                    count       <= count + 1;
                end
                2'b01: begin
                    data_out    <= mem[rd_ptr];
                    rd_ptr      <= rd_ptr + 1;
                    count       <= count - 1;
                end
                2'b11: begin 
                    mem[wr_ptr] <= data_in;
                    data_out    <= mem[rd_ptr];
                    wr_ptr      <= wr_ptr + 1;
                    rd_ptr      <= rd_ptr + 1;
                end
                default: ; 
            endcase
        end
    end

endmodule
