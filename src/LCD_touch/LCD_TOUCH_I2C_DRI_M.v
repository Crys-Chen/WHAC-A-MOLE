module LCD_TOUCH_I2C_DRI_M
  #(
        parameter   CLK_FREQ   = 26'd50_000_000, // for i2c_dri(CLK_FREQ)
        parameter   I2C_FREQ   = 18'd250_000   , // for I2C's SCL clock
        parameter   WIDTH      =  4'd8           // register width for every rw
   )(
        input               clk        , 
        input               rst_n      , 
        //i2c interface
        input        [6:0]  slave_addr ,  // Device address
        input               i2c_exec   ,  // I2C trigger execution signal
        input               i2c_rh_wl  ,  // I2C read/write control signal
        input        [15:0] i2c_addr   ,  // Internal address of I2C device
        input        [7:0]  i2c_data_w ,  // Data to be written by I2C
        input               bit_ctrl   ,  // Word address bit control (0: 8b, 1: 16b)
        input   [WIDTH-1:0] reg_num    ,  // Number of registers for one read/write operation      
        output  reg  [7:0]  i2c_data_r ,  // Data read by I2C
        output  reg         i2c_done   ,  // I2C operation completed
        output  reg         once_done  ,  // One read/write operation completed
        output  reg         scl        ,  // SCL clock signal of I2C
        input               sda_in     ,  // SDA input signal of I2C
        output  reg         sda_out    ,  // SDA output signal of I2C
        output  reg         sda_dir    ,  // SDA direction control of I2C
        output  reg         ack        ,  // Acknowledgment flag
        //user interface
        output  reg         dri_clk       // Driving clock for I2C operations
     );

    //localparam define
    localparam  st_idle     = 8'b0000_0001; // idle mode
    localparam  st_sladdr   = 8'b0000_0010; // send slave address
    localparam  st_addr16   = 8'b0000_0100; // Send 16-bit word address
    localparam  st_addr8    = 8'b0000_1000; // Send 8-bit word address
    localparam  st_data_wr  = 8'b0001_0000; // Write data (8 bit)
    localparam  st_addr_rd  = 8'b0010_0000; // Send device address for reading
    localparam  st_data_rd  = 8'b0100_0000; // Read data (8 bit)
    localparam  st_stop     = 8'b1000_0000; // End I2C operation

    //reg define
    reg                      st_done     ;  
    reg                      wr_flag     ;  

    reg    [ 6:0]            cnt         ;  
    reg    [ 7:0]            cur_state   ;  
    reg    [ 7:0]            next_state  ;  
    reg    [15:0]            addr_t      ;  
    reg    [ 7:0]            data_r      ;  
    reg    [ 7:0]            data_wr_t   ;  
    reg    [ 9:0]            clk_cnt     ;  
    reg    [WIDTH-1'b1:0]    reg_cnt     ;


    wire   [8:0]  clk_divide             ;  
    wire          reg_done               ;

    assign  clk_divide = (CLK_FREQ/I2C_FREQ) >> 2'd2; 
    assign  reg_done = reg_cnt == reg_num ? 1'b1 : 1'b0;

    // Divide clk for I2C
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            dri_clk <=  1'b1;
            clk_cnt <= 10'd0;
        end
        else if(clk_cnt == clk_divide - 1'd1) begin
            clk_cnt <= 10'd0;
            dri_clk <= ~dri_clk;
        end
        else
            clk_cnt <= clk_cnt + 1'b1;
    end

    always @(posedge dri_clk or negedge rst_n) begin
        if(!rst_n)
            reg_cnt <= 'd0;
        else if(once_done)
            reg_cnt <= reg_cnt + 1'd1;
        else if(i2c_done)
            reg_cnt <= 'd0;   
    end

    // state transfer
    always @(posedge dri_clk or negedge rst_n) begin
        if(rst_n == 1'b0)
            cur_state <= st_idle;
        else
            cur_state <= next_state;
    end

    // state switch
    always @( * ) begin
        case(cur_state)
            st_idle: begin                          
            if(i2c_exec) begin
                next_state = st_sladdr;
            end
            else
                next_state = st_idle;
            end
            st_sladdr: begin
                if(st_done) begin
                    if(!ack) begin
                        if(bit_ctrl)                  // Determine if the word address is 16-bit or 8-bit
                            next_state = st_addr16;
                        else
                            next_state = st_addr8 ;
                    end
                    else 
                        next_state = st_stop;    
                end
                else
                    next_state = st_sladdr;
            end
            st_addr16: begin                          // write 16-bit address
                if(st_done) begin
                    if(!ack) 
                        next_state = st_addr8;
                    else 
                        next_state = st_stop;   
                end
                else
                    next_state = st_addr16;
            end
            st_addr8: begin                           // 8-bit word address
                if(st_done) begin
                    if(!ack) begin
                        if(wr_flag==1'b0)             // r or w ?
                            next_state = st_data_wr;
                        else
                            next_state = st_addr_rd;
                    end
                    else 
                        next_state = st_stop;   
                end
                else
                    next_state = st_addr8;
            end
            st_data_wr: begin                          // write(8-bit)
                if(st_done) begin
                    if(reg_done)
                        next_state = st_stop;
                    else
                        next_state = st_data_wr;
                end
                else
                    next_state = st_data_wr;
            end
            st_addr_rd: begin                          // write address for reading
                if(st_done) begin
                    if(!ack)
                        next_state = st_data_rd;
                    else
                        next_state = st_stop;
                end
                else
                    next_state = st_addr_rd;
            end
            st_data_rd: begin                          // read (8-bit)
                if(st_done) begin
                    if(reg_done)
                        next_state = st_stop;
                    else
                        next_state = st_data_rd;
                end
                else
                    next_state = st_data_rd;
            end
            st_stop: begin                             // end I2C operation
                if(st_done)
                    next_state = st_idle;
                else
                    next_state = st_stop ;
            end
            default: next_state= st_idle;
        endcase
    end

    // Output
    always @(posedge dri_clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            scl        <= 1'b1;
            sda_out    <= 1'b1;
            sda_dir    <= 1'b1;
            i2c_done   <= 1'b0;
            ack        <= 1'b0;
            cnt        <= 1'b0;
            st_done    <= 1'b0;
            once_done  <= 1'b0;
            data_r     <= 1'b0;
            i2c_data_r <= 1'b0;
            wr_flag    <= 1'b0;
            addr_t     <= 1'b0;
            data_wr_t  <= 1'b0;
        end
        else begin
            st_done   <= 1'b0 ;
            once_done <= 1'b0;
            cnt       <= cnt +1'b1 ;
            case(cur_state)
                st_idle: begin                         
                    scl     <= 1'b1;
                    sda_out <= 1'b1;
                    sda_dir <= 1'b1;
                    i2c_done<= 1'b0;
                    cnt     <= 7'b0;
                    if(i2c_exec) begin
                        wr_flag   <= i2c_rh_wl ;
                        addr_t    <= i2c_addr  ;
                        data_wr_t <= i2c_data_w;
                    end
                end
                st_sladdr: begin                         // Writing Address (slave and word)
                    case(cnt)
                        7'd1 : begin
                            sda_dir <= 1'b1 ;
                            sda_out <= 1'b0;             // start I2C
                        end
                        7'd3 : scl <= 1'b0;
                        7'd4 : sda_out <= slave_addr[6]; // send slave address
                        7'd5 : scl <= 1'b1;
                        7'd7 : scl <= 1'b0;
                        7'd8 : sda_out <= slave_addr[5];
                        7'd9 : scl <= 1'b1;
                        7'd11: scl <= 1'b0;
                        7'd12: sda_out <= slave_addr[4];
                        7'd13: scl <= 1'b1;
                        7'd15: scl <= 1'b0;
                        7'd16: sda_out <= slave_addr[3];
                        7'd17: scl <= 1'b1;
                        7'd19: scl <= 1'b0;
                        7'd20: sda_out <= slave_addr[2];
                        7'd21: scl <= 1'b1;
                        7'd23: scl <= 1'b0;
                        7'd24: sda_out <= slave_addr[1];
                        7'd25: scl <= 1'b1;
                        7'd27: scl <= 1'b0;
                        7'd28: sda_out <= slave_addr[0];
                        7'd29: scl <= 1'b1;
                        7'd31: scl <= 1'b0;
                        7'd32: sda_out <= 1'b0;              // 0: write
                        7'd33: scl <= 1'b1;
                        7'd35: scl <= 1'b0;
                        7'd36: begin
                            sda_dir <= 1'b0;                 // slave acknowledge
                            sda_out <= 1'b1;
                        end
                        7'd37: begin 
                            scl <= 1'b1; 
                            ack <= sda_in;
                        end
                        7'd42: st_done <= 1'b1;
                        7'd43: begin //7'd39
                            scl <= 1'b0;
                            cnt <= 1'b0;
                        end
                        default :  ;
                    endcase
                end
                st_addr16: begin
                    case(cnt)
                        7'd0 : begin
                            sda_dir <= 1'b1 ;
                            sda_out <= addr_t[15];           // send word address
                        end
                        7'd1 : scl <= 1'b1;
                        7'd3 : scl <= 1'b0;
                        7'd4 : sda_out <= addr_t[14];
                        7'd5 : scl <= 1'b1;
                        7'd7 : scl <= 1'b0;
                        7'd8 : sda_out <= addr_t[13];
                        7'd9 : scl <= 1'b1;
                        7'd11: scl <= 1'b0;
                        7'd12: sda_out <= addr_t[12];
                        7'd13: scl <= 1'b1;
                        7'd15: scl <= 1'b0;
                        7'd16: sda_out <= addr_t[11];
                        7'd17: scl <= 1'b1;
                        7'd19: scl <= 1'b0;
                        7'd20: sda_out <= addr_t[10];
                        7'd21: scl <= 1'b1;
                        7'd23: scl <= 1'b0;
                        7'd24: sda_out <= addr_t[9];
                        7'd25: scl <= 1'b1;
                        7'd27: scl <= 1'b0;
                        7'd28: sda_out <= addr_t[8];
                        7'd29: scl <= 1'b1;
                        7'd31: scl <= 1'b0;
                        7'd32: begin
                            sda_dir <= 1'b0;                 // slave acknowledge
                            sda_out <= 1'b1;
                        end
                        7'd33:  begin 
                            scl <= 1'b1; 
                            ack <= sda_in;
                        end
                        7'd38: st_done <= 1'b1;
                        7'd39: begin //7'd35
                            scl <= 1'b0;
                            cnt <= 1'b0;
                        end
                        default :  ;
                    endcase
                end
                st_addr8: begin
                    case(cnt)
                        7'd0: begin
                        sda_dir <= 1'b1 ;
                        sda_out <= addr_t[7];            // word address
                        end
                        7'd1 : scl <= 1'b1;
                        7'd3 : scl <= 1'b0;
                        7'd4 : sda_out <= addr_t[6];
                        7'd5 : scl <= 1'b1;
                        7'd7 : scl <= 1'b0;
                        7'd8 : sda_out <= addr_t[5];
                        7'd9 : scl <= 1'b1;
                        7'd11: scl <= 1'b0;
                        7'd12: sda_out <= addr_t[4];
                        7'd13: scl <= 1'b1;
                        7'd15: scl <= 1'b0;
                        7'd16: sda_out <= addr_t[3];
                        7'd17: scl <= 1'b1;
                        7'd19: scl <= 1'b0;
                        7'd20: sda_out <= addr_t[2];
                        7'd21: scl <= 1'b1;
                        7'd23: scl <= 1'b0;
                        7'd24: sda_out <= addr_t[1];
                        7'd25: scl <= 1'b1;
                        7'd27: scl <= 1'b0;
                        7'd28: sda_out <= addr_t[0];
                        7'd29: scl <= 1'b1;
                        7'd31: scl <= 1'b0;
                        7'd32: begin
                            sda_dir <= 1'b0;                // slave acknowledge
                            sda_out <= 1'b1;
                        end
                        7'd33:  begin 
                            scl <= 1'b1; 
                            ack <= sda_in;
                        end
                        7'd38: st_done <= 1'b1;
                        7'd39: begin //7'd35
                            scl <= 1'b0;
                            cnt <= 1'b0;
                        end
                        default :  ;
                    endcase
                end
                st_data_wr: begin                            // write (8-bit)
                    case(cnt)
                        7'd0: begin
                            sda_out <= i2c_data_w[7];        // write
                            data_wr_t <= i2c_data_w;
                            sda_dir <= 1'b1;
                        end
                        7'd1 : scl <= 1'b1;
                        7'd3 : scl <= 1'b0;
                        7'd4 : sda_out <= data_wr_t[6];
                        7'd5 : scl <= 1'b1;
                        7'd7 : scl <= 1'b0;
                        7'd8 : sda_out <= data_wr_t[5];
                        7'd9 : scl <= 1'b1;
                        7'd11: scl <= 1'b0;
                        7'd12: sda_out <= data_wr_t[4];
                        7'd13: scl <= 1'b1;
                        7'd15: scl <= 1'b0;
                        7'd16: sda_out <= data_wr_t[3];
                        7'd17: scl <= 1'b1;
                        7'd19: scl <= 1'b0;
                        7'd20: sda_out <= data_wr_t[2];
                        7'd21: scl <= 1'b1;
                        7'd23: scl <= 1'b0;
                        7'd24: sda_out <= data_wr_t[1];
                        7'd25: scl <= 1'b1;
                        7'd27: scl <= 1'b0;
                        7'd28: sda_out <= data_wr_t[0];
                        7'd29: scl <= 1'b1;
                        7'd31: scl <= 1'b0;
                        7'd32: begin
                            sda_dir <= 1'b0;                
                            sda_out <= 1'b1;
                            once_done <= 1'b1;
                        end
                        7'd33:  begin 
                            scl <= 1'b1; 
                            ack <= sda_in;
                        end
                        7'd38: st_done <= 1'b1;
                        7'd39: begin //7'd35
                            scl  <= 1'b0;
                            cnt  <= 1'b0;
                        end
                        default  :  ;
                    endcase
                end
                st_addr_rd: begin                           
                    case(cnt)
                        7'd0 : begin
                            sda_dir <= 1'b1;
                            sda_out <= 1'b1;
                        end
                        7'd1 : scl <= 1'b1;
                        7'd2 : sda_out <= 1'b0;             // restart
                        7'd3 : scl <= 1'b0;
                        7'd4 : sda_out <= slave_addr[6];    
                        7'd5 : scl <= 1'b1;
                        7'd7 : scl <= 1'b0;
                        7'd8 : sda_out <= slave_addr[5];
                        7'd9 : scl <= 1'b1;
                        7'd11: scl <= 1'b0;
                        7'd12: sda_out <= slave_addr[4];
                        7'd13: scl <= 1'b1;
                        7'd15: scl <= 1'b0;
                        7'd16: sda_out <= slave_addr[3];
                        7'd17: scl <= 1'b1;
                        7'd19: scl <= 1'b0;
                        7'd20: sda_out <= slave_addr[2];
                        7'd21: scl <= 1'b1;
                        7'd23: scl <= 1'b0;
                        7'd24: sda_out <= slave_addr[1];
                        7'd25: scl <= 1'b1;
                        7'd27: scl <= 1'b0;
                        7'd28: sda_out <= slave_addr[0];
                        7'd29: scl <= 1'b1;
                        7'd31: scl <= 1'b0;
                        7'd32: sda_out <= 1'b1;             // 1: read
                        7'd33: scl <= 1'b1;
                        7'd35: scl <= 1'b0;
                        7'd36: begin
                            sda_dir <= 1'b0;                
                            sda_out <= 1'b1;
                        end
                        7'd37:  begin 
                            scl <= 1'b1; 
                            ack <= sda_in;
                        end
                        7'd42: st_done <= 1'b1;
                        7'd43: begin //7'd39
                            scl <= 1'b0;
                            cnt <= 1'b0;
                        end
                        default : ;
                    endcase
                end
                st_data_rd: begin                          // read (8-bit)
                    case(cnt)
                        7'd0: sda_dir <= 1'b0;
                        7'd1: begin
                            data_r[7] <= sda_in;
                            scl       <= 1'b1;
                        end
                        7'd3: scl  <= 1'b0;
                        7'd5: begin
                            data_r[6] <= sda_in ;
                            scl       <= 1'b1   ;
                        end
                        7'd7: scl  <= 1'b0;
                        7'd9: begin
                            data_r[5] <= sda_in;
                            scl       <= 1'b1  ;
                        end
                        7'd11: scl  <= 1'b0;
                        7'd13: begin
                            data_r[4] <= sda_in;
                            scl       <= 1'b1  ;
                        end
                        7'd15: scl  <= 1'b0;
                        7'd17: begin
                            data_r[3] <= sda_in;
                            scl       <= 1'b1  ;
                        end
                        7'd19: scl  <= 1'b0;
                        7'd21: begin
                            data_r[2] <= sda_in;
                            scl       <= 1'b1  ;
                        end
                        7'd23: scl  <= 1'b0;
                        7'd25: begin
                            data_r[1] <= sda_in;
                            scl       <= 1'b1  ;
                        end
                        7'd27: scl  <= 1'b0;
                        7'd29: begin
                            data_r[0] <= sda_in;
                            scl       <= 1'b1  ;
                        end
                        7'd31: scl  <= 1'b0;
                        7'd32: begin                       
                            if(reg_cnt == reg_cnt - 1'b1) begin
                                sda_dir <= 1'b1;          // do not ac
                                sda_out <= 1'b1;
                            end
                            else begin
                                sda_dir <= 1'b1;          // ac
                                sda_out <= 1'b0;
                            end
                        end
                        7'd33: begin
                            scl        <= 1'b1;
                            once_done  <= 1'b1;
                            i2c_data_r <= data_r;
                        end
                        7'd38: st_done <= 1'b1;
                        7'd39: begin  //7'd35
                            scl <= 1'b0;
                            cnt <= 1'b0;    
                        end
                        default  :  ;
                    endcase
                end
                st_stop: begin                            // end I2C
                    case(cnt)
                        7'd0: begin
                            sda_dir <= 1'b1;             
                            sda_out <= 1'b0;
                        end
                        7'd1 : scl     <= 1'b1;
                        7'd3 : sda_out <= 1'b1;
                        7'd5: st_done <= 1'b1;
                        7'd6: begin
                            cnt      <= 1'b0;
                            i2c_done <= 1'b1;            
                        end
                        default  : ;
                    endcase
                end
            endcase
        end
    end

endmodule