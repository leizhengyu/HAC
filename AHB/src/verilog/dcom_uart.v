//================================================================================
// Created by         : Ltd.com
// Filename           : dcom_uart.v
// Author             : Python_Wang
// Created On         : 2009-05-22 13:23
// Last Modified      : 2009-06-11 17:32
// Description        : 
//                      
//                      
//================================================================================
module DCOM_UART(
//apb
input         PCLK            , //clock
input         PRST_N          , //reset
input         PSEL            , 
input         PENABLE         ,
input         PWRITE          ,
input  [31:0] PADDR           ,
input  [31:0] PWDATA          ,
output [31:0] PRDATA          ,
//com
input         Read            ,
input         Write           ,
input  [ 7:0] DataIn          ,
output        DataReady       ,
output [ 7:0] DataOut         ,
output        THEmpty         ,
//uart
input         Rxd             ,
output        Txd             
);

parameter     STATUS_ADDR =  6'b100000 ;
parameter     CTRL_ADDR   =  6'b110000 ;

reg    [15:0] SCALER          ;
reg    [ 1:0] MODE            ;
reg           RE              ;
reg           ComBreak        ;
reg           FrameError      ;
reg           OverReceive     ;

reg    [ 1:0] AutoStep        ; //自适应步骤，2'b11已经自适应，即获得波特率
reg    [15:0] Scaler          ;
reg    [15:0] Brate           ;
reg    [ 7:0] RxdQ            ;
reg           iRxd            ;
reg           iRxdQ           ;
reg           RxdFallEdge     ;
reg           ReceiveEn       ;


wire   [15:0] NextScaler  = (&AutoStep) ? Scaler - 1'b1 : Scaler + 1'b1 ;

wire          RxdEn = RE & AutoStep[0] & AutoStep[1] ;

always @(posedge PCLK or negedge PRST_N) begin
    if (!PRST_N) begin
        RxdQ <= #1 8'b0 ;
    end
    else begin
        RxdQ <= #1 {RxdQ[6:0], Rxd} ;
    end
end

always @(posedge PCLK or negedge PRST_N)
begin
    if (!PRST_N) begin
        iRxd  <= #1 1'b0 ;
        iRxdQ <= #1 1'b0 ;
    end
    else begin
        iRxdQ <= #1 iRxd ;
        if(RxdQ[6:0] == {7{RxdQ[7]}}) begin
            iRxd <= #1 RxdQ[7] ;
        end
    end
end

always @(posedge PCLK or negedge PRST_N) begin
    if (!PRST_N) begin
        AutoStep    <= #1 2'b00     ;
        RxdFallEdge <= #1 1'b0      ;
        Scaler      <= #1 16'hFFFE  ;
        Brate       <= #1 16'hFFFF  ;
        ReceiveEn   <= #1 1'b0      ;
    end
    else begin
        if(&AutoStep) begin
            //自适应完成，获得波特率
            if(ReceiveEn) begin
            Scaler <= #1 NextScaler    ;
            if(~Scaler[15] & NextScaler[15]) begin
                Scaler <= #1 Brate       ;
            end
            end
            if(ComBreak & iRxdQ) begin
            Scaler    <= #1 16'hFFFE   ;
                Brate     <= #1 16'hFFFF   ;
            AutoStep  <= #1 2'b00      ;
            ReceiveEn <= #1 1'b0       ; 
            end
        end
        else begin
            //自适应
            if(~iRxd & iRxdQ) begin
            RxdFallEdge <= #1 1'b1 ;
            end
            if(RxdFallEdge) begin
            Scaler <= #1 NextScaler ;
            if(~Scaler[14] & NextScaler[15]) begin
                Scaler      <= #1 16'hFFFE ;
                RxdFallEdge <= #1 1'b0 ;
            end
            end
            if(~iRxd & iRxdQ & RxdFallEdge) begin
            Scaler <= #1 16'hFFFE ;
            if(Brate[15:1] > Scaler[15:1]) begin
                //因为Rxd的1bit占2个周期，所以/2
                Brate    <= #1 Scaler ;
                AutoStep <= #1 2'b00 ;
            end
            if(Brate[15:1] == Scaler[15:1]) begin
                AutoStep <= #1 AutoStep + 1'b1 ;
                if(AutoStep == 2'b10) begin
                    Brate     <= #1 {4'b0, Scaler[15:4]} ;//本地要产生8倍频的波特率，所以/8
                    Scaler    <= #1 {4'b0, Scaler[15:4]} ;
                    ReceiveEn <= #1 1'b1              ;
                end
            end
            end
        end
    end
end

reg          Tick            ;
reg          RxTick          ;
reg          TxTick          ;
reg    [ 2:0]RxTickCnt       ;
reg    [ 2:0]TxTickCnt       ;
reg    [ 2:0]RxBitCnt        ;
reg    [ 2:0]TxBitCnt        ;
//rx
reg    [ 7:0]RHold           ;
reg          DReady          ; 
reg    [ 7:0]RShift          ;
reg          RSEmpty         ;

reg          StateRxIdle     ;
reg          StateRxStart    ;
reg          StateRxData     ;
reg          StateRxStop     ;

wire         StartRxIdle     ;
wire         StartRxStart    ;
wire         StartRxData     ;
wire         StartRxStop     ;

assign       StartRxIdle  = StateRxStart & RxTick & iRxd | StateRxStop & RxTick ;
assign       StartRxStart = StateRxIdle & (~iRxd & iRxdQ) & RxdEn ;
assign       StartRxData  = StateRxStart & RxTick & ~iRxd      ;
assign       StartRxStop  = StateRxData && (RxBitCnt == 3'h7) && RxTick ;
//tx
reg    [ 7:0]THold           ;
reg          iTHEmpty        ; 
reg    [10:0]TShift          ;
reg          TSEmpty         ;

reg          StateTxIdle     ;
reg          StateTxData     ;
reg          StateTxStop     ;

wire         StartTxIdle     ;
wire         StartTxData     ;
wire         StartTxStop     ;

assign       StartTxIdle  = StateTxStop & TxTick ;
assign       StartTxData  = StateTxIdle & TxTick & ~iTHEmpty ;
assign       StartTxStop  = StateTxData & (TShift[10:1] == 10'b11_1111_1110) ;

always @(posedge PCLK or negedge PRST_N) begin
    if (!PRST_N) begin
        Tick <= #1 'b0 ;
    end
    else begin
        Tick <= #1 ~Scaler[15] & NextScaler[15] ;
    end
end

always @(posedge PCLK or negedge PRST_N) begin
    if (!PRST_N) begin
        RxTickCnt <= #1 3'b0 ;
    end
    else if(StartRxStart) begin
        RxTickCnt <= #1 3'b011  ;
    end
    else if(Tick) begin
        RxTickCnt <= #1 RxTickCnt + 1'b1 ;
    end
end

always @(posedge PCLK or negedge PRST_N) begin
    if (!PRST_N) begin
        TxTickCnt <= #1 3'b0 ;
    end
    else if(StartTxData) begin
        TxTickCnt <= #1 3'b011 ;
    end
    else if(Tick) begin
        TxTickCnt <= #1 TxTickCnt + 1'b1 ;
    end
end

always @(posedge PCLK or negedge PRST_N) begin
    if (!PRST_N) 
        RxTick <= #1 1'b0 ;
    else if(StartRxStart ) 
        RxTick <= #1 1'b0 ;
    else if(Tick && RxTickCnt == 3'b111) 
        RxTick <= #1 1'b1 ;
    else 
        RxTick <= #1 1'b0 ;
end

always @(posedge PCLK or negedge PRST_N) begin
    if (!PRST_N) 
        TxTick <= #1 1'b0 ;
    else if(StartTxData) 
        TxTick <= #1 1'b0 ;
    else if(Tick && TxTickCnt == 3'b111)
        TxTick <= #1 1'b1 ;
    else 
        TxTick <= #1 1'b0 ;
end

always @(posedge PCLK or negedge PRST_N) begin
    if (!PRST_N) begin
        StateRxIdle   <= #1 1'b1  ;
        StateRxStart  <= #1 1'b0  ;
        StateRxData   <= #1 1'b0  ;
        StateRxStop   <= #1 1'b0  ;
    end
    else begin
        if(StartRxStart)               StateRxIdle  <= #1 1'b0 ;
        else if(StartRxIdle)           StateRxIdle  <= #1 1'b1 ;

        if(StartRxData | StartRxIdle)  StateRxStart <= #1 1'b0 ;
        else if(StartRxStart)          StateRxStart <= #1 1'b1 ;

        if(StartRxStop)                StateRxData  <= #1 1'b0 ;
        else if(StartRxStart)          StateRxData  <= #1 1'b1 ;

        if(StartRxIdle)                StateRxStop  <= #1 1'b0 ;
        else if(StartRxStop)           StateRxStop  <= #1 1'b1 ;
    end
end

always @(posedge PCLK or negedge PRST_N) begin
    if (!PRST_N) begin
        RShift   <= #1 8'b0 ;
        RxBitCnt <= #1 3'b0 ;
        DReady   <= #1 1'b0 ;
        RHold    <= #1 8'b0 ;
    end
    else begin
        case({StateRxStop, StateRxData, StateRxStart, StateRxIdle}) 
            4'b0001 : begin
            if(~RSEmpty & ~DReady) begin
                RSEmpty <= #1 1'b1   ;
                DReady  <= #1 1'b1   ;
                RHold   <= #1 RShift ;
            end
            if(StartRxStart) begin
                RxBitCnt <= #1 3'b0 ;
                RShift   <= #1 8'b0 ;
                RSEmpty  <= #1 1'b0 ;
            end
            end
            4'b0100 : begin
            if(RxTick) begin
                RxBitCnt <= #1 RxBitCnt + 1'b1 ;
                //RShift   <= #1 {RShift[6:0], iRxd} ;
                RShift   <= #1 {iRxd, RShift[7:1]} ;
            end
            end
            4'b1000 : begin
            if(RxTick) begin
                if(iRxd) begin
                    if(~DReady) begin
                         RHold   <= #1 RShift ;
                        DReady  <= #1 1'b1   ;
                        RSEmpty <= #1 1'b1   ;
                    end
                end
                else begin
                    RSEmpty <= #1 1'b1     ;
                end
            end
            end
        endcase

        if(Read) begin
            DReady <= #1 1'b0 ;
        end
    end
end

always @(posedge PCLK or negedge PRST_N) begin
    if (!PRST_N) begin
        StateTxIdle  <= #1 1'b1   ;
        StateTxData  <= #1 1'b0   ;
        StateTxStop  <= #1 1'b0   ;
    end
    else begin
        if(StartTxData)      StateTxIdle <= #1 1'b0 ;
        else if(StartTxIdle) StateTxIdle <= #1 1'b1 ;

        if(StartTxStop)      StateTxData <= #1 1'b0 ;
        else if(StartTxData) StateTxData <= #1 1'b1 ;

        if(StartTxIdle)      StateTxStop <= #1 1'b0 ;
        else if(StartTxStop) StateTxStop <= #1 1'b1 ; 
    end
end

always @(posedge PCLK or negedge PRST_N) begin
    if (!PRST_N) begin
        THold    <= #1 8'b0  ;
        iTHEmpty <= #1 1'b1  ;
        TShift   <= #1 11'h7FF ;
        TSEmpty  <= #1 1'b1  ;
    end
    else begin
        if(Write) begin
            THold    <= #1 DataIn ;
            iTHEmpty <= #1 1'b0 ;
        end
        case({StateTxStop, StateTxData, StateTxIdle})
            3'b001  : begin
                if(StartTxData) begin
                    iTHEmpty <= #1 1'b1 ;
                    TShift  <= #1 {2'b10, THold, 1'b0} ;
                    TSEmpty <= #1 1'b0 ;
                end
            end
            3'b010  : begin
                if(TxTick) begin
                    TShift <= #1 {1'b1, TShift[10:1]} ;
                end
                if(StartTxStop) begin
                    TShift[0] <= #1 1'b1 ;
                end
            end
            3'b100  : begin
                if(TxTick) begin
                    TSEmpty <= #1 1'b1 ;
                    //TShift <= #1 {1'b1, TShift[10:1]} ;
                end
            end
        endcase
    end
end

always @(posedge PCLK or negedge PRST_N) begin
    if (!PRST_N) begin
        SCALER       <= #1 15'b0   ;
        MODE         <= #1  2'b0   ;
        RE           <= #1  1'b0   ;
        ComBreak     <= #1  1'b0   ;
        FrameError   <= #1  1'b0   ;
        OverReceive  <= #1  1'b0   ;
    end
    else begin
        if(StateRxStop & RxTick) begin
            if(~Rxd) begin
                if(RShift == 0)  ComBreak   <= #1 1'b1 ;
                else             FrameError <= #1 1'b1 ;
            end
        end

        if(PSEL & PENABLE & PWRITE) begin
            case(PADDR[5:0]) 
                STATUS_ADDR : {OverReceive, ComBreak, FrameError} <= #1 PWDATA[2:0] ;
                CTRL_ADDR   : {SCALER, MODE, RE} <= #1 PWDATA[18:0] ;
            endcase
        end
    end
end

assign THEmpty   = iTHEmpty ;
assign DataOut   = RHold    ;
assign DataReady = DReady   ;
assign Txd       = TShift[0] ;

endmodule
