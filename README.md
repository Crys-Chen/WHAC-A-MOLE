本人已将结果录制成视频并上传至bilibili，请点击查看[FPGA打地鼠（触摸屏+蜂鸣器版）](https://www.bilibili.com/video/BV1KMVpzWEPA/?vd_source=49d6aba24331143eae8d3fc696136e50)

# 一、设计规划

## 1.1 设计要求

本项目是复旦大学2024-2025春季学期《专用集成电路设计方法》（俞军）的期末课程项目。设计要求如下：

<img src="D:\TyporaImages\image-20250505150206517.png" alt="image-20250505150206517" style="zoom:50%;" />


## 1.2 设计思路

本项目在电路架构层面，采用**Top-Down设计方法**；在模块实现方面，采用**Design For Test(DFT)设计原则**。

**项目特色：**

- 在完成项目要求的基础上，外接<font color=Red>**<u>电容式触摸屏</u>**</font>和<font color=Red>**<u>无源蜂鸣器</u>**</font>，实现了一个<font color=Red>**<u>“打地鼠游戏机”</u>**</font>。
- 电容式触摸屏：采用触屏输入，显示屏输出
- 无源蜂鸣器：与只能发出固定音高的有源蜂鸣器不同，无源蜂鸣器能够根据输入信号的频率调整音高，实现播放背景音乐的功能
- 采用俞老师课上讲授的Top-Down设计方法，设计简明，结构清晰。
- 凭借Xilinx提供的IP核进行开发，最大限度利用FPGA的板载资源。
- 采用俞老师课上讲授的DFT设计原则，极大地便利功能仿真与测试。

<img src="D:\TyporaImages\4b03f993172975ccef61f7c528ff874.jpg" alt="4b03f993172975ccef61f7c528ff874" style="zoom:50%;" />


## 1.3 设计平台

本项目所采用的FPGA开发板是正点原子的“启明星ZYNQ-7010开发板”。ZYNQ-7000 系列是 Xilinx 于 2010 年 4 月推出的行业第一个**嵌入式开发平台**，它集成了一个双核 ARM Cortex-A9 处理器和一个传统的FPGA逻辑部件。本项目由于俞老师要求不得使用ARM核，因此只对该开发板的FPGA资源进行开发。

<img src="D:\TyporaImages\image-20250505161342702.png" alt="image-20250505161342702" style="zoom: 67%;" />

该开发板的底板资源如下：

- 核心板的芯片型号： XC7Z010CLG400-1

- PL 逻辑单元： 28K
- BRAM ：2.1Mbit
- SDRAM：2片DDR3，型号为 NT5CC128M16，每片 2Gbit，总容量为 4Gbit（512MB）
- 1 个 1x6 下载接口，14-Pin JTAG
- 2 个 PL LED
- 1个有源蜂鸣器
- 1 个 PL 晶振：50Mhz，给 PL 可编程逻辑提供时钟
- 1 个标准的 RGB888 TFT-LCD 接口



## 1.4 设计流程图

<img src="D:\TyporaImages\image-20250505180219051.png" alt="image-20250505180219051" style="zoom: 50%;" />

# 二、设计实现

## 2.1 框图介绍

Top-Down设计方法流程如下：

- 拆解项目功能，确定整个项目的整体架构。
- 自顶向下地确定各个模块的功能、接口和连接关系。
- 实现各个模块。

最终，笔者对本项目的功能分析与模块的划分如下：

### 2.1.2 游戏部分

| Modules            | Source Code       | Description                                  |
| ------------------ | ----------------- | -------------------------------------------- |
| 有限状态机模块     | FSM.v             | 游戏状态机                                   |
| 游戏后台控制器模块 | GAME_CONTROLLER.v | 记录分数、击杀、连击、逃跑、等级等游戏数据   |
| 地鼠模块           | MOLE.v            | 初始化新地鼠，管理每只地鼠的行为、生命周期等 |
| 伪随机数模块       | PRNG.v            | 生成伪随机数，用于初始化下一只地鼠的出现位置 |

### 2.1.3 RGB TFT-LCD部分

| Modules          | Source Code           | Description                                      |
| ---------------- | --------------------- | ------------------------------------------------ |
| 触屏顶层模块     | LCD_TOUCH_TOP.v       |                                                  |
| 触屏驱动模块     | LCD_TOUCH_DRI.v       | 检测触屏坐标                                     |
| 触屏I2C协议模块  | LCD_TOUCH_I2C_DRI_M.v | I2C协议传输                                      |
| 显示顶层模块     | LCD_DISPLAY_TOP.v     |                                                  |
| 显示时钟分频模块 | LCD_DISPLAY_CLKDIV.v  | 产生LCD的工作时钟                                |
| 显示驱动模块     | LCD_DISPLAY_DRIVER.v  | 行扫描、列扫描等                                 |
| 显示界面模块     | LCD_DISPLAY_SCREEN.v  | 例化ROM IP核，根据当前游戏状态显示对应贴图和数据 |

### 2.1.4 蜂鸣器部分

| Modules            | Source Code   | Description      |
| ------------------ | ------------- | ---------------- |
| 蜂鸣器顶层模块     | BEEP_TOP.v    |                  |
| 蜂鸣器时钟分频模块 | BEEP_CLKDIV.v | 生成节拍器       |
| 蜂鸣器背景音乐模块 | BEEP_BGM.v    | 将乐谱写入FPGA中 |
| 蜂鸣器播放模块     | BEEP_PLAY.v   | 播放音乐         |



电路模块框图如下，其中更小的模块没有在图中画出。

![image-20250506184522689](D:\TyporaImages\image-20250506184522689.png)



## 2.2 各模块设计和验证

### 2.2.1 游戏部分

#### 2.2.1.1 状态机设计

整个游戏由嵌套的两个状态机组成，外层状态机的状态为：菜单界面、游戏进行中、游戏结束；内层状态机的状态为游戏等级，该数值会随游戏进行而递增，最高为4级。而地鼠的刷新间隔、生命周期，每次打地鼠获得的分数都由当前玩家所处的等级计算得到。

| Level | Life Span（地鼠的生命周期，s） | Generation Interval（地鼠的刷新间隔，s） |
| ----- | ------------------------------ | ---------------------------------------- |
| 1     | 6                              | 3                                        |
| 2     | 4                              | 2                                        |
| 3     | 2                              | 1                                        |
| 4     | 1                              | 0.5                                      |

#### 2.2.1.2 连击系统

为了增加游戏趣味性，笔者加入了连击奖励机制，每次击打的分数为`等级+连击次数（最大为5）`，即：

`points = level + (combo > 8'd5 ? 10'd5 : combo)`

#### 2.2.1.3 多只地鼠同时存在

在原本的项目要求中，由于地鼠的生命周期和刷新间隔一致，同一时间只能出现一只地鼠。为了增加挑战性，笔者令游戏刷新间隔=生命周期的一半，如此可让多只地鼠同时存在。但这一更改需要对代码进行重大调整。

首先，原本的地鼠寄存器只有一个，但现在需要多个寄存器，笔者将这一数值设置为5，并进行拼接。如以下代码所示，moles存放的是每只地鼠的位置，因为笔者的地图为九宫格，因此只有0-9是有效的，其他值，如4'b1111为无效，此时地鼠不会显示。

```verilog
output  [19 : 0]    moles;   
......
assign  moles_array[0]         =   moles[3  : 0];
assign  moles_array[1]         =   moles[7  : 4];
assign  moles_array[2]         =   moles[11 : 8];
assign  moles_array[3]         =   moles[15 : 12];
assign  moles_array[4]         =   moles[19 : 16];
......
  // State Machine: State Switch
  genvar i;
  genvar j;
  generate
  for (i = 0; i < 5; i = i + 1) begin
      always @(*) begin
          if (kill_list[i] || moles_life[i] == life_span) 
            next_moles[(i+1)*4-1 : i*4] = 4'b1111; //4'b1111 is invalid
          else if (interval_counter == gen_interval && moles[(i+1)*4-1 : i*4] == 4'b1111 && prior_moles_dead[i:0] == 0) // random
              next_moles[(i+1)*4-1 : i*4] = next_location[3:0];
          else
              next_moles[(i+1)*4-1 : i*4] = moles[(i+1)*4-1 : i*4];
      end
  end
  endgenerate
```

#### 2.2.1.4 打地鼠逻辑

使用`kill_list[5]`记录，程序运行时会不断检测坐标是否落在任意一只地鼠上，若判断为真，`kill_list`对应的flag为1，否则为0。

```verilog
genvar i;
generate
for (i = 0; i < 5; i = i + 1) begin
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            kill_list[i]    <=  1'b0;
        else
            if (moles_array[i] < 4'b1111 && kill_list[i] == 1'b0)
                case (moles_array[i])
                    4'd0: kill_list[i]  <=  tp_x_coord > `GRID_TOP_LEFT_X_0 & tp_x_coord < `GRID_BOTTOM_RIGHT_X_0 & tp_y_coord > `GRID_TOP_LEFT_Y_0 & tp_y_coord < `GRID_BOTTOM_RIGHT_Y_0;
                    4'd1: kill_list[i]  <=  tp_x_coord > `GRID_TOP_LEFT_X_1 & tp_x_coord < `GRID_BOTTOM_RIGHT_X_1 & tp_y_coord > `GRID_TOP_LEFT_Y_1 & tp_y_coord < `GRID_BOTTOM_RIGHT_Y_1;
                    4'd2: kill_list[i]  <= tp_x_coord > `GRID_TOP_LEFT_X_2 & tp_x_coord < `GRID_BOTTOM_RIGHT_X_2 & tp_y_coord > `GRID_TOP_LEFT_Y_2 & tp_y_coord < `GRID_BOTTOM_RIGHT_Y_2;
                   ......
                    default: kill_list[i]  <=  1'b0;
                endcase
            else
                kill_list[i]        <=  1'b0;        
    end 
end
endgenerate
```

#### 2.2.1.5 伪随机数发生器(PRNG)

本项目的伪随机数发生器参考文章[基于FPGA的伪随机序列发生器设计-腾讯云开发者社区-腾讯云](https://cloud.tencent.com/developer/article/1655498)设计，基于Fibonacci方式进行，本原多项式设置为$x^{32}+x^7+x^5+x^3+x^2+x+1$

![img](https://ask.qcloudimg.com/http-save/7469656/0t2gkojuoy.png)

代码如下：

```verilog
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


```



#### 2.2.2.2 测试

仿真波形如下图所示，我们重点关注moles，可以看到我们同一时间可以出现多只地鼠。地鼠被击打后，kill寄存器+1。当有10只地鼠成功逃脱时（`runaway=10`），游戏结束；否则每刷线9只地鼠，`level+=1`，当`level=5`时，游戏结束。

<img src="D:\TyporaImages\image-20250506224145222.png" alt="image-20250506224145222" style="zoom: 67%;" />

### 2.2.2 蜂鸣器部分

#### 2.2.2.1 电路连接

> 蜂鸣器是一种一体化结构的电子讯响器，采用直流电压供电，广泛应用于计算机、打印机、复印机、报警器、电子玩具、汽车电子设备、电话机、定时器等电子产品中作发声器件。

本项目音频输出采用三个蜂鸣器串联，电路图和实物图如下：

<img src="https://gitee.com/feng-zhiye/images/raw/master/imgs/image-20221108184341157.png" alt="image-20221108184341157" style="zoom:50%;" />

<img src="D:\TyporaImages\15f59eb33a3be44a388554ca4a7ea8c.jpg" alt="15f59eb33a3be44a388554ca4a7ea8c" style="zoom: 25%;" />

#### 2.2.2.2 BGM

每个音调都有独特的频率，本项目所采用的21音阶频率表如下：

|   c3(高音1)   | d3(高音2)     | e3(高音3)     | f3(高音4)     | g3(高音5)     | a3(高音6)     | b3(高音7)     |
| :-----------: | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- |
|     1047      | 1175          | 1319          | 1398          | 1569          | 1762          | 1977          |
| **c2(中音1)** | **d2(中音2)** | **e2(中音3)** | **f2(中音4)** | **g2(中音5)** | **a2(中音6)** | **b2(中音7)** |
|      523      | 587           | 659           | 699           | 784           | 880           | 988           |
| **c1(低音1)** | **d1(低音2)** | **e1(低音3)** | **f1(低音4)** | **g1(低音5)** | **a1(低音6)** | **b1(低音7)** |
|      262      | 294           | 330           | 349           | 392           | 440           | 494           |

根据不同音调的频率特性，用频率信号来表示各个音调，将其输入振荡电路，令蜂鸣器发出不同的音高。代码如下：

``` verilog
 parameter low_do=262, middle_do=523, high_do=1046,
              low_re=294, middle_re=587, high_re=1175,
              low_mi=330, middle_mi=659, high_mi=1318,
              low_fa=349, middle_fa=699, high_fa=1398,
              low_so=392, middle_so=784, high_so=1569,
              low_la=440, middle_la=880, high_la=1762,
              low_xi=494, middle_xi=988, high_xi=1977,
              silence=1;
```

基于以上乐谱，可以在特定时间使用对应音高的频率驱动蜂鸣器：

```verilog	
always @(*) begin
    case (rhythm) // Growing Fond of You
        0:          tone   =  silence;
        2:          tone   =  low_so;
        4:          tone   =  middle_do;
        6:          tone   =  middle_re;
        8:          tone   =  middle_mi;
        9:          tone   =  silence;  
        10:         tone   =  middle_mi;
        11:         tone   =  silence;    
        12:         tone   =  middle_mi;
        13:         tone   =  silence;  
        14:         tone   =  middle_mi;
        15:         tone   =  silence;        
        16:         tone   =  middle_fa;
        18:         tone   =  middle_mi;
        20:         tone   =  middle_fa;
        22:         tone   =  middle_la;
        24:         tone   =  middle_so;
        32:         tone   =  middle_mi;
        ......
```



每个频率信号以Hz为单位，据此对正点原子的50MHz时钟信号进行分频，得到对应频率的振荡信号，代码如下：

``` verilog
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
```

#### 2.2.2.3 测试

由于该电路较为简单，且输出是现实世界的声波，因此此处略过波形测试，直接上板，用人耳调试效率更高。



### 2.2.3 RGB TFT-LCD电容触摸屏

在完成了该项目的基本要求后，我希望能够进一步将俞老师课程上所学到的知识应用于实践，因此，我决定外接一个RGB TFT-LCD的电容触摸屏，实现手机游戏的视觉效果。

> 本项目之所以不采用VGA，主要原因是：
>
> - 缺乏挑战性：笔者此前在大二的《数字逻辑基础（H）》课上已经使用VGA实现过一个钢琴音乐游戏（详见[Crys-Chen/Piano](https://github.com/Crys-Chen/Piano)）。笔者认为如果继续吃老本，难以有进一步的收获。
> - 缺乏原创性：无论是校园还是互联网，均充斥着学长学姐和行业前辈们实现的“FPGA打地鼠”参考代码。不如挑战无人区，尝试RGB TFT-LCD电容触摸屏的开发。
> - 便捷性：本项目使用的开发板直接提供了TFT-LCD 接口，这是笔者挑战使用RGB TFT-LCD进行开发的直接动力。

#### 2.2.3.1 显示屏介绍

RGB TFT-LCD的电容触摸屏基于TFT-LCD(Thin Film Transistor-Liquid Crystal Display)，即薄膜晶体管液晶显示屏。它显示的每个像素点都是由集成在液晶后面的薄膜晶体管独立驱动，因此 TFT-LCD 具有较高的响应速度以及较好的图像质量。本项目采用的是正点原子推出的4.3寸800x480显示屏，如图：

<img src="D:\TyporaImages\3d7b340cca05a92451a9a619242ff3b.jpg" alt="3d7b340cca05a92451a9a619242ff3b" style="zoom:33%;" /><img src="D:\TyporaImages\image-20250501145924514.png" alt="image-20250501145924514" style="zoom:50%;" />

#### 2.2.3.2 显示原理

LCD的显示原理与VGA大同小异，均可以想象成绘画，在显示的过程中用一根“笔”在不同的像素点画上不同的颜色。这根笔按照从左至右、从上到下的顺序扫描每个像素点，并且在像素画上对应的颜色，当画到最后一个像素点的时候一幅图像就绘制好了。假如一个 LCD 的分辨率为 1024*600，那么其扫描如下图所示。绘画所用的“笔”由行同步信号HSYNC和垂直同步信号VSYNC所控制。

<img src="D:\TyporaImages\image-20250505160449535.png" alt="image-20250505160449535" style="zoom: 50%;" />

本项目所采用屏幕的显示参数如下：

<img src="D:\TyporaImages\image-20250505160314812.png" alt="image-20250505160314812" style="zoom:50%;" />

接口如下：

<img src="D:\TyporaImages\image-20250505160806010.png" alt="image-20250505160806010" style="zoom:50%;" />

#### 2.2.3.3 触屏原理

电容式触摸屏分为自我电容和交互电容两种，本项目所使用的屏幕采用的是交互电容类型，也称“投射式”。投射式电容触摸屏采用纵横两列电极组成感应矩阵来感应触摸。以两个交叉的电极矩阵（X 轴电极和 Y轴电极）来检测每一格感应单元的电容变化，如下图所示：

<img src="D:\TyporaImages\image-20250505164914454.png" alt="image-20250505164914454" style="zoom:50%;" />

4.3 寸 800*480 的 RGB TFT-LCD 屏使用的触摸芯片为 GT911，该芯片是深圳汇顶科技研发的一颗电容触摸屏驱动 IC，支持 100Hz 触点扫描频率，支持 5 点触摸，支持 1810 个检测通道。

阅读该芯片的SPEC，可知该芯片的基本信息和开发方法：

GT911 与 FPGA 连接通过 4 根线完成：SDA、SCL、RST 和 INT。其中：SDA 和 SCL 是 IIC 通信用的，RST 是复位脚（低电平有效），INT 是中断输出信号。GT911采用标准的IIC通信，最大通信速率为400KHz。GT911的IIC器件地址，可以是0X14或者0X5D，

当复位结束后的 5ms 内，如果 INT 是高电平，则使用 0X14 作为地址，否则使用 0X5D 作为地址。

本章我们使用 7’h14 作为器件地址（不含最低位，换算成读写命令则是读：0X29，写：0X28）。GT911 上电设置器件地址的时序图如下图所示：

<img src="D:\TyporaImages\image-20250505165214828.png" alt="image-20250505165214828" style="zoom: 50%;" />



除了驱动方法以外，我们还关心两个非常重要的寄存器：状态寄存器和坐标寄存器：

<img src="D:\TyporaImages\image-20250505165405292.png" alt="image-20250505165405292" style="zoom:67%;" />

此处最高位用于表示 buffer 状态，如果有数据（坐标/按键），buffer就会是 1，最低 4 位用于表示有效触点的个数，范围是：0~5，0 表示没有触摸，5 表示有 5 点触摸。

<img src="D:\TyporaImages\image-20250505165419150.png" alt="image-20250505165419150" style="zoom: 67%;" />

我们一般只用到触点的 X，Y 坐标，所以只需要读取 0X8150~0X8153 的数据组合，即可得到触点坐标。其他 4 组分别是：0X8158、0X8160、0X8168 和 0X8170 等开头的 16 个寄存器组成，分别针对触点 2~4 的坐标。GT911 支持寄存器地址自增，我们只需要发送寄存器组的首地址，然后连续读取即可，GT911 会自动地址自增，从而提高读取速度。

```verilog
st_get_coord : begin
    case(flow_cnt)   
        'd0 : begin
            i2c_exec <= 1'b1;
            i2c_rh_wl <= 1'b1;
            i2c_addr <= coord_reg;       // Get X and Y direction coordinates
            reg_num <= 'd4;              // Continuous read of four registers
            flow_cnt <= flow_cnt + 1'b1;
        end
        'd1 : begin
            if(once_done) begin
                if(i2c_ack == 1'b0) begin
                    tp_x_coord_t[7:0] <= i2c_data_r;
                    flow_cnt <= flow_cnt + 1'b1;
                end    
                else
                    flow_cnt <= 1'b0;                                    
            end
        end
        'd2 : begin
            if(once_done) begin
                flow_cnt <= flow_cnt + 1'b1;
                tp_x_coord_t[15:8] <= i2c_data_r;   
            end                            
        end
        'd3 : begin
            if(once_done) begin
                flow_cnt <= flow_cnt + 1'b1;
                tp_y_coord_t[7:0] <= i2c_data_r;    
            end                            
        end    
        'd4 : begin
            if(once_done) begin
                st_done  <= 1'b1;
                flow_cnt <= 'd0;
                tp_y_coord_t[15:8] <= i2c_data_r;  
            end                            
        end
```



在开发文档中，设计人员建议的触屏状态机设计如下：

<img src="D:\TyporaImages\image-20250505173621455.png" alt="image-20250505173621455" style="zoom:67%;" />

<img src="D:\TyporaImages\image-20250505173828127.png" alt="image-20250505173828127" style="zoom: 67%;" />

#### 2.2.3.4 数据字模&界面图片

因为TFT-LCD的显示是以像素点为单位的，因此相比起七段数码管，TFT-LCD显示文字要复杂许多。我们必须对每个文字进行像素分析，得到以像素点为单位的字模，将对应字模存在FPGA上，才能控制TFT-LCD显示对应的文字。本项目对10个阿拉伯数字进行了上述字模编码，得到16×32的字模。

<img src="D:\TyporaImages\image-20250505170855952.png" alt="image-20250505170855952" style="zoom: 67%;" />

导入Verilog代码中：

``` verilog
always @(posedge clk) begin
    char[0 ]  <= {8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h03,8'hC0,8'h06,8'h20,
                8'h0C,8'h30,8'h18,8'h18,8'h18,8'h18,8'h18,8'h08,8'h30,8'h0C,8'h30,8'h0C,8'h30,8'h0C,8'h30,8'h0C,
                8'h30,8'h0C,8'h30,8'h0C,8'h30,8'h0C,8'h30,8'h0C,8'h30,8'h0C,8'h30,8'h0C,8'h18,8'h08,8'h18,8'h18,
                8'h18,8'h18,8'h0C,8'h30,8'h06,8'h20,8'h03,8'hC0,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00} ; // "0"
    char[1 ]  <= {8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h80,8'h01,8'h80,
                8'h1F,8'h80,8'h01,8'h80,8'h01,8'h80,8'h01,8'h80,8'h01,8'h80,8'h01,8'h80,8'h01,8'h80,8'h01,8'h80,
                8'h01,8'h80,8'h01,8'h80,8'h01,8'h80,8'h01,8'h80,8'h01,8'h80,8'h01,8'h80,8'h01,8'h80,8'h01,8'h80,
                8'h01,8'h80,8'h01,8'h80,8'h03,8'hC0,8'h1F,8'hF8,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00} ; // "1"
    ...
end
```



由于使用verilog来控制界面绘制实在过于麻烦，片上的寄存器资源也相当有限，因此，笔者决定事先将图片绘制完毕，存于FPGA的ROM中。本项目一共有三个游戏界面：

- 菜单界面（Menu Screen）

<img src="D:\TyporaImages\MenuScreen.jpg" alt="MenuScreen" style="zoom:50%;" />

- 游戏界面（Game Screen）：右图九宫格为地鼠出现的田地，每个田地格大小为$150\times150$

<img src="D:\TyporaImages\GameScreen.jpg" alt="GameScreen" style="zoom:50%;" />

- 结算界面（Over Screen）

<img src="D:\TyporaImages\OverScreen.jpg" alt="OverScreen" style="zoom:50%;" />

此三界面均使用基于python的opencv库绘制，字体和配色均由笔者精挑细选、反复推敲得到，源代码位于src/img/xxxScreen.py等几个文件中。最后，我们可通过Matlab将上述三张图片转为coe格式，源代码位于src/img/IMG2COE.m中。

例化IP核：选择Block Memory，Basic选项卡中选择Single Port ROM，因为是RGB888数据，因此宽度为24，深度与图片大小有关，笔者所使用图片的coe文件由24000行，因此深度为24000。设置完毕后在Other Options选项卡里选择加载coe文件。

<img src="D:\TyporaImages\image-20250505173339021.png" alt="image-20250505173339021" style="zoom:50%;" />



> 在例化ROM IP核的过程中，笔者遇到了一个尴尬的问题：显示屏的尺寸为800×480，这要求仅仅每张图片的大小便要达到$800\times480\times24\div2^{20}=8.79\text{Mbit}$，而板载BRAM仅有$2.1\text{Mbit}$。项目所需的BRAM大小远远超出能利用的硬件资源。最后笔者无可奈何，只能将每张图片的宽和高均缩小到原来的$\frac{1}{4}$，如此一来大小便缩小到原来的$\frac{1}{16}$。三张图片一共是$8.79\div16\times3=1.65\text{Mbit}$，加上游戏过程中随机出现的地鼠贴图，原本为$150\times150$，但为了节省空间也缩小到$75\times75(0.13Mbit)$。如此一来，项目一共使用的BRAM资源是$1.65+0.13=1.78\text{Mbit}<2.1\text{Mbit}$，能够完整存于BRAM中。缩小后的图片会在显示时拉伸放大，以损失清晰度的代价换取游戏视觉效果的完整性。

#### 2.2.3.5 显示优先级

当处于游戏中且显示屏的扫描到地鼠或数据与背景图的重叠左边时，会优先显示地鼠和数据。

```verilog
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
```



#### 2.2.3.6 测试

由于该电路较为简单，且涉及现实世界的声波，因此此处略过波形测试，直接上板，用眼睛调试效率更高。



## 2.3 综合与实现

### 2.3.1 综合条件设定和结果分析

综合条件设定：如图所示，按Vivado默认的设定来。

<img src="D:\TyporaImages\image-20250506230639346.png" alt="image-20250506230639346" style="zoom:50%;" />

结果分析：该项目使用了35%的LUT和90%的BRAM。

<img src="D:\TyporaImages\image-20250506230808073.png" alt="image-20250506230808073" style="zoom: 67%;" />

<img src="D:\TyporaImages\image-20250506231157356.png" alt="image-20250506231157356" style="zoom: 33%;" />

电路图如图所示：最大的两个模块为LCD的显示和触屏模块。

![image-20250506231046451](D:\TyporaImages\image-20250506231046451.png)

### 2.3.2 静态时序结果分析

时序：

![image-20250506231314904](D:\TyporaImages\image-20250506231314904.png)

功耗：

<img src="D:\TyporaImages\image-20250506231422696.png" alt="image-20250506231422696" style="zoom: 67%;" />

# 三，下板实现

本人已将结果录制成视频并上传至bilibili，请点击查看[FPGA打地鼠（触摸屏+蜂鸣器版）](https://www.bilibili.com/video/BV1KMVpzWEPA/?vd_source=49d6aba24331143eae8d3fc696136e50)

