`timescale 1ns/1ps
`include "src/cbrt.v"
`include "src/sum.v"

module test_bench;
    reg clk = 0;
    reg rst = 1;
    reg start = 0;
    reg [7:0] x = 0;
    wire [2:0] result;
    wire busy;

    wire [15:0] sum_in_a_w;
    wire [15:0] sum_in_b_w;
    wire [15:0] sum_out_w;

    cbrt cbrt_debug (
        .x_i(x),
        .start(start),
        .clk(clk),
        .rst(rst),
        .result(result),
        .busy(busy),

        .sum_in_a(sum_in_a_w),
        .sum_in_b(sum_in_b_w),
        .sum_out(sum_out_w)
    );

    sum sum_dut (
        .a(sum_in_a_w),
        .b(sum_in_b_w),
        .result(sum_out_w)
    );

    // Clock period = 10ns (100 MHz)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, test_bench);

        test(8'd1, 3'd1, 1); // ∛1 = 1
        test(8'd8, 3'd2, 2); // ∛8 = 2
        test(8'd27, 3'd3, 3); // ∛27 = 3
        test(8'd64, 3'd4, 4); // ∛64 = 4
        test(8'd125, 3'd5, 5); // ∛125 = 5
        test(8'd216, 3'd6, 6); // ∛216 = 6
        test(8'd2, 3'd1, 7); // ∛2 = 1
        test(8'd5, 3'd1, 8); // ∛8 = 1
        test(8'd9, 3'd2, 9); // ∛9 = 2
        test(8'd17, 3'd2, 10); // ∛17 = 2
        test(8'd26, 3'd2, 11); // ∛26 = 2
        test(8'd28, 3'd3, 12); // ∛28 = 3
        test(8'd255, 3'd6, 13); // ∛255 = 6
        test(8'd0, 3'd0, 14); // ∛0 = 0
        #10 $finish;
    end

    localparam integer MAX_WAIT_CYCLES = 2000;

    task test;
        input [7:0] x_t;
        input [2:0] expected;
        input integer num;
        integer total_cycles;
        begin

            rst = 1;
            @(posedge clk);
            rst = 0;
            @(posedge clk);

            x = x_t;
            
            start = 1;
            @(posedge clk);
            #1;
            start = 0;

            total_cycles = 0;
            
            while (busy && total_cycles < MAX_WAIT_CYCLES) begin
                total_cycles = total_cycles + 1;
                @(posedge clk);
                #1;
            end

            if (!busy) begin
                $display("Test %2d: ∛%-3d = %-5d (exp %-5d) | cycles: %2d", 
                         num, x, result, expected, 
                         total_cycles);
            end else begin
                $display("TIMEOUT in test %0d", num);
            end
        end
    endtask
    

endmodule