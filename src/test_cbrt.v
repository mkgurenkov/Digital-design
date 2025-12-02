`timescale 1ns/1ps
`include "src/cbrt.v"
`include "src/mul.v"

module test_bench;
    reg clk = 0;
    reg rst = 1;
    reg start = 0;
    reg [7:0] x = 0;
    wire [2:0] result;
    wire busy;

    cbrt cbrt_debug (
        .x_i(x),
        .start(start),
        .clk(clk),
        .rst(rst),
        .result(result),
        .busy(busy)
    );

    // Clock period = 10ns (100 MHz)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, test_bench);

        rst = 1;
        @(posedge clk);
        rst = 0;
        @(posedge clk);
        test(8'd27, 3'd3, 1);

        rst = 1;
        @(posedge clk);
        rst = 0;
        @(posedge clk);
        test(8'd64, 3'd4, 2);

        rst = 1;
        @(posedge clk);
        rst = 0;
        @(posedge clk);
        test(8'd125, 3'd5, 3);

        rst = 1;
        @(posedge clk);
        rst = 0;
        @(posedge clk);
        test(8'd216, 3'd6, 4);


        rst = 1;
        @(posedge clk);
        rst = 0;
        @(posedge clk);
        test(8'd8, 3'd2, 5);

        #10 $finish;
    end

    localparam integer MAX_WAIT_CYCLES = 2000;

    task test;
        input [7:0] x_t;
        input [2:0] expected;
        input integer num;
        integer total_cycles;
        begin
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
                $display("Test %d: %d^1/3 = %d (exp %d) | cycles: %d", 
                         num, x, result, expected, 
                         total_cycles);
            end else begin
                $display("TIMEOUT in test %0d", num);
            end
        end
    endtask
    

endmodule