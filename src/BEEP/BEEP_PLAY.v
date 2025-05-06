module BEEP_PLAY (
    input             clk,
    input             rst_n,
    input   [10:0]    frequency,
    output  reg       melody
);
    reg [30:0]        count;
    reg [30:0]        flag;
    reg               change;
    parameter N=9999_9999/2;

    always @(frequency) begin
        if(frequency==1)
            flag   <=  1; // high freq will not be heard 
        else 
            flag   <=  N/(2*frequency);                
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count   <=  count + 1;
            change  <=  0;
        end
        else begin
            if(count    <   flag) begin
                count   <=  count+1;
                change  <=  0;
            end
            else begin  
                change  <=  1;
                count   <=  0;
            end               
        end
    end

    always@(posedge change or negedge rst_n) begin
		if (!rst_n)
            melody  <=   1'b0;
        else
            melody  <=   ~melody;
    end

endmodule