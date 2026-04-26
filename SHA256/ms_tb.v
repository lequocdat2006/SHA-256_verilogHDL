`timescale 1ns/1ps

module ms_tb;

reg clk;
reg enable;
reg [511:0] in;
wire [31:0] out;

integer total_checks;
integer total_pass;
integer total_fail;

reg [31:0] exp_w [0:63];

message_scheduler dut (
    .clk(clk),
    .enable(enable),
    .in(in),
    .out(out)
);

always #5 clk = ~clk;

function [31:0] sigma0_f;
    input [31:0] x;
    begin
        sigma0_f = {x[6:0], x[31:7]} ^ {x[17:0], x[31:18]} ^ (x >> 3);
    end
endfunction

function [31:0] sigma1_f;
    input [31:0] x;
    begin
        sigma1_f = {x[16:0], x[31:17]} ^ {x[18:0], x[31:19]} ^ (x >> 10);
    end
endfunction

task build_expected;
    input [511:0] blk;
    reg [511:0] tmp;
    integer k;
    begin
        tmp = blk;

        for (k = 0; k < 16; k = k + 1) begin
            exp_w[k] = tmp[511:480];
            tmp = tmp << 32;
        end

        for (k = 16; k < 64; k = k + 1) begin
            exp_w[k] = sigma1_f(exp_w[k-2]) + exp_w[k-7] + sigma0_f(exp_w[k-15]) + exp_w[k-16];
        end
    end
endtask

task run_case;
    input integer case_id;
    input [511:0] blk;
    integer k;
    integer case_pass;
    integer case_fail;
    begin
        case_pass = 0;
        case_fail = 0;

        $display("\n================ CASE %0d START ================", case_id);
        build_expected(blk);

        in <= blk;
        enable <= 1'b0;
        @(posedge clk);
        #1;

        enable <= 1'b1;
        for (k = 0; k < 64; k = k + 1) begin
            @(posedge clk);
            #1;
            total_checks = total_checks + 1;

            if (out === exp_w[k]) begin
                case_pass = case_pass + 1;
                total_pass = total_pass + 1;
                $display("[PASS] case=%0d t=%0d out=%08h", case_id, k, out);
            end else begin
                case_fail = case_fail + 1;
                total_fail = total_fail + 1;
                $display("[FAIL] case=%0d t=%0d out=%08h expected=%08h", case_id, k, out, exp_w[k]);
            end
        end

        enable <= 1'b0;
        @(posedge clk);
        #1;

        if (case_fail == 0) begin
            $display("CASE %0d RESULT: PASS (%0d/%0d)", case_id, case_pass, case_pass + case_fail);
        end else begin
            $display("CASE %0d RESULT: FAIL (%0d pass, %0d fail)", case_id, case_pass, case_fail);
        end
    end
endtask

initial begin
    clk = 1'b0;
    enable = 1'b0;
    in = 512'd0;

    total_checks = 0;
    total_pass = 0;
    total_fail = 0;

    // Wait one cycle before starting checks.
    @(posedge clk);
    #1;

    run_case(1, 512'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000);

    run_case(2, 512'h00010203_04050607_08090A0B_0C0D0E0F_10111213_14151617_18191A1B_1C1D1E1F_20212223_24252627_28292A2B_2C2D2E2F_30313233_34353637_38393A3B_3C3D3E3F);

    run_case(3, 512'h61626380_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000018);

    $display("\n================ FINAL SUMMARY ================");
    $display("Total checks: %0d", total_checks);
    $display("Total pass  : %0d", total_pass);
    $display("Total fail  : %0d", total_fail);

    if (total_fail == 0) begin
        $display("MS_TB FINAL RESULT: PASS");
    end else begin
        $display("MS_TB FINAL RESULT: FAIL");
    end

    $finish;
end

endmodule
