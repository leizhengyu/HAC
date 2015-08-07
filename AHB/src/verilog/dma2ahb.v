//================================================================================
// Created by         : Ltd.com
// Filename           : dma2ahb.v
// Author             : Python_Wang
// Created On         : 2009-06-03 09:29
// Last Modified      : 2009-06-15 22:38
// Description        : 
//                      
//                      
//================================================================================
module DMA2AHB(
input         HCLK            , //clock
input         HRST_N          , //reset
//ahb
input         HGRANT          ,
input         HREADY          ,
input  [ 1:0] HRESP           ,
input  [31:0] HRDATA          ,
output        HBUSREQ         ,
output        HLOCK           ,
output [31:0] HADDR           ,
output [ 1:0] HTRANS          ,
output [ 2:0] HBURST          ,
output [ 2:0] HSIZE           ,
output        HWRITE          ,
output [ 3:0] HPROT           ,
output [31:0] HWDATA          ,
//master
input         Request         ,
input         Lock            ,
input         Burst           ,
input         Busy            ,
input         Write           ,
input  [ 2:0] Beat            ,
input  [ 2:0] Size            ,
input  [31:0] Addr            ,
input  [31:0] DataIn          ,
output [31:0] DataOut         ,
output        DataReady       ,
output        Grant           ,
output        Okay            ,
output        Error           ,
output        Retry            
);

reg           AddrPhase       ;
reg           DataPhase       ;
reg           RetryPhase      ;
reg           TerminalPhase   ;
reg           BusyPhase       ;
reg           BoundaryPhase   ;
reg    [ 1:0] iHTRANS         ;
reg    [ 2:0] iHBURST         ;
reg    [ 2:0] iHSIZE          ;
reg           iHWRITE         ;
reg    [31:0] iDataOut        ;
reg           iDataReady      ;
reg           WriteAccess     ;
reg           SingleAccess    ;
reg    [31:0] Address         ;
reg    [31:0] AddressSave     ;
reg           Hgrant          ;
reg    [ 2:0] SizeQ           ;

always @(posedge HCLK or negedge HRST_N) begin
    if (!HRST_N) begin
        Hgrant <= #1 1'b0 ;
    end
    else if(HREADY) begin
        Hgrant <= #1 HGRANT ;
    end
end

always @(posedge HCLK or negedge HRST_N) begin
    if (!HRST_N) begin
        WriteAccess  <= #1 1'b0 ;
        SingleAccess <= #1 1'b0 ;
    end
    else if(HREADY & HGRANT & Request & ~AddrPhase) begin
        WriteAccess  <= #1 Write ;
        SingleAccess <= #1 Burst ;
    end
end

always @(posedge HCLK or negedge HRST_N) begin
    if (!HRST_N) begin
        RetryPhase <= #1 1'b0 ;
    end
    else if(HREADY & RetryPhase & HGRANT) begin
        RetryPhase <= #1 1'b0 ;
    end
    else begin
        RetryPhase <= #1 DataPhase && (HRESP == `HRESP_SPLIT || HRESP == `HRESP_RETRY) ;
    end
end

always @(posedge HCLK or negedge HRST_N) begin
    if (!HRST_N) begin
        TerminalPhase <= #1 1'b0 ;
    end
    else if(HREADY & HGRANT & (TerminalPhase | RetryPhase)) begin
        TerminalPhase <= #1 1'b0 ;
    end
    else begin
        //TerminalPhase <= #1 (AddrPhase || DataPhase) && Request && ~Hgrant ;
        TerminalPhase <= #1 AddrPhase && Request && ~HGRANT && HREADY ;
    end
end

always @(posedge HCLK or negedge HRST_N) begin
    if (!HRST_N) begin
        BusyPhase <= #1 1'b0 ;
    end
    else if(HREADY & HGRANT & Request) begin
        BusyPhase <= #1 Busy  ;
    end
    else if(~Request | ~HGRANT) begin
        BusyPhase <= #1 1'b0 ;
    end
end

always @(posedge HCLK or negedge HRST_N) begin
    if (!HRST_N) begin
        AddrPhase <= #1 1'b0 ;
    end
    else if(HREADY) begin
        if(HGRANT) begin
            if(Request & Busy) AddrPhase <= #1 1'b0 ;
            AddrPhase <= #1 Request | RetryPhase | TerminalPhase ;
        end
        else begin
            AddrPhase <= #1 1'b0 ;
        end
    end
    else if(HRESP == `HRESP_ERROR || HRESP == `HRESP_RETRY || HRESP == `HRESP_SPLIT)  begin
            AddrPhase <= #1 1'b0 ;
    end
end

always @(posedge HCLK or negedge HRST_N) begin
    if (!HRST_N) begin
        DataPhase <= #1 1'b0 ;
    end
    else if(HREADY & AddrPhase) begin
        DataPhase <= #1 1'b1 ;
    end
    else if(HREADY & DataPhase) begin
        DataPhase <= #1 1'b0 ;
    end
    else if(HRESP == `HRESP_ERROR || HRESP == `HRESP_RETRY || HRESP == `HRESP_SPLIT)  begin
        DataPhase <= #1 1'b0 ;
    end
end

always @(posedge HCLK or negedge HRST_N) begin
    if (!HRST_N) begin
        iHSIZE        <= #1 3'b0 ;
        iHWRITE       <= #1 1'b0 ;
        iHTRANS       <= #1 2'b0 ;
        iHBURST       <= #1 3'b0 ;
    end
    else begin
        if(HREADY & HGRANT & Request) begin
            if(AddrPhase) begin
                if(Burst)  iHTRANS <= #1 `HTRANS_SEQ    ;
                else       iHTRANS <= #1 `HTRANS_IDLE   ;
                if(BoundaryPhase) iHTRANS <= #1 `HTRANS_NONSEQ ;
                if(Busy)     iHTRANS <= #1 `HTRANS_BUSY   ;
            end
            else if(~BusyPhase) begin
                iHSIZE  <= #1 Size   ;
                iHWRITE <= #1 Write  ;
                iHTRANS <= #1 `HTRANS_NONSEQ ;
                if(Burst) begin
                    case(Beat)
                        3'b000   : iHBURST <= #1 `HBURST_INCR   ;
                        3'b001   : iHBURST <= #1 `HBURST_INCR4  ;
                        3'b010   : iHBURST <= #1 `HBURST_INCR8  ;
                        3'b011   : iHBURST <= #1 `HBURST_INCR16 ;
                        default  : iHBURST <= #1 `HBURST_INCR   ;
                    endcase
                end
                else begin
                    iHBURST <= #1 `HBURST_SINGLE  ;
                end
            end
        end
        else if((HREADY & (~HGRANT | ~Request))
                        || (~HREADY && (HRESP == `HRESP_ERROR || HRESP == `HRESP_SPLIT || HRESP == `HRESP_RETRY))) begin
            iHWRITE <= #1 1'b0 ;
            iHTRANS <= #1 `HTRANS_IDLE  ;
            iHBURST <= #1 `HBURST_SINGLE;
        end

        if(HREADY & (TerminalPhase | RetryPhase)) begin
            iHWRITE <= #1 WriteAccess    ;
            iHTRANS <= #1 `HTRANS_NONSEQ ;
            iHBURST <= #1 (TerminalPhase | SingleAccess) ? `HBURST_INCR : `HBURST_SINGLE;
        end
    end
end

always @(posedge HCLK or negedge HRST_N) begin
    if (!HRST_N) begin
        SizeQ <= #1 3'b0 ;
    end
    else if(HREADY & HGRANT) begin
        case(Size) 
            3'b000  : SizeQ <= #1 3'd1 ;
            3'b001  : SizeQ <= #1 3'd2 ;
            3'b010  : SizeQ <= #1 3'd4 ;
            default : SizeQ <= #1 3'd4 ;
        endcase
    end
end

always @(posedge HCLK or negedge HRST_N) begin
    if (!HRST_N) begin
        BoundaryPhase <= #1 1'b0 ;
    end
    else if(HREADY && AddrPhase && (Address[9:2] == 8'hFF)) begin
        BoundaryPhase <= #1 1'b1 ;
    end
    else if(HREADY & AddrPhase & BoundaryPhase) begin
        BoundaryPhase <= #1 1'b0 ;
    end
end

always @(posedge HCLK or negedge HRST_N) begin
    if (!HRST_N) begin
        Address       <= #1 32'b0 ;
        AddressSave   <= #1 32'b0 ;
    end
    else begin
        if(HREADY) begin
            if(AddrPhase)  begin
                AddressSave <= #1 Address ;
                Address[9:0] <= #1 Address[9:0] + SizeQ  ; 
            end
            else begin
                Address <= #1 Addr        ;
            end
        end

        if(HREADY & RetryPhase) Address <= #1 AddressSave ;
    end
end

always @(posedge HCLK or negedge HRST_N) begin
    if (!HRST_N) begin
        iDataReady  <= #1  1'b0 ;
        iDataOut    <= #1 32'b0 ;
    end
    //else if(HREADY & DataPhase) begin
    else if(HREADY & AddrPhase & DataPhase & ~iHWRITE) begin
        //因为用时序逻辑输出地址段，数据段，所以在数据段会多读一个数据，利用同时地
        //址段，数据段内接收到的数据有效
        iDataReady  <= #1  1'b1  ;
        iDataOut    <= #1 HRDATA ;
    end
    else begin
        iDataReady  <= #1  1'b0  ;
    end
end

assign HBUSREQ     = Request | RetryPhase | TerminalPhase  ;
assign HLOCK       = Request & Lock  ;
assign HADDR       = Address    ;
//assign HTRANS      = iHTRANS    ;
//assign HBURST      = iHBURST    ;
assign HTRANS      = Request ? iHTRANS  : `HTRANS_IDLE   ;
assign HBURST      = Request ? iHBURST  : `HBURST_SINGLE ;
assign HSIZE       = iHSIZE     ;
assign HWRITE      = iHWRITE    ;
assign HPROT       = 3'b000     ;
assign HWDATA      = DataIn     ;

assign DataOut     = iDataOut   ;
assign DataReady   = iDataReady ;
//assign Grant       = Hgrant & HREADY & Request & ~RetryPhase & ~TerminalPhase ;
assign Grant       = HREADY && Hgrant && Request 
                                && (iHTRANS == `HTRANS_NONSEQ || iHTRANS == `HTRANS_SEQ) ;
                                //&& (iHTRANS == `HTRANS_NONSEQ || iHTRANS == `HTRANS_BUSY || iHTRANS == `HTRANS_SEQ) ;
assign Okay        = DataPhase && HREADY && (HRESP == `HRESP_OKAY )   ;
assign Error       = DataPhase && HREADY && (HRESP == `HRESP_ERROR)   ;
assign Retry       = DataPhase && HREADY && (HRESP == `HRESP_RETRY || HRESP == `HRESP_SPLIT)   ;

endmodule
