`include "src/cbrt.v"
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
    reg [7:0] a, b;
    
    reg [15:0] sum_in_a, sum_in_b;
    wire [15:0] sum_out;

    reg rst_cbrt, rst_mul, start_cbrt, start_mul;
    wire busy_cbrt, busy_mul;

    wire [15:0] sum_in_a_cbrt, sum_in_b_cbrt, sum_in_a_mul, sum_in_b_mul;
    wire [2:0] result_cbrt;
    wire [15:0] result_mul;
    
    cbrt my_cbrt (
        .x_i(b),
        .start(start_cbrt),
        .clk(clk),
        .rst(rst_cbrt),
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
        .rst(rst_mul),
        .result(result_mul),
        .busy(busy_mul),

        .sum_in_a(sum_in_a_mul),
        .sum_in_b(sum_in_b_mul),
        .sum_out(sum_out)
    );

    localparam IDLE = 0;
    localparam START_CBRT = 1;
    localparam CBRT = 2;
    localparam MUL = 3;

    always @(*) begin
        busy = (state != IDLE);
        sum_in_a = 0;
        sum_in_b = 0;
        start_cbrt = 0;
        start_mul = 0;
        state_next = state;

        case (state)
            IDLE: begin
                state_next = (start) ? START_CBRT : IDLE;
            end

            START_CBRT: begin
                start_cbrt = 1;
                state_next = CBRT;
            end

            CBRT: begin
                sum_in_a = sum_in_a_cbrt;
                sum_in_b = sum_in_b_cbrt;
                state_next = (busy_cbrt) ? CBRT : MUL;
                start_mul = (state_next == MUL);
            end

            MUL: begin
                sum_in_a = sum_in_a_mul;
                sum_in_b = sum_in_b_mul;
                state_next = (busy_mul) ? MUL : IDLE;
            end
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            result <= 0;
            rst_cbrt <= 1;
            rst_mul <= 1;
        end else begin
            rst_cbrt <= 0;
            rst_mul <= 0;
            state <= state_next;

            case (state)
                IDLE: begin
                    if (start) begin
                        a <= a_i;
                        b <= b_i;
                    end
                end

                CBRT: begin
                    if (state_next == IDLE) begin
                        result <= {8'd0, result_cbrt};
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