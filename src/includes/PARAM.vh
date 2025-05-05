`ifndef PARAMETERS_VH
`define PARAMETERS_VH

// module HEADER (

// )
`define     WIDTH              800
`define     HEIGHT             480
`define     BG_START_X         0
`define     BG_START_Y         0
`define     MOLE_WIDTH         150
`define     MOLE_HEIGHT        150

`define     GRID_TOP_LEFT_X_0  335
`define     GRID_TOP_LEFT_X_1  485
`define     GRID_TOP_LEFT_X_2  635
`define     GRID_TOP_LEFT_X_3  335
`define     GRID_TOP_LEFT_X_4  485
`define     GRID_TOP_LEFT_X_5  635
`define     GRID_TOP_LEFT_X_6  335
`define     GRID_TOP_LEFT_X_7  485
`define     GRID_TOP_LEFT_X_8  635


`define     GRID_TOP_LEFT_Y_0  15
`define     GRID_TOP_LEFT_Y_1  15
`define     GRID_TOP_LEFT_Y_2  15
`define     GRID_TOP_LEFT_Y_3  165
`define     GRID_TOP_LEFT_Y_4  165
`define     GRID_TOP_LEFT_Y_5  165
`define     GRID_TOP_LEFT_Y_6  315
`define     GRID_TOP_LEFT_Y_7  315
`define     GRID_TOP_LEFT_Y_8  315


`define     GRID_BOTTOM_RIGHT_X_0  485
`define     GRID_BOTTOM_RIGHT_X_1  635
`define     GRID_BOTTOM_RIGHT_X_2  785
`define     GRID_BOTTOM_RIGHT_X_3  485
`define     GRID_BOTTOM_RIGHT_X_4  635
`define     GRID_BOTTOM_RIGHT_X_5  785
`define     GRID_BOTTOM_RIGHT_X_6  485
`define     GRID_BOTTOM_RIGHT_X_7  635
`define     GRID_BOTTOM_RIGHT_X_8  785

`define     GRID_BOTTOM_RIGHT_Y_0  165
`define     GRID_BOTTOM_RIGHT_Y_1  165
`define     GRID_BOTTOM_RIGHT_Y_2  165
`define     GRID_BOTTOM_RIGHT_Y_3  315
`define     GRID_BOTTOM_RIGHT_Y_4  315
`define     GRID_BOTTOM_RIGHT_Y_5  315
`define     GRID_BOTTOM_RIGHT_Y_6  465
`define     GRID_BOTTOM_RIGHT_Y_7  465
`define     GRID_BOTTOM_RIGHT_Y_8  465

`define     RESTART_TOP_LEFT_X      70
`define     RESTART_TOP_LEFT_Y      432
`define     RESTART_BOTTOM_RIGHT_X  240
`define     RESTART_BOTTOM_RIGHT_Y  472
`define     START_TOP_LEFT_X        100
`define     START_TOP_LEFT_Y        200
`define     START_BOTTOM_RIGHT_X    700
`define     START_BOTTOM_RIGHT_Y    380
`define     LIFE_SPAN_1  300_000_000
`define     LIFE_SPAN_2  200_000_000
`define     LIFE_SPAN_3  100_000_000
`define     LIFE_SPAN_4  50_000_000
// `define     LIFE_SPAN_1  60
// `define     LIFE_SPAN_2  40
// `define     LIFE_SPAN_3  20
// `define     LIFE_SPAN_4  10
`define     TEXT_LEFT_X 230
`define     SCORE_TOP_Y 50
`define     SCORE_BOTTOM_Y 112
`define     KILL_TOP_Y 130
// `define     KILL_BOTTOM_Y 192
`define     RUNAWAY_TOP_Y 210
// `define     RUNAWAY_BOTTOM_Y 272
`define     COMBO_TOP_Y 290
// `define     COMBO_BOTTOM_Y 352
`define     LEVEL_TOP_Y 370
// `define     LEVEL_BOTTOM_Y 432
`define     FINAL_SCORE_TOP_LEFT_X 380
`define     FINAL_SCORE_TOP_LEFT_Y 220

`define     STATE_MENU     0
`define     STATE_GAME     1
`define     STATE_OVER     2
        
// endmodule
`endif