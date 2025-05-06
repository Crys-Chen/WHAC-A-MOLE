`include "PARAM.vh"
module FSM (
    input               clk,
    input               rst_n,
    input               move_on,
    input   [15 : 0]    tp_x_coord,
    input   [15 : 0]    tp_y_coord,
    // game data
    output  [19 : 0]    moles,
    output  [31 : 0]    life_span,
    output  [31 : 0]    gen_interval,
    output  [9  : 0]    score,
    output  [7  : 0]    kill,
    output  [7  : 0]    runaway,
    output  [7  : 0]    combo,
    output  [3  : 0]    level,
    output  [1  : 0]    state,
    output  [31 : 0]    timer,
    // control signal
    output              game_rst_n,
    output              just_kill
);

    reg     [1  : 0]   state_reg, next_state;
    wire               restart;
    wire               game_over;
    assign             restart      =   (tp_x_coord > `RESTART_TOP_LEFT_X) & (tp_x_coord < `RESTART_BOTTOM_RIGHT_X) & (tp_y_coord > `RESTART_TOP_LEFT_Y) & (tp_y_coord < `RESTART_BOTTOM_RIGHT_Y);
    assign             state        =   state_reg;
    assign             game_rst_n   =   rst_n & (~(state == `STATE_GAME & restart)) & (~(state==`STATE_MENU));
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            state_reg   <=  `STATE_MENU;
        else
            state_reg   <=  next_state;
    end

    always @(*) begin
        case (state)
            `STATE_MENU: 
                if (move_on)
                    next_state  =  `STATE_GAME;
                else
                    next_state  =  `STATE_MENU;
            `STATE_GAME: 
                if (move_on | game_over)
                    next_state  =  `STATE_OVER;
                else
                    next_state  =  `STATE_GAME;
            `STATE_OVER: 
                if (move_on)
                    next_state  =  `STATE_MENU;
                else
                    next_state  =  `STATE_OVER;
            default:     next_state  =  `STATE_MENU;
        endcase
    end

    GAME_CONTROLLER game_controller(
        .clk(clk),
        .rst_n(game_rst_n),
        .sys_rst_n(rst_n),
        .tp_x_coord(tp_x_coord),
        .tp_y_coord(tp_y_coord),
        .life_span(life_span),
        .gen_interval(gen_interval),
        .moles(moles),
        .score(score),
        .kill(kill),
        .runaway(runaway),
        .combo(combo),
        .level(level),
        .game_over(game_over),
        .timer(timer),
        .just_kill(just_kill)
    );
endmodule