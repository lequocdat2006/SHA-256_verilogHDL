module sha256_padding (
    input  wire         clk,
    input  wire         rst_n,

    input  wire         msg_start,
    input  wire [7:0]   in_data,
    input  wire         in_valid,
    input  wire         msg_end,
    output wire         in_ready,

    output reg  [511:0] out_block,
    output reg          out_valid,
    input  wire         out_ready,
    output reg          out_last,

    output wire         busy
);

    localparam [1:0]
        S_IDLE  = 2'd0,
        S_RECV  = 2'd1,
        S_SEND1 = 2'd2,
        S_SEND2 = 2'd3;

    reg [1:0] state;

    // Lưu dữ liệu hiện tại theo byte: buffer[0] là byte đầu, buffer[63] là byte cuối block
    reg [7:0] buffer [0:63];

    // Lưu block thứ 2 nếu cuối message cần 2 block padding
    reg [511:0] second_block_reg;

    reg [6:0]  byte_cnt;       // số byte hiện có trong buffer
    reg [63:0] total_bytes;    // tổng số byte của message gốc

    reg        need_second_block;
    reg        go_back_to_recv;

    wire [6:0]  bytes_after_take;
    wire [63:0] total_bytes_after_take;
    wire [63:0] bit_len_now;
    wire [63:0] bit_len_after_take;

    integer i;

    assign in_ready = (state == S_RECV);
    assign busy     = (state != S_IDLE);

    assign bytes_after_take       = byte_cnt + 7'd1;
    assign total_bytes_after_take = total_bytes + 64'd1;
    //Quy đổi về độ dài bit = byte x 8
    assign bit_len_now            = total_bytes << 3;
    assign bit_len_after_take     = total_bytes_after_take << 3;

    function [7:0] len_byte;
        input [63:0] bit_len;
        input integer idx;
        begin
            case (idx)
                0: len_byte = bit_len[63:56];
                1: len_byte = bit_len[55:48];
                2: len_byte = bit_len[47:40];
                3: len_byte = bit_len[39:32];
                4: len_byte = bit_len[31:24];
                5: len_byte = bit_len[23:16];
                6: len_byte = bit_len[15:8];
                7: len_byte = bit_len[7:0];
                default: len_byte = 8'h00;
            endcase
        end
    endfunction

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state             <= S_IDLE;
            byte_cnt          <= 7'd0;
            total_bytes       <= 64'd0;
            need_second_block <= 1'b0;
            go_back_to_recv   <= 1'b0;
            out_block         <= 512'd0;
            out_valid         <= 1'b0;
            out_last          <= 1'b0;
            second_block_reg  <= 512'd0;

            for (i = 0; i < 64; i = i + 1) begin
                buffer[i] <= 8'h00;
            end
        end 
        else begin
            case (state)

                // -------------------------------------------------
                // Chờ bắt đầu message mới
                // -------------------------------------------------
                S_IDLE: begin
                    out_valid         <= 1'b0;
                    out_last          <= 1'b0;
                    need_second_block <= 1'b0;
                    go_back_to_recv   <= 1'b0;
                    second_block_reg  <= 512'd0;

                    if (msg_start) begin
                        byte_cnt    <= 7'd0;
                        total_bytes <= 64'd0;
                        out_block   <= 512'd0;

                        for (i = 0; i < 64; i = i + 1) begin
                            buffer[i] <= 8'h00;
                        end

                        state <= S_RECV;
                    end
                end

                // -------------------------------------------------
                // Nhận dữ liệu
                // -------------------------------------------------
                S_RECV: begin
                    // Case: kết thúc message nhưng không có byte mới
                    // Dùng cho message rỗng hoặc kết thúc khi buffer còn dữ liệu
                    if (msg_end && !in_valid) begin
                        if (byte_cnt <= 7'd55) begin
                            // Chỉ cần 1 block cuối
                            //signal[start_bit -: width] - lấy khoảng bit từ bit_start đếm xuống đến cuối khoảng
                            for (i = 0; i < 64; i = i + 1) begin
                                if (i < byte_cnt)
                                    out_block[511 - i*8 -: 8] <= buffer[i];
                                else if (i == byte_cnt)
                                    out_block[511 - i*8 -: 8] <= 8'h80;
                                else if (i < 56)
                                    out_block[511 - i*8 -: 8] <= 8'h00;
                                else
                                    out_block[511 - i*8 -: 8] <= len_byte(bit_len_now, i-56);
                            end

                            out_valid         <= 1'b1;
                            out_last          <= 1'b1;
                            need_second_block <= 1'b0;
                        end else begin
                            // Cần 2 block cuối
                            for (i = 0; i < 64; i = i + 1) begin
                                if (i < byte_cnt)
                                    out_block[511 - i*8 -: 8] <= buffer[i];
                                else if (i == byte_cnt)
                                    out_block[511 - i*8 -: 8] <= 8'h80;
                                else
                                    out_block[511 - i*8 -: 8] <= 8'h00;
                            end

                            second_block_reg <= 512'd0;
                            for (i = 0; i < 64; i = i + 1) begin
                                if (i < 56)
                                    second_block_reg[511 - i*8 -: 8] <= 8'h00;
                                else
                                    second_block_reg[511 - i*8 -: 8] <= len_byte(bit_len_now, i-56);
                            end

                            out_valid         <= 1'b1;
                            out_last          <= 1'b0;
                            need_second_block <= 1'b1;
                        end

                        byte_cnt        <= 7'd0;
                        total_bytes     <= 64'd0;
                        go_back_to_recv <= 1'b0;
                        state           <= S_SEND1;
                    end

                    // Case: có byte mới
                    else if (in_valid) begin

                        // -----------------------------------------
                        // Byte hiện tại là byte cuối cùng của message
                        // -----------------------------------------
                        if (msg_end) begin

                            // Tròn đúng 64 byte
                            if (byte_cnt == 7'd63) begin
                                for (i = 0; i < 64; i = i + 1) begin
                                    if (i < 63)
                                        out_block[511 - i*8 -: 8] <= buffer[i];
                                    else
                                        out_block[511 - i*8 -: 8] <= in_data;
                                end

                                second_block_reg <= 512'd0;
                                for (i = 0; i < 64; i = i + 1) begin
                                    if (i == 0)
                                        second_block_reg[511 - i*8 -: 8] <= 8'h80;
                                    else if (i < 56)
                                        second_block_reg[511 - i*8 -: 8] <= 8'h00;
                                    else
                                        second_block_reg[511 - i*8 -: 8] <= len_byte(bit_len_after_take, i-56);
                                end

                                out_valid         <= 1'b1;
                                out_last          <= 1'b0;
                                need_second_block <= 1'b1;

                                byte_cnt        <= 7'd0;
                                total_bytes     <= 64'd0;
                                go_back_to_recv <= 1'b0;
                                state           <= S_SEND1;
                            end

                            // Còn đủ chỗ cho 0x80 + 8 byte length
                            else if (bytes_after_take <= 7'd55) begin
                                for (i = 0; i < 64; i = i + 1) begin
                                    if (i < byte_cnt)
                                        out_block[511 - i*8 -: 8] <= buffer[i];
                                    else if (i == byte_cnt)
                                        out_block[511 - i*8 -: 8] <= in_data;
                                    else if (i == bytes_after_take)
                                        out_block[511 - i*8 -: 8] <= 8'h80;
                                    else if (i < 56)
                                        out_block[511 - i*8 -: 8] <= 8'h00;
                                    else
                                        out_block[511 - i*8 -: 8] <= len_byte(bit_len_after_take, i-56);
                                end

                                out_valid         <= 1'b1;
                                out_last          <= 1'b1;
                                need_second_block <= 1'b0;

                                byte_cnt        <= 7'd0;
                                total_bytes     <= 64'd0;
                                go_back_to_recv <= 1'b0;
                                state           <= S_SEND1;
                            end

                            // Không đủ chỗ, phải tạo 2 block cuối
                            else begin
                                for (i = 0; i < 64; i = i + 1) begin
                                    if (i < byte_cnt)
                                        out_block[511 - i*8 -: 8] <= buffer[i];
                                    else if (i == byte_cnt)
                                        out_block[511 - i*8 -: 8] <= in_data;
                                    else if (i == bytes_after_take)
                                        out_block[511 - i*8 -: 8] <= 8'h80;
                                    else
                                        out_block[511 - i*8 -: 8] <= 8'h00;
                                end

                                second_block_reg <= 512'd0;
                                for (i = 0; i < 64; i = i + 1) begin
                                    if (i < 56)
                                        second_block_reg[511 - i*8 -: 8] <= 8'h00;
                                    else
                                        second_block_reg[511 - i*8 -: 8] <= len_byte(bit_len_after_take, i-56);
                                end

                                out_valid         <= 1'b1;
                                out_last          <= 1'b0;
                                need_second_block <= 1'b1;

                                byte_cnt        <= 7'd0;
                                total_bytes     <= 64'd0;
                                go_back_to_recv <= 1'b0;
                                state           <= S_SEND1;
                            end
                        end

                        // -----------------------------------------
                        // Chưa phải byte cuối
                        // -----------------------------------------
                        else begin
                            // Nếu byte này làm block vừa đủ 64 byte
                            if (byte_cnt == 7'd63) begin
                                for (i = 0; i < 64; i = i + 1) begin
                                    if (i < 63)
                                        out_block[511 - i*8 -: 8] <= buffer[i];
                                    else
                                        out_block[511 - i*8 -: 8] <= in_data;
                                end

                                out_valid         <= 1'b1;
                                out_last          <= 1'b0;
                                need_second_block <= 1'b0;

                                byte_cnt        <= 7'd0;
                                total_bytes     <= total_bytes_after_take;
                                go_back_to_recv <= 1'b1;
                                state           <= S_SEND1;
                            end
                            // Còn chỗ trong buffer, cứ ghi tiếp
                            else begin
                                buffer[byte_cnt] <= in_data;
                                byte_cnt         <= bytes_after_take;
                                total_bytes      <= total_bytes_after_take;
                            end
                        end
                    end
                end

                // -------------------------------------------------
                // Gửi block đầu tiên
                // -------------------------------------------------
                S_SEND1: begin
                    if (out_valid && out_ready) begin
                        if (need_second_block) begin
                            out_block         <= second_block_reg;
                            out_valid         <= 1'b1;
                            out_last          <= 1'b1;
                            need_second_block <= 1'b0;
                            state             <= S_SEND2;
                        end else begin
                            out_valid <= 1'b0;
                            out_last  <= 1'b0;

                            if (go_back_to_recv) begin
                                go_back_to_recv <= 1'b0;
                                state           <= S_RECV;
                            end else begin
                                state <= S_IDLE;
                            end
                        end
                    end
                end

                // -------------------------------------------------
                // Gửi block thứ hai nếu có
                // -------------------------------------------------
                S_SEND2: begin
                    if (out_valid && out_ready) begin
                        out_valid <= 1'b0;
                        out_last  <= 1'b0;
                        state     <= S_IDLE;
                    end
                end

                default: begin
                    state <= S_IDLE;
                end
            endcase
        end
    end

endmodule
