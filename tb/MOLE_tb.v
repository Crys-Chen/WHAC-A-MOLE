module MOLE_tb;

    // Inputs
    reg clk;
    reg clk_50M;
    reg rst_n;
    reg [31:0] life_span;
    reg [31:0] gen_interval;
    reg [4:0] kill_list;
    reg start;

    // Outputs
    wire [19:0] moles;

    // Instantiate the MOLE module
    MOLE uut (
        .clk(clk),
        // .clk_50M(clk_50M),
        .start(start),
        .rst_n(rst_n),
        .life_span(life_span),
        .gen_interval(gen_interval),
        .kill_list(kill_list),
        .moles(moles)
    );

    // Clock generation for clk
    initial begin
        clk_50M = 0;
        forever #5 clk_50M = ~clk_50M;  // 10 time units clock period
    end

    // Clock generation for clk_1s
    initial begin
        clk = 0;
        forever #10 clk = ~clk;  // 100 time units simulating 1 second
    end

    // Test procedure
    initial begin
        // Initialize inputs
        rst_n = 0;
        life_span = 32'd100;      // Example life span
        gen_interval = 32'd50;    // Example generation interval
        kill_list = 5'b00000;   // Example kill list (no kills)
        start = 1'b0;

        // Apply reset
        #20;
        rst_n = 1;
        
        // Test case 1: Normal operation
        #200;  // Wait some time to observe mole generation
        start = 1'b1;
        #15
        start = 1'b0;
        // Simulate killing a mole
        // kill_list = 5'b00001;  // Kill first mole
        #60;
        // kill_list = 5'b00000;  // Reset kill list
        #100;
        // Change generation interval
        gen_interval = 32'd30;

        // Change life span
        life_span = 32'd150;
        #5000;
        kill_list = 5'b01011;
        #25
        kill_list = 5'b00000;
        // // Test case 2: Reset and observe behavior
        // rst_n = 0;
        // #20;
        // rst_n = 1;

        // Further testing, adjusting kill list, span, etc.
        // kill_list = 5'b11111; // Kill all moles
        #100;

        // Finish simulation
        #200;
        $finish;
    end

    // Monitor moles output
    initial begin
        $monitor("Time: %0t | Moles: %b | Life Span: %b | Interval: %b | Kill List: %b", $time, moles, life_span, gen_interval, kill_list);
    end

endmodule
