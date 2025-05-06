module BEEP_CLKDIV (
    // input clk_100MHz,
    input clk_50MHz,
    input rst_n,
    output reg clk_rhythm //每分钟180拍，即3Hz
); 
    parameter N = 9999_9999/2;
    reg[31:0] count3;

    // always @(posedge clk_50MHz, posedge rst_n) begin
    //     if(rst_n==1)
    //         count1<=0;
    //     else count1<=count1+1;
    // end

    // assign clk_25MHz=count1[1];

    //分频获得频闪时钟
   

    // always @(posedge clk_50MHz) begin
    //     clk_20ms<=0;
    //     if(count2<N/50)
    //         count2<=count2+1;
    //     else begin
    //         count2<=0;
    //         clk_20ms<=1;
    //     end
    // end

    always @(posedge clk_50MHz) begin
        if(count3<N/3) begin
            count3      <=  count3+1;
            clk_rhythm  <=  0;            
        end
        else begin
            count3      <=  0;
            clk_rhythm  <=  1;
        end
    end

    // always@(posedge clk_50MHz) begin //数码管不需要100MHz的时钟，381Hz即可
    //     count4<=count4+1;
    // end

    // assign clk_381Hz=count4[17]; //100MHz÷(2^18)=381Hz
    
endmodule