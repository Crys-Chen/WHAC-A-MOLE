module BEEP_TOP (
    input   clk,
    input   rst_n,
    input   bee,
    output  melody
);  

    wire[10:0] frequency;

    wire clk_rhythm;

    BEEP_CLKDIV beep_clkdiv(.clk_50MHz(clk),
                            .rst_n(rst_n),
                            .clk_rhythm(clk_rhythm));

    BEEP_BGM  beep_bgm(.clk(clk_rhythm),
                       .bee(bee),
                       .rst_n(rst_n),
                       .frequency(frequency));

    BEEP_PLAY beep_play(.clk(clk),
                        .rst_n(rst_n),
                        .frequency(frequency),
                        .melody(melody));


endmodule