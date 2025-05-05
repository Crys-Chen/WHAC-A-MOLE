`include "PARAM.vh"
module TOP (
    input            clk,
    input            rst_n,
    //RGB LCD Ports
    output           lcd_de,     //LCD Enable 
    output           lcd_hs,     //LCD horizontal sync
    output           lcd_vs,     //LCD vertical sync
    output           lcd_bl,     //LCD backlight
    output           lcd_rst_n,  //LCD rst_n
    output           lcd_clk,    //LCD pixel clk
    inout  [23 : 0]  lcd_rgb,     //LCD RGB
    //TOUCH Ports                 
    inout            touch_sda,  //TOUCH IIC data
    output           touch_scl,  //TOUCH IIC clk
    inout            touch_int,  //TOUCH INT signal
    output           touch_rst_n//TOUCH rst_n
);

    wire    [1 : 0]     state;
    reg                 move_on;
    wire                start;
    wire    [15 : 0]    tp_x_coord;
    wire    [15 : 0]    tp_y_coord;
    wire    [31 : 0]    life_span;
    wire    [31 : 0]    gen_interval;
    wire    [19 : 0]    moles;
    wire    [9  : 0]    score;
    wire    [7  : 0]    kill;
    wire    [7  : 0]    runaway;
    wire    [7  : 0]    combo;
    wire    [3  : 0]    level;
    wire    [31 : 0]    timer;
    //wire define
    wire                clk_50m      ;
    wire                locked       ;

    wire                touch_int_in ;
    wire                touch_int_dir;
    wire                touch_int_out;
    wire                touch_sda_in ;
    wire                touch_sda_out;
    wire                touch_sda_dir;

    wire  [31:0]        data         ;
    wire  [15:0]        lcd_id       ;
    wire                touch_valid  ;


    assign              start     =   (tp_x_coord > `START_TOP_LEFT_X) & (tp_x_coord < `START_BOTTOM_RIGHT_X) & (tp_y_coord > `START_TOP_LEFT_Y) & (tp_y_coord < `START_BOTTOM_RIGHT_Y);

    always @(*) begin
        case (state)
            `STATE_MENU:  move_on    =   start;
            `STATE_GAME:  move_on    =   1'b0;
            `STATE_OVER:  move_on    =   start;
            default:     move_on    =   1'b0;
        endcase
    end

    OVERALL_FSM overall_FSM (
        .clk(clk_50m),
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
        .state(state),
        .timer(timer)
    );

    // assign  state = `STATE_MENU;
    // assign  level = 1;
    // assign  score = 1;
    // assign  combo = 0;
    // assign  runaway = 0;
    // assign  moles = 20'd0;
    // assign  kill  = 0;



    //*****************************************************
    //**                    main code
    //*****************************************************

    // assign rst_n = rst_n & locked;
    assign data = {tp_x_coord,tp_y_coord};
    assign lcd_rst_n = 1'b1;
    assign touch_sda = touch_sda_dir ? touch_sda_out : 1'bz;
    assign touch_sda_in = touch_sda;
    assign touch_int = touch_int_dir ? touch_int_out : 1'bz;
    assign touch_int_in = touch_int;

    clk_wiz_0 u_clk_wiz_0
    (
        // Clock out ports
        .clk_out1     (clk_50m  ),        // output clk_out1
        // Status and control signals
        .reset        (~rst_n),       // input reset
        .locked       (locked    ),       // output locked
    // Clock in ports
        .clk_in1      (clk   )        // input clk_in1
        );     

    touch_top  u_touch_top(
        .clk            (clk_50m),
        .rst_n          (rst_n),

        .touch_rst_n    (touch_rst_n  ),
        .touch_int_in   (touch_int_in ),
        .touch_int_dir  (touch_int_dir),
        .touch_int_out  (touch_int_out),
        .touch_scl      (touch_scl    ),
        .touch_sda_in   (touch_sda_in ),
        .touch_sda_out  (touch_sda_out),
        .touch_sda_dir  (touch_sda_dir),

        .lcd_id         (lcd_id     ),
        .touch_valid    (touch_valid),
        .tp_x_coord     (tp_x_coord ),
        .tp_y_coord     (tp_y_coord )
        ); 

    lcd_rgb_char  u_lcd_rgb_char
    (
    .clk             (clk_50m),
    .rst_n           (rst_n  ),
    .timer           (timer   ),     
    .moles           (moles),
    .score           (score),
    .kill            (kill),
    .runaway         (runaway),
    .combo           (combo),
    .level           (level),
    .state           (state),
    //RGB LCD Ports 
    .lcd_id          (lcd_id),
    .lcd_hs          (lcd_hs),       //LCD Enable 
    .lcd_vs          (lcd_vs),       //LCD horizontal sync
    .lcd_de          (lcd_de),       //LCD vertical sync
    .lcd_rgb         (lcd_rgb),      //LCD backlight
    .lcd_bl          (lcd_bl),       //LCD rst_n
    .lcd_clk         (lcd_clk)       //LCD pixel clk
    );

endmodule