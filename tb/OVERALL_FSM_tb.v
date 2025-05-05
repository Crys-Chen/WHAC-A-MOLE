`timescale 1ns / 1ps
`include "PARAM.vh"
module OVERALL_FSM_tb;

    // Inputs
    reg clk;
    reg rst_n;
    reg move_on;
    reg [15:0] tp_x_coord;
    reg [15:0] tp_y_coord;

    // Outputs
    wire [31:0] life_span;
    wire [31:0] gen_interval;
    wire [19:0] moles;
    wire [9:0] score;
    wire [7:0] kill;
    wire [7:0] runaway;
    wire [7:0] combo;
    wire [3:0] level;
    wire [1:0] state;

    // Instantiate the OVERALL_FSM module
    OVERALL_FSM uut (
        .clk(clk),
        .rst_n(rst_n),
        .move_on(move_on),
        .tp_x_coord(tp_x_coord),
        .tp_y_coord(tp_y_coord),
        .moles(moles),
        .life_span(life_span),
        .gen_interval(gen_interval),
        .score(score),
        .kill(kill),
        .runaway(runaway),
        .combo(combo),
        .level(level),
        .state(state)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10 time units clock period
    end

    // Test procedure
    initial begin
        // Initialize inputs
        rst_n = 0;
        move_on = 0;
        tp_x_coord = 0;
        tp_y_coord = 0;

        // Apply reset
        #10;
        rst_n = 1;
        #10;

        // Test case 1: Start game from menu
        tp_x_coord = `START_TOP_LEFT_X + 10;
        tp_y_coord = `START_TOP_LEFT_Y + 10;
        move_on = 1;
        #10;
        move_on = 0;
        #100;
        tp_x_coord = 500;
        tp_y_coord = 200;

        // // Test case 2: Simulate game over and transition to game over state
        // move_on = 1;
        // #20;
        // move_on = 0;
        // #100;

        // // Test case 3: Restart the game
        // tp_x_coord = `RESTART_TOP_LEFT_X + 10;
        // tp_y_coord = `RESTART_TOP_LEFT_Y + 10;
        // move_on = 1;
        // #20;
        // move_on = 0;
        // #100;

        // // Test case 4: Transition back to menu
        // tp_x_coord = `START_TOP_LEFT_X + 10;
        // tp_y_coord = `START_TOP_LEFT_Y + 10;
        // move_on = 1;
        // #20;
        // move_on = 0;
        // #100;

        // Finish simulation
        $finish;
    end

    // Monitor outputs
    initial begin
        $monitor("Time: %0t | State: %b | Score: %d | Level: %d | Life Span: %d | Gen Interval: %d", 
                 $time, state, score, level, life_span, gen_interval);
    end

endmodule
