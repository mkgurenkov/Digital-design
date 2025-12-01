`timescale 1ns/1ps
`include "src/mul.v"

module test_bench;
    reg clk = 0;
    reg rst = 1;
    reg start = 0;
    reg [7:0] a = 0;
    reg [7:0] b = 0;
    wire [15:0] result;
    wire busy;

    mul dut (
        .a(a),
        .b(b),
        .start(start),
        .clk(clk),
        .rst(rst),
        .result(result),
        .busy(busy)
    );

    // Clock period = 10ns (100 MHz)
    always #5 clk = ~clk;
    
    // Statistics counters
    // integer total_sqrt_cycles = 0;
    // integer total_mult_cycles = 0;
    // integer total_system_cycles = 0;
    // integer test_count = 0;
    // integer min_sqrt_cycles = 9999;
    // integer max_sqrt_cycles = 0;
    // integer min_mult_cycles = 9999;
    // integer max_mult_cycles = 0;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, test_bench);

        // $display("\n========================================");
        // $display("   CUBROOT-ADD SYSTEM TIMING ANALYSIS");
        // $display("   Clock Frequency: 100 MHz (10 ns period)");
        // $display("========================================\n");

        rst = 1;
        @(posedge clk);
        rst = 0;
        @(posedge clk);
        test(8'd3,   8'd2,  16'd6,  1);

        rst = 1;
        @(posedge clk);
        rst = 0;
        @(posedge clk);
        test(8'd5,   8'd5,  16'd25,  2);

        rst = 1;
        @(posedge clk);
        rst = 0;
        @(posedge clk);
        test(8'd4,   8'd3,  16'd12,  3);

        // test(8'd4,   8'd16,  16'd20,  1);   // 4^2 + sqrt(16) = 20
        // test(8'd5,   8'd25,  16'd30,  2);   // 5^2 + sqrt(25) = 30
        // test(8'd3,   8'd2,   16'd10,   3);   // 3^2 + sqrt(2) = 10
        // test(8'd0,   8'd100, 16'd10,   4);   // 0^2 + sqrt(100) = 10
        // test(8'd8,   8'd0,   16'd64,   5);   // 8^2 + sqrt(0) = 64
        // test(8'd1,   8'd1,   16'd2,   6);   // 1^2 + sqrt(1) = 2
        // test(8'd255, 8'd255, 16'd65040,7);   // 255^2 + sqrt(255) = 65040
        // test(8'd100, 8'd4,   16'd10002, 8);   // 100^2 + sqrt(4) = 10002
        // test(8'd2,   8'd225, 16'd19,  9);   // 2^2 + sqrt(225) = 19
        // test(8'd6,   8'd64,  16'd44,  10);  // 6^2 + sqrt(64) = 44


        #10 $finish;
    end

    localparam integer MAX_WAIT_CYCLES = 2000;
    //localparam real CLK_PERIOD = 10.0; // 100 MHz = 10 ns period

    task test;
        input [7:0] a_t, b_t;
        input [15:0] expected;
        input integer num;
        integer total_cycles;
        // integer sqrt_cycles, mult_cycles, total_cycles, overhead_cycles;
        // real sqrt_time_ns, mult_time_ns, total_time_ns;
        begin
            a = a_t;
            b = b_t;
            
            start = 1;
            @(posedge clk);
            start = 0;
            @(posedge clk);
            // Count cycles in each state
            // sqrt_cycles = 0;
            // mult_cycles = 0;
            // overhead_cycles = 0;
            total_cycles = 0;
            
            while (busy && total_cycles < MAX_WAIT_CYCLES) begin
                @(posedge clk);
                total_cycles = total_cycles + 1;
            end

            // total_time_ns = total_cycles * CLK_PERIOD;

            // Update statistics
            if (!busy) begin
                // test_count = test_count + 1;
                
                
                $display("Test %d: %d * %d = %d (exp %d) | cycles: %d", 
                         num, a, b, result, expected, 
                         total_cycles);
            end else begin
                $display("TIMEOUT in test %0d", num);
            end

            //repeat (2) @(posedge clk);
        end
    endtask
    

endmodule