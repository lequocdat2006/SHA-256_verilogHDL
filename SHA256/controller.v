module controller (
    input  wire clk,
    input  wire rst_n,

    input  wire pad_valid,
    input  wire block_last,
    input  wire round_last,

    output reg  pad_ready,
    output reg  latch_block,
    output reg  load_working,
    output reg  ms_load,
    output reg  ms_advance,
    output reg  round_en,
    output reg  ff_en,
    output reg  done
);

    localparam [2:0]
        S_WAIT_BLOCK = 3'd0,
        S_LOAD_BLOCK = 3'd1,
        S_ROUND      = 3'd2,
        S_FEED       = 3'd3,
        S_DONE       = 3'd4;

    reg [2:0] state;
    reg [2:0] state_next;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= S_WAIT_BLOCK;
        else
            state <= state_next;
    end

    always @(*) begin
        pad_ready    = 1'b0;
        latch_block  = 1'b0;
        load_working = 1'b0;
        ms_load      = 1'b0;
        ms_advance   = 1'b0;
        round_en     = 1'b0;
        ff_en        = 1'b0;
        done         = 1'b0;
        state_next   = state;

        case (state)
            S_WAIT_BLOCK: begin
                pad_ready = 1'b1;
                if (pad_valid) begin
                    latch_block = 1'b1;
                    state_next  = S_LOAD_BLOCK;
                end
            end

            S_LOAD_BLOCK: begin
                load_working = 1'b1;
                ms_load      = 1'b1;
                state_next   = S_ROUND;
            end

            S_ROUND: begin
                round_en = 1'b1;
                if (!round_last)
                    ms_advance = 1'b1;

                if (round_last)
                    state_next = S_FEED;
            end

            S_FEED: begin
                ff_en = 1'b1;
                if (block_last)
                    state_next = S_DONE;
                else
                    state_next = S_WAIT_BLOCK;
            end

            S_DONE: begin
                done       = 1'b1;
                state_next = S_WAIT_BLOCK;
            end

            default: begin
                state_next = S_WAIT_BLOCK;
            end
        endcase
    end

endmodule
