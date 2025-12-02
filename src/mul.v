`ifndef MUL
`define MUL

module mul(
    input [7:0] a_i,
    input [7:0] b_i,
    input start,
    input clk,
    input rst,

    output reg busy,
    output reg [15:0] result,

    output reg [15:0] sum_in_a,
    output reg [15:0] sum_in_b,
    input [15:0] sum_out
    );
 
    reg [2:0] ctr;
    reg [1:0] state, state_next;
    reg [7:0] a, b;

    localparam IDLE = 0;
    localparam SUM = 1;
    localparam INC = 2;

    always @(*) begin
        busy = (state != IDLE);
        sum_in_a = 0;
        sum_in_b = 0;
        state_next = state;

        case (state)
            IDLE: state_next = (start) ? SUM : IDLE;

            SUM: begin
                sum_in_a = ({16{b[ctr]}} & a) << ctr;
                sum_in_b = result;
                state_next = (ctr != 7) ? INC : IDLE;
            end

            INC: begin
                sum_in_a = ctr;
                sum_in_b = 1;
                state_next = SUM;
            end
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            result <= 0;
            ctr <= 0;
        end else begin
            state <= state_next;
            case (state)
                IDLE: begin
                    if (start) begin
                        a <= a_i;
                        b <= b_i;
                    end
                end

                INC: begin
                    ctr <= sum_out;
                end

                SUM: begin
                    result <= sum_out;
                end
            endcase
        end
    end
endmodule
`endif
