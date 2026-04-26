module sha256_top (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        in_valid,
    input  wire [7:0]  in_data,
    input  wire        msg_start,
    input  wire        msg_end,
    output wire        in_ready,
    output wire [31:0] H0,
    output wire [31:0] H1,
    output wire [31:0] H2,
    output wire [31:0] H3,
    output wire [31:0] H4,
    output wire [31:0] H5,
    output wire [31:0] H6,
    output wire [31:0] H7,
    output wire        done
);

    wire [511:0] pad_block;
    wire         pad_valid;
    wire         pad_last;
    wire         pad_ready;
    wire         pad_busy_unused;

    wire         ctrl_latch_block;
    wire         ctrl_load_working;
    wire         ctrl_ms_load;
    wire         ctrl_ms_advance;
    wire         ctrl_round_en;
    wire         ctrl_ff_en;
    wire         ctrl_done;

    reg  [511:0] block_reg;
    reg          block_last_reg;
    reg  [5:0]   round_cnt;

    reg  [31:0]  a_reg;
    reg  [31:0]  b_reg;
    reg  [31:0]  c_reg;
    reg  [31:0]  d_reg;
    reg  [31:0]  e_reg;
    reg  [31:0]  f_reg;
    reg  [31:0]  g_reg;
    reg  [31:0]  h_reg;

    reg  [31:0]  H0_reg;
    reg  [31:0]  H1_reg;
    reg  [31:0]  H2_reg;
    reg  [31:0]  H3_reg;
    reg  [31:0]  H4_reg;
    reg  [31:0]  H5_reg;
    reg  [31:0]  H6_reg;
    reg  [31:0]  H7_reg;

    wire [31:0]  Wt;
    wire [31:0]  Kt;
    wire         round_last;

    wire [31:0]  a_next_w;
    wire [31:0]  b_next_w;
    wire [31:0]  c_next_w;
    wire [31:0]  d_next_w;
    wire [31:0]  e_next_w;
    wire [31:0]  f_next_w;
    wire [31:0]  g_next_w;
    wire [31:0]  h_next_w;

    wire [31:0]  sig0_dbg;
    wire [31:0]  sig1_dbg;
    wire [31:0]  maj_dbg;
    wire [31:0]  ch_dbg;
    wire [31:0]  sum1_dbg;
    wire [31:0]  sum2_dbg;
    wire [31:0]  sum3_dbg;
    wire [31:0]  ut_dbg;
    wire [31:0]  vt_dbg;
    wire [31:0]  t1_dbg;
    wire [31:0]  t2_dbg;

    wire [31:0]  H0_new_w;
    wire [31:0]  H1_new_w;
    wire [31:0]  H2_new_w;
    wire [31:0]  H3_new_w;
    wire [31:0]  H4_new_w;
    wire [31:0]  H5_new_w;
    wire [31:0]  H6_new_w;
    wire [31:0]  H7_new_w;

    function [31:0] k_rom;
        input [5:0] idx;
        begin
            case (idx)
                6'd0:  k_rom = 32'h428a2f98;
                6'd1:  k_rom = 32'h71374491;
                6'd2:  k_rom = 32'hb5c0fbcf;
                6'd3:  k_rom = 32'he9b5dba5;
                6'd4:  k_rom = 32'h3956c25b;
                6'd5:  k_rom = 32'h59f111f1;
                6'd6:  k_rom = 32'h923f82a4;
                6'd7:  k_rom = 32'hab1c5ed5;
                6'd8:  k_rom = 32'hd807aa98;
                6'd9:  k_rom = 32'h12835b01;
                6'd10: k_rom = 32'h243185be;
                6'd11: k_rom = 32'h550c7dc3;
                6'd12: k_rom = 32'h72be5d74;
                6'd13: k_rom = 32'h80deb1fe;
                6'd14: k_rom = 32'h9bdc06a7;
                6'd15: k_rom = 32'hc19bf174;
                6'd16: k_rom = 32'he49b69c1;
                6'd17: k_rom = 32'hefbe4786;
                6'd18: k_rom = 32'h0fc19dc6;
                6'd19: k_rom = 32'h240ca1cc;
                6'd20: k_rom = 32'h2de92c6f;
                6'd21: k_rom = 32'h4a7484aa;
                6'd22: k_rom = 32'h5cb0a9dc;
                6'd23: k_rom = 32'h76f988da;
                6'd24: k_rom = 32'h983e5152;
                6'd25: k_rom = 32'ha831c66d;
                6'd26: k_rom = 32'hb00327c8;
                6'd27: k_rom = 32'hbf597fc7;
                6'd28: k_rom = 32'hc6e00bf3;
                6'd29: k_rom = 32'hd5a79147;
                6'd30: k_rom = 32'h06ca6351;
                6'd31: k_rom = 32'h14292967;
                6'd32: k_rom = 32'h27b70a85;
                6'd33: k_rom = 32'h2e1b2138;
                6'd34: k_rom = 32'h4d2c6dfc;
                6'd35: k_rom = 32'h53380d13;
                6'd36: k_rom = 32'h650a7354;
                6'd37: k_rom = 32'h766a0abb;
                6'd38: k_rom = 32'h81c2c92e;
                6'd39: k_rom = 32'h92722c85;
                6'd40: k_rom = 32'ha2bfe8a1;
                6'd41: k_rom = 32'ha81a664b;
                6'd42: k_rom = 32'hc24b8b70;
                6'd43: k_rom = 32'hc76c51a3;
                6'd44: k_rom = 32'hd192e819;
                6'd45: k_rom = 32'hd6990624;
                6'd46: k_rom = 32'hf40e3585;
                6'd47: k_rom = 32'h106aa070;
                6'd48: k_rom = 32'h19a4c116;
                6'd49: k_rom = 32'h1e376c08;
                6'd50: k_rom = 32'h2748774c;
                6'd51: k_rom = 32'h34b0bcb5;
                6'd52: k_rom = 32'h391c0cb3;
                6'd53: k_rom = 32'h4ed8aa4a;
                6'd54: k_rom = 32'h5b9cca4f;
                6'd55: k_rom = 32'h682e6ff3;
                6'd56: k_rom = 32'h748f82ee;
                6'd57: k_rom = 32'h78a5636f;
                6'd58: k_rom = 32'h84c87814;
                6'd59: k_rom = 32'h8cc70208;
                6'd60: k_rom = 32'h90befffa;
                6'd61: k_rom = 32'ha4506ceb;
                6'd62: k_rom = 32'hbef9a3f7;
                6'd63: k_rom = 32'hc67178f2;
                default: k_rom = 32'h00000000;
            endcase
        end
    endfunction

    assign round_last = (round_cnt == 6'd63);
    assign Kt         = k_rom(round_cnt);
    assign done       = ctrl_done;

    assign H0 = H0_reg;
    assign H1 = H1_reg;
    assign H2 = H2_reg;
    assign H3 = H3_reg;
    assign H4 = H4_reg;
    assign H5 = H5_reg;
    assign H6 = H6_reg;
    assign H7 = H7_reg;

    sha256_padding u_padding (
        .clk(clk),
        .rst_n(rst_n),
        .msg_start(msg_start),
        .in_data(in_data),
        .in_valid(in_valid),
        .msg_end(msg_end),
        .in_ready(in_ready),
        .out_block(pad_block),
        .out_valid(pad_valid),
        .out_ready(pad_ready),
        .out_last(pad_last),
        .busy(pad_busy_unused)
    );

    controller u_ctrl (
        .clk(clk),
        .rst_n(rst_n),
        .pad_valid(pad_valid),
        .block_last(block_last_reg),
        .round_last(round_last),
        .pad_ready(pad_ready),
        .latch_block(ctrl_latch_block),
        .load_working(ctrl_load_working),
        .ms_load(ctrl_ms_load),
        .ms_advance(ctrl_ms_advance),
        .round_en(ctrl_round_en),
        .ff_en(ctrl_ff_en),
        .done(ctrl_done)
    );

    message_scheduler u_ms (
        .clk(clk),
        .rst_n(rst_n),
        .load(ctrl_ms_load),
        .advance(ctrl_ms_advance),
        .in_block(block_reg),
        .Wt(Wt)
    );

    compression_round_core u_comp (
        .A(a_reg),
        .B(b_reg),
        .C(c_reg),
        .D(d_reg),
        .E(e_reg),
        .F(f_reg),
        .G(g_reg),
        .H(h_reg),
        .Kt(Kt),
        .Wt(Wt),
        .A_next(a_next_w),
        .B_next(b_next_w),
        .C_next(c_next_w),
        .D_next(d_next_w),
        .E_next(e_next_w),
        .F_next(f_next_w),
        .G_next(g_next_w),
        .H_next(h_next_w),
        .sig0_out(sig0_dbg),
        .sig1_out(sig1_dbg),
        .maj_out(maj_dbg),
        .ch_out(ch_dbg),
        .Sum1(sum1_dbg),
        .Sum2(sum2_dbg),
        .Sum3(sum3_dbg),
        .U_t(ut_dbg),
        .V_t(vt_dbg),
        .T1(t1_dbg),
        .T2(t2_dbg)
    );

    sha256_feedforward u_ff (
        .H0_old(H0_reg),
        .H1_old(H1_reg),
        .H2_old(H2_reg),
        .H3_old(H3_reg),
        .H4_old(H4_reg),
        .H5_old(H5_reg),
        .H6_old(H6_reg),
        .H7_old(H7_reg),
        .A_final(a_reg),
        .B_final(b_reg),
        .C_final(c_reg),
        .D_final(d_reg),
        .E_final(e_reg),
        .F_final(f_reg),
        .G_final(g_reg),
        .H_final(h_reg),
        .H0_new(H0_new_w),
        .H1_new(H1_new_w),
        .H2_new(H2_new_w),
        .H3_new(H3_new_w),
        .H4_new(H4_new_w),
        .H5_new(H5_new_w),
        .H6_new(H6_new_w),
        .H7_new(H7_new_w)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            block_reg      <= 512'd0;
            block_last_reg <= 1'b0;
            round_cnt      <= 6'd0;

            a_reg <= 32'd0;
            b_reg <= 32'd0;
            c_reg <= 32'd0;
            d_reg <= 32'd0;
            e_reg <= 32'd0;
            f_reg <= 32'd0;
            g_reg <= 32'd0;
            h_reg <= 32'd0;

            H0_reg <= 32'h6a09e667;
            H1_reg <= 32'hbb67ae85;
            H2_reg <= 32'h3c6ef372;
            H3_reg <= 32'ha54ff53a;
            H4_reg <= 32'h510e527f;
            H5_reg <= 32'h9b05688c;
            H6_reg <= 32'h1f83d9ab;
            H7_reg <= 32'h5be0cd19;
        end else begin
            if (msg_start) begin
                H0_reg <= 32'h6a09e667;
                H1_reg <= 32'hbb67ae85;
                H2_reg <= 32'h3c6ef372;
                H3_reg <= 32'ha54ff53a;
                H4_reg <= 32'h510e527f;
                H5_reg <= 32'h9b05688c;
                H6_reg <= 32'h1f83d9ab;
                H7_reg <= 32'h5be0cd19;

                block_reg      <= 512'd0;
                block_last_reg <= 1'b0;
                round_cnt      <= 6'd0;
            end

            if (ctrl_latch_block) begin
                block_reg      <= pad_block;
                block_last_reg <= pad_last;
            end

            if (ctrl_load_working) begin
                a_reg     <= H0_reg;
                b_reg     <= H1_reg;
                c_reg     <= H2_reg;
                d_reg     <= H3_reg;
                e_reg     <= H4_reg;
                f_reg     <= H5_reg;
                g_reg     <= H6_reg;
                h_reg     <= H7_reg;
                round_cnt <= 6'd0;
            end else if (ctrl_round_en) begin
                a_reg <= a_next_w;
                b_reg <= b_next_w;
                c_reg <= c_next_w;
                d_reg <= d_next_w;
                e_reg <= e_next_w;
                f_reg <= f_next_w;
                g_reg <= g_next_w;
                h_reg <= h_next_w;

                if (!round_last)
                    round_cnt <= round_cnt + 6'd1;
            end

            if (ctrl_ff_en) begin
                H0_reg <= H0_new_w;
                H1_reg <= H1_new_w;
                H2_reg <= H2_new_w;
                H3_reg <= H3_new_w;
                H4_reg <= H4_new_w;
                H5_reg <= H5_new_w;
                H6_reg <= H6_new_w;
                H7_reg <= H7_new_w;
            end
        end
    end

endmodule
