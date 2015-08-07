//=======================================================================
// Created by         : Ltd.com.
// Filename           : ahb_sdrctrl.v
// Author             : bb(RDC)
// Created On         : 2008-11-07 20:10
// Last Modified      : 2009-06-12 12:44
// Update Count       : 2008-11-07 20:10
// Description        : 基于ahb总线的sdram控制器 
//                     
//                     
//=======================================================================

module AHB_SDRCTRL(
input          HCLK           ; //clock
input          HRST_N         ; //reset
input          HREADY         ;
input          HSEL           ;
input   [31:0] HADDR          ;
input   [ 2:0] HSIZE          ;
input          HWRITE         ;
input   [ 1:0] HTRANS         ;
input   [ 2:0] HBURST         ;
input   [31:0] HWDATA         ;
input          WPROT          ;
input   [31:0] SDR_DATA_I     ;
//to ahb
output         HREADY_O       ;
output  [ 1:0] HRESP          ;
output  [15:0] HSPLIT         ;
//to sdram
output         SDR_CKE        ;
output         SDR_CS_N       ;
output         SDR_WE         ;
output         SDR_RAS_N      ;
output         SDR_CAS_N      ;
output  [ 3:0] SDR_DQM        ;
output  [14:0] SDR_ADDR       ;
output         SDR_DATA_O_EN  ;
output  [31:0] SDR_DATA_O     ;
output  [31:0] HRDATA         ;
);

//interconnect 
reg            i_hready       ;
reg     [ 1:0] i_hresp        ;
reg            i_cs_n         ;
reg            i_we           ;
reg            i_ras_n        ;
reg            i_cas_n        ;
reg     [ 3:0] i_dqm          ;
reg     [14:0] i_addr         ; //bank size : i_addr[14:13]； data address : i_addr[12:0];
reg     [31:0] i_data_o       ;
reg            i_data_o_en    ;
reg     [31:0] i_hrdata       ;


parameter     WPROT_EN   = 1'b0 ; // 写保护开关
parameter     PAGE_BURST = 2'b00; // 突发类型 0:不支持页突发，1：支持页突发;2:可编程的突发模式（根据寄存器配置page_burst)

//sdr配置寄存器
//////////////////////////////////////////////////////////////////////////////////////////
//|Renable| tRP | tRFC | tCD | BankSize  | Col Size | Command |PageBurst| Refresh Counter |
//    31     30  29 -27  26       25-23      22-21    20 - 18    17           14 - 0
reg     [31:0] SDR_CFG        ;

wire           renable   = SDR_CFG[31]    ; //读写允许标志
wire           trp       = SDR_CFG[30]    ; //precharege  :2+寄存器值
wire    [ 2:0] trfc      = SDR_CFG[29:27] ; //auto_refresh:3+寄存器值,同时作为tRAS的时间(tRAS=寄存器值+1) 
wire           tcal      = SDR_CFG[26]    ; //cas latency 长度： 2+寄存器值,同时作为tRCD延迟
wire    [ 2:0] bsize     = SDR_CFG[25:23] ; //bank size: 000 : 4M ,001: 8M ..........
wire    [ 1:0] csize     = SDR_CFG[22:21] ; //col size: 00:256(A7-A0)  , 01:512 (A8-A0), 10:1024 (A9-A0)
wire    [ 2:0] command   = SDR_CFG[20:18] ;
wire           page_burst= SDR_CFG[17]    ;
wire    [14:0] ref_cnt   = SDR_CFG[14:0 ] ;


reg     [14:0] refresh_cnt;//自动刷新计数器
reg     [ 2:0] trfc_cnt   ; //刷新计数器，这里设计为，每次执行完一个命令就不选中sdram，然后延迟trfc+1个时间 
reg     [ 2:0] tras_cnt   ; //tRAS计数器，用来判断RAS的延迟是否争取  modified by python_wang 2008.11.22


parameter     SD_IDLE   = 5'd0  ; //sdram 操作状态
parameter     SD_ACT1   = 5'd1  ;
parameter     SD_ACT2   = 5'd2  ;
parameter     SD_ACT3   = 5'd3  ;
parameter     SD_RD1    = 5'd4  ;
parameter     SD_RD2    = 5'd5  ;
parameter     SD_RD3    = 5'd6  ;
parameter     SD_RD4    = 5'd7  ;
parameter     SD_RD5    = 5'd8  ;
parameter     SD_RD6    = 5'd9  ;
parameter     SD_RD7    = 5'd10 ;
parameter     SD_WR1    = 5'd12 ;
parameter     SD_WR2    = 5'd13 ;
parameter     SD_WR3    = 5'd14 ;
parameter     SD_WR4    = 5'd15 ;
parameter     SD_WR5    = 5'd16 ;

parameter     CM_IDLE   = 3'b000; //命令状态机
parameter     CM_ACTIVE = 3'b001;
parameter     CM_DOUT   = 3'b010;

parameter     I_IDLE    = 3'b000;//初始化状态机
parameter     I_PRE     = 3'b001;
parameter     I_REF     = 3'b010;
parameter     I_LMODE   = 3'b100;
parameter     I_FINISH  = 3'b101;

parameter     PRECHARGE = 3'b001;
parameter     AUTO_REF  = 3'b010;
parameter     LOAD_MODE = 3'b011;

reg  [4:0] SD_CS,SD_NS;
reg  [2:0] CM_CS,CM_NS;
reg  [2:0] I_CS,I_NS  ;


//地址控制段寄存
reg     [ 2:0] size_r    ;
reg     [ 1:0] trans_r   ;
reg     [31:0] addr_r    ;
reg            wr_r      ;

always@(posedge HCLK or negedge HRST_N) begin : register_for_address_control_data
    if(!HRST_N) begin
        addr_r  <= #1 'b0     ;
        size_r  <= #1 'b0     ;
        wr_r    <= #1 'b0     ;
        trans_r <= #1 'b0     ;
    end
    else if(HREADY && HSEL) begin
        //如果传输准备好，同时sdram被选种，寄存地址控制段的数据
        addr_r  <= #1  HADDR   ;
        size_r  <= #1  HSIZE   ;
        wr_r    <= #1  HWRITE  ;
        trans_r <= #1  HTRANS  ;
    end
end
//输入数据寄存
always@(posedge HCLK or negedge HRST_N) begin : sdram_input_data_register
    if (!HRST_N) begin
        i_hrdata <= #1 'b0;
    end
    else begin
        i_hrdata <= #1 SDR_DATA_I;
    end
end

wire  hio  = addr_r[27] ;//地址的27位用来说明是写寄存器还是写sdram

////////////////write configure register //////////////////////////////////////////
always@(posedge HCLK or negedge HRST_N) begin : write_configure_register
    if(!HRST_N) begin
        SDR_CFG  <= #1  'b0;
    end
    else if(HREADY && HSEL && hio && trans_r[1] && wr_r) begin
        //sdram被选中，同时是写配置寄存器，而且此次读写有效
        SDR_CFG  <= #1  HWDATA;
    end
    else if(CM_CS == CM_DOUT && trfc_cnt == 0) begin
        //命令寄存器在命令状态机执行完命令之后清空
        SDR_CFG[20:18] <= #1  'b0;
    end
    else if(refresh_cnt == 1) begin
        //刷新计数器超时，写入命令
        SDR_CFG[20:18] <= #1  AUTO_REF;
    end
    else if(I_NS == I_PRE) begin
        SDR_CFG[20:18] <= #1  PRECHARGE;
    end
    else if(I_NS == I_REF) begin
        SDR_CFG[20:18] <= #1  AUTO_REF;
    end
    else if(I_NS == I_LMODE) begin
        SDR_CFG[20:18] <= #1  LOAD_MODE;
    end
end

//////////////////initial fsm ////////////////////////
reg    [ 2:0]ref_cmd_cnt;//刷新命令计数器,执行几次刷新命令

always@(posedge HCLK or negedge HRST_N) begin : refresh_command_counter
    if (!HRST_N) begin
        ref_cmd_cnt <= #1 3'b111;
    end
    else if(I_CS == I_PRE) begin
        //刷新命令执行次数
        ref_cmd_cnt <= #1 3'b10;
    end
    else if(I_CS == I_REF && command == 'b0) begin
        //在刷新状态，同时命令执行完，对命令计数
        ref_cmd_cnt <= #1 ref_cmd_cnt - 1;
    end
end

//     I_IDLE    = 3'b000,//初始化状态机
//     I_PRE     = 3'b001,
//     I_REF     = 3'b010,
//     I_LMODE   = 3'b100,
//     I_FINISH  = 3'b101;
always@(posedge HCLK or negedge HRST_N) begin
    if(!HRST_N) begin
        I_CS <= #1  I_IDLE;
    end
    else begin
        I_CS <= #1  I_NS;
    end
end

//    PRECHARGE = 3'b001,
//    AUTO_REF  = 3'b010,
//    LOAD_MODE = 3'b011;
always@(*) begin : sdram_initial_fsm
    case(I_CS)
        I_IDLE   : begin
            if(renable) begin
            //寄存器SDRAM使能标志有效
                I_NS      = I_PRE;
            end	
            else begin
                I_NS       = I_IDLE  ;
            end
        end
        I_PRE    : begin
            if(command == 0) begin
                //上一个命令执行完
                //执行自动刷新操作
                I_NS      = I_REF    ;	
            end
            else begin
                I_NS       = I_PRE  ;
            end
        end
        I_REF    : begin
            if(command == 'b0) begin
                //上一个命令执行完
                if(ref_cmd_cnt == 'b0) begin
                    I_NS      = I_LMODE;
                end
                else begin
                    I_NS      = I_REF    ;	
                end
            end
            else begin
                I_NS       = I_REF  ;
            end
        end
        I_LMODE  : begin
            if(command == 'b0) begin
                I_NS = I_FINISH;
            end
            else begin
                I_NS = I_LMODE;
            end
        end
        default  : begin
            if(renable == 'b0) begin
                I_NS = I_IDLE;
            end
            else begin
                I_NS = I_FINISH ;
            end
        end
    endcase
end


/////////////////command fsm///////////
always@(posedge HCLK or negedge HRST_N) begin : trfc_counter
    if (!HRST_N) begin
        trfc_cnt <= #1 'b0;
    end
    else if(CM_CS == CM_DOUT) begin
        trfc_cnt <= #1 trfc_cnt - 1'b1;
    end
    else if(CM_CS == CM_ACTIVE)begin
        trfc_cnt <= #1 trfc ;
    end
    else begin
        trfc_cnt <= #1 'b0;
    end
end

always@(posedge HCLK or negedge HRST_N) begin : command_fsm_cs
    if (!HRST_N) begin
        CM_CS <= #1 CM_IDLE;
    end
    else begin
        CM_CS <= #1 CM_NS  ;
    end
end

//     CM_IDLE   = 3'b000, //命令状态机
//     CM_ACTIVE = 3'b001,
//     CM_DOUT   = 3'b010;
always @(*) begin : command_fsm_ns
    case(CM_CS)
        CM_IDLE   : begin 
            if(SD_CS == SD_IDLE) begin
                case(command) 
                    PRECHARGE   :  CM_NS   = CM_ACTIVE;
                    AUTO_REF    :  CM_NS   = CM_ACTIVE;
                    LOAD_MODE   :  CM_NS   = CM_ACTIVE;
                    default     :  CM_NS   = CM_IDLE;
                endcase
            end
            else begin
                CM_NS = CM_IDLE ;
            end
        end
        CM_ACTIVE : CM_NS   = CM_DOUT;
        CM_DOUT   : begin 
            if(trfc_cnt == 'b0)
                CM_NS = CM_IDLE;
            else 
                CM_NS = CM_DOUT;
        end
        default   :   CM_NS = CM_IDLE;
    endcase
end
//////////////////////auto refresh counter////////////////////////////////
always@(posedge HCLK or negedge HRST_N) begin : auto_refresh_counter
    if (!HRST_N) begin
        refresh_cnt <= #1 'b0;
    end
    else if(HREADY && HSEL && hio && wr_r && trans_r[1]) begin
        //如果sdram准备好，同时被选中，同时为有效传输，此时正在写配置寄存器
        refresh_cnt  <= #1 'b0;
    end
    else if(renable && I_CS == I_FINISH) begin
        //sdram使能，同时完成初始化，开始计数
        if(refresh_cnt == 1) begin
            refresh_cnt <= #1 ref_cnt;
        end
        else begin
            refresh_cnt <= #1 refresh_cnt - 1'b1;
        end
    end
end


////////////////////sdram read or write fsm/////////////////////////////
reg           line_burst   ; //突发类型

always@(posedge HCLK or negedge HRST_N) begin : set_line_bust_type
    if (!HRST_N) begin
        line_burst <= #1 'b0 ;
    end
    else if(PAGE_BURST == 2'b0 || (PAGE_BURST == 2'b10 && page_burst == 1'b0)) begin
        //禁止页突发，或者可编程模式的突发类型，且配置寄存器不允许页突发
        line_burst <= #1 'b1;
    end
    else begin
        line_burst <= #1 1'b0;
    end
end

//sdram准备好，同时被选中，此时为一个有效的传输，不是写寄存器
wire valid_sel = HREADY && HSEL && HTRANS[1] && (!HADDR[27]);

reg  valid_sel_r ; //有效操作选择
always@(posedge HCLK or negedge HRST_N) begin : set_valid_select_read_or_write
    if (!HRST_N) begin
        valid_sel_r <= #1 'b0;
    end
    else if(HREADY && HSEL) begin
        valid_sel_r <= #1 valid_sel;
    end
end

reg  wr_prot ;//写保护
always@(posedge HCLK or negedge HRST_N) begin : set_write_protection
    if (!HRST_N) begin
        wr_prot <= #1 'b0;
    end
    else  begin
        //如果允许写保护
        wr_prot <= #1 WPROT_EN ? WPROT : 'b0 ;
    end
end

always@(posedge HCLK or negedge HRST_N) begin : tras_counter
    if (!HRST_N) begin
        tras_cnt <= #1 'b0;
    end
    else if(SD_CS == SD_WR1) begin
        tras_cnt <= #1 trfc;
    end
    else if(tras_cnt != 0) begin
        tras_cnt <= #1 tras_cnt - 1;
    end
end
//////////////////SDRAM 读写状态机//////////////////////////
always@(posedge HCLK or negedge HRST_N) begin
    if (!HRST_N) begin
        SD_CS  <= #1 SD_IDLE;
    end
    else begin
        SD_CS  <= #1 SD_NS;
    end
end

always @(*) begin
    case(SD_CS)
        SD_IDLE   : begin  
            if(CM_CS == CM_IDLE && command == 0 &&  (valid_sel_r || valid_sel) && (!hio)) begin
                //命令状态机空闲，且无命令执行，sdram被选种，同时是有效读写，非寄存器
                //读写
                SD_NS = SD_ACT1;
            end
            else begin
                SD_NS = SD_IDLE;
            end
        end
        SD_ACT1   : begin  
            if(tcal) begin
                //根据寄存器配置，是延迟2个周期，还是延迟3个周期
                SD_NS = SD_ACT2;
            end
            else begin
                SD_NS = SD_ACT3;
            end
        end
        SD_ACT2   : begin  
            SD_NS = SD_ACT3; 
        end
        SD_ACT3   : begin  
            if(wr_r) begin
            //如果寄存的操作是写sdram
                SD_NS = SD_WR1;
            end
            else begin
                SD_NS = SD_RD1;
            end
        end
        SD_WR1    : begin  
            //写sdram
            if(wr_r && trans_r == `HTRANS_SEQ && i_hready && (!wr_prot)) begin
                //上次是连续写，当前ready 准备好，同时不是写保护
                if(addr_r[5:2] == 4'b1111 && command == AUTO_REF) begin
                  //如果写地址低4位为1111,同时当前命令寄存器是刷新操作，退出，执行刷新
                  //写到边界，同时命令寄存器中有刷新操作，退出
                  SD_NS = SD_WR2 ;
                end
                else begin
                    SD_NS = SD_WR1;
                end
            end
            else begin
                //回写，执行nop一次
                SD_NS = SD_WR2;
            end
        end
        SD_WR2    : begin  
            //每次写完sdram进行precharge
            //precharege 延迟 2+trp值
            if(tras_cnt == 0) 
                //如果满足tras，执行precharege
                SD_NS = SD_WR3;
            else
                SD_NS = SD_WR2;
            end
        SD_WR3    : begin  
            SD_NS = SD_WR4;
        end
        SD_WR4    : begin  
            if(trp == 1'b0) begin
                //precharege延迟2周期
                SD_NS = SD_IDLE;
            end
            else begin
                //precharege延迟3周期
                SD_NS = SD_WR5;
            end
        end
        SD_WR5    : begin  
            SD_NS =SD_IDLE;
        end
        SD_RD1    : begin  
            //执行read命令，同时跳转,CL延迟
            SD_NS = SD_RD2;
        end
        SD_RD2    : begin  
            if(tcal) begin
                //tCAS延迟，如果是1，延迟2+1个周期
                SD_NS = SD_RD3;
            end
            else begin
                //延迟2个周期
                SD_NS = SD_RD4;
            end
        end
        SD_RD3    : begin  
            SD_NS = SD_RD4;
        end
        SD_RD4    : begin  
            SD_NS = SD_RD5;
        end
        SD_RD5    : begin  
         //执行读命令
         if(HTRANS != `HTRANS_SEQ || i_cs_n == 1'b1  
                || (addr_r[5:2] == 4'b1111 && command == AUTO_REF)) begin
             //如果当前传输不是连续的，或者当前执行了刷新命令 ,或者当前没有选中sdram
             SD_NS  = SD_RD6;
         end
         else begin
             SD_NS = SD_RD5;
         end
        end
        SD_RD6    : begin  
        //每次写完执行precharge操作
            if(trp) begin
                SD_NS = SD_RD7;
            end
            else begin
                SD_NS = SD_IDLE;
            end
        end
        SD_RD7    : begin  
             SD_NS = SD_IDLE;
        end
        default   : begin
            SD_NS = SD_IDLE;
        end
    endcase
end

///////////////////SDRAM Output signal/////////////////////////

reg    [3:0] dqm ;
always@(*) begin : set_dqm
    case(size_r) 
        2'b00 : begin   //字节
            case(addr_r[1:0])
                2'b00   : dqm = 4'b0111;//最高位有效
                2'b01   : dqm = 4'b1011;//次高位有效
                2'b10   : dqm = 4'b1101;//次低位有效
                2'b11   : dqm = 4'b1110;//最低位有效
                default : dqm = 4'b1110;//最低位有效
            endcase
        end
        2'b01 : begin  //半字
            if(addr_r[1]) begin
                //高半字有效
                dqm = 4'b0011;
            end
            else begin
                //低半字有效
                dqm = 4'b0011;
            end
        end
        2'b10 : begin  //字
            dqm = 4'b0000;
        end
        default : begin
            dqm = 4'b0000;
        end
    endcase
end

reg    [12:0]row_addr   ;
reg    [ 9:0]col_addr   ;
always@(*) begin : set_sdram_address
    case(csize)
        2'b00 : begin
            //256
            col_addr  = {2'b0,addr_r[9:2]};
            row_addr  = addr_r[22:10];
        end
        2'b01 : begin
            //512
            col_addr  = {1'b0,addr_r[10:2]};
            row_addr  = addr_r[23:11];
        end
        2'b10 : begin
            //1024
            col_addr  = addr_r[11:2];
            row_addr  = addr_r[24:12];
        end
        default : begin
            col_addr  = {2'b0,addr_r[9:2]};
            row_addr  = addr_r[22:10];
        end
    endcase
end

reg    [ 1:0]bank_addr  ;
always@(*) begin : set_bank_address
    case(bsize)
        3'b000  : bank_addr = addr_r[21:20] ; //4m
        3'b001  : bank_addr = addr_r[22:21] ; //8m
        3'b010  : bank_addr = addr_r[23:22] ; //16m
        3'b011  : bank_addr = addr_r[24:23] ; //32m
        default : bank_addr = addr_r[25:24] ; //128m
    endcase
end

////////////////////////sdram output signal/////////////////////////////////
always@(posedge HCLK or negedge HRST_N) begin : set_sdram_output_signal
    if (!HRST_N) begin
        {i_cs_n,i_ras_n,i_cas_n,i_we} <= #1   {1'b1,1'b1,1'b1,1'b1}; //deselect
        i_addr   <= #1 'b0;
        i_dqm    <= #1 'b0;
    end
    else if(SD_NS == SD_IDLE && command != 0) begin
        //SDRAM处于空闲状态，同时有命令执行
        //根据命令状态机确定输出
        case(CM_NS)
            CM_ACTIVE : begin
                case(command) 
                        PRECHARGE   :  begin
                            //precharge all bank
                            {i_cs_n,i_ras_n,i_cas_n,i_we} <= #1  {1'b0,1'b0,1'b1,1'b0}; //precharege
                            i_addr[10]                    <= #1  1'b1;
                        end
                        AUTO_REF    :  begin
                            //auto refresh
                            {i_cs_n,i_ras_n,i_cas_n,i_we} <= #1  {1'b0,1'b0,1'b0,1'b1}; //refresh
                        end 
                        LOAD_MODE    : begin
                            {i_cs_n,i_ras_n,i_cas_n,i_we} <= #1  {1'b0,1'b0,1'b0,1'b0}; //load mode register
                              //写：single ，读：burst
                            if(line_burst) begin
                                //如果允许行突发,读突发长度为8
                                i_addr  <= #1  {10'b00_0001_0001,tcal,4'b0011};
                            end
                            else begin
                                //读突发长度为全页
                                i_addr  <= #1  {10'b00_0001_0001,tcal,4'b0111};
                            end
                        end
                        default   : {i_cs_n,i_ras_n,i_cas_n,i_we} <= #1  {1'b0,1'b1,1'b1,1'b1}; //nop
                    endcase
            end
            CM_DOUT   : {i_cs_n,i_ras_n,i_cas_n,i_we} <= #1  {1'b1,1'b1,1'b1,1'b1}; //deselect;
            default   : ; //nop
        endcase
    end
    else begin
        //根据sdram操作状态机确定输出
        case(SD_NS)
            SD_ACT1 : begin
                //active bank row 激活
                {i_cs_n,i_ras_n,i_cas_n,i_we} <= #1  {1'b0,1'b0,1'b1,1'b1}; //active
                i_addr                        <= #1  {bank_addr,row_addr};
            end
            SD_ACT2 : {i_cs_n,i_ras_n,i_cas_n,i_we} <= #1  {1'b0,1'b1,1'b1,1'b1}; //nop
            SD_ACT3 : {i_cs_n,i_ras_n,i_cas_n,i_we} <= #1  {1'b0,1'b1,1'b1,1'b1}; //nop
            SD_WR1  : begin
                //写数据，
                {i_cs_n,i_ras_n,i_cas_n,i_we} <= #1  {1'b0,1'b1,1'b0,1'b0}; //write
                i_addr   <= #1  {5'b0,col_addr};
                i_dqm    <= #1  dqm            ;
            end
            SD_WR2  : begin
                //nop,回写
                {i_cs_n,i_ras_n,i_cas_n,i_we} <= #1  {1'b0,1'b1,1'b1,1'b1}; //nop
                i_dqm                         <= #1  4'b1111;
            end
            SD_WR3  : {i_cs_n,i_ras_n,i_cas_n,i_we} <= #1  {1'b0,1'b0,1'b1,1'b0}; //precharege//回写后precharge 
            SD_WR4  : {i_cs_n,i_ras_n,i_cas_n,i_we} <= #1  {1'b0,1'b1,1'b1,1'b1}; //nop
            SD_WR5  : {i_cs_n,i_ras_n,i_cas_n,i_we} <= #1  {1'b0,1'b1,1'b1,1'b1}; //nop
            SD_RD1  : begin
                //读数据
                {i_cs_n,i_ras_n,i_cas_n,i_we} <= #1  {1'b0,1'b1,1'b0,1'b1}; //read
                i_addr <= #1  {5'b0,col_addr}  ;
                i_dqm  <= #1  dqm              ;
            end
            SD_RD2  : begin
                if(line_burst && HTRANS[1] && HTRANS[0]) begin
                    //支持突发读,同时当前是连续传输
                    if(addr_r[4:2] == 3'b111) begin
                        {i_cs_n,i_ras_n,i_cas_n,i_we} <= #1  {1'b0,1'b1,1'b0,1'b1}; //read
                        //上次读地址低3位为7，下次读地址低3位为0 ，同时高位加1
                        i_addr[2:0]  <= #1  3'b0           ;
                        i_addr[9:3]  <= #1  col_addr[9:3] + 1'b1; 
                    end
                    else begin
                          {i_cs_n,i_ras_n,i_cas_n,i_we} <= #1  {1'b0,1'b1,1'b1,1'b1}; //nop
                    end
                end
                else begin
                    {i_cs_n,i_ras_n,i_cas_n,i_we} <= #1  {1'b0,1'b1,1'b1,1'b1}; //nop
                end
            end
            SD_RD3  : begin
                if(line_burst && HTRANS[1] && HTRANS[0]) begin
                    //支持突发读,同时当前是连续传输
                    if(addr_r[4:2] == 3'b110) begin
                        //上次读地址低3位为6，下次读地址低3位为0 ，同时高位加1
                        {i_cs_n,i_ras_n,i_cas_n,i_we} <= #1  {1'b0,1'b1,1'b0,1'b1}; //read
                        i_addr[2:0]  <= #1  3'b0           ;
                        i_addr[9:3]  <= #1  col_addr[9:3] + 1'b1; 
                    end
                    else begin
                        {i_cs_n,i_ras_n,i_cas_n,i_we} <= #1  {1'b0,1'b1,1'b1,1'b1}; //nop
                    end
                end
                else begin
                    {i_cs_n,i_ras_n,i_cas_n,i_we} <= #1  {1'b0,1'b1,1'b1,1'b1}; //nop
                    i_dqm  <= #1  4'b1111        ;
                end
            end
            SD_RD4  : begin
                if(! (HTRANS[0] & HTRANS[1])) begin
                    //当前是非连续笔，那么执行precharge
                    {i_cs_n,i_ras_n,i_cas_n,i_we} <= #1  {1'b0,1'b0,1'b1,1'b0}; //precharege
                    i_dqm  <= #1  4'b1111        ;
                end
                else if(line_burst && HTRANS[1] && HTRANS[0]) begin
                    //支持突发读,同时当前是连续传输
                    if(addr_r[4:2] == {1'b1,~tcal,tcal}) begin
                        //上次读地址低3位为6或5，下次读地址低3位为0 ，同时高位加1
                        {i_cs_n,i_ras_n,i_cas_n,i_we} <= #1  {1'b0,1'b1,1'b0,1'b1}; //read
                        i_addr[2:0]  <= #1  3'b0           ;
                        i_addr[9:3]  <= #1  col_addr[9:3] + 1'b1; 
                    end
                    else begin
                        {i_cs_n,i_ras_n,i_cas_n,i_we} <= #1  {1'b0,1'b1,1'b1,1'b1}; //nop
                    end
                end
                else begin
                    {i_cs_n,i_ras_n,i_cas_n,i_we} <= #1  {1'b0,1'b1,1'b1,1'b1}; //nop
                end
            end
            SD_RD5  : begin
                if(SD_CS == SD_RD4) begin
                    if(i_cs_n == 1'b0 && i_ras_n == 1'b0 && i_cas_n == 1'b1 && i_we == 1'b0) begin
                        //上次执行的是precharege，此次执行deselect
                        {i_cs_n,i_ras_n,i_cas_n,i_we} <= #1  {1'b1,1'b1,1'b1,1'b1}; //deselect
                    end
                    else if(line_burst && HTRANS[1] && HTRANS[0] &&
                                i_cs_n == 1'b0 && i_ras_n == 1'b1 && i_cas_n == 1'b1 && i_we == 1'b1) begin
                    //支持突发读,同时当前是连续传输,且上次执行的是nop命令
                        if(addr_r[4:2] == {2'b10,~tcal}) begin
                              //上次读地址低3位为4或5，下次读地址低3位为0 ，同时高位加1
                              {i_cs_n,i_ras_n,i_cas_n,i_we} <= #1  {1'b0,1'b1,1'b0,1'b1}; //read
                              i_addr[2:0]  <= #1  3'b0           ;
                              i_addr[9:3]  <= #1  col_addr[9:3] + 1'b1; 
                        end
                        else begin
                              {i_cs_n,i_ras_n,i_cas_n,i_we} <= #1  {1'b0,1'b1,1'b1,1'b1}; //nop
                        end
                    end
                    else begin
                        {i_cs_n,i_ras_n,i_cas_n,i_we} <= #1  {1'b0,1'b1,1'b1,1'b1}; //nop
                    end
                end
                else if(line_burst && HTRANS[1] && HTRANS[0] && 
                                i_cs_n == 1'b0 && i_ras_n == 1'b1 && i_cas_n == 1'b1 && i_we == 1'b1) begin
                    //支持突发读,同时当前是连续传输,且上次执行的是nop命令
                    if(addr_r[4:2] == {~tcal,tcal,tcal}) begin
                        //上次读地址低3位为3或4，下次读地址低3位为0 ，同时高位加1
                        {i_cs_n,i_ras_n,i_cas_n,i_we} <= #1  {1'b0,1'b1,1'b0,1'b1}; //read
                        i_addr[2:0]  <= #1  3'b0           ;
                        i_addr[9:3]  <= #1  col_addr[9:3] + 1'b1; 
                    end
                    else begin
                        {i_cs_n,i_ras_n,i_cas_n,i_we} <= #1  {1'b0,1'b1,1'b1,1'b1}; //nop
                    end
                end
                else begin
                    {i_cs_n,i_ras_n,i_cas_n,i_we} <= #1  {1'b0,1'b1,1'b1,1'b1}; //nop
                end
            end
            SD_RD6  : begin
                {i_cs_n,i_ras_n,i_cas_n,i_we} <= #1  {1'b0,1'b0,1'b1,1'b0}; //precharege
                i_dqm  <= #1  4'b1111              ;
            end
            SD_RD7  : begin
                {i_cs_n,i_ras_n,i_cas_n,i_we} <= #1 {1'b0,1'b1,1'b1,1'b1}; //nop
            end
            default : {i_cs_n,i_ras_n,i_cas_n,i_we} <= #1  {1'b0,1'b1,1'b1,1'b1}; //nop
        endcase
    end
end

/////////i_hready////////////////
always@(posedge HCLK or negedge HRST_N) begin : set_hready_output
    if (!HRST_N) begin
        i_hready <= #1 'b1;
    end
    else begin
        if(HREADY && HSEL && HTRANS[1] && (!i_hready) && HADDR[27]) begin
            //有效传输，写配置寄存器，同时当前ready输出为0
            i_hready <= #1  1'b1;
        end
        //else if(HREADY && HSEL && (!HTRANS[1]) && (!valid_sel)) begin
        else if(HREADY && HSEL && (!HTRANS[1])) begin
            //选中但是是非有效传输
            i_hready <= #1  1'b1;
        end
        else if(SD_NS == SD_ACT3) begin
            i_hready <= #1  wr_r & HTRANS[1] & HTRANS[0];
        end
        else if(SD_NS == SD_WR1 && SD_CS == SD_ACT3) begin
            i_hready <= #1  1'b1;
        end
        else if(SD_NS == SD_WR1) begin
            i_hready <= #1  HTRANS[0] && HTRANS[1] ;
        end
        else if(SD_NS == SD_RD5) begin
            i_hready <= #1  1'b1;
        end
        else if(HREADY && HSEL ) begin
            //如果是有效的传输
            i_hready <= #1  HADDR[27] ; //地址段的27位用来说明当前是写配置寄存器还是读写sdram
        end
    end
end



always@(posedge HCLK or negedge HRST_N) begin : hresp_output
    if (!HRST_N) begin
        i_hresp <= #1 `HRESP_OKAY;
    end
    else if((SD_NS == SD_ACT3) && wr_prot) begin
        i_hresp <= #1 `HRESP_ERROR;
    end
    else if(SD_NS == SD_WR1 && wr_prot) begin
        i_hresp <= #1 `HRESP_ERROR;
    end
    else begin
        i_hresp <= #1 `HRESP_OKAY;
    end
end

always@(posedge HCLK or negedge HRST_N) begin : set_sdram_output
    if (!HRST_N) begin
        i_data_o_en <= #1 'b0;
        i_data_o    <= #1 'b0;
    end
    else if(SD_NS == SD_WR1) begin
        i_data_o_en <= #1 'b1;
        i_data_o    <= #1  HWDATA         ;
    end
    else begin
        i_data_o_en <= #1 'b0;
        i_data_o    <= #1 'b0;
    end
end


assign    HREADY_O     = i_hready       ;
assign    SDR_CS_N     = i_cs_n         ;
assign    SDR_RAS_N    = i_ras_n        ;
assign    SDR_CAS_N    = i_cas_n        ;
assign    SDR_WE       = i_we           ;
assign    SDR_DQM      = i_dqm          ;
assign    SDR_ADDR     = i_addr         ;
assign    SDR_DATA_O   = i_data_o       ;
assign    SDR_DATA_O_EN= i_data_o_en    ;
assign    HRDATA       = i_hrdata       ;
assign    SDR_CKE      = 1'b1           ;
assign    HSPLIT       = 16'b0          ;
assign    HRESP        = i_hresp        ;

endmodule
