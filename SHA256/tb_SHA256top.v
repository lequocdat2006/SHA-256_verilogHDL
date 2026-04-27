`timescale 1ns / 1ps

module sha256_top_tb;

    // --- Tham số và Tín hiệu ---
    parameter CLK_PERIOD = 10;
    parameter FILE_PATH  = "D:/Vivado/SHA256/tb_input.txt";

    reg          clk, rst_n, in_valid, msg_start, msg_end;
    reg  [7:0]   in_data;
    wire         in_ready, done;
    wire [31:0] H0, H1, H2, H3, H4, H5, H6, H7;

    integer file_ptr, current_char, next_char;
    integer cycle_count = 0;

    // --- Khởi tạo DUT ---
    sha256_top uut (
        .clk(clk), .rst_n(rst_n), .in_valid(in_valid), .in_data(in_data),
        .msg_start(msg_start), .msg_end(msg_end), .in_ready(in_ready),
        .H0(H0), .H1(H1), .H2(H2), .H3(H3), .H4(H4), .H5(H5), .H6(H6), .H7(H7),
        .done(done)
    );

    // --- Tạo xung Clock ---
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Bộ đếm chu kỳ
    always @(posedge clk) cycle_count <= cycle_count + 1;

    // --- Luồng Stimulus chính ---
    initial begin
        // 1. Trạng thái mặc định
        rst_n     = 1'b1;
        in_valid  = 1'b0;
        in_data   = 8'h00;
        msg_start = 1'b0;
        msg_end   = 1'b0;

        // 2. Reset
        #2 rst_n = 1'b0;
        #(CLK_PERIOD);
        rst_n = 1'b1;
        #(CLK_PERIOD * 2);

        // 3. Mở file
        file_ptr = $fopen(FILE_PATH, "r");
        if (file_ptr == 0) begin
            $display("ERROR: Khong the mo file tai: %s", FILE_PATH);
            $finish;
        end

        current_char = $fgetc(file_ptr);

        if (current_char != -1) begin
            // 4. Bật msg_start
            @(posedge clk);
            msg_start <= 1'b1;
            in_valid  <= 1'b0;
            
            // 5. Truyền dữ liệu Handshaking
            @(posedge clk);
            msg_start <= 1'b0;
            in_valid  <= 1'b1; 

            while (current_char != -1) begin
                next_char = $fgetc(file_ptr);
                in_data <= current_char[7:0];
                msg_end <= (next_char == -1);

                @(posedge clk);
                
                // Chờ in_ready
                while (in_ready == 1'b0) begin
                    @(posedge clk);
                end

                current_char = next_char;
            end
        end // <--- BẠN THIẾU DÒNG NÀY (Đóng khối if (current_char != -1))

        // 6. Kết thúc truyền
        in_valid  <= 1'b0;
        in_data   <= 8'h00;
        msg_end   <= 1'b0;
        $fclose(file_ptr);

        // 7. Chờ đủ 500 chu kỳ
        wait(done || cycle_count >= 500);
        while (cycle_count < 500) @(posedge clk);

        $display("Mo phong ket thuc tai chu ky: %d", cycle_count);
        $display("Ket qua Hash: %h%h%h%h%h%h%h%h", H0, H1, H2, H3, H4, H5, H6, H7);
        $finish;
    end

endmodule