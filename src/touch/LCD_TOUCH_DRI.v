module LCD_TOUCH_DRI #(parameter   WIDTH = 4'd8) //һ�ζ�д�Ĵ����ĸ�����λ��
(
    input                   clk          , // Clock signal
    input                   rst_n        , // Reset signal (active low)
    //I2C user ports                        
    output  reg [6:0]       slave_addr   , // I2C device address
    output  reg             i2c_exec     , // I2C trigger control
    output  reg             i2c_rh_wl    , // I2C read/write control
    output  reg [15:0]      i2c_addr     , // I2C operation address
    output  reg [7:0]       i2c_data_w   , // I2C write data
    output  reg             bit_ctrl     , // Word address bit control (0:8-bit, 1:16-bit)
    output  reg [WIDTH-1:0] reg_num      , // Number of registers read/write at once
                                         
    input       [7:0]       i2c_data_r   , // I2C read data
    input                   i2c_ack      , // I2C acknowledgment signal
    input                   i2c_done     , // I2C operation completion flag
    input                   once_done    , // One read/write operation completed    
                                          
    //LCD-related ports                         
    input       [15:0]      lcd_id       , // LCD ID
    output  reg             touch_valid  , // Touch flag
    output  reg [15:0]      tp_x_coord   , // X-axis touch point coordinate
    output  reg [15:0]      tp_y_coord   , // Y-axis touch point coordinate                           
    output  reg             touch_rst_n  , // Touch screen reset
    input                   touch_int_in , // INT input signal
    output  reg             touch_int_dir, // INT direction control signal
    output  reg             touch_int_out  // INT output signal
 );

    //parameter define
    //FTϵ��
    localparam FT_SLAVE_ADDR    = 7'h38;     //FTϵ��������ַ
    localparam FT_BIT_CTRL      = 1'b0;      //FTϵ��λ����
                                            
    localparam FT_ID_LIB_VERSION= 8'hA1;     //�汾
    localparam FT_DEVIDE_MODE   = 8'h00;     //ģʽ���ƼĴ���
    localparam FT_ID_MODE       = 8'hA4;     //FT�ж�ģʽ���ƼĴ���
    localparam FT_ID_THGROUP    = 8'h80;     //������Чֵ���üĴ���
    localparam FT_ID_PERIOD_ACT = 8'h88;     //����״̬�������üĴ���
    localparam FT_STATE_REG     = 8'h02;     //����״̬�Ĵ���
    localparam FT_TP1_REG       = 8'h03;     //��һ�����������ݵ�ַ

    //GT series
    localparam GT_SLAVE_ADDR    = 7'h14;     // GT series device address
    localparam GT_BIT_CTRL      = 1'b1;      // GT series bit control
                                            
    localparam GT_STATE_REG     = 16'h814E;  // Touch state register
    localparam GT_TP1_REG       = 16'h8150;  // First touch point data address

    localparam st_idle          = 7'b000_0001;// Idle state
    localparam st_init          = 7'b000_0010;// Power-on initialization
    localparam st_get_id        = 7'b000_0100;// Get touch chip ID
    localparam st_cfg_reg       = 7'b000_1000;// Configure register
    localparam st_check_touch   = 7'b001_0000;// Check touch state
    localparam st_get_coord     = 7'b010_0000;// Get touch point coordinates
    localparam st_coord_handle  = 7'b100_0000;// Handle coordinate data for mismatched sizes

    //reg define                            
    reg    [6:0]        cur_state   ;
    reg    [6:0]        next_state  ;

    reg                 cnt_1us_en  ;  // Enable timing
    reg    [19:0]       cnt_1us_cnt ;  // Timing counter
    reg    [15:0]       chip_version;  // Chip version number
    reg                 ft_flag     ;  // FT series chip flag
    reg    [15:0]       touch_s_reg ;  // Touch state register
    reg    [15:0]       coord_reg   ;  // Touch point coordinate register
    reg    [15:0]       tp_x_coord_t;  // Temporary X-axis touch point coordinate
    reg    [15:0]       tp_y_coord_t;  // Temporary Y-axis touch point coordinate
    reg    [15:0]       last_tp_x_coord;  // X-axis touch point coordinate at last cycle
    reg    [15:0]       last_tp_y_coord;  // Y-axis touch point coordinate at last cycle
    reg    [3:0]        flow_cnt    ;  // Flow counter
    reg                 st_done     ;  // Operation completion signal

    //*****************************************************
    //**                    main code
    //*****************************************************

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            cnt_1us_cnt <= 20'd0;
        end
        else if(cnt_1us_en)
            cnt_1us_cnt <= cnt_1us_cnt + 1'b1;
        else
            cnt_1us_cnt <= 20'd0;
    end

    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n)
            cur_state <= st_idle;
        else
            cur_state <= next_state;
    end

    always @(*) begin
        case(cur_state)
            st_idle : begin
                if(st_done)
                    next_state = st_init;
                else 
                    next_state = st_idle;
            end
            st_init : begin
                if(st_done)
                    next_state = st_get_id; 
                else
                    next_state = st_init;
            end
            st_get_id : begin
                if(st_done) begin
                    if(ft_flag)  //��FTϵ����Ҫ���üĴ���
                        next_state = st_cfg_reg;
                    else
                        next_state = st_check_touch;
                end
                else
                    next_state = st_get_id;
            end       
            st_cfg_reg : begin
                if(st_done)
                    next_state = st_check_touch;
                else
                    next_state = st_cfg_reg;
            end
            st_check_touch: begin
                if(st_done)
                    next_state = st_get_coord;
                else
                    next_state = st_check_touch;
            end
            st_get_coord : begin
                if(st_done)
                    next_state = st_coord_handle;
                else
                    next_state = st_get_coord;
            end
            st_coord_handle : begin
                if(st_done)
                    next_state = st_check_touch;
                else
                    next_state = st_coord_handle;        
            end
            default: next_state = st_idle;
        endcase
    end

    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            cnt_1us_en   <= 1'b0;
            chip_version <= 1'b0;
            ft_flag      <= 1'b0;
            touch_s_reg  <= 1'b0;
            coord_reg    <= 1'b0;
            tp_x_coord_t <= 1'b0;
            tp_y_coord_t <= 1'b0;
            flow_cnt     <= 1'b0;
            st_done      <= 1'b0;
            touch_int_dir<= 1'b0;
            touch_int_out<= 1'b0;
            
            slave_addr   <= 1'b0;
            i2c_exec     <= 1'b0;
            i2c_rh_wl    <= 1'b0;
            i2c_addr     <= 1'b0;
            i2c_data_w   <= 1'b0;
            bit_ctrl     <= 1'b0;
            reg_num      <= 1'b0;
            
            touch_valid  <= 1'b0;
            tp_x_coord   <= 1'b0;
            tp_y_coord   <= 1'b0;
            touch_rst_n  <= 1'b0;
        end
        else begin
            i2c_exec <= 1'b0;
            st_done <= 1'b0;
            case(next_state)
                st_idle : begin
                    cnt_1us_en <= 1'b1;
                    touch_int_dir <= 1'b1;               //TOUCH INT�˿ڷ�������Ϊ���
                    touch_int_out <= 1'b1;               //TOUCH INT�˿�����ߵ�ƽ
                    if(cnt_1us_cnt >= 10) begin
                        st_done <= 1'b1;
                        cnt_1us_en <= 1'b0;
                    end
                end
                st_init : begin
                    cnt_1us_en <= 1'b1;
                    if(cnt_1us_cnt < 10_000)             // delay 10ms
                        touch_rst_n <= 1'b0;             
                    else if(cnt_1us_cnt == 10_000)
                        touch_rst_n <= 1'b1;            
                    else if(cnt_1us_cnt == 60_000) begin 
                        touch_int_dir <= 1'b0;           // Set INT pin to floating input
                        cnt_1us_en <= 1'b0;
                        st_done <= 1'b1;
                        flow_cnt <= 'd0;                 
                    end    
                end
                st_get_id : begin
                    case(flow_cnt)
                        'd0 : begin
                            //�⼸����Ļ��GTϵ��
                            if(lcd_id == 16'h4384 || lcd_id == 16'h4342 || 
                            lcd_id == 16'h1018) begin 
                                flow_cnt <= 'd5;
                                ft_flag  <= 1'b0;        //ft_flag=0,˵������оƬΪGTϵ�� 
                            end    
                            else
                                flow_cnt <= flow_cnt + 1'b1;
                        end
                        'd1 : begin  //��FTϵ�а汾��
                            i2c_exec <= 1'b1;
                            i2c_rh_wl <= 1'b1;
                            i2c_addr <= FT_ID_LIB_VERSION;
                            reg_num <= 'd2;
                            slave_addr <= FT_SLAVE_ADDR;
                            bit_ctrl <= FT_BIT_CTRL;
                            flow_cnt <= flow_cnt + 1'b1;
                        end
                        'd2 : begin
                            if(once_done) begin
                                chip_version[15:8] <= i2c_data_r;
                                flow_cnt <= flow_cnt + 1'b1;
                            end    
                            else if(i2c_done && i2c_ack) begin  //δӦ��,˵����GTϵ��
                                chip_version = "GT";
                                flow_cnt <= 'd4;
                            end
                        end
                        'd3 : begin
                            if(i2c_done) begin
                                chip_version[7:0] <= i2c_data_r;
                                flow_cnt <= flow_cnt + 1'b1;
                            end
                        end
                        'd4 : begin
                            flow_cnt <= flow_cnt + 1'b1;
                            //FTϵ�а汾:0X3003/0X0001/0X0002/CST340
                            if(chip_version == 16'h3003 || chip_version == 16'h0001  
                            || chip_version == 16'h0002 || chip_version == 16'h0000)
                                ft_flag <= 1'b1;         //ft_flag=1,˵������оƬΪFTϵ�� 
                            else 
                                ft_flag <= 1'b0;         //ft_flag=0,˵������оƬΪGTϵ�� 
                        end
                        'd5 : begin
                            st_done <= 1'b1;
                            flow_cnt <= 'd0;
                            if(ft_flag) begin            //����������ΪFTϵ��
                                touch_s_reg <= FT_STATE_REG;
                                coord_reg <= FT_TP1_REG;
                                bit_ctrl <= FT_BIT_CTRL;
                                slave_addr <= FT_SLAVE_ADDR;   
                            end
                            else begin                   //����������ΪGTϵ��
                                touch_s_reg <= GT_STATE_REG;
                                coord_reg <= GT_TP1_REG;
                                bit_ctrl <= GT_BIT_CTRL;
                                slave_addr <= GT_SLAVE_ADDR;   
                            end                        
                        end
                        default :;
                    endcase    
                end
                st_cfg_reg : begin
                    case(flow_cnt)
                        //����FTϵ��
                        'd0 : begin
                            i2c_exec <= 1'b1;
                            i2c_rh_wl <= 1'b0;
                            i2c_addr <= FT_DEVIDE_MODE;        
                            i2c_data_w <= 8'd0;                    
                            reg_num <= 'd1;
                            flow_cnt <= flow_cnt + 1'b1;  
                        end                          
                        'd1 : begin
                            if(i2c_done) begin
                                if(i2c_ack == 1'b0)      
                                    flow_cnt <= flow_cnt + 1'b1;
                                else                   
                                    flow_cnt <= flow_cnt - 1'b1;
                            end        
                        end
                        'd2 : begin
                            i2c_exec <= 1'b1;
                            i2c_rh_wl <= 1'b0;
                            i2c_addr <= FT_ID_MODE;          
                            i2c_data_w <= 8'd0;              
                            reg_num <= 'd1;
                            flow_cnt <= flow_cnt + 1'b1;     
                        end                           
                        'd3 : begin
                            if(i2c_done) begin
                                if(i2c_ack == 1'b0)      
                                    flow_cnt <= flow_cnt + 1'b1;
                                else                   
                                    flow_cnt <= flow_cnt - 1'b1;
                            end        
                        end
                        'd4 : begin
                            i2c_exec <= 1'b1;
                            i2c_rh_wl <= 1'b0;
                            i2c_addr <= FT_ID_THGROUP;       
                            i2c_data_w <= 8'd22;                 
                            reg_num <= 'd1;
                            flow_cnt <= flow_cnt + 1'b1;    
                        end                        
                        'd5 : begin
                            if(i2c_done) begin
                                if(i2c_ack == 1'b0)    
                                    flow_cnt <= flow_cnt + 1'b1;
                                else                     
                                    flow_cnt <= flow_cnt - 1'b1;
                            end        
                        end      
                        'd6 : begin
                            i2c_exec <= 1'b1;
                            i2c_rh_wl <= 1'b0;
                            i2c_addr <= FT_ID_PERIOD_ACT;       
                            i2c_data_w <= 8'd12;                
                            reg_num <= 'd1;
                            flow_cnt <= flow_cnt + 1'b1;  
                        end                          
                        'd7 : begin
                            if(i2c_done) begin
                                if(i2c_ack == 1'b0) begin
                                    flow_cnt <= 'd0;
                                    st_done <= 1'b1;
                                end    
                                else                 
                                    flow_cnt <= flow_cnt - 1'b1;
                            end
                        end
                        default : ;
                    endcase                       
                end
                st_check_touch : begin
                    case(flow_cnt)
                        'd0: begin  
                            cnt_1us_en <= 1'b1;
                            if(cnt_1us_cnt == 20_000) begin
                                flow_cnt <= flow_cnt + 1'b1;
                                cnt_1us_en <= 1'b0;
                            end    
                        end        
                        'd1 : begin
                            i2c_exec <= 1'b1;
                            i2c_rh_wl <= 1'b1;
                            i2c_addr <= touch_s_reg;     // Read touch point state 
                            reg_num <= 'd1;
                            flow_cnt <= flow_cnt + 1'b1;
                        end
                        'd2 : begin
                            if(i2c_done) begin
                                if(i2c_ack == 1'b0)
                                    flow_cnt <= flow_cnt + 1'b1;
                                else
                                    flow_cnt <= flow_cnt - 1'b1;                                    
                            end
                        end
                        'd3 : begin
                            flow_cnt <= flow_cnt + 1'b1;
                            if(ft_flag) begin
                                if(i2c_data_r[3:0] > 4'd0 && i2c_data_r[3:0] <= 4'd5)
                                    touch_valid <= 1'b1; 
                                else
                                    touch_valid <= 1'b0; 
                            end
                            else begin
                                if(i2c_data_r[7]== 1'b1 && i2c_data_r[3:0] > 4'd0 
                                && i2c_data_r[3:0] <= 4'd5) begin      
                                    touch_valid <= 1'b1; // touch detected
                                end
                                else 
                                    touch_valid <= 1'b0; // No touch detected
                            end
                        end
                        'd4 : begin
                            i2c_exec <= 1'b1;
                            i2c_rh_wl <= 1'b0;
                            i2c_addr <= touch_s_reg;
                            i2c_data_w <= 8'd0;          // Clear touch flag
                            reg_num <= 'd1;
                            flow_cnt <= flow_cnt + 1'b1;
                        end
                        'd5 : begin
                            if(i2c_done) begin
                                if(i2c_ack == 1'b0) begin
                                    st_done <= touch_valid;
                                    flow_cnt <= 1'b0;
                                end
                                else
                                    flow_cnt <= flow_cnt - 1'b1;                                    
                            end                            
                        end
                        default : ;
                    endcase    
                end
                st_get_coord : begin
                    case(flow_cnt)   
                        'd0 : begin
                            i2c_exec <= 1'b1;
                            i2c_rh_wl <= 1'b1;
                            i2c_addr <= coord_reg;       // Get X and Y direction coordinates
                            reg_num <= 'd4;              // Continuous read of four registers
                            flow_cnt <= flow_cnt + 1'b1;
                        end
                        'd1 : begin
                            if(once_done) begin
                                if(i2c_ack == 1'b0) begin
                                    tp_x_coord_t[7:0] <= i2c_data_r;
                                    flow_cnt <= flow_cnt + 1'b1;
                                end    
                                else
                                    flow_cnt <= 1'b0;                                    
                            end
                        end
                        'd2 : begin
                            if(once_done) begin
                                flow_cnt <= flow_cnt + 1'b1;
                                tp_x_coord_t[15:8] <= i2c_data_r;   
                            end                            
                        end
                        'd3 : begin
                            if(once_done) begin
                                flow_cnt <= flow_cnt + 1'b1;
                                tp_y_coord_t[7:0] <= i2c_data_r;    
                            end                            
                        end    
                        'd4 : begin
                            if(once_done) begin
                                st_done  <= 1'b1;
                                flow_cnt <= 'd0;
                                tp_y_coord_t[15:8] <= i2c_data_r;  
                            end                            
                        end
                        default:;
                    endcase    
                end
                st_coord_handle : begin
                    st_done <= 1'b1;
                    if(ft_flag) begin                    //FTϵ���������������
                        tp_x_coord <= {4'd0,tp_y_coord_t[3:0],tp_y_coord_t[15:8]};
                        tp_y_coord <= {4'd0,tp_x_coord_t[3:0],tp_x_coord_t[15:8]};
                    end
                    else begin
                        if (last_tp_x_coord == tp_x_coord_t && last_tp_y_coord == tp_y_coord_t) begin // avoid being stuck at certain coordinate
                            tp_x_coord <= 16'd0;
                            tp_y_coord <= 16'd0;
                        end
                        else begin
                            tp_x_coord <= tp_x_coord_t;
                            tp_y_coord <= tp_y_coord_t;                          
                        end
                    end
                end
                default : ;
            endcase
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            last_tp_x_coord <=  16'd0;
            last_tp_y_coord <=  16'd0;
        end
        else begin
            if (tp_x_coord == 'd0 && tp_y_coord == 'd0) begin
                last_tp_x_coord <= last_tp_x_coord;
                last_tp_y_coord <= last_tp_y_coord;
            end
            else begin
                last_tp_x_coord <=  tp_x_coord;
                last_tp_y_coord <=  tp_y_coord;            
            end

        end
    end

endmodule 
