module LCD_DISPLAY_DRIVER(
    input                clk,    // Clock
    input                rst_n,   // Reset, active low
	
    input        [15:0]  lcd_id,      // LCD screen ID
	
    input        [23:0]  pixel_data,  // Pixel data
    output       [10:0]  pixel_xpos,  // Current pixel horizontal coordinate
    output       [10:0]  pixel_ypos,  // Current pixel vertical coordinate   
    output  reg  [10:0]  h_disp,      // LCD screen horizontal resolution
    output  reg  [10:0]  v_disp,      // LCD screen vertical resolution   
    //RGB LCD interface
    output               lcd_de,      // LCD data enable signal
    output               lcd_hs,      // LCD horizontal sync signal
    output               lcd_vs,      // LCD vertical sync signal
    output               lcd_bl,      // LCD backlight control signal
    output               lcd_clk,     // LCD pixel clock
    output       [23:0]  lcd_rgb      // LCD RGB color data
    );

    //parameter define  
    // 4.3' 480*272
    parameter  H_SYNC_4342   =  11'd41;     // Horizontal sync
    parameter  H_BACK_4342   =  11'd2;      // Horizontal back porch
    parameter  H_DISP_4342   =  11'd480;    // Horizontal display width
    parameter  H_FRONT_4342  =  11'd2;      // Horizontal front porch
    parameter  H_TOTAL_4342  =  11'd525;    // Horizontal total period
    
    parameter  V_SYNC_4342   =  11'd10;     // Vertical sync
    parameter  V_BACK_4342   =  11'd2;      // Vertical back porch
    parameter  V_DISP_4342   =  11'd272;    // Vertical display height
    parameter  V_FRONT_4342  =  11'd2;      // Vertical front porch
    parameter  V_TOTAL_4342  =  11'd286;    // Vertical total period
    
    // 7' 800*480   
    parameter  H_SYNC_7084   =  11'd128;    // Horizontal sync
    parameter  H_BACK_7084   =  11'd88;     // Horizontal back porch
    parameter  H_DISP_7084   =  11'd800;    // Horizontal display width
    parameter  H_FRONT_7084  =  11'd40;     // Horizontal front porch
    parameter  H_TOTAL_7084  =  11'd1056;   // Horizontal total period
    
    parameter  V_SYNC_7084   =  11'd2;      // Vertical sync
    parameter  V_BACK_7084   =  11'd33;     // Vertical back porch
    parameter  V_DISP_7084   =  11'd480;    // Vertical display height
    parameter  V_FRONT_7084  =  11'd10;     // Vertical front porch
    parameter  V_TOTAL_7084  =  11'd525;    // Vertical total period       
    
    // 7' 1024*600   
    parameter  H_SYNC_7016   =  11'd20;     // Horizontal sync
    parameter  H_BACK_7016   =  11'd140;    // Horizontal back porch
    parameter  H_DISP_7016   =  11'd1024;   // Horizontal display width
    parameter  H_FRONT_7016  =  11'd160;    // Horizontal front porch
    parameter  H_TOTAL_7016  =  11'd1344;   // Horizontal total period
    
    parameter  V_SYNC_7016   =  11'd3;      // Vertical sync
    parameter  V_BACK_7016   =  11'd20;     // Vertical back porch
    parameter  V_DISP_7016   =  11'd600;    // Vertical display height
    parameter  V_FRONT_7016  =  11'd12;     // Vertical front porch
    parameter  V_TOTAL_7016  =  11'd635;    // Vertical total period
    
    // 10.1' 1280*800   
    parameter  H_SYNC_1018   =  11'd10;     // Horizontal sync
    parameter  H_BACK_1018   =  11'd80;     // Horizontal back porch
    parameter  H_DISP_1018   =  11'd1280;   // Horizontal display width
    parameter  H_FRONT_1018  =  11'd70;     // Horizontal front porch
    parameter  H_TOTAL_1018  =  11'd1440;   // Horizontal total period
    
    parameter  V_SYNC_1018   =  11'd3;      // Vertical sync
    parameter  V_BACK_1018   =  11'd10;     // Vertical back porch
    parameter  V_DISP_1018   =  11'd800;    // Vertical display height
    parameter  V_FRONT_1018  =  11'd10;     // Vertical front porch
    parameter  V_TOTAL_1018  =  11'd823;    // Vertical total period

    // 4.3' 800*480   
    parameter  H_SYNC_4384   =  11'd128;    // Horizontal sync
    parameter  H_BACK_4384   =  11'd88;     // Horizontal back porch
    parameter  H_DISP_4384   =  11'd800;    // Horizontal display width
    parameter  H_FRONT_4384  =  11'd40;     // Horizontal front porch
    parameter  H_TOTAL_4384  =  11'd1056;   // Horizontal total period
    
    parameter  V_SYNC_4384   =  11'd2;      // Vertical sync
    parameter  V_BACK_4384   =  11'd33;     // Vertical back porch
    parameter  V_DISP_4384   =  11'd480;    // Vertical display height
    parameter  V_FRONT_4384  =  11'd10;     // Vertical front porch
    parameter  V_TOTAL_4384  =  11'd525;    // Vertical total period    

    //reg define
    reg  [10:0] h_sync ;
    reg  [10:0] h_back ;
    reg  [10:0] h_total;
    reg  [10:0] v_sync ;
    reg  [10:0] v_back ;
    reg  [10:0] v_total;
    reg  [10:0] h_cnt  ;
    reg  [10:0] v_cnt  ;

    //wire define    
    wire        lcd_en;
    wire        data_req;

    //*****************************************************
    //**                    main code
    //*****************************************************

    // When using DE mode for RGB LCD, the horizontal and vertical sync signals need to be pulled high
    assign  lcd_hs = 1'b1;        // LCD horizontal sync signal
    assign  lcd_vs = 1'b1;        // LCD vertical sync signal

    assign  lcd_bl = 1'b1;        // LCD backlight control signal  
    assign  lcd_clk = clk;   // LCD pixel clock
    assign  lcd_de = lcd_en;      // LCD data enable signal

    // Enable RGB888 data output
    assign  lcd_en = ((h_cnt >= h_sync + h_back) && (h_cnt < h_sync + h_back + h_disp)
                    && (v_cnt >= v_sync + v_back) && (v_cnt < v_sync + v_back + v_disp)) 
                    ? 1'b1 : 1'b0;

    // Request pixel color data input    
    assign data_req = ((h_cnt >= h_sync + h_back - 1'b1) && (h_cnt < h_sync + h_back + h_disp - 1'b1)
                    && (v_cnt >= v_sync + v_back) && (v_cnt < v_sync + v_back + v_disp)) 
                    ? 1'b1 : 1'b0;

    // Pixel coordinates    
    assign pixel_xpos = data_req ? (h_cnt - (h_sync + h_back - 1'b1)) : 11'd0;
    assign pixel_ypos = data_req ? (v_cnt - (v_sync + v_back - 1'b1)) : 11'd0;

    // RGB888 data output
    assign lcd_rgb = lcd_en ? pixel_data : 24'd0;

    // Horizontal and vertical timing parameters
    always @(*) begin
        case(lcd_id)
            16'h4342 : begin
                h_sync  = H_SYNC_4342; 
                h_back  = H_BACK_4342; 
                h_disp  = H_DISP_4342; 
                h_total = H_TOTAL_4342;
                v_sync  = V_SYNC_4342; 
                v_back  = V_BACK_4342; 
                v_disp  = V_DISP_4342; 
                v_total = V_TOTAL_4342;            
            end
            16'h7084 : begin
                h_sync  = H_SYNC_7084; 
                h_back  = H_BACK_7084; 
                h_disp  = H_DISP_7084; 
                h_total = H_TOTAL_7084;
                v_sync  = V_SYNC_7084; 
                v_back  = V_BACK_7084; 
                v_disp  = V_DISP_7084; 
                v_total = V_TOTAL_7084;        
            end
            16'h7016 : begin
                h_sync  = H_SYNC_7016; 
                h_back  = H_BACK_7016; 
                h_disp  = H_DISP_7016; 
                h_total = H_TOTAL_7016;
                v_sync  = V_SYNC_7016; 
                v_back  = V_BACK_7016; 
                v_disp  = V_DISP_7016; 
                v_total = V_TOTAL_7016;            
            end
            16'h4384 : begin
                h_sync  = H_SYNC_4384; 
                h_back  = H_BACK_4384; 
                h_disp  = H_DISP_4384; 
                h_total = H_TOTAL_4384;
                v_sync  = V_SYNC_4384; 
                v_back  = V_BACK_4384; 
                v_disp  = V_DISP_4384; 
                v_total = V_TOTAL_4384;             
            end        
            16'h1018 : begin
                h_sync  = H_SYNC_1018; 
                h_back  = H_BACK_1018; 
                h_disp  = H_DISP_1018; 
                h_total = H_TOTAL_1018;
                v_sync  = V_SYNC_1018; 
                v_back  = V_BACK_1018; 
                v_disp  = V_DISP_1018; 
                v_total = V_TOTAL_1018;        
            end
            default : begin
                h_sync  = H_SYNC_4342; 
                h_back  = H_BACK_4342; 
                h_disp  = H_DISP_4342; 
                h_total = H_TOTAL_4342;
                v_sync  = V_SYNC_4342; 
                v_back  = V_BACK_4342; 
                v_disp  = V_DISP_4342; 
                v_total = V_TOTAL_4342;          
            end
        endcase
    end

    // Line counter for pixel clock counting
    always@ (posedge clk or negedge rst_n) begin
        if(!rst_n) 
            h_cnt <= 11'd0;
        else begin
            if(h_cnt == h_total - 1'b1)
                h_cnt <= 11'd0;
            else
                h_cnt <= h_cnt + 1'b1;           
        end
    end

    // Field counter for line counting
    always@ (posedge clk or negedge rst_n) begin
        if(!rst_n) 
            v_cnt <= 11'd0;
        else begin
            if(h_cnt == h_total - 1'b1) begin
                if(v_cnt == v_total - 1'b1)
                    v_cnt <= 11'd0;
                else
                    v_cnt <= v_cnt + 1'b1;    
            end
        end    
    end

endmodule
