//================================================================================
// Created by         : Ltd.com
// Filename           : ahb_spim.v
// Author             : Python_Wang
// Created On         : 2009-04-22 20:18
// Last Modified      : 2009-06-14 19:46
// Description        : 
//                      
//                      
//================================================================================

module AHB_SPIM(
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
//spimem
input         MISO           ,
output        MOSI           ,
output        SCK            ,
output        CSN            ,
//control signal
output        Initialized    ,
output        Done           
);


parameter     CTRL_ADDR = 6'b001100 ;
parameter     tPOWERUP  = 32'h1_86A0 ; //4ms

reg    [15:0] SCALER         ;
reg    [ 7:0] RDCMD          ;
reg           FastRead       ;
reg           FlashRst       ;

reg    [23:0] Addr           ;
reg    [ 2:0] DataSize       ;

reg           iMOSI          ;
reg           iSCK           ;
reg           iCSN           ; 
// 
reg           iInitialized   ;
reg           iDone          ;
reg           iHREADY        ;
reg    [31:0] iHRDATA        ;
//fsm
reg           StateIdle      ;
reg           StateReady     ;
reg           StateSendCmd   ;
reg           StateSendAddr  ;
reg           StateSendDummy ;
reg           StateRespond   ;

// inter reg
reg    [15:0] ScalerCnt      ;
reg    [31:0] InitCnt        ;
reg           iSCKQ          ;
reg    [ 2:0] BitCnt         ;
reg    [31:0] ShiftReg       ;
reg    [ 2:0] AddrCnt        ;
reg    [ 2:0] DataCnt        ;
reg    [31:0] ReceiveReg     ;
reg           DataDoneQ      ;

wire  CtrlBank      = HADDR[27]  ;

wire  Sample        = iSCK & ~iSCKQ ;
wire  Change        = iSCKQ & ~iSCK ;

wire  ByteDone      = Sample & (&BitCnt) ;
wire  AddrDone      = StateSendAddr && (AddrCnt == 1 ) && ByteDone ;
wire  DummyDone     = StateSendDummy & ByteDone                    ;
wire  DataDone      = StateRespond  && (DataCnt == 1 ) && ByteDone ;

wire  ValidRead     = HSEL & HREADY & ~HWRITE & HTRANS[1] & ~CtrlBank ;

wire  StartIdle     = ~iInitialized    ;
wire  StartReady    = StateIdle & iInitialized || StateRespond & iHREADY & ~ValidRead;
wire  StartSendCmd  = StateReady & ValidRead   ;
wire  StartSendAddr = StateSendCmd & ByteDone  ;
wire  StartSendDummy= StateSendAddr & AddrDone & FastRead ;
wire  StartRespond  = StateSendAddr & AddrDone & ~FastRead || StateSendDummy & ByteDone ;

always @(posedge HCLK or negedge HRST_N) begin
    if (!HRST_N) begin
        StateIdle     <= #1 1'b1 ;
        StateReady    <= #1 1'b0 ;
        StateSendCmd  <= #1 1'b0 ;
        StateSendAddr <= #1 1'b0 ;
        StateSendDummy<= #1 1'b0 ;
        StateRespond  <= #1 1'b0 ;
    end
    else begin
        if(StartReady)         StateIdle <= #1 1'b0 ;
        else if(StartIdle)     StateIdle <= #1 1'b1 ;

        if(StartSendCmd)       StateReady <= #1 1'b0 ;
        else if(StartReady)    StateReady <= #1 1'b1 ;

        if(StartSendAddr)      StateSendCmd <= #1 1'b0 ; 
        else if(StartSendCmd)  StateSendCmd <= #1 1'b1 ;

        if(StartSendDummy | StartRespond)  StateSendAddr <= #1 1'b0 ;
        else if(StartSendAddr)         StateSendAddr <= #1 1'b1 ;

        if(StartRespond)        StateSendDummy <= #1 1'b0 ;
        else if(StartSendDummy) StateSendDummy <= #1 1'b1 ;

        if(StartReady)          StateRespond <= #1 1'b0 ;
        else if(StartRespond)   StateRespond <= #1 1'b1 ;
    end
end

always @(posedge HCLK or negedge HRST_N) begin
    if (!HRST_N) begin
        {FlashRst, FastRead, RDCMD, SCALER} <= #1 26'b0 ;
    end
    else if(HSEL && HREADY && HTRANS[1] && HWRITE && CtrlBank && (HADDR[5:0] == CTRL_ADDR)) begin
        {FlashRst, FastRead, RDCMD, SCALER} <= #1 HWDATA[25:0] ;
    end
end

always @(posedge HCLK or negedge HRST_N) begin
    if (!HRST_N) begin
        DataDoneQ <= #1 1'b0 ;
    end
    else begin
        DataDoneQ <= #1 DataDone ;
    end
end

//写地址
always @(posedge HCLK or negedge HRST_N) begin
    if (!HRST_N) begin
        Addr     <= #1 23'b0  ;
        DataSize <= #1 3'b0 ;
    end
    else if(ValidRead) begin
        Addr     <= #1 HADDR[23:0] ;
        DataSize <= #1 HSIZE ;
    end
end

always @(posedge HCLK or negedge HRST_N) begin
    if (!HRST_N) begin
        iInitialized <= #1 'b0     ;
        InitCnt      <= #1 tPOWERUP ;
    end
    else begin
        if(InitCnt == 0) iInitialized <= #1 1'b1 ;
        else             InitCnt      <= #1 InitCnt - 1'b1 ;
    end
end

always @(posedge HCLK or negedge HRST_N) begin
    if (!HRST_N) begin
        ScalerCnt <= #1 SCALER ;
        iSCK      <= #1 1'b1  ;
    end
    else if(~iCSN) begin
        if(ScalerCnt == 0) begin
            ScalerCnt <= #1 SCALER ;
            iSCK      <= #1 ~iSCK  ;
        end
        else begin
            ScalerCnt <= #1 ScalerCnt - 1'b1;
        end
    end
    else begin
        ScalerCnt <= #1 SCALER ;
        iSCK      <= #1 1'b1  ;
    end
end

always @(posedge HCLK or negedge HRST_N) begin
    if (!HRST_N) begin
        iSCKQ  <= #1 1'b0 ;
    end
    else begin
        iSCKQ  <= #1 iSCK ;
    end
end

always @(posedge HCLK or negedge HRST_N) begin
    if (!HRST_N) begin
        BitCnt <= #1 'b0 ;
    end
    else if(StartReady) begin
        BitCnt <= #1 'b0 ;
    end 
    else if(~iCSN & Sample) begin
        BitCnt <= #1 BitCnt + 1'b1 ;
    end
end

always @(posedge HCLK or negedge HRST_N) begin
    if (!HRST_N) begin
        iCSN       <= #1 1'b1  ;
        DataCnt    <= #1 0     ;
        AddrCnt    <= #1 0     ;
        ShiftReg   <= #1 32'hff_ff_ff_ff ;
        ReceiveReg <= #1 'b0   ;
        iDone      <= #1 1'b0  ;
    end
    else begin
        case({StateRespond, StateSendDummy, StateSendAddr, StateSendCmd, StateReady, StateIdle}) 
            6'b000010 : begin//ready
        if(StartSendCmd) iCSN <= #1 1'b0 ;
        else if(Change)  iCSN <= #1 1'b1 ;
        if(StartSendCmd)   ShiftReg <= #1 {RDCMD, 24'hFFFFFF} ; 
        if(StartSendCmd) iDone <= #1 1'b0 ;
        else if(Change)  iDone <= #1 1'b1 ;
            end
            6'b000100 : begin//send cmd
        if(StartSendAddr)  ShiftReg <= #1 {Addr, 8'hFF} ;
        else if(Change)    ShiftReg <= #1 {ShiftReg[30:0], 1'b1} ;
        if(StartSendAddr)  AddrCnt  <= #1 3 ;
            end
            6'b001000 : begin//send addr
        if(StartRespond) begin
            ReceiveReg <= #1 'd0 ;
            case(DataSize)
                3'd0    : DataCnt <= #1 1 ;
                3'd1    : DataCnt <= #1 2 ;
                3'd2    : DataCnt <= #1 4 ;
                default : DataCnt <= #1 0 ;
            endcase
        end
        if(StartSendDummy)    ShiftReg <= #1 32'hFF_FF_FF_FF        ;
        else if(Change)       ShiftReg <= #1 {ShiftReg[30:0], 1'b1} ;
        if(ByteDone)          AddrCnt  <= #1 AddrCnt - 1'b1 ;
            end
            6'b010000 : begin//send dummy
        if(Change)       ShiftReg <= #1 {ShiftReg[30:0], 1'b1} ;
            end
            6'b100000 : begin//respond
        if(DataDone) begin
            case(DataSize)
                3'd0    : DataCnt <= #1 1 ;
                3'd1    : DataCnt <= #1 2 ;
                3'd2    : DataCnt <= #1 4 ;
                default : DataCnt <= #1 0 ;
            endcase
        end
        else if(ByteDone)     DataCnt  <= #1 DataCnt - 1'b1 ;

        if(iHREADY) ReceiveReg <= #1 32'b0 ;
        else if(Sample)  ReceiveReg <= #1 {ReceiveReg[30:0],MISO} ; 
            end
            default  : begin
                iCSN     <= #1 1'b1  ;
                DataCnt  <= #1 0     ;
                AddrCnt  <= #1 0     ;
                ShiftReg <= #1 32'hff_ff_ff_ff ;
            end
        endcase
    end
end

always @(posedge HCLK or negedge HRST_N) begin
    if (!HRST_N) begin
        iMOSI <= #1 1'b1 ;
    end
    else if(Change) begin
        iMOSI <= #1  ShiftReg[31] ;
    end
end

always @(*) begin
    iHREADY = StateIdle | StateReady & iCSN | StateRespond & DataDoneQ;
end

always @(*) begin
    iHRDATA = StateRespond & DataDoneQ ? ReceiveReg : 32'b0  ;
end


assign   HREADY_O  =   iHREADY      ;
assign   HRESP     =   `HRESP_OKAY  ;
assign   HSPLIT    =   16'd0        ;
assign   HRDATA    =   iHRDATA      ;
assign   MOSI      =   iMOSI        ;
assign   SCK       =   iSCK         ;
assign   CSN       =   iCSN         ;
assign   Initialized = iInitialized ;
//assign   Done        = ~StateIdle & iCSN         ;
assign   Done        = iDone        ;

endmodule
