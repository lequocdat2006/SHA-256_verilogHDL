`timescale 1ns/1ps

module sha256_tb;

    reg         clk;
    reg         rst_n;
    reg         in_valid;
    reg         msg_start;
    reg         msg_end;
    reg  [7:0]  in_data;

    wire        in_ready;
    wire [31:0] H0;
    wire [31:0] H1;
    wire [31:0] H2;
    wire [31:0] H3;
    wire [31:0] H4;
    wire [31:0] H5;
    wire [31:0] H6;
    wire [31:0] H7;
    wire        done;

    integer fd;
    integer ch;
    integer len;
    integer i;
    integer cycle;

    reg [7:0] msg_buf [0:1023];

    sha256_top uut (
        .clk(clk),
        .rst_n(rst_n),
        .in_valid(in_valid),
        .in_data(in_data),
        .msg_start(msg_start),
        .msg_end(msg_end),
        .in_ready(in_ready),
        .H0(H0),
        .H1(H1),
        .H2(H2),
        .H3(H3),
        .H4(H4),
        .H5(H5),
        .H6(H6),
        .H7(H7),
        .done(done)
    );

    always #5 clk = ~clk;

    task start_message;
    begin
        @(negedge clk);
        msg_start = 1'b1;
        in_valid  = 1'b0;
        msg_end   = 1'b0;
        in_data   = 8'h00;

        @(negedge clk);
        msg_start = 1'b0;
    end
    endtask

    task send_byte;
        input [7:0] data;
        input       is_last;
    begin
        while (in_ready !== 1'b1)
            @(negedge clk);

        in_valid = 1'b1;
        in_data  = data;
        msg_end  = is_last;

        @(negedge clk);
        in_valid = 1'b0;
        in_data  = 8'h00;
        msg_end  = 1'b0;
    end
    endtask

    initial begin
        clk       = 1'b0;
        rst_n     = 1'b0;
        in_valid  = 1'b0;
        msg_start = 1'b0;
        msg_end   = 1'b0;
        in_data   = 8'h00;
        len       = 0;

        #20;
        rst_n = 1'b1;

        fd = $fopen("tb_input.txt", "rb");
        if (fd == 0) begin
            $display("ERROR: cannot open tb_input.txt");
            $finish;
        end

        while (!$feof(fd) && len < 1024) begin
            ch = $fgetc(fd);
            if (ch != -1) begin
                msg_buf[len] = ch[7:0];
                len = len + 1;
            end
        end
        $fclose(fd);

        $display("INPUT LENGTH = %0d bytes", len);

        start_message();

        if (len == 0) begin
            while (in_ready !== 1'b1)
                @(negedge clk);

            msg_end = 1'b1;
            @(negedge clk);
            msg_end = 1'b0;
        end else begin
            for (i = 0; i < len; i = i + 1) begin
                send_byte(msg_buf[i], (i == len-1));
            end
        end

        cycle = 0;
        while ((done !== 1'b1) && (cycle < 10000)) begin
            @(posedge clk);
            cycle = cycle + 1;
        end

        $display("done = %b", done);
        $display("cycles waited = %0d", cycle);
        $display("H0 = %08x", H0);
        $display("H1 = %08x", H1);
        $display("H2 = %08x", H2);
        $display("H3 = %08x", H3);
        $display("H4 = %08x", H4);
        $display("H5 = %08x", H5);
        $display("H6 = %08x", H6);
        $display("H7 = %08x", H7);
        $display("HASH = %08x%08x%08x%08x%08x%08x%08x%08x",
                 H0, H1, H2, H3, H4, H5, H6, H7);

        #20;
        $finish;
    end

endmodule
