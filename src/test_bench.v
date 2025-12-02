`timescale 1ns/1ps
`include "src/fun.v"

module test_bench;
    reg clk = 0;
    reg rst = 1;
    reg start = 0;
    reg [7:0] a = 0;
    reg [7:0] b = 0;
    wire [10:0] result;
    wire busy;

    fun fun_dut (
        .a_i(a),
        .b_i(b),
        .start(start),
        .clk(clk),
        .rst(rst),
        .result(result),
        .busy(busy)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, test_bench);

        rst = 1;
        @(posedge clk);
        rst = 0;
        @(posedge clk);
        test(8'd5, 8'd27, 10'd15,  1); // 5 * cb

        rst = 1;
        @(posedge clk);
        rst = 0;
        @(posedge clk);
        test(8'd3, 8'd64, 10'd12,  2);

        rst = 1;
        @(posedge clk);
        rst = 0;
        @(posedge clk);
        test(8'd9,   8'd125,  10'd45,  3);

        #10 $finish;
    end

    localparam integer MAX_WAIT_CYCLES = 2000;

    task test;
        input [7:0] a_t, b_t;
        input [10:0] expected;
        input integer num;
        integer total_cycles;
        
        begin
            a = a_t;
            b = b_t;
            
            start = 1;
            @(posedge clk);
            start = 0;
            @(posedge clk);
            total_cycles = 0;
            
            while (busy && total_cycles < MAX_WAIT_CYCLES) begin
                @(posedge clk);
                total_cycles = total_cycles + 1;
            end

            if (!busy) begin                
                $display("Test %2d: %3d * ∛%-3d = %-5d (exp %-5d) | cycles: %2d", 
                         num, a, b, result, expected, 
                         total_cycles);
            end else begin
                $display("TIMEOUT in test %0d", num);
            end
        end
    endtask
    

endmodule