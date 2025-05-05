`include "PARAM.vh"
module PRNG (
    input               rst_n,
    input               clk,
    // input               start,
    output  [31 : 0]    random
);

    reg     [31 : 0]    rand_reg;
    reg     [31 : 0]    seed;

    assign              random  =   rand_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            rand_reg   <=  seed;
        else 
            rand_reg   <=  {rand_reg[0] ^ rand_reg[25] ^ rand_reg[27] ^ rand_reg[29] ^ rand_reg[30] ^ rand_reg[31],
                            rand_reg[31:1]};
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            seed       <=  32'd65536;
        else if (seed == 32'd0)
            seed       <=  32'b1010;
        else
            seed       <=  seed + 1;
    end
    
endmodule

