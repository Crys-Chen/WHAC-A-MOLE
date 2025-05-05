`include "PARAM.vh"
module LCD_SCREEN(
    input             clk,                  
    input             rst_n,               
    
	input  [9  : 0]    timer,
    input  [19 : 0]    moles,
    input  [1  : 0]    state,
    input  [9  : 0]    score,
    input  [7  : 0]    kill,
    input  [7  : 0]    runaway,
    input  [7  : 0]    combo,
    input  [3  : 0]    level,
	
    input      [10:0] pixel_xpos,             
    input      [10:0] pixel_ypos,             
    output reg [23:0] pixel_data                
);

	// //parameter define
	localparam CLK_POS_X  = 11'd1;                
	localparam CLK_POS_Y  = 11'd1;                
	localparam CHAR_WIDTH  = 11'd144;              
	localparam CHAR_HEIGHT = 11'd32;               

	localparam WHITE  = 24'b11111111_11111111_11111111;     
	localparam BLACK  = 24'b00000000_00000000_00000000;     

	//reg define
	reg    [511:0]  char  [11:0] ;               

	// //wire define
	// wire   [3:0]              data0    ;       
	// wire   [3:0]              data1    ;       
	// wire   [3:0]              data2    ;       
	// wire   [3:0]              data3    ;       
	// wire   [3:0]              data4    ;       
	// wire   [3:0]              data5    ;       
	// wire   [3:0]              data6    ;        


	//*****************************************************
	//**                    main code
	//*****************************************************
	// assign  data6 = data[31:16] / 10'd1000 % 4'd10 ;          
	// assign  data5 = data[31:16] / 7'd100 % 4'd10   ;  
	// assign  data4 = data[31:16] / 4'd10 % 4'd10    ;  
	// assign  data3 = data[31:16] % 4'd10            ;  
	// assign  data2 = data[15:0]  / 7'd100 % 4'd10   ;  
	// assign  data1 = data[15:0]  / 4'd10 % 4'd10    ;  
	// assign  data0 = data[15:0]  % 4'd10            ;  

	wire   [3:0]			  timer_data2;
	wire   [3:0]			  timer_data1;
	wire   [3:0]			  timer_data0;

	wire   [3:0]              score_data2;        // hundred
	wire   [3:0]              score_data1;        // decimal
	wire   [3:0]              score_data0;        // single

	wire   [3:0]              kill_data1;        // decimal
	wire   [3:0]              kill_data0;        // single

	wire   [3:0]              runaway_data1;        // decimal
	wire   [3:0]              runaway_data0;        // single

	wire   [3:0]              combo_data1;        // decimal
	wire   [3:0]              combo_data0;        // single

	reg    [23:0] 			  timer_data;
	reg    [23:0] 			  score_data;
	reg    [23:0] 			  kill_data;
	reg    [23:0] 			  runaway_data;
	reg    [23:0] 			  combo_data;
	reg    [23:0] 			  statistics;
	reg	   [23:0]			  final_score;


	assign  timer_data2 = timer  / 7'd100 % 4'd10   ;  
	assign  timer_data1 = timer  / 4'd10 % 4'd10    ;  
	assign  timer_data0 = timer  % 4'd10            ;  

	assign	score_data2 = score / 7'd100 % 4'd10; 
	assign	score_data1 = score / 4'd10 % 4'd10 ;
	assign	score_data0 = score % 4'd10   		; 

	assign	kill_data1	= kill / 4'd10 % 4'd10 ;
	assign	kill_data0	= kill % 4'd10 ;

	assign	runaway_data1	= runaway / 4'd10 % 4'd10 ;
	assign	runaway_data0	= runaway % 4'd10 ;

	assign	combo_data1	= combo / 4'd10 % 4'd10 ;
	assign	combo_data0	= combo % 4'd10 ;


	always @(posedge clk) begin
		char[0 ]  <= {8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h03,8'hC0,8'h06,8'h20,
					8'h0C,8'h30,8'h18,8'h18,8'h18,8'h18,8'h18,8'h08,8'h30,8'h0C,8'h30,8'h0C,8'h30,8'h0C,8'h30,8'h0C,
					8'h30,8'h0C,8'h30,8'h0C,8'h30,8'h0C,8'h30,8'h0C,8'h30,8'h0C,8'h30,8'h0C,8'h18,8'h08,8'h18,8'h18,
					8'h18,8'h18,8'h0C,8'h30,8'h06,8'h20,8'h03,8'hC0,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00} ; // "0"
		char[1 ]  <= {8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h80,8'h01,8'h80,
					8'h1F,8'h80,8'h01,8'h80,8'h01,8'h80,8'h01,8'h80,8'h01,8'h80,8'h01,8'h80,8'h01,8'h80,8'h01,8'h80,
					8'h01,8'h80,8'h01,8'h80,8'h01,8'h80,8'h01,8'h80,8'h01,8'h80,8'h01,8'h80,8'h01,8'h80,8'h01,8'h80,
					8'h01,8'h80,8'h01,8'h80,8'h03,8'hC0,8'h1F,8'hF8,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00} ; // "1"
		char[2 ]  <= {8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h07,8'hE0,8'h08,8'h38,
					8'h10,8'h18,8'h20,8'h0C,8'h20,8'h0C,8'h30,8'h0C,8'h30,8'h0C,8'h00,8'h0C,8'h00,8'h18,8'h00,8'h18,
					8'h00,8'h30,8'h00,8'h60,8'h00,8'hC0,8'h01,8'h80,8'h03,8'h00,8'h02,8'h00,8'h04,8'h04,8'h08,8'h04,
					8'h10,8'h04,8'h20,8'h0C,8'h3F,8'hF8,8'h3F,8'hF8,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00} ; // "2"
		char[3 ]  <= {8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h07,8'hC0,8'h18,8'h60,
					8'h30,8'h30,8'h30,8'h18,8'h30,8'h18,8'h30,8'h18,8'h00,8'h18,8'h00,8'h18,8'h00,8'h30,8'h00,8'h60,
					8'h03,8'hC0,8'h00,8'h70,8'h00,8'h18,8'h00,8'h08,8'h00,8'h0C,8'h00,8'h0C,8'h30,8'h0C,8'h30,8'h0C,
					8'h30,8'h08,8'h30,8'h18,8'h18,8'h30,8'h07,8'hC0,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00} ; // "3"
		char[4 ]  <= {8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h60,8'h00,8'h60,
					8'h00,8'hE0,8'h00,8'hE0,8'h01,8'h60,8'h01,8'h60,8'h02,8'h60,8'h04,8'h60,8'h04,8'h60,8'h08,8'h60,
					8'h08,8'h60,8'h10,8'h60,8'h30,8'h60,8'h20,8'h60,8'h40,8'h60,8'h7F,8'hFC,8'h00,8'h60,8'h00,8'h60,
					8'h00,8'h60,8'h00,8'h60,8'h00,8'h60,8'h03,8'hFC,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00} ; // "4"
		char[5 ]  <= {8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h0F,8'hFC,8'h0F,8'hFC,
					8'h10,8'h00,8'h10,8'h00,8'h10,8'h00,8'h10,8'h00,8'h10,8'h00,8'h10,8'h00,8'h13,8'hE0,8'h14,8'h30,
					8'h18,8'h18,8'h10,8'h08,8'h00,8'h0C,8'h00,8'h0C,8'h00,8'h0C,8'h00,8'h0C,8'h30,8'h0C,8'h30,8'h0C,
					8'h20,8'h18,8'h20,8'h18,8'h18,8'h30,8'h07,8'hC0,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00} ; // "5"
		char[6 ]  <= {8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h01,8'hE0,8'h06,8'h18,
					8'h0C,8'h18,8'h08,8'h18,8'h18,8'h00,8'h10,8'h00,8'h10,8'h00,8'h30,8'h00,8'h33,8'hE0,8'h36,8'h30,
					8'h38,8'h18,8'h38,8'h08,8'h30,8'h0C,8'h30,8'h0C,8'h30,8'h0C,8'h30,8'h0C,8'h30,8'h0C,8'h18,8'h0C,
					8'h18,8'h08,8'h0C,8'h18,8'h0E,8'h30,8'h03,8'hE0,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00} ; // "6"
		char[7 ]  <= {8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h1F,8'hFC,8'h1F,8'hFC,
					8'h10,8'h08,8'h30,8'h10,8'h20,8'h10,8'h20,8'h20,8'h00,8'h20,8'h00,8'h40,8'h00,8'h40,8'h00,8'h40,
					8'h00,8'h80,8'h00,8'h80,8'h01,8'h00,8'h01,8'h00,8'h01,8'h00,8'h01,8'h00,8'h03,8'h00,8'h03,8'h00,
					8'h03,8'h00,8'h03,8'h00,8'h03,8'h00,8'h03,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00} ; // "7"
		char[8 ]  <= {8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h07,8'hE0,8'h0C,8'h30,
					8'h18,8'h18,8'h30,8'h0C,8'h30,8'h0C,8'h30,8'h0C,8'h38,8'h0C,8'h38,8'h08,8'h1E,8'h18,8'h0F,8'h20,
					8'h07,8'hC0,8'h18,8'hF0,8'h30,8'h78,8'h30,8'h38,8'h60,8'h1C,8'h60,8'h0C,8'h60,8'h0C,8'h60,8'h0C,
					8'h60,8'h0C,8'h30,8'h18,8'h18,8'h30,8'h07,8'hC0,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00} ; // "8"
		char[9 ]  <= {8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h07,8'hC0,8'h18,8'h20,
					8'h30,8'h10,8'h30,8'h18,8'h60,8'h08,8'h60,8'h0C,8'h60,8'h0C,8'h60,8'h0C,8'h60,8'h0C,8'h60,8'h0C,
					8'h70,8'h1C,8'h30,8'h2C,8'h18,8'h6C,8'h0F,8'h8C,8'h00,8'h0C,8'h00,8'h18,8'h00,8'h18,8'h00,8'h10,
					8'h30,8'h30,8'h30,8'h60,8'h30,8'hC0,8'h0F,8'h80,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00} ; // "9"
		char[10]  <= {8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h7C,8'h3E,8'h18,8'h08,
					8'h18,8'h10,8'h0C,8'h10,8'h0C,8'h20,8'h06,8'h20,8'h06,8'h40,8'h03,8'h40,8'h03,8'h80,8'h01,8'h80,
					8'h01,8'h80,8'h01,8'h80,8'h01,8'hC0,8'h02,8'hC0,8'h02,8'h60,8'h04,8'h60,8'h04,8'h70,8'h08,8'h30,
					8'h08,8'h30,8'h18,8'h18,8'h10,8'h1C,8'h7C,8'h3E,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00}; // "X"
		char[11]  <= {8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h7E,8'h3E,8'h38,8'h08,
					8'h18,8'h08,8'h18,8'h10,8'h0C,8'h10,8'h0C,8'h10,8'h0C,8'h20,8'h06,8'h20,8'h06,8'h20,8'h03,8'h40,
					8'h03,8'h40,8'h03,8'h80,8'h01,8'h80,8'h01,8'h80,8'h01,8'h80,8'h01,8'h80,8'h01,8'h80,8'h01,8'h80,
					8'h01,8'h80,8'h01,8'h80,8'h01,8'h80,8'h07,8'hE0,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00}; // "Y"
	end


	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)  begin
			timer_data <= WHITE;
		end
		else if((pixel_xpos >= CLK_POS_X) && (pixel_xpos < CLK_POS_X + 16)
			&& (pixel_ypos >= CLK_POS_Y) && (pixel_ypos < CLK_POS_Y + 32)) begin
			if(char [timer_data2] [ (CHAR_HEIGHT+CLK_POS_Y - pixel_ypos)*16 - ((pixel_xpos-CLK_POS_X)%16) -1 ]  )
				timer_data <= BLACK;
			else
				timer_data <= WHITE;
		end	   
		else if((pixel_xpos >= CLK_POS_X + 16) && (pixel_xpos < CLK_POS_X + 16*2)
			&& (pixel_ypos >= CLK_POS_Y)      && (pixel_ypos < CLK_POS_Y + 32)) begin
			if(char [timer_data1] [ (CHAR_HEIGHT+CLK_POS_Y - pixel_ypos)*16 - ((pixel_xpos-CLK_POS_X)%16) -1 ] )
				timer_data <= BLACK;       
			else
				timer_data <= WHITE;          
		end
		else if((pixel_xpos >= CLK_POS_X + 16*2) && (pixel_xpos < CLK_POS_X + 16*3)
			&& (pixel_ypos >= CLK_POS_Y)        && (pixel_ypos < CLK_POS_Y + 32)) begin
			if(char [timer_data0] [ (CHAR_HEIGHT+CLK_POS_Y - pixel_ypos)*16 - ((pixel_xpos-CLK_POS_X)%16) -1 ]  )
				timer_data <= BLACK;
			else
				timer_data <= WHITE;
		end
		else begin
			timer_data <= WHITE;            
		end
	end


	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)  begin
			statistics <= WHITE;
		end
		else if ((pixel_xpos >= `TEXT_LEFT_X)  && (pixel_xpos < `TEXT_LEFT_X + 16)) begin
			if (pixel_ypos >= `SCORE_TOP_Y && pixel_ypos < `SCORE_TOP_Y + 32 &&
				char[score_data2][(CHAR_HEIGHT+`SCORE_TOP_Y-pixel_ypos)*16 - ((pixel_xpos-`TEXT_LEFT_X)%16) -1])
				statistics	<=	BLACK;
			else if (pixel_ypos >= `KILL_TOP_Y && pixel_ypos < `KILL_TOP_Y + 32 &&
				char[0][(CHAR_HEIGHT+`KILL_TOP_Y-pixel_ypos)*16 - ((pixel_xpos-`TEXT_LEFT_X)%16) -1])
				statistics	<=	BLACK;
			else if (pixel_ypos >= `RUNAWAY_TOP_Y && pixel_ypos < `RUNAWAY_TOP_Y + 32 &&
				char[0][(CHAR_HEIGHT+`RUNAWAY_TOP_Y-pixel_ypos)*16 - ((pixel_xpos-`TEXT_LEFT_X)%16) -1])
				statistics	<=	BLACK;
			else if (pixel_ypos >= `COMBO_TOP_Y && pixel_ypos < `COMBO_TOP_Y + 32 &&
				char[0][(CHAR_HEIGHT+`COMBO_TOP_Y-pixel_ypos)*16 - ((pixel_xpos-`TEXT_LEFT_X)%16) -1])
				statistics	<=	BLACK;
			else if (pixel_ypos >= `LEVEL_TOP_Y && pixel_ypos < `LEVEL_TOP_Y + 32 &&
				char[0][(CHAR_HEIGHT+`LEVEL_TOP_Y-pixel_ypos)*16 - ((pixel_xpos-`TEXT_LEFT_X)%16) -1])
				statistics	<=	BLACK;
			else
				statistics	<=	WHITE;
		end
		else if ((pixel_xpos >= `TEXT_LEFT_X + 16)  && (pixel_xpos < `TEXT_LEFT_X + 16*2)) begin
			if (pixel_ypos >= `SCORE_TOP_Y && pixel_ypos < `SCORE_TOP_Y + 32 &&
				char[score_data1][(CHAR_HEIGHT+`SCORE_TOP_Y-pixel_ypos)*16 - ((pixel_xpos-`TEXT_LEFT_X)%16) -1])
				statistics	<=	BLACK;
			else if (pixel_ypos >= `KILL_TOP_Y && pixel_ypos < `KILL_TOP_Y + 32 &&
				char[kill_data1][(CHAR_HEIGHT+`KILL_TOP_Y-pixel_ypos)*16 - ((pixel_xpos-`TEXT_LEFT_X)%16) -1])
				statistics	<=	BLACK;
			else if (pixel_ypos >= `RUNAWAY_TOP_Y && pixel_ypos < `RUNAWAY_TOP_Y + 32 &&
				char[runaway_data1][(CHAR_HEIGHT+`RUNAWAY_TOP_Y-pixel_ypos)*16 - ((pixel_xpos-`TEXT_LEFT_X)%16) -1])
				statistics	<=	BLACK;
			else if (pixel_ypos >= `COMBO_TOP_Y && pixel_ypos < `COMBO_TOP_Y + 32 &&
				char[combo_data1][(CHAR_HEIGHT+`COMBO_TOP_Y-pixel_ypos)*16 - ((pixel_xpos-`TEXT_LEFT_X)%16) -1])
				statistics	<=	BLACK;
			else if (pixel_ypos >= `LEVEL_TOP_Y && pixel_ypos < `LEVEL_TOP_Y + 32 &&
				char[0][(CHAR_HEIGHT+`LEVEL_TOP_Y-pixel_ypos)*16 - ((pixel_xpos-`TEXT_LEFT_X)%16) -1])
				statistics	<=	BLACK;
			else
				statistics	<=	WHITE;
		end
		else if ((pixel_xpos >= `TEXT_LEFT_X + 16*2)  && (pixel_xpos < `TEXT_LEFT_X + 16*3)) begin
			if (pixel_ypos >= `SCORE_TOP_Y && pixel_ypos < `SCORE_TOP_Y + 32 &&
				char[score_data0][(CHAR_HEIGHT+`SCORE_TOP_Y-pixel_ypos)*16 - ((pixel_xpos-`TEXT_LEFT_X)%16) -1])
				statistics	<=	BLACK;
			else if (pixel_ypos >= `KILL_TOP_Y && pixel_ypos < `KILL_TOP_Y + 32 &&
				char[kill_data0][(CHAR_HEIGHT+`KILL_TOP_Y-pixel_ypos)*16 - ((pixel_xpos-`TEXT_LEFT_X)%16) -1])
				statistics	<=	BLACK;
			else if (pixel_ypos >= `RUNAWAY_TOP_Y && pixel_ypos < `RUNAWAY_TOP_Y + 32 &&
				char[runaway_data0][(CHAR_HEIGHT+`RUNAWAY_TOP_Y-pixel_ypos)*16 - ((pixel_xpos-`TEXT_LEFT_X)%16) -1])
				statistics	<=	BLACK;
			else if (pixel_ypos >= `COMBO_TOP_Y && pixel_ypos < `COMBO_TOP_Y + 32 &&
				char[combo_data0][(CHAR_HEIGHT+`COMBO_TOP_Y-pixel_ypos)*16 - ((pixel_xpos-`TEXT_LEFT_X)%16) -1])
				statistics	<=	BLACK;
			else if (pixel_ypos >= `LEVEL_TOP_Y && pixel_ypos < `LEVEL_TOP_Y + 32 &&
				char[level][(CHAR_HEIGHT+`LEVEL_TOP_Y-pixel_ypos)*16 - ((pixel_xpos-`TEXT_LEFT_X)%16) -1])
				statistics	<=	BLACK;
			else
				statistics	<=	WHITE;
		end
		else begin
			statistics <= WHITE;            
		end
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)  begin
			final_score <= WHITE;
		end
		else if ((pixel_xpos >= `FINAL_SCORE_TOP_LEFT_X)  && (pixel_xpos < `FINAL_SCORE_TOP_LEFT_X + 16)) begin
			if (pixel_ypos >= `FINAL_SCORE_TOP_LEFT_Y && pixel_ypos < `FINAL_SCORE_TOP_LEFT_Y + 32 &&
				char[score_data2][(CHAR_HEIGHT+`FINAL_SCORE_TOP_LEFT_Y-pixel_ypos)*16 - ((pixel_xpos-`FINAL_SCORE_TOP_LEFT_X)%16) -1])
				final_score	<=	BLACK;
			else
				final_score	<=	WHITE;
		end
		else if ((pixel_xpos >= `FINAL_SCORE_TOP_LEFT_X + 16)  && (pixel_xpos < `FINAL_SCORE_TOP_LEFT_X + 16*2)) begin
			if (pixel_ypos >= `FINAL_SCORE_TOP_LEFT_Y && pixel_ypos < `FINAL_SCORE_TOP_LEFT_Y + 32 &&
				char[score_data1][(CHAR_HEIGHT+`FINAL_SCORE_TOP_LEFT_Y-pixel_ypos)*16 - ((pixel_xpos-`FINAL_SCORE_TOP_LEFT_X)%16) -1])
				final_score	<=	BLACK;
			else
				final_score	<=	WHITE;
		end
		else if ((pixel_xpos >= `FINAL_SCORE_TOP_LEFT_X + 16*2)  && (pixel_xpos < `FINAL_SCORE_TOP_LEFT_X + 16*3)) begin
			if (pixel_ypos >= `FINAL_SCORE_TOP_LEFT_Y && pixel_ypos < `FINAL_SCORE_TOP_LEFT_Y + 32 &&
				char[score_data0][(CHAR_HEIGHT+`FINAL_SCORE_TOP_LEFT_Y-pixel_ypos)*16 - ((pixel_xpos-`FINAL_SCORE_TOP_LEFT_X)%16) -1])
				final_score	<=	BLACK;
			else
				final_score	<=	WHITE;
		end
		else begin
			final_score <= WHITE;            
		end
	end


	wire    [3  : 0]  moles_array [4 : 0];
	assign  moles_array[0]   =   moles[3  : 0];
	assign  moles_array[1]   =   moles[7  : 4];
	assign  moles_array[2]   =   moles[11 : 8];
	assign  moles_array[3]   =   moles[15 : 12];
	assign  moles_array[4]   =   moles[19 : 16];

	reg	  [10 : 0]	moles_top_left_x [4 : 0];
	reg	  [10 : 0]	moles_top_left_y [4 : 0];
	reg	  [10 : 0]	moles_bottom_right_x [4 : 0];
	reg	  [10 : 0]	moles_bottom_right_y [4 : 0];

	genvar i;
	generate
	for (i = 0; i < 5; i = i + 1) begin
		always @(*) begin
			case (moles_array[i])
				5'd0: begin
					moles_top_left_x[i]		=	`GRID_TOP_LEFT_X_0;
					moles_top_left_y[i]		=	`GRID_TOP_LEFT_Y_0;
					moles_bottom_right_x[i]	=	`GRID_BOTTOM_RIGHT_X_0;
					moles_bottom_right_y[i]	=	`GRID_BOTTOM_RIGHT_Y_0;
				end 
				5'd1: begin
					moles_top_left_x[i]     = 	`GRID_TOP_LEFT_X_1;
					moles_top_left_y[i]     = 	`GRID_TOP_LEFT_Y_1;
					moles_bottom_right_x[i] = 	`GRID_BOTTOM_RIGHT_X_1;
					moles_bottom_right_y[i] = 	`GRID_BOTTOM_RIGHT_Y_1;
				end
				5'd2: begin
					moles_top_left_x[i]     = 	`GRID_TOP_LEFT_X_2;
					moles_top_left_y[i]     = 	`GRID_TOP_LEFT_Y_2;
					moles_bottom_right_x[i] = 	`GRID_BOTTOM_RIGHT_X_2;
					moles_bottom_right_y[i] = 	`GRID_BOTTOM_RIGHT_Y_2;
				end
				5'd3: begin
					moles_top_left_x[i]     = 	`GRID_TOP_LEFT_X_3;
					moles_top_left_y[i]     = 	`GRID_TOP_LEFT_Y_3;
					moles_bottom_right_x[i] = 	`GRID_BOTTOM_RIGHT_X_3;
					moles_bottom_right_y[i] = 	`GRID_BOTTOM_RIGHT_Y_3;
				end
				5'd4: begin
					moles_top_left_x[i]     = 	`GRID_TOP_LEFT_X_4;
					moles_top_left_y[i]     = 	`GRID_TOP_LEFT_Y_4;
					moles_bottom_right_x[i] = 	`GRID_BOTTOM_RIGHT_X_4;
					moles_bottom_right_y[i] = 	`GRID_BOTTOM_RIGHT_Y_4;
				end
				5'd5: begin
					moles_top_left_x[i]     = 	`GRID_TOP_LEFT_X_5;
					moles_top_left_y[i]     = 	`GRID_TOP_LEFT_Y_5;
					moles_bottom_right_x[i] = 	`GRID_BOTTOM_RIGHT_X_5;
					moles_bottom_right_y[i] = 	`GRID_BOTTOM_RIGHT_Y_5;
				end
				5'd6: begin
					moles_top_left_x[i]     = 	`GRID_TOP_LEFT_X_6;
					moles_top_left_y[i]     = 	`GRID_TOP_LEFT_Y_6;
					moles_bottom_right_x[i] = 	`GRID_BOTTOM_RIGHT_X_6;
					moles_bottom_right_y[i] = 	`GRID_BOTTOM_RIGHT_Y_6;
				end
				5'd7: begin
					moles_top_left_x[i]     = 	`GRID_TOP_LEFT_X_7;
					moles_top_left_y[i]     = 	`GRID_TOP_LEFT_Y_7;
					moles_bottom_right_x[i] = 	`GRID_BOTTOM_RIGHT_X_7;
					moles_bottom_right_y[i] = 	`GRID_BOTTOM_RIGHT_Y_7;
				end
				5'd8: begin
					moles_top_left_x[i]     = 	`GRID_TOP_LEFT_X_8;
					moles_top_left_y[i]     = 	`GRID_TOP_LEFT_Y_8;
					moles_bottom_right_x[i] = 	`GRID_BOTTOM_RIGHT_X_8;
					moles_bottom_right_y[i] = 	`GRID_BOTTOM_RIGHT_Y_8;
				end
				default: begin
					moles_top_left_x[i]     = 	0;
					moles_top_left_y[i]     = 	0;
					moles_bottom_right_x[i] = 	0;
					moles_bottom_right_y[i] = 	0;
				end
			endcase
		end
	end
	endgenerate

	reg   [14 : 0]  rom_bg_addr  ;  
	reg	  [12 : 0]  rom_mole_addr;

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n)
			rom_bg_addr <= 15'd0;
		else 
			rom_bg_addr <= 200 * (pixel_ypos / 4 - 1) + pixel_xpos / 4; //zoom
	end

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n)
			rom_mole_addr <= 13'd0;
		else if((pixel_ypos >= moles_top_left_y[0]) && (pixel_ypos < moles_bottom_right_y[0]) 
			&& (pixel_xpos >= moles_top_left_x[0]) && (pixel_xpos < moles_bottom_right_x[0])) 
			rom_mole_addr <= 75 * ((pixel_ypos - moles_top_left_y[0]) / 2 - 1) + (pixel_xpos - moles_top_left_x[0]) / 2;
		else if ((pixel_ypos >= moles_top_left_y[1]) && (pixel_ypos < moles_bottom_right_y[1]) &&
				(pixel_xpos >= moles_top_left_x[1]) && (pixel_xpos < moles_bottom_right_x[1])) 
			rom_mole_addr <= 75 * ((pixel_ypos - moles_top_left_y[1]) / 2 - 1) + (pixel_xpos - moles_top_left_x[1]) / 2;
		else if ((pixel_ypos >= moles_top_left_y[2]) && (pixel_ypos < moles_bottom_right_y[2]) &&
				(pixel_xpos >= moles_top_left_x[2]) && (pixel_xpos < moles_bottom_right_x[2])) 
			rom_mole_addr <= 75 * ((pixel_ypos - moles_top_left_y[2]) / 2 - 1) + (pixel_xpos - moles_top_left_x[2]) / 2;
		else if ((pixel_ypos >= moles_top_left_y[3]) && (pixel_ypos < moles_bottom_right_y[3]) &&
				(pixel_xpos >= moles_top_left_x[3]) && (pixel_xpos < moles_bottom_right_x[3])) 
			rom_mole_addr <= 75 * ((pixel_ypos - moles_top_left_y[3]) / 2 - 1) + (pixel_xpos - moles_top_left_x[3]) / 2;
		else if ((pixel_ypos >= moles_top_left_y[4]) && (pixel_ypos < moles_bottom_right_y[4]) &&
				(pixel_xpos >= moles_top_left_x[4]) && (pixel_xpos < moles_bottom_right_x[4])) 
			rom_mole_addr <= 75 * ((pixel_ypos - moles_top_left_y[4]) / 2 - 1) + (pixel_xpos - moles_top_left_x[4]) / 2;
		else 
			rom_mole_addr <= 13'd0;
	end


	wire	[23 : 0]	rom_menu_data;
	wire	[23 : 0]	rom_game_data;
	wire	[23 : 0]	rom_mole_data;
	wire	[23 : 0]	rom_over_data;

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)  
			pixel_data <= WHITE;
		else
			case (state)
				`STATE_MENU: 	pixel_data	<=	rom_menu_data;
				`STATE_GAME:	pixel_data	<=	rom_mole_data != BLACK ? rom_mole_data : (timer_data == BLACK ? timer_data : (statistics == BLACK ? statistics : rom_game_data));
				`STATE_OVER:	pixel_data	<=	final_score == BLACK ? final_score : rom_over_data;
				default: 		pixel_data	<=	rom_menu_data;
			endcase
	end



	MENUSCREEN  MenuScreen (
	.clka  (clk),    // input wire clka
	.ena   (1'b1),   // input wire ena
	.addra (rom_bg_addr),    // input wire [13 : 0] addra
	.douta (rom_menu_data)  // output wire [23 : 0] douta
	);

	GAMESCREEN  GameScreen (
	.clka  (clk),    // input wire clka
	.ena   (1'b1),   // input wire ena
	.addra (rom_bg_addr),    // input wire [13 : 0] addra
	.douta (rom_game_data)  // output wire [23 : 0] douta
	);

	OVERSCREEN  OverScreen (
	.clka  (clk),    // input wire clka
	.ena   (1'b1),   // input wire ena
	.addra (rom_bg_addr),    // input wire [13 : 0] addra
	.douta (rom_over_data)  // output wire [23 : 0] douta
	);

	MOLESCREEN  Mole (
	.clka  (clk),    // input wire clka
	.ena   (1'b1),   // input wire ena
	.addra (rom_mole_addr),    // input wire [13 : 0] addra
	.douta (rom_mole_data)  // output wire [23 : 0] douta
	);
endmodule 