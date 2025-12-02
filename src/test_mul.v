`timescale 1ns/1ps
`include "src/mul.v"
`include "src/sum.v"

module test_bench;
    reg clk = 0;
    reg rst = 1;
    reg start = 0;
    reg [7:0] a = 0;
    reg [7:0] b = 0;
    wire [15:0] result;
    wire busy;

    wire [15:0] sum_in_a_w;
    wire [15:0] sum_in_b_w;
    wire [15:0] sum_out_w;

    mul mul_dut (
        .a_i(a),
        .b_i(b),
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

    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, test_bench);

        test(8'd3,   8'd2,  16'd6,  1); // 3 * 2 = 6
        test(8'd5,   8'd5,  16'd25,  2); // 5 * 5 = 25
        test(8'd4,   8'd3,  16'd12,  3); // 3 * 4 = 12
        test(8'd255,   8'd255,  16'd65025,  4); // 255 * 255 = 65025
        test(8'd255,   8'd0,  16'd65025,  5); // 255 * 0 = 0

        #10 $finish;
    end

    localparam integer MAX_WAIT_CYCLES = 2000;

    task test;
        input [7:0] a_t, b_t;
        input [15:0] expected;
        input integer num;
        integer total_cycles;
        
        begin

            rst = 1;
            @(posedge clk);
            rst = 0;
            @(posedge clk);

            a = a_t;
            b = b_t;
            
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
                $display("Test %2d: %3d * %-3d = %-5d (exp %-5d) | cycles: %2d, time: %3dns", 
                         num, a, b, result, expected, 
                         total_cycles, total_cycles * 10);
            end else begin
                $display("TIMEOUT in test %0d", num);
            end
        end
    endtask
    

endmodule