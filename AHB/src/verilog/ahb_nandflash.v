//================================================================================
// Created by         : Ltd.com
// Filename           : ahb_nandflash.v
// Author             : Python_Wang
// Created On         : 2009-07-20 09:58
// Last Modified      : 2009-07-23 21:47
// Description        : 
//                      
//                      
//================================================================================
module AHB_NANDFLASH(
input         HCLK           , //clock
input         HRST_N         , //reset
//ahb
input         HREADY         ,
input         HSEL           ,
input  [31:0] HADDR          ,
input  [ 2:0] HSIZE          ,
input         HWRITE         ,
input  [ 1:0] HTRANS         ,
input  [ 2:0] HBURST         ,
input  [31:0] HWDATA         ,
output        HREADY_O       ,
output [ 1:0] HRESP          ,
output [15:0] HSPLIT         ,
output [31:0] HRDATA         ,
//nand flash
output        CE_N           ,
output        ALE            ,
output        CLE            ,
output        RE_N           ,
output        WE_N           ,
output        DataEn         ,
output [ 7:0] DataOut        ,
input         RB             ,
input  [ 7:0] DataIn         ,
output        IRQ            
);

parameter    PAGE_RD1    = 8'h00     ;
parameter    PAGE_RD2    = 8'h30     ;
parameter    RD_COPY     = 8'h35     ;
parameter    RD_ID       = 8'h90     ;
parameter    FLASH_RST   = 8'hFF     ;
parameter    PAGE_WR1    = 8'h80     ;
parameter    PAGE_WR2    = 8'h10     ;
parameter    CACHE_WR    = 8'h15     ;
parameter    BLK_ERS1    = 8'h60     ;
parameter    BLK_ERS2    = 8'hD0     ;
parameter    RAND_WR     = 8'h85     ;
parameter    RAND_RD1    = 8'h05     ;
parameter    RAND_RD2    = 8'hE0     ;
parameter    RD_STATUS   = 8'h70     ;
parameter    CMD_ADDR    = 6'b001000 ;
parameter    CFG_ADDR    = 6'b010010 ;
parameter    ADR_ADDR    = 6'b001010 ;
parameter    STATUS_ADDR = 6'b001110 ;
parameter    LEN_ADDR    = 6'b101001 ;
parameter    DATA_ADDR   = 6'b010101 ;

parameter    IDLE        = 4'd0      ;
parameter    CMD_S       = 4'd1      ;
parameter    CMD         = 4'd2      ;
parameter    CMD_H       = 4'd3      ;
parameter    ADDR_S      = 4'd5      ;
parameter    ADDR        = 4'd6      ;
parameter    ADDR_H      = 4'd7      ;
parameter    READ        = 4'd8      ;
parameter    READ_S      = 4'd9      ;
parameter    READ_H      = 4'd10     ;
parameter    WRITE       = 4'd11     ;
parameter    WRITE_S     = 4'd12     ;
parameter    WRITE_H     = 4'd13     ;
parameter    CORE_RST    = 4'd14     ;

reg           iHREADY        ;
reg           iALE           ;
reg           iCLE           ;
reg           iRE_N          ;
reg           iWE_N          ;
reg           iCE_N          ;
reg           iDataEn        ;
reg    [ 7:0] iDataOut       ;
reg           FlashRst       ;
reg           iIRQ           ;
reg    [ 2:0] ColSize        ; //0:1KB  1:2KB 2:4KB
reg    [ 2:0] FlashSize      ; //0:1Gb  1:2Gb 2:4Gb 3:8Gb 4:16Gb
reg    [ 2:0] TACLS          ; // (n+1)*HCLK
reg    [ 2:0] TWRPH0         ; // (n+1)*HCLK
reg    [ 2:0] TWRPH1         ; // (n+1)*HCLK
reg    [31:0] RdData         ;
reg    [31:0] WrData         ;
reg    [39:0] Addr           ;
reg    [ 2:0] ByteCnt        ;
reg    [ 2:0] QHSize         ;
reg           QHWrite        ;
reg    [31:0] QHAddr         ;
reg    [ 1:0] QHTrans        ;
reg    [31:0] FlashRdData    ;
reg    [31:0] FlashWrData    ;
reg    [ 3:0] TimeCnt        ;
reg           RandomRead     ;
reg           StatusRead     ;
reg           ReadId         ;
reg           BlockEaser     ;
reg    [ 1:0] RandState      ;
reg           QRB            ;
reg    [ 3:0] CS, NS         ;

wire          RBPos = RB & ~QRB ;
wire          RandomWrite  = RandState[1]   ;

always @(posedge HCLK or negedge HRST_N) begin
    if (!HRST_N) begin
        QRB <= #1 1'b0 ;
    end
    else begin
        QRB <= #1 RB   ;
    end
end

always @(posedge HCLK or negedge HRST_N) begin
    if (!HRST_N) begin
        QHSize    <= #1  3'b0      ;
        QHWrite   <= #1  1'b0      ;
        QHAddr    <= #1 32'b0      ;
        QHTrans   <= #1  2'b0      ;
    end
    else if(HREADY & HSEL) begin //输入寄存
        QHSize    <= #1 HSIZE    ;
        QHAddr    <= #1 HADDR    ;
        QHWrite   <= #1 HWRITE   ;
        QHTrans   <= #1 HTRANS   ;
    end
end

always @(posedge HCLK or negedge HRST_N) begin
    if (!HRST_N) begin
        {TWRPH1, TWRPH0, TACLS, FlashSize, ColSize} <= #1 15'b0 ;
    end
    else if(HREADY && HSEL && QHWrite && QHTrans[1] && HADDR[5:0] == CFG_ADDR) begin//写寄存器
        {TWRPH1, TWRPH0, TACLS, FlashSize, ColSize} <= #1 HWDATA[14:0] ;
    end
end

always @(posedge HCLK or negedge HRST_N) begin
    if (!HRST_N)   FlashRst <= #1 1'b0 ;
    else if(FlashRst)       FlashRst <= #1 1'b0 ;
    else if(HREADY && HSEL && QHWrite && QHTrans[1] && HADDR[5:0] == STATUS_ADDR) FlashRst <= #1 1'b1 ;
end

always @(posedge HCLK or negedge HRST_N) begin
    if (!HRST_N)  RdData <= #1 32'b0 ;
    else if((~HWRITE && HADDR[5:0] == STATUS_ADDR) || (~QHWrite && QHAddr[5:0] == STATUS_ADDR))  RdData <= #1 {30'b0, FlashRst, RB} ;
    else if(CS == READ_H && NS == IDLE)                                                          RdData <= #1 {24'b0, FlashRdData} ;
end

always @(posedge HCLK or negedge HRST_N) begin
    if (!HRST_N)                                                                 WrData <= #1 32'b0       ;
    else if(CS == WRITE_H && NS == IDLE)                                         WrData <= #1 32'b0       ;
    else if(HREADY && HSEL && QHWrite && QHTrans[1] && QHAddr[5:0] == DATA_ADDR) WrData <= #1 HWDATA      ;
end

always @(posedge HCLK or negedge HRST_N) begin//当前是随机读
    if (!HRST_N)                                                             RandomRead <= #1 1'b0 ;
    else if(NS == CMD && HWDATA[7:0] != RAND_RD1 && HWDATA[7:0] != RAND_RD2) RandomRead <= #1 1'b0 ;
    else if(NS == CMD && HWDATA[7:0] == RAND_RD1)                            RandomRead <= #1 1'b1 ;
end

always @(posedge HCLK or negedge HRST_N) begin
    if (!HRST_N) begin
        RandState <= #1 2'b0 ;
    end
    else begin
        if(RandState == 2'b00 && NS == CMD && (HWDATA[7:0] == PAGE_WR1 || HWDATA[7:0] == RAND_WR)) 
            RandState <= #1 2'b01 ;
        else if(RandState == 2'b01 &&  HWDATA[7:0] == RAND_WR) 
            RandState <= #1 2'b10 ;
        else if(   RandState == 2'b10 && NS == CMD && HWDATA[7:0] != RAND_WR
                        || RandState == 2'b01 && NS == CMD && HWDATA[7:0] != RAND_WR)
            RandState <= #1 2'b00 ;
    end
end

always @(posedge HCLK or negedge HRST_N) begin//当前读状态命令
    if (!HRST_N)                                   StatusRead <= #1 1'b0 ;
    else if(NS == IDLE && CS == READ_H)            StatusRead <= #1 1'b0 ;
    else if(NS == CMD && HWDATA[7:0] == RD_STATUS) StatusRead <= #1 1'b1 ;
end

always @(posedge HCLK or negedge HRST_N) begin//当前读Id
    if (!HRST_N)                              ReadId     <= #1 1'b0 ;
    else if(NS == IDLE && CS == READ_H)       ReadId     <= #1 1'b0 ;
    else if(NS == CMD && HWDATA[7:0] == RD_ID)ReadId     <= #1 1'b1 ;
end

always @(posedge HCLK or negedge HRST_N) begin//擦除
    if (!HRST_N)                                   BlockEaser <= #1 1'b0 ;
    else if(RBPos == 1)                            BlockEaser <= #1 1'b0 ;
    else if(NS == CMD && HWDATA[7:0] == BLK_ERS1)  BlockEaser <= #1 1'b1 ;
end

reg    [39:0]iAddr     ;
reg    [ 2:0]iAddrSize ;
always @(*) begin
    iAddr     = 40'b0     ;
    iAddrSize =  3'b0     ;
    if(NS == ADDR) begin
        case(FlashSize)
            0 : begin //1Gb
                case(ColSize)
                    0       : begin iAddrSize = 5 ; iAddr = {7'b0, HWDATA[27:11], 5'b0, HWDATA[10:0]} ; end //1kB
                    1       : begin iAddrSize = 4 ; iAddr = {8'b0, HWDATA[27:12], 4'b0, HWDATA[11:0]} ; end //2kB
                    2       : begin iAddrSize = 4 ; iAddr = {9'b0, HWDATA[27:13], 3'b0, HWDATA[12:0]} ; end //4kB
                    default : begin iAddrSize = 5 ; iAddr = {7'b0, HWDATA[27:11], 5'b0, HWDATA[10:0]} ; end //1kB
                endcase
            end
            1 : begin //2Gb
                case(ColSize)
                    0       : begin iAddrSize = 5 ; iAddr = {6'b0, HWDATA[28:11], 5'b0, HWDATA[10:0]} ; end //1kB
                    1       : begin iAddrSize = 5 ; iAddr = {7'b0, HWDATA[28:12], 4'b0, HWDATA[11:0]} ; end //2kB
                    2       : begin iAddrSize = 5 ; iAddr = {8'b0, HWDATA[28:13], 3'b0, HWDATA[12:0]} ; end //4kB
                    default : begin iAddrSize = 5 ; iAddr = {6'b0, HWDATA[28:11], 5'b0, HWDATA[10:0]} ; end //1kB
                endcase
            end
            2 : begin //4Gb
                case(ColSize)
                    0       : begin iAddrSize = 5 ; iAddr = {5'b0, HWDATA[29:11], 5'b0, HWDATA[10:0]} ; end //1kB
                    1       : begin iAddrSize = 5 ; iAddr = {6'b0, HWDATA[29:12], 4'b0, HWDATA[11:0]} ; end //2kB
                    2       : begin iAddrSize = 5 ; iAddr = {7'b0, HWDATA[29:13], 3'b0, HWDATA[12:0]} ; end //4kB
                    default : begin iAddrSize = 5 ; iAddr = {5'b0, HWDATA[29:11], 5'b0, HWDATA[10:0]} ; end //1kB
                endcase
            end
            3 : begin //8Gb
                case(ColSize)
                    0       : begin iAddrSize = 5 ; iAddr = {4'b0, HWDATA[30:11], 5'b0, HWDATA[10:0]} ; end //1kB
                    1       : begin iAddrSize = 5 ; iAddr = {5'b0, HWDATA[30:12], 4'b0, HWDATA[11:0]} ; end //2kB
                    2       : begin iAddrSize = 5 ; iAddr = {6'b0, HWDATA[30:13], 3'b0, HWDATA[12:0]} ; end //4kB
                    default : begin iAddrSize = 5 ; iAddr = {4'b0, HWDATA[30:11], 5'b0, HWDATA[10:0]} ; end //1kB
                endcase
            end
            3 : begin //16Gb
                case(ColSize)
                    0       : begin iAddrSize = 5 ; iAddr = {3'b0, HWDATA[31:11], 5'b0, HWDATA[10:0]} ; end //1kB
                    1       : begin iAddrSize = 5 ; iAddr = {4'b0, HWDATA[31:12], 4'b0, HWDATA[11:0]} ; end //2kB
                    2       : begin iAddrSize = 5 ; iAddr = {5'b0, HWDATA[31:13], 3'b0, HWDATA[12:0]} ; end //4kB
                    default : begin iAddrSize = 5 ; iAddr = {4'b0, HWDATA[31:11], 5'b0, HWDATA[10:0]} ; end //1kB
                endcase
            end
        endcase
    end
end


always @(posedge HCLK or negedge HRST_N) begin
    if (!HRST_N) begin
        CS <= #1 IDLE ;
    end
    else begin
        CS <= #1 NS   ;
    end
end

always @(*) begin
    NS = CS ;
    case(CS)
        IDLE       : begin
            if(HREADY && HSEL && HTRANS[1] && ~HWRITE && HADDR[5:0] == DATA_ADDR)  NS = READ ;
            else if(HREADY && HSEL && QHTrans[1] && QHWrite) begin
                case(QHAddr[5:0])
                 CMD_ADDR  : NS = CMD   ;
                 ADR_ADDR  : NS = ADDR  ;
                 DATA_ADDR : NS = WRITE ;
                 default   : NS = IDLE  ;
                endcase
            end
            else begin
                NS = IDLE ;
            end
        end
        CMD        : begin
            if(TimeCnt == 0)  NS = CMD_S    ; //时间参数达到要求
            else              NS = CMD      ;
        end
        CMD_S      : begin
            if(TimeCnt == 0)  NS = CMD_H    ; //时间参数达到要求
            else              NS = CMD_S    ;
        end
        CMD_H      : begin
            if(TimeCnt == 0)  NS = IDLE     ; //时间参数达到要求
            else              NS = CMD_H    ;
        end
        ADDR       : begin
            if(TimeCnt == 0)  NS = ADDR_S   ;
            else              NS = ADDR     ;
        end
        ADDR_S     : begin
            if(TimeCnt == 0)  NS = ADDR_H   ; //时间参数达到要求
            else              NS = ADDR_S   ;
        end
        ADDR_H     : begin
            if(TimeCnt == 0 && ByteCnt!= 1)     NS = ADDR_S ; //时间参数达到要求,地址没有发送完
            else if(TimeCnt ==0 && ByteCnt == 1) NS = IDLE   ;//时间参数达到要求,地址发送完
            else                                  NS = ADDR_H ;
        end
        READ       : begin
            if(TimeCnt == 0)  NS = READ_S   ;
            else              NS = READ     ;
        end
        READ_S     : begin
            if(TimeCnt == 0 ) NS = READ_H ; //满足时间参数
            else              NS = READ_S ; //等待
        end
        READ_H     : begin
            if(TimeCnt == 0 && ByteCnt !=1 )       NS = READ_S ;//还没有读取32bit
            else if(TimeCnt == 0 && ByteCnt == 1)  NS = IDLE   ;//已经读取了32bit
            else                                   NS = READ_H ;//时间参数不满足
        end
        WRITE      : begin
            if(TimeCnt == 0)  NS = WRITE_S ;
            else              NS = WRITE   ;
        end
        WRITE_S    : begin
            if(TimeCnt == 0)  NS = WRITE_H ;
            else              NS = WRITE_S ;
        end
        WRITE_H    : begin
            if(TimeCnt == 0 && ByteCnt !=1 )       NS = WRITE_S;//还没有写完32bit
            else if(TimeCnt == 0 && ByteCnt == 1)  NS = IDLE   ;//已经写完了32bit
            else                                   NS = WRITE_H;//时间参数不满足
        end
        CORE_RST   : begin
            NS = CMD  ;
        end
        default    : begin
            NS = IDLE ;
        end
    endcase

    if(FlashRst)  NS = CORE_RST;
end

always @(posedge HCLK or negedge HRST_N) begin
    if (!HRST_N) begin
        {iCLE, iCE_N, iWE_N, iALE, iRE_N, iDataEn} <= #1 {1'b0, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0} ; 
        TimeCnt     <= #1  3'b0 ;
        Addr        <= #1 40'b0 ;
        iDataOut    <= #1 32'b0 ;
        ByteCnt     <= #1  3'b0 ;
        FlashRdData <= #1 32'b0 ;
        FlashWrData <= #1 32'b0 ;
    end
    else begin
        case(NS)
            IDLE       : begin
                {iCLE, iCE_N, iWE_N, iALE, iRE_N, iDataEn} <= #1 {1'b0, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0} ; 
                TimeCnt     <= #1  3'b0 ;
                Addr        <= #1 40'b0 ;
                FlashWrData <= #1 32'b0 ;
                iDataOut    <= #1 32'b0 ;
                ByteCnt     <= #1  3'b0 ;
            end
            CMD        : begin
                {iCLE, iCE_N, iWE_N, iALE, iRE_N, iDataEn} <= #1 {1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0} ; 
                if(CS == CMD_S) TimeCnt <= #1 TACLS ;
                else if(TimeCnt != 0) TimeCnt <= #1 TimeCnt - 1'b1 ;

                if(CS == IDLE)  iDataOut <= #1 HWDATA[7:0];
                else if(CS == CORE_RST) iDataOut <= #1 8'hFF ;
            end
            CMD_S      : begin
                {iCLE, iCE_N, iWE_N, iALE, iRE_N, iDataEn} <= #1 {1'b1, 1'b0, 1'b0, 1'b0, 1'b1, 1'b1} ; 
                if(CS == IDLE) TimeCnt <= #1 TACLS ;
                else if(TimeCnt != 0) TimeCnt <= #1 TimeCnt - 1'b1 ;
            end
            CMD_H      : begin
                {iCLE, iCE_N, iWE_N, iALE, iRE_N, iDataEn} <= #1 {1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b1} ; 
                if(CS == CMD) TimeCnt <= #1 TWRPH1;
                else if(TimeCnt != 0) TimeCnt <= #1 TimeCnt - 1'b1 ;
            end
            ADDR       : begin
                {iCLE, iCE_N, iWE_N, iALE, iRE_N, iDataEn} <= #1 {1'b0, 1'b0, 1'b1, 1'b1, 1'b1, 1'b0} ; 
                if(CS == IDLE)   TimeCnt <= #1 TACLS          ;
                else if(TimeCnt != 0) TimeCnt <= #1 TimeCnt - 1'b1 ;

                if(CS == IDLE)  begin
                    ByteCnt  <= #1 iAddrSize ;
                    Addr     <= #1 iAddr     ;
                    if(RandomRead | RandomWrite | BlockEaser) ByteCnt <= #1 2 ;
                    else if(ReadId)                           ByteCnt <= #1 1 ;
                end
            end
            ADDR_S     : begin
                {iCLE, iCE_N, iWE_N, iALE, iRE_N, iDataEn} <= #1 {1'b0, 1'b0, 1'b0, 1'b1, 1'b1, 1'b1} ; 
                if(CS == ADDR || CS == ADDR_H)  TimeCnt <= #1 TWRPH0         ;
                else if(TimeCnt != 0)           TimeCnt <= #1 TimeCnt - 1'b1 ;

                if(CS == ADDR || CS == ADDR_H)  iDataOut <= #1 Addr[7:0] ;
                if(CS == ADDR_H)  ByteCnt <= #1 ByteCnt - 1'b1 ;
            end
            ADDR_H     : begin
                {iCLE, iCE_N, iWE_N, iALE, iRE_N, iDataEn} <= #1 {1'b0, 1'b0, 1'b1, 1'b1, 1'b1, 1'b1} ; 
                if(CS == ADDR_S)      TimeCnt <= #1 TWRPH1         ;
                else if(TimeCnt != 0) TimeCnt <= #1 TimeCnt - 1'b1 ;

                if(CS == ADDR_S)      Addr <= #1 {8'b0, Addr[39:9]} ;
            end
            READ       : begin
                {iCLE, iCE_N, iWE_N, iALE, iRE_N, iDataEn} <= #1 {1'b0, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0} ; 
                if(CS == IDLE)        TimeCnt <= #1 TACLS;
                else if(TimeCnt != 0) TimeCnt <= #1 TimeCnt - 1'b1 ;

                if(CS == IDLE)       ByteCnt <= #1 3'd4   ;
                else if(StatusRead)  ByteCnt <= #1 3'd1   ;

                if(CS == IDLE)        FlashRdData <= #1 32'b0 ;
            end
            READ_S     : begin
                {iCLE, iCE_N, iWE_N, iALE, iRE_N, iDataEn} <= #1 {1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0} ; 
                if(CS == READ || CS == READ_H) TimeCnt <= #1 TWRPH0;
                else if(TimeCnt != 0)          TimeCnt <= #1 TimeCnt - 1'b1 ;

                if(CS == READ_H)  ByteCnt <= #1 ByteCnt - 1'b1 ;
            end
            READ_H     : begin
                {iCLE, iCE_N, iWE_N, iALE, iRE_N, iDataEn} <= #1 {1'b0, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0} ; 
                if(CS == READ_S)      TimeCnt <= #1 TWRPH1;
                else if(TimeCnt != 0) TimeCnt <= #1 TimeCnt - 1'b1 ;

                if(CS == READ_S)   FlashRdData <= #1 {DataIn, FlashRdData[31:8]} ;
            end
            WRITE      : begin
                {iCLE, iCE_N, iWE_N, iALE, iRE_N, iDataEn} <= #1 {1'b0, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0} ; 
                if(CS == IDLE)       TimeCnt <= #1 TACLS          ;
                else if(TimeCnt != 0) TimeCnt <= #1 TimeCnt - 1'b1 ;

                if(CS == IDLE)        ByteCnt     <= #1 4    ;

            end
            WRITE_S    : begin
                {iCLE, iCE_N, iWE_N, iALE, iRE_N, iDataEn} <= #1 {1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b1} ; 
                if(CS == WRITE || CS == WRITE_H) TimeCnt <= #1 TWRPH0;
                else if(TimeCnt != 0)            TimeCnt <= #1 TimeCnt - 1'b1 ;

                if(CS == WRITE_H)      ByteCnt  <= #1 ByteCnt - 1'b1 ;

                if(CS == WRITE)        iDataOut     <= #1 WrData[7:0] ;
                else if(CS == WRITE_H) iDataOut  <= #1 FlashWrData[7:0] ;

                if(CS == WRITE)        FlashWrData <= #1 {8'b0, WrData[31:8]};
                else if(CS == WRITE_H) FlashWrData <= #1 {8'b0, FlashWrData[31:8]};
            end
            WRITE_H    : begin
                {iCLE, iCE_N, iWE_N, iALE, iRE_N, iDataEn} <= #1 {1'b0, 1'b0, 1'b1, 1'b0, 1'b1, 1'b1} ; 
                if(CS == WRITE_S)     TimeCnt <= #1 TWRPH1;
                else if(TimeCnt != 0) TimeCnt <= #1 TimeCnt - 1'b1 ;

            end
            default    : begin
                {iCLE, iCE_N, iWE_N, iALE, iRE_N, iDataEn} <= #1 {1'b0, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0} ; 
                TimeCnt     <= #1  3'b0 ;
                Addr        <= #1 40'b0 ;
                iDataOut    <= #1 32'b0 ;
                ByteCnt     <= #1  3'b0 ;
                FlashRdData <= #1 32'b0 ;
                FlashWrData <= #1 32'b0 ;
            end
        endcase
    end
end

always @(posedge HCLK or negedge HRST_N) begin
    if (!HRST_N) begin
        iHREADY <= #1 1'b1 ;
    end
    else if(NS == IDLE) begin
        iHREADY <= #1 1'b1 ;
    end
    else begin
        iHREADY <= #1 1'b0 ;
    end
end

always @(posedge HCLK or negedge HRST_N) begin
    if (!HRST_N) begin
        iIRQ <= #1 1'b0 ;
    end
    else if(NS == IDLE && RBPos) begin
        iIRQ <= #1 1'b1 ;
    end
    else begin
        iIRQ <= #1 1'b0 ;
    end
end

assign  HRESP    = `HRESP_OKAY                    ;
assign  HSPLIT   = 16'd0                          ;
assign  HRDATA   = RdData                         ;
assign  HREADY_O = iHREADY                        ;
assign  CE_N     = iCE_N                          ;
assign  ALE      = iALE                           ;
assign  CLE      = iCLE                           ;
assign  RE_N     = iRE_N                          ;
assign  WE_N     = iWE_N                          ;
assign  DataEn   = iDataEn                        ;
assign  DataOut  = iDataOut                       ;
assign  IRQ      = iIRQ                           ;

endmodule
