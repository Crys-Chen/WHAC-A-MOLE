module BEEP_BGM (
    input             clk, //180 beats per min
    input             rst_n,
    input             bee,
    output reg[10:0]  frequency
); 
    reg [10:0]        rhythm; 
    reg [10:0]        tone;

    parameter low_do=262, middle_do=523, high_do=1046,
              low_re=294, middle_re=587, high_re=1175,
              low_mi=330, middle_mi=659, high_mi=1318,
              low_fa=349, middle_fa=699, middle_fa_up=742,high_fa=1398,
              low_so=392, middle_so=784, middle_so_up=832, high_so=1569,
              low_la=440, middle_la=880, middle_la_up=934,high_la=1762,
              low_xi=494, middle_xi=988, high_xi=1977,
              silence=1,  bee_tone=2000;

    always @(posedge clk or posedge bee or negedge rst_n) begin
        if (!rst_n) begin
            rhythm          <=  11'd0;
            frequency       <=  silence;
        end 
        else begin  
            rhythm          <=  rhythm + 1;
            if (bee) 
                frequency   <=  bee_tone;
            else
                frequency   <=  tone;
        end 
    end

    always @(posedge clk) begin
        case (rhythm) // Growing Fond of You
            0:          tone   <=  silence;
            2:          tone   <=  low_so;
            4:          tone   <=  middle_do;
            6:          tone   <=  middle_re;
            8:          tone   <=  middle_mi;
            9:          tone   <=  silence;  
            10:         tone   <=  middle_mi;
            11:         tone   <=  silence;    
            12:         tone   <=  middle_mi;
            13:         tone   <=  silence;  
            14:         tone   <=  middle_mi;
            15:         tone   <=  silence;        
            16:         tone   <=  middle_fa;
            18:         tone   <=  middle_mi;
            20:         tone   <=  middle_fa;
            22:         tone   <=  middle_la;
            24:         tone   <=  middle_so;
            32:         tone   <=  middle_mi;

            35:         tone   <=  silence;
            36:         tone   <=  middle_re;
            38:         tone   <=  middle_mi;
            40:         tone   <=  middle_fa;
            41:         tone   <=  silence;
            42:         tone   <=  middle_fa;
            43:         tone   <=  silence;
            44:         tone   <=  middle_fa;
            46:         tone   <=  low_la;
            48:         tone   <=  low_xi;
            50:         tone   <=  middle_do;
            52:         tone   <=  middle_re;
            54:         tone   <=  middle_mi;
            55:         tone   <=  silence;
            56:         tone   <=  middle_mi;
            62:         tone   <=  middle_re;

            65:         tone   <=  silence;
            66:         tone   <=  low_so;
            68:         tone   <=  middle_do;
            70:         tone   <=  middle_re;
            72:         tone   <=  middle_mi;
            73:         tone   <=  silence;
            74:         tone   <=  middle_mi;
            75:         tone   <=  silence;
            76:         tone   <=  middle_mi;
            77:         tone   <=  silence;
            78:         tone   <=  middle_mi;
            80:         tone   <=  middle_fa;
            82:         tone   <=  middle_mi;
            84:         tone   <=  middle_fa;
            86:         tone   <=  middle_la;
            88:         tone   <=  middle_so;
            96:         tone   <=  middle_so_up;
            99:         tone   <=  silence;
            100:        tone   <=  middle_la;
            102:        tone   <=  middle_xi;
            104:        tone   <=  high_re;
            106:        tone   <=  high_do;
            107:        tone   <=  silence;
            108:        tone   <=  high_do;
            110:        tone   <=  middle_xi;
            111:        tone   <=  middle_la;
            112:        tone   <=  middle_xi;
            114:        tone   <=  middle_la;
            115:        tone   <=  silence;
            116:        tone   <=  middle_la;
            118:        tone   <=  middle_so;
            119:        tone   <=  middle_mi;
            120:        tone   <=  middle_la;
            122:        tone   <=  middle_so;
            123:        tone   <=  silence;
            124:        tone   <=  middle_so;
            126:        tone   <=  middle_fa;
            127:        tone   <=  middle_mi;
            128:        tone   <=  middle_fa;
            132:        tone   <=  silence;
            134:        tone   <=  middle_do;
            136:        tone   <=  middle_mi;
            138:        tone   <=  middle_so;
            142:        tone   <=  middle_mi;
            144:        tone   <=  middle_re;
            147:        tone   <=  silence;
            148:        tone   <=  low_xi;
            150:        tone   <=  middle_do;
    
            160-2:        tone   <=  silence;
            162-2:        tone   <=  middle_xi;
            164-2:        tone   <=  high_do;
            166-2:        tone   <=  high_re;
            168-2:        tone   <=  high_mi;
            170-2:        tone   <=  middle_so;
            172-2:        tone   <=  high_fa;
            174-2:        tone   <=  high_mi;
            175-2:        tone   <=  high_re;
            176-2:        tone   <=  high_re;
            178-2:        tone   <=  middle_mi;
            180-2:        tone   <=  high_mi;
            182-2:        tone   <=  high_re;
            183-2:        tone   <=  middle_xi;
            184-2:        tone   <=  high_do;
            186-2:        tone   <=  middle_mi;
            188-2:        tone   <=  high_re;
            190-2:        tone   <=  high_do;
            191-2:        tone   <=  middle_la;
            192-2:        tone   <=  middle_la_up;
            194-2:        tone   <=  high_do;
            196-2:        tone   <=  middle_la;
            199-2:        tone   <=  middle_so;
            200-2:        tone   <=  middle_la;
            202-2:        tone   <=  silence;
            203-2:        tone   <=  middle_la;
            // -2 fuck
            204:        tone   <=  middle_xi;
            205:        tone   <=  high_do;
            206:        tone   <=  middle_so;
            208:        tone   <=  middle_xi;
            210:        tone   <=  high_do;
            212:        tone   <=  middle_so;
            214:        tone   <=  middle_fa_up;
            216:        tone   <=  high_mi;
            218:        tone   <=  high_re;
            220:        tone   <=  high_do;
            222:        tone   <=  high_re;
            223:        tone   <=  silence;
            224:        tone   <=  middle_xi;
            226:        tone   <=  high_do;
            228:        tone   <=  high_re;
            230:        tone   <=  high_mi;
            232:        tone   <=  middle_so;
            234:        tone   <=  high_fa;
            236:        tone   <=  high_mi;
            237:        tone   <=  high_re;
            228:        tone   <=  high_re;
            240:        tone   <=  middle_mi;
            242:        tone   <=  high_mi;
            244:        tone   <=  high_re;
            245:        tone   <=  middle_xi;
            // ck
            246:        tone   <=  high_do;
            248:        tone   <=  high_re;
            249:        tone   <=  middle_xi;
            250:        tone   <=  high_do;
            252:        tone   <=  high_re;
            253:        tone   <=  middle_xi;
            254:        tone   <=  high_do;
            261:        tone   <=  silence;
            262:        tone   <=  middle_so;
            264:        tone   <=  high_do;
            265:        tone   <=  silence;
            266:        tone   <=  high_do;
            268:        tone   <=  middle_so;
            270:        tone   <=  middle_fa_up;
            272:        tone   <=  high_do;
            273:        tone   <=  silence;
            274:        tone   <=  high_do;
            276:        tone   <=  middle_fa;
            286:        tone   <=  silence;
            288:        tone   <=  high_do;
            289:        tone   <=  silence;
            290:        tone   <=  high_do;
            300:        tone   <=  silence;
            default:    tone   <=  tone;
        endcase
    end

endmodule