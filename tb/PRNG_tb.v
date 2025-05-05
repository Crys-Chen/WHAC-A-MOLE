`timescale 1ns/1ps

module PRNG_tb;

  reg                 clk;
  reg                 rst_n;
  reg                 ivalid;
  reg       [31:0]    seed;
  
  wire      [31:0]    data;

  PRNG PRNG_inst(
    .clk            (clk),
    .rst_n          (rst_n),
    .en             (1),
    .random         (data)
  );
  
  initial clk = 1'b0;
  always # 5 clk = ~clk;
  
  initial begin
    rst_n = 1'b0;
  ivalid = 1'b0;
  seed = 32'd0;
  # 201;
  
  rst_n = 1'b1;
  #200;

  
  #200000;
  $stop;
  end

endmodule 