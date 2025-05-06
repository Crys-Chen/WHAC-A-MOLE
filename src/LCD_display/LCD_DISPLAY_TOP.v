module  LCD_DISPLAY_TOP(
    input              clk     ,
    input              rst_n   ,
	
	input  [9  : 0]    timer ,  
    input  [19 : 0]    moles,
    input  [1  : 0]    state,
    input  [9  : 0]    score,
    input  [7  : 0]    kill,
    input  [7  : 0]    runaway,
    input  [7  : 0]    combo,
    input  [3  : 0]    level,
	//RGB LCD Display
    output             lcd_hs  ,       
    output             lcd_vs  ,       
    output             lcd_de  ,       
    inout      [23:0]  lcd_rgb ,       
    output             lcd_bl  ,       
    output             lcd_clk ,       
    output     [15:0]  lcd_id
);

    //wire define
    wire  [10:0]  pixel_xpos_w ;
    wire  [10:0]  pixel_ypos_w ;
    wire  [23:0]  pixel_data_w ;
    wire  [23:0]  lcd_rgb_o    ;
    wire          lcd_pclk     ;

    assign lcd_rgb = lcd_de ? lcd_rgb_o : {24{1'bz}};
    assign lcd_id = 16'h4384; // 4.3-inch 800x480 screen

    LCD_DISPLAY_CLKDIV  lcd_display_clkdiv(
        .clk          (clk),
        .rst_n        (rst_n),
        
        .lcd_id       (lcd_id),
        .lcd_pclk     (lcd_pclk)
    );

    LCD_DISPLAY_SCREEN  lcd_display_screen(          
        .clk            (lcd_pclk),
        .rst_n          (rst_n),
        .timer          (timer),
        .moles          (moles),
        .score          (score),
        .kill           (kill),
        .runaway        (runaway),
        .combo          (combo),
        .level          (level),
        .state          (state),
        .pixel_xpos     (pixel_xpos_w),
        .pixel_ypos     (pixel_ypos_w),
        .pixel_data     (pixel_data_w)
    );   
        
  
    LCD_DISPLAY_DRIVER  lcd_display_driver(
        .clk            (lcd_pclk),
        .rst_n          (rst_n),
        
        .lcd_id         (lcd_id),
        
        .lcd_hs         (lcd_hs),
        .lcd_vs         (lcd_vs),
        .lcd_de         (lcd_de),
        .lcd_bl         (lcd_bl),
        .lcd_clk        (lcd_clk),
        .lcd_rgb        (lcd_rgb_o),
        
        .pixel_data     (pixel_data_w),
        .pixel_xpos     (pixel_xpos_w),
        .pixel_ypos     (pixel_ypos_w)
    ); 

endmodule
