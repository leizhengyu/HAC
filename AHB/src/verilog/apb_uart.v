//================================================================================
// Created by         : Ltd.com
// Filename           : apb_uart.v
// Author             : Python_Wang
// Created On         : 2009-03-27 09:14
// Last Modified      : 2009-07-09 19:18
// Description        : 
//                      
//                      
//================================================================================

module APB_UART(
input         PCLK            , //clock
input         PRST_N          , //reset
input         PSEL            , 
input         PENABLE         ,
input         PWRITE          ,
input  [31:0] PADDR           ,
input  [31:0] PWDATA          ,
output [31:0] PRDATA          ,

output        IRQ             ,
input         Rxd_i           ,
input         ExtClk_i        ,
output        Txd_o           
);
parameter    CTRL_ADDR    = 6'b000001,
parameter    STATUS_ADDR  = 6'b000010,
parameter    SCALER_ADDR  = 6'b000100,
parameter    RHOLD_ADDR   = 6'b001000,
parameter         THOLD_ADDR   = 6'b010000;


reg    [31:0]SCALER          ; //分频基数
reg          RE              ; //receive enable
reg          TE              ; //transmit enabel
reg          PE              ; //parity enable
reg          PS              ; //parity select
reg          ECE             ; //extent clock enable 
reg          ExtClkQ         ; //extent clock register
reg    [31:0]ScalerCnt       ; //scaler counter
reg          iIRQ            ; //interrupt request

wire   [31:0]ScalerCntNext = ScalerCnt - 1'b1;
wire         Tick          = ECE ? (ExtClk_i & ~ExtClkQ) : (((ScalerCnt[31] == 1'b0) && (ScalerCntNext[31] == 1'b1)) ? 1'b1 : 1'b0);


always @(posedge PCLK or negedge PRST_N) begin
    if (!PRST_N) begin
        SCALER <= #1 'b0         ; 
    end
    else if(PSEL && PENABLE && PWRITE && (PADDR[5:0] == SCALER_ADDR)) begin
        SCALER <= #1 PWDATA      ;
    end
end

always @(posedge PCLK or negedge PRST_N) begin
    if (!PRST_N) begin
        RE     <= #1 'b0         ; 
        TE     <= #1 'b0         ; 
        PE     <= #1 'b0         ; 
        PS     <= #1 'b0         ; 
        ECE    <= #1 'b0         ; 
    end
    else if(PSEL && PENABLE && PWRITE && (PADDR[5:0] == CTRL_ADDR)) begin
        {RE,TE,PE,PS,ECE} <= #1 PWDATA[4:0] ;
    end
end

always @(posedge PCLK or negedge PRST_N) begin
    if (!PRST_N) begin
        ExtClkQ <= #1 1'b0 ;
    end
    else begin
        ExtClkQ <= #1 ExtClk_i ;
    end
end

always @(posedge PCLK or negedge PRST_N) begin//本地时钟分频
    if (!PRST_N) begin
        ScalerCnt <= #1 'b0;
    end 
    else if((ScalerCnt[31] == 1'b0) && (ScalerCntNext[31] == 1'b1) ) begin
        ScalerCnt <= #1 SCALER        ;
    end
    else begin
        ScalerCnt <= #1 ScalerCntNext ;
    end
end

//receive
reg          StateRxIdle     ;
reg          StateRxStart    ;
reg          StateRxData     ;
reg          StateRxParity   ;
reg          StateRxStop     ;
reg          Rxd             ; //通过tick采样到的数据
reg          RxdQ            ; //rxd延迟
reg    [ 2:0]RxTickCnt       ; 
reg          RxTick          ; //tick的8分频脉冲 PCLK = ext_clk*tick*8
reg          BreakReceive    ;
reg          OverRun         ;
reg          ParityErr       ;
reg          FrmErr          ;
reg    [ 7:0]RHold[7:0]      ; //receive hold fifo
reg    [ 7:0]RShift          ; //recieve shift register
reg          RSEmpty         ;
reg    [ 2:0]RRAddr          ; 
reg    [ 2:0]RWAddr          ; 
reg    [ 3:0]RCnt            ;
reg          RxDataParity    ;

wire         StartRxIdle     ;
wire         StartRxStart    ;
wire         StartRxData     ;
wire         StartRxParity   ;
wire         StartRxStop     ;
wire   [ 2:0]RxTickCntNext   ;
wire         StartToggle     ;
wire         iRFifoFull      ; 
wire         iRFifoHalfFull  ; 
wire         iDataReady      ; 


assign  iRFifoFull    = (RCnt == 8) ? 1'b1 : 1'b0 ;
assign  iRFifoHalfFull= RCnt[3] | RCnt[2] ;
assign  iDataReady    = |RCnt                     ;

assign  RxTickCntNext = RxTickCnt + 1'b1  ;

assign  StartToggle   = ~Rxd & RxdQ ;

assign  StartRxIdle   = (StateRxStart & RxTick & Rxd) | (StateRxStop & RxTick) ;
assign  StartRxStart  = RE & StateRxIdle & StartToggle  ;
assign  StartRxData   = StateRxStart & RxTick & ~Rxd ;
assign  StartRxParity = PE & StateRxData & RxTick & ~RShift[0] ;
assign  StartRxStop   = (~PE & StateRxData & RxTick & ~RShift[0]) | (StateRxParity & RxTick) ;

always @(posedge PCLK or negedge PRST_N) begin//波特率的8倍频用于采集数据
    if (!PRST_N) begin
        RxTickCnt <= #1 'b0 ;
    end
    else if(StartRxStart) begin
        RxTickCnt <= #1 3'b100    ;
    end
    else if(Tick) begin
        RxTickCnt <= #1 RxTickCntNext ;
    end
end

always @(posedge PCLK or negedge PRST_N) begin
    if (!PRST_N) begin
        RxTick  <= #1 1'b0 ;
    end
    else if(StartRxStart) begin
        RxTick  <= #1 1'b0 ;
    end
    else begin
        RxTick  <= ((RxTickCnt[2] == 1'b1) && (RxTickCntNext[2] == 1'b0) && Tick) ? 1'b1 : 1'b0;
    end
end

//filter input 
reg          RxdQ1            ;
reg          RxdQ2            ;
reg          RxdFilterQ1      ;
reg          RxdFilterQ2      ;
reg          RxdFilterQ3      ;

always @(posedge PCLK or negedge PRST_N) begin //输入数据采样
    if (!PRST_N) begin
        RxdQ1       <= #1 1'b0 ;
        RxdQ2       <= #1 1'b0 ;
        RxdFilterQ1 <= #1 1'b0 ;
        RxdFilterQ2 <= #1 1'b0 ;
        RxdFilterQ3 <= #1 1'b0 ;
        Rxd         <= #1 1'b0 ;
        RxdQ        <= #1 1'b0 ;
    end
    else begin
        RxdQ1       <= #1 Rxd_i ;
        RxdQ2       <= #1 RxdQ1 ;
        if(Tick) begin
            RxdFilterQ1 <= #1 RxdQ2       ;
            RxdFilterQ2 <= #1 RxdFilterQ1 ;
            RxdFilterQ3 <= #1 RxdFilterQ2 ;
        end
        Rxd         <= #1 (RxdFilterQ3 & RxdFilterQ2) | (RxdFilterQ3 & RxdFilterQ1) | (RxdFilterQ2 & RxdFilterQ1) ;
        RxdQ        <= #1 Rxd  ;
    end
end

always @(posedge PCLK or negedge PRST_N) begin //状态机
    if (!PRST_N) begin
        StateRxIdle    <= #1 1'b1  ;
        StateRxStart   <= #1 1'b0  ;
        StateRxData    <= #1 1'b0  ;
        StateRxParity  <= #1 1'b0  ;
        StateRxStop    <= #1 1'b0  ;
    end
    else begin
        if(StartRxStart)     StateRxIdle <= #1 1'b0  ;
        else if(StartRxIdle) StateRxIdle <= #1 1'b1  ;

        if(StartRxIdle | StartRxData) StateRxStart <= #1 1'b0  ;
        else if(StartRxStart)         StateRxStart <= #1 1'b1  ;

        if(StartRxParity | StartRxStop) StateRxData <= #1 1'b0 ;
        else if(StartRxData)            StateRxData <= #1 1'b1 ;

        if(StartRxStop)        StateRxParity <= #1 1'b0  ;
        else if(StartRxParity) StateRxParity <= #1 1'b1  ;

        if(StartRxIdle)        StateRxStop <= #1 1'b0 ;
        else if(StartRxStop)   StateRxStop <= #1 1'b1 ;
    end
end

integer      i               ;
always @(posedge PCLK or negedge PRST_N) begin
    if (!PRST_N) begin
        RWAddr     <= #1 3'b0 ;
        for(i = 0; i < 8; i = i + 1) begin
            RHold[i] <= #1 'b0;
        end
    end
    else if((StateRxIdle & ~RSEmpty & ~iRFifoFull) | (StateRxStop & RxTick & Rxd & ~RxDataParity & ~RSEmpty & ~iRFifoFull)) begin
        RHold[RWAddr] <= #1 RShift  ;
        RWAddr      <= #1 RWAddr + 1'b1 ;
    end
end

always @(posedge PCLK or negedge PRST_N) begin
    if (!PRST_N) begin
        RCnt <= #1 4'b0 ;
    end
    else if((StateRxIdle & ~RSEmpty & ~iRFifoFull) | (StateRxStop & RxTick & Rxd & ~RxDataParity & ~RSEmpty & ~iRFifoFull)) begin
        RCnt <= #1 RCnt + 1'b1 ;
    end
    else if(PSEL && PENABLE && ~PWRITE && (PADDR[5:0] == RHOLD_ADDR) && (|RCnt)) begin
        RCnt <= #1 RCnt - 1'b1 ;
    end
end

always @(posedge PCLK or negedge PRST_N) begin
    if (!PRST_N) begin
        RRAddr <= #1 'b0 ;
    end
    else if(PSEL && PENABLE && ~PWRITE && (PADDR[5:0] == RHOLD_ADDR) && (|RCnt)) begin
        RRAddr <= #1 RRAddr + 1'b1 ;
    end
end

always @(posedge PCLK or negedge PRST_N) begin
    if (!PRST_N) begin
        RShift       <= #1 8'b0 ;
        RSEmpty      <= #1 1'b1 ;
        RxDataParity <= #1 1'b0;
    end
    else begin
        case({StateRxStop, StateRxParity, StateRxData, StateRxStart, StateRxIdle})
            5'b00001 : begin
                if(~RSEmpty & ~iRFifoFull) begin
                    RSEmpty      <= #1 1'b1 ;
                end
                if(StartRxStart) begin
                    RSEmpty      <= #1 1'b0  ;
                    RShift       <= #1 8'hFF ;
                    RxDataParity <= #1 PS    ;
                end
            end
            5'b00010 : begin
                if(RxTick) begin
                    RShift <= #1 {Rxd, RShift[7:1]} ;
                end
                if(StartRxIdle) begin
                    RSEmpty <= #1 1'b1 ;
                end
            end
            5'b00100 : begin
                if(RxTick) begin
                    RShift <= #1 {Rxd, RShift[7:1]} ;
                    RxDataParity <= #1 RxDataParity ^ Rxd ;
                end
            end
            5'b01000 : begin
                if(RxTick) begin
                    RxDataParity <= #1 RxDataParity ^ Rxd ;
                end
            end
            5'b10000 : begin
                if(RxTick) begin
                    if(Rxd) begin
                        if(~RxDataParity & ~iRFifoFull) begin
                            RSEmpty <= #1 1'b1 ;
                        end
                    end
                    else begin
                        RSEmpty <= #1 1'b1 ;
                        RShift  <= #1 8'b0 ;
                    end
                end
            end
        endcase
    end
end

always @(posedge PCLK or negedge PRST_N) begin//接收数据有效性判断
    if (!PRST_N) begin
        FrmErr       <= #1 1'b0;
        BreakReceive <= #1 1'b0 ;
        OverRun      <= #1 1'b0;
        ParityErr    <= #1 1'b0;
    end
    else if(PSEL && PENABLE && PWRITE && (PADDR[5:0] == STATUS_ADDR)) begin
        {FrmErr, BreakReceive, OverRun, ParityErr} <= #1 PWDATA[3:0] ;
    end
    else begin
        if((StateRxStop & RxTick & ~Rxd) & |RShift) begin
         //接收到非停止位
            FrmErr <= #1 1'b1 ;
        end
        if((StateRxStop & RxTick & ~Rxd) & ~(|RShift)) begin
         //接收到非停止位，同时数据全部为0
            BreakReceive <= #1 1'b1 ;
        end
        if(StateRxIdle & StartToggle & ~RSEmpty) begin
         //移位寄存器没有写到fifo，此时接收到开始标志
            OverRun <= #1 1'b1 ;
        end
        if((StateRxStop & RxTick & Rxd) & (ParityErr | RxDataParity)) begin
         //奇偶校验错误,包含上一次接收数据的奇偶性错误
            ParityErr <= #1 1'b1 ;
        end
    end
end

//transmit
reg    [ 7:0]THold[7:0]      ; //transmit hold fifo
reg    [10:0]TShift          ; //traminist shift register
reg          TSEmpty         ;
reg          TxDataParity    ;
reg    [ 2:0]TWAddr          ; 
reg    [ 2:0]TRAddr          ; 
reg    [ 3:0]TCnt            ;
reg    [ 2:0]TxTickCnt       ; 
reg          TxTick          ;
reg          StateTxIdle     ;
reg          StateTxData     ;
reg          StateTxParity   ;
reg          StateTxStop     ;

wire         StartTxIdle     ;
wire         StartTxData     ;
wire         StartTxParity   ;
wire         StartTxStop     ;
wire   [ 2:0]TxTickCntNext   ;
wire         iTFifoHalfFull  ;
wire         iTFifoFull      ;
wire         iTHEmpty        ;

assign  TxTickCntNext  = TxTickCnt + 1'b1  ;
assign  iTFifoFull     = (TCnt == 8) ? 1'b1 : 1'b0 ;
assign  iTFifoHalfFull = TCnt[3] | TCnt[2] ;
assign  iTHEmpty       = ~(|TCnt)  ;

always @(posedge PCLK or negedge PRST_N) begin
    if (!PRST_N) begin
        TxTickCnt <= #1 'b0 ;
    end
    else if(StartTxData) begin
        TxTickCnt <= #1 {2'b00,Tick} ;
    end
    else if(Tick) begin
        TxTickCnt <= #1 TxTickCntNext ;
    end
end

always @(posedge PCLK or negedge PRST_N) begin
    if (!PRST_N) begin
        TxTick <= #1 1'b0 ;
    end
    else if(StartTxData) begin
        TxTick <= #1 1'b0 ;
    end
    else begin
        TxTick <= #1  ((TxTickCnt[2] == 1'b1) && (TxTickCntNext[2] == 1'b0) && Tick) ? 1'b1 : 1'b0;
    end
end

assign       StartTxIdle   = (StateTxStop & TxTick) ? 1'b1 : 1'b0 ;
assign       StartTxData   = (StateTxIdle & TE & ~iTHEmpty & TxTick) ? 1'b1 : 1'b0 ;
assign       StartTxParity = (StateTxData && TShift[10:1] == 10'b11_1111_1110 && TxTick && PE) ? 1'b1 : 1'b0 ;
assign       StartTxStop   = ((StateTxData && TShift[10:1] == 10'b11_1111_1110 && TxTick && ~PE) | (StateTxParity & TxTick)) ? 1'b1 : 1'b0 ;

always @(posedge PCLK or negedge PRST_N) begin
    if (!PRST_N) begin
        StateTxIdle    <= #1 1'b1 ;
        StateTxData    <= #1 1'b0 ;
        StateTxParity  <= #1 1'b0 ;
        StateTxStop    <= #1 1'b0 ;
    end
    else begin
        if(StartTxData)       StateTxIdle <= #1 1'b0 ;
        else if(StartTxIdle)  StateTxIdle <= #1 1'b1 ;

        if(StartTxParity | StartTxStop) StateTxData <= #1 1'b0 ;
        else if(StartTxData)            StateTxData <= #1 1'b1 ;
        
        if(StartTxStop)       StateTxParity <= #1 1'b0 ;
        else if(StartTxParity)StateTxParity <= #1 1'b1 ;

        if(StartTxIdle)       StateTxStop   <= #1 1'b0 ;
        else if(StartTxStop)  StateTxStop   <= #1 1'b1 ;
    end
end

always @(posedge PCLK or negedge PRST_N) begin
    if (!PRST_N) begin
        TWAddr     <= #1 3'b0 ;
        for(i = 0; i < 8; i = i + 1)  begin
            THold[i] <= #1 8'b0 ;
        end
    end
    else if(PSEL && PENABLE && PWRITE && (PADDR[5:0] == THOLD_ADDR) && ~iTFifoFull) begin
        THold[TWAddr] <= #1 PWDATA[7:0] ;
        TWAddr        <= #1 TWAddr + 1'b1 ;
    end
end

always @(posedge PCLK or negedge PRST_N) begin
    if (!PRST_N) begin
        TRAddr <= #1 3'b0 ;
    end
    else if(StartTxData) begin
        TRAddr <= #1 TRAddr + 1'b1 ;
    end
end

always @(posedge PCLK or negedge PRST_N) begin
    if (!PRST_N) begin
        TCnt <= #1 4'b0 ;
    end
    else if(PSEL && PENABLE && PWRITE && (PADDR[5:0] == THOLD_ADDR) && ~iTFifoFull) begin
        TCnt <= #1 TCnt + 1'b1 ;
    end
    else if(StartTxData) begin
        TCnt <= #1 TCnt - 1'b1 ;
    end
end

always @(posedge PCLK or negedge PRST_N) begin
    if (!PRST_N) begin
        TShift       <= #1 11'b111_1111_1111 ;
        TSEmpty      <= #1 1'b1 ;
        TxDataParity <= #1 1'b0 ;
    end
    else begin
        case({StateTxStop, StateTxParity, StateTxData, StateTxIdle})
            4'b0001 : begin
                TSEmpty      <= #1 1'b1 ;
                if(StartTxData) begin
                    TSEmpty      <= #1 1'b0 ;
                    TxDataParity <= #1 PS ;
                    TShift       <= #1 {2'b10,THold[TRAddr],1'b0} ;
                end
            end
            4'b0010 : begin
                if(TxTick) begin
                    TShift       <= #1 {1'b1, TShift[10:1]} ;
                    TxDataParity <= #1 TxDataParity ^ TShift[1];
                end
                if(StartTxParity) begin
                    TShift[0]    <= #1 TxDataParity ;
                end
                else if(StartTxStop) begin
                    TShift[0]    <= #1 1'b1         ;
                end
            end
            4'b0100 : begin
                if(TxTick) begin
                    TShift       <= #1 {1'b1, TShift[10:1]} ;
                end
            end
            4'b1000 : begin
                if(TxTick) begin
                    TShift       <= #1 {1'b1, TShift[10:1]} ;
                end
            end
        endcase
    end
end

reg          Txd             ;
always @(posedge PCLK or negedge PRST_N) begin
    if (!PRST_N) begin
        Txd  <= #1 1'b0 ;
    end
    else begin
        Txd <= #1 TShift[0] ;
    end
end


reg    [31:0]iPRDATA         ;
always @(*) begin
    iPRDATA = 32'b0 ;
    if(PSEL && PENABLE && ~PWRITE) begin
        case(PADDR[5:0])
            CTRL_ADDR   : begin 
                iPRDATA = {27'b0,RE,TE,PE,PS,ECE}  ;
            end
            STATUS_ADDR : begin 
                iPRDATA =  {28'b0, FrmErr, BreakReceive, OverRun, ParityErr}  ;
            end
            SCALER_ADDR : begin 
                iPRDATA = SCALER  ;
            end
            RHOLD_ADDR  : begin 
                iPRDATA = {24'b0, RHold[RRAddr]} ;
            end
            default     : begin
                iPRDATA = 32'b0 ;
            end
        endcase
    end
    else begin
        iPRDATA = 32'b0 ;
    end
end

always @(posedge PCLK or negedge PRST_N) begin
    if (!PRST_N) begin
        iIRQ <= #1 1'b0 ;
    end
    else begin
        iIRQ <= #1 iRFifoFull | iTFifoFull | (StateRxStop & RxTick) ;
    end
end

assign       PRDATA = iPRDATA ;
assign       Txd_o  = Txd     ;
assign       IRQ    = iIRQ    ;

endmodule
