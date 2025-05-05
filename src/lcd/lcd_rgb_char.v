module  lcd_rgb_char(
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
	//RGB LCD�ӿ� 
    output             lcd_hs  ,       //LCD ��ͬ���ź�
    output             lcd_vs  ,       //LCD ��ͬ���ź�
    output             lcd_de  ,       //LCD ��������ʹ��
    inout      [23:0]  lcd_rgb ,       //LCD RGB��ɫ����
    output             lcd_bl  ,       //LCD ��������ź�
    output             lcd_clk ,       //LCD ����ʱ��
    output     [15:0]  lcd_id
);

//wire define
wire  [10:0]  pixel_xpos_w ;
wire  [10:0]  pixel_ypos_w ;
wire  [23:0]  pixel_data_w ;
wire  [23:0]  lcd_rgb_o    ;
wire          lcd_pclk     ;

//*****************************************************
//**                    main code
//*****************************************************

//RGB565�������
assign lcd_rgb = lcd_de ? lcd_rgb_o : {24{1'bz}};

//��rgb lcd ID ģ��
rd_id    u_rd_id(
    .clk          (clk),
    .rst_n        (rst_n),
    
    .lcd_rgb      (lcd_rgb),
    .lcd_id       (lcd_id)
);

//��Ƶģ�飬���ݲ�ͬ��LCD ID�����Ӧ��Ƶ�ʵ�����ʱ��
CLKDIV  u_CLKDIV(
    .clk          (clk),
    .rst_n        (rst_n),
    
    .lcd_id       (lcd_id),
    .lcd_pclk     (lcd_pclk)
);

lcd_display  u_lcd_display(          //lcd��ʾģ��
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
	
//lcd����ģ��    
lcd_driver  u_lcd_driver(
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
