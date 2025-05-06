`include "PARAM.vh"
module MOLE 
(
    input               clk,
    input               rst_n,
    input               sys_rst_n,
    input   [31 : 0]    life_span,
    input   [31 : 0]    gen_interval,
    input   [4  : 0]    kill_list,
    output  [19 : 0]    moles,
    output              survival
);
    reg     [19 : 0]    moles_reg;
    reg     [19 : 0]    next_moles;
    wire    [3  : 0]    moles_array [4 : 0];
    wire    [4  : 0]    prior_moles_dead;
    reg     [31 : 0]    moles_life  [4 : 0];
    reg     [31 : 0]    interval_counter;
    wire    [31 : 0]    random_data;
    reg     [31 : 0]    next_location;

    assign  moles                  =   moles_reg;
    assign  survival               =   (moles_life[0] == life_span) | (moles_life[1] == life_span) | (moles_life[2] == life_span) | (moles_life[3] == life_span) | (moles_life[4] == life_span);

    // State Machine: State Transfer
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            moles_reg   <=  20'b1111_1111_1111_1111_1111;
        else 
            moles_reg   <=  next_moles;
    end

    
    assign  moles_array[0]         =   moles[3  : 0];
    assign  moles_array[1]         =   moles[7  : 4];
    assign  moles_array[2]         =   moles[11 : 8];
    assign  moles_array[3]         =   moles[15 : 12];
    assign  moles_array[4]         =   moles[19 : 16];
    assign  prior_moles_dead[0]    =   0;
    assign  prior_moles_dead[1]    =   moles_array[0] == 4'b1111;
    assign  prior_moles_dead[2]    =   moles_array[1] == 4'b1111 || moles_array[0] == 4'b1111;
    assign  prior_moles_dead[3]    =   moles_array[2] == 4'b1111 || moles_array[1] == 4'b1111 || moles_array[0] == 4'b1111;
    assign  prior_moles_dead[4]    =   moles_array[3] == 4'b1111 || moles_array[2] == 4'b1111 || moles_array[1] == 4'b1111 || moles_array[0] == 4'b1111;

    // State Machine: State Switch
    genvar i;
    genvar j;
    generate
    for (i = 0; i < 5; i = i + 1) begin
        always @(*) begin
            if (kill_list[i] || moles_life[i] == life_span) 
                next_moles[(i+1)*4-1 : i*4] = 4'b1111;
            else if (interval_counter == gen_interval && moles[(i+1)*4-1 : i*4] == 4'b1111 && prior_moles_dead[i:0] == 0)
                next_moles[(i+1)*4-1 : i*4] = next_location[3:0];
            else
                next_moles[(i+1)*4-1 : i*4] = moles[(i+1)*4-1 : i*4];
        end
    end
    endgenerate


    // Two counters: one for the life span of each mole, the other for the generation interval of moles
    generate 
    for (i = 0; i < 5; i=i+1) begin
        always @(posedge clk or negedge rst_n) begin
            if (!rst_n) 
                moles_life[i]    <=  32'd0;
            else
                if (moles[(i+1)*4-1 : i*4] == 4'b1111 || moles_life[i] == life_span)
                    moles_life[i]   <=  32'd0;
                else
                    moles_life[i]   <=  moles_life[i] + 32'd1;
        end
    end
    endgenerate


    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            interval_counter        <=  32'd0;
        else
            if (interval_counter == gen_interval) 
                interval_counter    <=  32'd0;
            else
                interval_counter    <=  interval_counter + 32'd1;
    end

    // Generate the location of next mole

    PRNG gen_location(
        .clk(clk),
        .rst_n(sys_rst_n),
        .random(random_data)
    );
    
    integer k, m;
    always @(*) begin
        next_location   =   random_data % 32'd9;
        for(m = 0; m < 5; m = m + 1)
            for(k = 0; k < 5; k = k + 1)
                if (next_location[3:0] == moles_array[k])
                    next_location   =   (next_location + 32'd1) % 32'd9;
    end


    
endmodule