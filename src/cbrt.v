`timescale 1ns / 1ps

module cbrt(
    input [7:0] x_i,
    input clk,
    input rst,
    input start,

    output reg [2:0] result,
    output reg busy,
    );

    reg [15:0] x, s, buff, buff_next, result_next;
    reg [3:0] state, state_next;

    reg [15:0] sum_in_a, sum_in_b;
    wire [15:0] sum_out;
    
    sum2 my_sum2 (
        .a(sum_in_a),
        .b(sum_in_b),

        .result(sum_out)
    );

    reg start_mul;
    reg rst_mul;
    wire [15:0] res_mul;
    wire busy_mul;

    mul mul2 (
        .a_i(sum_out[7:0]),
        .b_i({ 5'd0, result}),
        .start(start_mul),
        .clk(clk),
        .rst(rst_mul),

        .busy(busy_mul),
        .result(res_mul)
    );

    localparam IDLE = 0;
    localparam ST1 = 1;
    localparam ST2 = 2;
    localparam ST3 = 3;
    localparam ST4 = 4;
    localparam ST5 = 5;
    localparam ST6 = 6;
    localparam ST7 = 7;
    localparam ST8 = 8;
    localparam ST9 = 9;

    always @(*) begin
        state_next = state;
        case (state)
            IDLE: state_next = (start) ? ST1 : IDLE;
            ST1: state_next = ST2;
            ST2: state_next = ST3;
            ST3: state_next = (busy_mul) ? ST3 : ST4;
            ST4: state_next = ST5;
            ST5: state_next = ST6;
            ST6: state_next = ST7;
            ST7: state_next = (buff_next[15]) ? ST9 : ST8;
            ST8: state_next = ST9;
            ST9: state_next = (s == 0) ? IDLE : ST1;
        endcase
    end

    always @(*) begin
        rst_mul = (state == ST1);
        start_mul = (state == ST2);
        buff_next = (state == ST5) ? sum_out << s : sum_out;
        result_next = (state == ST8) ? sum_out : { 13'd0, result} << 1;
        busy = (state != IDLE);
    end

    always @(*) begin
        sum_in_a = 0;
        sum_in_b = 0;

        case (state)
            ST1: begin
                sum_in_a = s;
                sum_in_b = 16'hFFFD;
            end

            ST2: begin
                sum_in_a = result;
                sum_in_b = 1;
            end

            ST4: begin
                sum_in_a = res_mul;
                sum_in_b = res_mul << 1;
            end

            ST5: begin
                sum_in_a = 1;
                sum_in_b = buff;
            end

            ST6: begin
                sum_in_a = 1;
                sum_in_b = ~buff;
            end

            ST7: begin
                sum_in_a = x;
                sum_in_b = buff;
            end

            ST8: begin
                sum_in_a = result;
                sum_in_b = 1;
            end
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            x <= 0;
            s <= 0;
            buff <= 0;
            result <= 0;
        end else begin
            state <= state_next;
            case (state)
                IDLE: begin
                    if (start) begin
                        s <= 9;
                        x <= {8'd0, x_i};
                    end
                end

                ST1: begin
                    s <= sum_out;
                    result <= result_next[2:0];
                end

                ST4, ST5, ST6, ST7: buff <= buff_next;

                ST8: begin
                    x <= buff;
                    result <= result_next[2:0];
                end

            endcase
        end
    end
endmodule

module sum2(
    input [15:0] a,
    input [15:0] b,
    output [15:0] result
);

    assign result = a + b;

endmodule