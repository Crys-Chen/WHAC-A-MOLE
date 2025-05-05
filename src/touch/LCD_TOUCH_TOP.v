module LCD_TOUCH_TOP(
    input             clk          ,
    input             rst_n        ,
  
    output            touch_rst_n  , 
    input             touch_int_in , 
    output            touch_int_dir, 
    output            touch_int_out, 
    output            touch_scl    , 
    input             touch_sda_in , 
    output            touch_sda_out, 
    output            touch_sda_dir,  

    input     [15:0]  lcd_id       , 
    output            touch_valid  , 
    output    [15:0]  tp_x_coord   , 
    output    [15:0]  tp_y_coord             
);

    //parameter define
    parameter CLK_FREQ = 50_000_000   ; 
    parameter I2C_FREQ = 250_000      ;  
    parameter REG_NUM_WID = 8         ;  
                                        
    //wire define                       
    wire  [6:0]             slave_addr;  
    wire                    i2c_exec  ;  
    wire                    i2c_rh_wl ;  
    wire  [15:0]            i2c_addr  ;  
    wire  [7:0]             i2c_data_w;  
    wire                    bit_ctrl  ;  
    wire  [REG_NUM_WID-1:0] reg_num   ;  
    wire  [7:0]             i2c_data_r;  
    wire                    i2c_done  ;  
    wire                    once_done ;  
    wire                    i2c_ack   ;  
    wire                    dri_clk   ;  


    I2C_DRI_M  #(
        .CLK_FREQ      (CLK_FREQ),       
        .I2C_FREQ      (I2C_FREQ),       
        .WIDTH         (REG_NUM_WID)     
        )                             
        i2c_dri_m(   
        .clk           (clk          ),  
        .rst_n         (rst_n        ),  
                                    
        .slave_addr    (slave_addr   ),  
        .i2c_exec      (i2c_exec     ),  
        .i2c_rh_wl     (i2c_rh_wl    ),  
        .i2c_addr      (i2c_addr     ),  
        .i2c_data_w    (i2c_data_w   ),  
        .bit_ctrl      (bit_ctrl     ),  
        .reg_num       (reg_num      ),  
        .i2c_data_r    (i2c_data_r   ),  
        .i2c_done      (i2c_done     ),  
        .once_done     (once_done    ),  
        .scl           (touch_scl    ),  
        .sda_in        (touch_sda_in ),  
        .sda_out       (touch_sda_out),  
        .sda_dir       (touch_sda_dir),  
        .ack           (i2c_ack      ),  
                                    
        .dri_clk       (dri_clk      )   
        );

    //��������ģ��    
    LCD_TOUCH_DRI  #(
        .WIDTH   (REG_NUM_WID)  
        )
        u_touch_dri(
        .clk           (dri_clk       ), 
        .rst_n         (rst_n         ), 
                                    
        .slave_addr    (slave_addr    ), 
        .i2c_exec      (i2c_exec      ), 
        .i2c_rh_wl     (i2c_rh_wl     ), 
        .i2c_addr      (i2c_addr      ), 
        .i2c_data_w    (i2c_data_w    ), 
        .bit_ctrl      (bit_ctrl      ), 
        .reg_num       (reg_num       ), 
                                    
        .i2c_data_r    (i2c_data_r    ), 
        .i2c_ack       (i2c_ack       ), 
        .i2c_done      (i2c_done      ), 
        .once_done     (once_done     ), 
        
        .lcd_id        (lcd_id        ), 
        .touch_valid   (touch_valid   ), 
        .tp_x_coord    (tp_x_coord    ), 
        .tp_y_coord    (tp_y_coord    ), 
        .touch_rst_n   (touch_rst_n   ), 
        .touch_int_in  (touch_int_in  ), 
        .touch_int_dir (touch_int_dir ), 
        .touch_int_out (touch_int_out )  
        );

endmodule
