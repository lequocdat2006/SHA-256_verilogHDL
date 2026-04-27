`timescale 1ns / 1ps

module sha256_top_tb;

    // --- Tham s? và Tín hi?u ---
    parameter CLK_PERIOD = 10;
    parameter FILE_PATH  = "D:/ModelSim/Final_term/tb_input.txt";

    reg         clk, rst_n, in_valid, msg_start, msg_end;
    reg  [7:0]  in_data;
    wire        in_ready, done;
    wire [31:0] H0, H1, H2, H3, H4, H5, H6, H7;

    integer file_ptr, current_char, next_char;
    integer cycle_count = 0;

    // --- Kh?i t?o DUT ---
    sha256_top uut (
        .clk(clk), .rst_n(rst_n), .in_valid(in_valid), .in_data(in_data),
        .msg_start(msg_start), .msg_end(msg_end), .in_ready(in_ready),
        .H0(H0), .H1(H1), .H2(H2), .H3(H3), .H4(H4), .H5(H5), .H6(H6), .H7(H7),
        .done(done)
    );

    // --- T?o xung Clock ---
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // B? ??m chu k? ?? ??m b?o ch?y ít nh?t 300 cycles
    always @(posedge clk) cycle_count <= cycle_count + 1;

    // --- Lu?ng Stimulus chính ---
    initial begin
        // 1. Tr?ng thái m?c ??nh rst_n = 1
        rst_n     = 1'b1;
        in_valid  = 1'b0;
        in_data   = 8'h00;
        msg_start = 1'b0;
        msg_end   = 1'b0;

        // 2. Reset: T?t xu?ng 0 TR??C khi xung clock ??u tiên kích c?nh lên (t=5ns)
        #2 rst_n = 1'b0;
        #(CLK_PERIOD);     // Gi? reset 1 chu k?
        rst_n = 1'b1;
        
        #(CLK_PERIOD * 2); // Ch? 2 chu k? sau reset cho ?n ??nh

        // 3. M? file d? li?u
        file_ptr = $fopen(FILE_PATH, "r");
        if (file_ptr == 0) begin
            $display("ERROR: Khong the mo file tai: %s", FILE_PATH);
            $finish;
        end

        // ??c byte ??u tiên ?? chu?n b?
        current_char = $fgetc(file_ptr);

        if (current_char != -1) begin
            // 4. B?t msg_start lên 1 tr??c khi in_data có giá tr? 1 chu k?
            @(posedge clk);
            msg_start <= 1'b1;
            in_valid  <= 1'b0; // V?n là 0 theo ?úng yêu c?u
            
            // 5. B?t ??u truy?n d? li?u t? chu k? ti?p theo
            @(posedge clk);
            msg_start <= 1'b0;
            in_valid  <= 1'b1; // in_valid b?t t? byte ??u tiên

            while (current_char != -1) begin
                next_char = $fgetc(file_ptr);
                
                in_data <= current_char[7:0];

                // N?u là ký t? cu?i cùng thì b?t msg_end
                if (next_char == -1)
                    msg_end <= 1'b1;
                else
                    msg_end <= 1'b0;

                @(posedge clk);
                current_char = next_char;
            end
        end

        // 6. Sau khi truy?n ký t? cu?i cùng, t?t h?t tín hi?u
        in_valid  <= 1'b0;
        in_data   <= 8'h00;
        msg_end   <= 1'b0;
        $fclose(file_ptr);

        // 7. Ch? cho ??n khi xong ho?c ?? 300 chu k?
        wait(done || cycle_count >= 300);
        
        // ??m b?o ch?y t?i thi?u 300 chu k?
        while (cycle_count < 300) @(posedge clk);

        $display("Mo phong ket thuc tai chu ky: %d", cycle_count);
        $display("Ket qua Hash: %h%h%h%h%h%h%h%h", H0, H1, H2, H3, H4, H5, H6, H7);
        $finish;
    end

endmodule