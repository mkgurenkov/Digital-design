`ifndef FUN
`define FUN
`include "src/cbrt.v"
`include "src/mul.v"
`include "src/sum.v"

module fun (
    input clk,
    input rst,
    input start,
    input [7:0] a_i,
    input [7:0] b_i,
    output reg busy,
    output reg [10:0] result
);

    reg [1:0] state, state_next;
    reg [7:0] a;
    
    reg [15:0] sum_in_a, sum_in_b;
    wire [15:0] sum_out;

    reg start_cbrt, start_mul;
    wire busy_cbrt, busy_mul;

    wire [15:0] sum_in_a_cbrt, sum_in_b_cbrt, sum_in_a_mul, sum_in_b_mul;
    wire [2:0] result_cbrt;
    wire [15:0] result_mul;
    
    cbrt my_cbrt (
        .x_i(b_i),
        .start(start_cbrt),
        .clk(clk),
        .rst(rst),
        .result(result_cbrt),
        .busy(busy_cbrt),

        .sum_in_a(sum_in_a_cbrt),
        .sum_in_b(sum_in_b_cbrt),
        .sum_out(sum_out)
    );

    sum my_sum (
        .a(sum_in_a),
        .b(sum_in_b),
        .result(sum_out)
    );

    mul my_mul (
        .a_i(a),
        .b_i({5'd0, result_cbrt}),
        .start(start_mul),
        .clk(clk),
        .rst(rst),
        .result(result_mul),
        .busy(busy_mul),

        .sum_in_a(sum_in_a_mul),
        .sum_in_b(sum_in_b_mul),
        .sum_out(sum_out)
    );

    localparam IDLE = 0;
    localparam CBRT = 1;
    localparam MUL = 2;

    always @(*) begin
        state_next = state;
        case (state)
            IDLE: state_next = (start) ? CBRT : IDLE;
            CBRT: state_next = (busy_cbrt) ? CBRT : MUL;
            MUL: state_next = (busy_mul) ? MUL : IDLE;
        endcase
    end

    always @(*) begin
        busy = (state != IDLE);
        start_cbrt = 0;
        start_mul = 0;
        case (state)
            IDLE: start_cbrt = (state_next == CBRT);
            CBRT: start_mul = (state_next == MUL);
        endcase
    end

    always @(*) begin
        sum_in_a = 0;
        sum_in_b = 0;
        case (state)
            CBRT: begin
                sum_in_a = sum_in_a_cbrt;
                sum_in_b = sum_in_b_cbrt;
            end

            MUL: begin
                sum_in_a = sum_in_a_mul;
                sum_in_b = sum_in_b_mul;
            end
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            result <= 0;
        end else begin
            state <= state_next;

            case (state)
                IDLE: begin
                    if (start) begin
                        a <= a_i;
                    end
                end

                MUL: begin
                    if (state_next == IDLE) begin
                        result <= result_mul[10:0];
                    end
                end
            endcase
        end
    end
endmodule
`endif
