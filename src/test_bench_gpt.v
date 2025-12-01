`timescale 1ns / 1ps

// ============================================================================
//  Dummy MUL – заглушка для тестирования FSM
// ============================================================================
module mul(
    input      [7:0]  a,
    input      [7:0]  b,
    input             clk,
    input             rst,
    input             start,

    output reg [15:0] result,
    output reg        busy
);

    // задержка умножения (количество тактов)
    localparam LATENCY = 3;

    reg [1:0] counter;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            busy    <= 0;
            result  <= 0;
            counter <= 0;
        end else begin
            if (start && !busy) begin
                // начинаем операцию
                busy    <= 1;
                counter <= LATENCY;
                result  <= a * b;  // обычное умножение
            end else if (busy) begin
                if (counter == 0) begin
                    busy <= 0; // закончили
                end else begin
                    counter <= counter - 1;
                end
            end
        end
    end

endmodule



// ============================================================================
//  Тестбенч для CBRT
// ============================================================================
module tb_cbrt;

    reg        clk;
    reg        rst;
    reg        start;
    reg [7:0]  x_i;

    wire [7:0] y;
    wire       busy;

    // DUT
    cbrt dut (
        .x_i  (x_i),
        .clk  (clk),
        .rst  (rst),
        .start(start),
        .y    (y),
        .busy (busy)
    );

    // генерация такта
    initial begin
        clk = 0;
        forever #5 clk = ~clk;   // период 10 нс
    end

    // единичный тест
    task run_test(input [7:0] value);
    begin
        @(negedge clk);
        x_i  <= value;
        start <= 1;

        @(negedge clk);
        start <= 0;

        // ждём начала
        $display("wait busy");
        wait (busy == 1'b1);
        // ждём конца
        $display("wait end");
        wait (busy == 1'b0);

        @(negedge clk);

        $display("[%0t] x=%0d (0x%02h) -> y=%0d (0x%02h)",
                 $time, value, value, y, y);
    end
    endtask


    // Основной сценарий
    initial begin
        // включаем waveform в GTKWave
        $dumpfile("cbrt_tb.vcd");
        $dumpvars(0, tb_cbrt);

        x_i   = 0;
        start = 0;

        @(negedge clk);

        // тестовые входы
        rst = 1;
        @(negedge clk);
        rst = 0;
        run_test(0);

        rst = 1;
        @(negedge clk);
        rst = 0;
        run_test(1);

        rst = 1;
        @(negedge clk);
        rst = 0;
        run_test(2);

        rst = 1;
        @(negedge clk);
        rst = 0;
        run_test(8);

        rst = 1;
        @(negedge clk);
        rst = 0;
        run_test(15);

        rst = 1;
        @(negedge clk);
        rst = 0;
        run_test(27);

        // run_test(64);
        // run_test(125);
        // run_test(200);
        // run_test(255);

        #50;
        $display("Finished.");
        $finish;
    end

endmodule
