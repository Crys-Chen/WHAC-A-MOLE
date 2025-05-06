`include "PARAM.vh"
module GAME_CONTROLLER (
    input               clk,
    input               rst_n,
    input               sys_rst_n,
    input   [15 : 0]    tp_x_coord,
    input   [15 : 0]    tp_y_coord,
    // game data
    output  [9  : 0]    timer
    output  [31 : 0]    life_span,
    output  [31 : 0]    gen_interval,
    output  [19 : 0]    moles,
    output  [9  : 0]    score,
    output  [7  : 0]    kill,
    output  [7  : 0]    runaway,
    output  [7  : 0]    combo,
    output  [3  : 0]    level,
    // control signal
    output              game_over,
    output              just_kill,
);
    wire              survival;
    reg     [31 : 0]  clk_1s_cnt;
    reg     [4  : 0]  kill_list;
    wire    [3  : 0]  moles_array [4 : 0];
    wire    [9  : 0]  score_per_mole;
    reg     [9  : 0]  score_reg;
    reg     [3  : 0]  level_reg;
    reg     [7  : 0]  kill_reg;
    reg     [7  : 0]  combo_reg;
    reg     [7  : 0]  runaway_reg;

    assign  game_over        =   (runaway == 8'd10) | (level == 5);
    assign  score            =   score_reg;
    assign  kill             =   kill_reg;
    assign  combo            =   combo_reg;
    assign  level            =   level_reg;
    assign  runaway          =   runaway_reg;
    assign  moles_array[0]   =   moles[3  : 0];
    assign  moles_array[1]   =   moles[7  : 4];
    assign  moles_array[2]   =   moles[11 : 8];
    assign  moles_array[3]   =   moles[15 : 12];
    assign  moles_array[4]   =   moles[19 : 16];
    
    assign  score_per_mole   =   level + (combo > 8'd5 ? 10'd5 : combo);
    assign  just_kill        =   kill_list > 5'd0;

    genvar i;
    generate
    for (i = 0; i < 5; i = i + 1) begin
        always @(posedge clk or negedge rst_n) begin
            if (!rst_n) 
                kill_list[i]    <=  1'b0;
            else
                if (moles_array[i] < 4'b1111 && kill_list[i] == 1'b0)
                    case (moles_array[i])
                        4'd0: kill_list[i]  <=  tp_x_coord > `GRID_TOP_LEFT_X_0 & tp_x_coord < `GRID_BOTTOM_RIGHT_X_0 & 
                                                tp_y_coord > `GRID_TOP_LEFT_Y_0 & tp_y_coord < `GRID_BOTTOM_RIGHT_Y_0;
                        4'd1: kill_list[i]  <=  tp_x_coord > `GRID_TOP_LEFT_X_1 & tp_x_coord < `GRID_BOTTOM_RIGHT_X_1 & 
                                                tp_y_coord > `GRID_TOP_LEFT_Y_1 & tp_y_coord < `GRID_BOTTOM_RIGHT_Y_1;
                        4'd2: kill_list[i]  <= tp_x_coord > `GRID_TOP_LEFT_X_2 & tp_x_coord < `GRID_BOTTOM_RIGHT_X_2 & 
                                                tp_y_coord > `GRID_TOP_LEFT_Y_2 & tp_y_coord < `GRID_BOTTOM_RIGHT_Y_2;
                        4'd3: kill_list[i]  <= tp_x_coord > `GRID_TOP_LEFT_X_3 & tp_x_coord < `GRID_BOTTOM_RIGHT_X_3 & 
                                                tp_y_coord > `GRID_TOP_LEFT_Y_3 & tp_y_coord < `GRID_BOTTOM_RIGHT_Y_3;
                        4'd4: kill_list[i]  <= tp_x_coord > `GRID_TOP_LEFT_X_4 & tp_x_coord < `GRID_BOTTOM_RIGHT_X_4 & 
                                                tp_y_coord > `GRID_TOP_LEFT_Y_4 & tp_y_coord < `GRID_BOTTOM_RIGHT_Y_4;
                        4'd5: kill_list[i]  <= tp_x_coord > `GRID_TOP_LEFT_X_5 & tp_x_coord < `GRID_BOTTOM_RIGHT_X_5 & 
                                                tp_y_coord > `GRID_TOP_LEFT_Y_5 & tp_y_coord < `GRID_BOTTOM_RIGHT_Y_5;
                        4'd6: kill_list[i]  <= tp_x_coord > `GRID_TOP_LEFT_X_6 & tp_x_coord < `GRID_BOTTOM_RIGHT_X_6 & 
                                                tp_y_coord > `GRID_TOP_LEFT_Y_6 & tp_y_coord < `GRID_BOTTOM_RIGHT_Y_6;
                        4'd7: kill_list[i]  <= tp_x_coord > `GRID_TOP_LEFT_X_7 & tp_x_coord < `GRID_BOTTOM_RIGHT_X_7 & 
                                                tp_y_coord > `GRID_TOP_LEFT_Y_7 & tp_y_coord < `GRID_BOTTOM_RIGHT_Y_7;
                        4'd8: kill_list[i]  <= tp_x_coord > `GRID_TOP_LEFT_X_8 & tp_x_coord < `GRID_BOTTOM_RIGHT_X_8 & 
                                                tp_y_coord > `GRID_TOP_LEFT_Y_8 & tp_y_coord < `GRID_BOTTOM_RIGHT_Y_8;
                        default: kill_list[i]  <=  1'b0;
                    endcase
                else
                    kill_list[i]        <=  1'b0;        
        end 
    end
    endgenerate

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            score_reg   <=  10'd0;
            kill_reg    <=  8'd0;
        end
        else if (just_kill) begin
            score_reg   <=  score_reg + score_per_mole;
            kill_reg    <=  kill_reg + 8'd1;
        end
        else begin
            score_reg   <=  score_reg;
            kill_reg    <=  kill_reg;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            level_reg   <=  4'd1;
        else begin
            if (kill + runaway == level_reg * 8'd9)
                level_reg   <=  level_reg + 8'd1;
            else
                level_reg   <=  level_reg;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            combo_reg   <=  8'd0;
        else begin
            if (survival)
                combo_reg   <=  8'd0;
            else if (just_kill)
                combo_reg   <=  combo_reg + 8'd1;
            else
                combo_reg   <=  combo_reg;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            runaway_reg   <=  8'd0;
        else begin
            if (survival)
                runaway_reg   <=  runaway_reg + 8'd1;
            else
                runaway_reg   <=  runaway_reg;
        end
    end

    // Compute life_span, gen_interval
    assign  life_span      =   (level == 1 ? `LIFE_SPAN_1 : (level == 2 ? `LIFE_SPAN_2 : (level == 3 ? `LIFE_SPAN_3 : (level == 4 ? `LIFE_SPAN_4 : `LIFE_SPAN_1))));
    assign  gen_interval   =   (level == 1 ? `GEN_INTERVAL_1 : (level == 2 ? `GEN_INTERVAL_2 : (level == 3 ? `GEN_INTERVAL_3 : (level == 4 ? `GEN_INTERVAL_4 : `GEN_INTERVAL_1))));

    MOLE mole(
        .clk(clk),
        .rst_n(rst_n & ~game_over),
        .sys_rst_n(sys_rst_n),
        .life_span(life_span),
        .gen_interval(gen_interval),
        .kill_list(kill_list),
        .moles(moles),
        .survival(survival)
    );

    reg [9 : 0] timer_reg;
    assign  timer = timer_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_1s_cnt  <=  32'd0;
            timer_reg   <=  10'd0;
        end
        else
            if (clk_1s_cnt == 50_000_000) begin
                timer_reg   <=   timer_reg + 32'd1;
                clk_1s_cnt  <=   32'd0;
            end
            else begin
                timer_reg   <=  timer_reg;
                clk_1s_cnt  <=  clk_1s_cnt + 32'd1;
            end
    end
    
endmodule