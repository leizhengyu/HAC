//================================================================================
// Created by         : Ltd.com
// Filename           : ahb_dma.v
// Author             : Python_Wang
// Created On         : 2009-06-15 15:44
// Last Modified      : 2009-06-15 22:32
// Description        : 
//                      
//                      
//================================================================================
module ahb_dma(
input        CLk             , //clock
input        RST_N           , //reset
//apb
input        PSEL            , 
input        PENABLE         ,
input        PWRITE          ,
input  [31:0]PADDR           ,
input  [31:0]PWDATA          ,
output [31:0]PRDATA          ,
//if
output       DmaBusy         ,
output       DmaLock         ,
output       Start           ,
output [ 2:0]WRSize          ,
output       WR              ,
output [31:0]WRAddr          ,
output [ 9:0]WRLen           ,
output       WRBurst         ,
output [31:0]Din             ,      
input        ReadEn          ,
input        DoutVld         ,
input  [31:0]Dout            ,
input        Done            
);

parameter    BUF = 16        ;
parameter    SIMPLE_DMA_CTRL_ADDR1 = 6'b111100 ;
parameter    SIMPLE_DMA_CTRL_ADDR2 = 6'b110111 ;
parameter    SIMPLE_DMA_CTRL_ADDR3 = 6'b110111 ;

reg    [31:0]Fifo[BUF-1:0]   ;

reg    [31:0]SrcAddr         ;
reg    [31:0]DirAddr         ;
reg    [ 2:0]SrcSize         ;
reg    [ 2:0]DirSize         ;
reg          Enable          ;

reg    [ 3:0]ReceiveCnt      ;
reg    [ 3:0]SendCnt         ;

reg          iDmaLock        ;

reg          iStart          ;
reg    [31:0]iWRAddr         ;
reg    [ 2:0]iWRSize         ;
reg          iWR             ;
reg    [ 9:0]iWRLen          ;
reg          iWRBurst        ;
reg    [31:0]iDin            ;     
reg    [31:0]iPRDATA         ;


always @(posedge CLk or negedge RST_N)
begin
  if (!RST_N) begin
    SrcAddr <= #1 32'b0 ;
    DirAddr <= #1 32'b0 ;
    SrcSize <= #1 3'b0  ;
    DirSize <= #1 3'b0  ;
    iWRLen  <= #1 10'b0 ;
  end
  else begin
    if(PSEL & PENABLE & PWRITE) begin
      case(PADDR[5:0])
	SIMPLE_DMA_CTRL_ADDR1 : SrcAddr <= #1 PWDATA ;
	SIMPLE_DMA_CTRL_ADDR2 : DirAddr <= #1 PWDATA ;
	SIMPLE_DMA_CTRL_ADDR3 : begin 
	  SrcSize <= #1 PWDATA[1:0] ; 
	  DirSize <= #1 PWDATA[3:2] ; 
	  iWRLen <= #1 PWDATA[13:4]; 
	end
      endcase
    end
  end
end

always @(*)
begin
  iPRDATA = 32'b0 ;
  if(PSEL & PENABLE & ~PWRITE) begin
    case(PADDR[5:0])
      SIMPLE_DMA_CTRL_ADDR1 : iPRDATA = SrcAddr ;
      SIMPLE_DMA_CTRL_ADDR2 : iPRDATA = DirAddr ;
      SIMPLE_DMA_CTRL_ADDR3 : iPRDATA = {17'b0,Enable,iWRLen,DirSize,SrcSize};
      default               : iPRDATA = 32'b0 ;
    endcase
  end
end

reg          StateIdle       ;
reg          StateRead       ;
reg          StateWrite      ;

wire         StartIdle  = StateWrite & Done ;
wire         StartRead  = StateIdle & Enable;
wire         StartWrite = StateRead & Done  ;

always @(posedge CLk or negedge RST_N)
begin
  if (!RST_N) begin
    StateIdle  <= #1 1'b1  ;
    StateRead  <= #1 1'b0  ;
    StateWrite <= #1 1'b0 ;
  end
  else begin
    if(StartRead)       StateIdle <= #1 1'b0 ;
    else if(StartIdle)  StateIdle <= #1 1'b1 ;

    if(StartWrite)      StateRead <= #1 1'b0 ;
    else if(StartRead)  StateRead <= #1 1'b1 ;

    if(StartIdle)       StateWrite <= #1 1'b0 ;
    else if(StartWrite) StateWrite <= #1 1'b1 ;
  end
end

always @(posedge CLk or negedge RST_N)
begin
  if (!RST_N) begin
    iStart   <= #1 'b0 ;
    iWRAddr  <= #1 'b0 ;
    iWRSize  <= #1 'b0 ;
    iWR      <= #1 'b0 ;
    iWRBurst <= #1 'b0 ;
  end
  else begin
    case({StateWrite, StateRead, StateIdle})
      3'b001  : begin
	if(StartRead) begin
	  iStart   <= #1 1'b1 ;
          iWRAddr  <= #1 SrcAddr       ;
          iWRSize  <= #1 SrcSize       ;
          iWR      <= #1 1'b0          ;
          iWRBurst <= #1 |iWRLen[9:1]  ;
	end
      end
      3'b010  : begin
	iStart <= #1 1'b0  ;
	if(StartWrite) begin
	  iStart   <= #1 1'b1 ;
          iWRAddr  <= #1 DirAddr       ;
          iWRSize  <= #1 DirSize       ;
          iWR      <= #1 1'b1          ;
          iWRBurst <= #1 |iWRLen[9:1]  ;
	end
      end
      3'b100  : begin
	iStart <= #1 1'b0  ;
	if(StartIdle) begin
	  iStart   <= #1 'b0 ;
          iWRAddr  <= #1 'b0 ;
          iWRSize  <= #1 'b0 ;
          iWR      <= #1 'b0 ;
          iWRBurst <= #1 'b0 ;
	end
      end
      default : begin
	  iStart   <= #1 'b0 ;
          iWRAddr  <= #1 'b0 ;
          iWRSize  <= #1 'b0 ;
          iWR      <= #1 'b0 ;
          iWRBurst <= #1 'b0 ;
      end
    endcase
  end
end


always @(posedge CLk or negedge RST_N)
begin
  if (!RST_N) begin
    Enable <= #1 1'b0 ;
  end
  else if(StartIdle) begin
    Enable <= #1 1'b0 ;
  end
  else if(PSEL && PENABLE && PWRITE && (PADDR[5:0] == SIMPLE_DMA_CTRL_ADDR3)) begin
    Enable <= #1 PWDATA[14] ;
  end
end

always @(posedge CLk or negedge RST_N)
begin
  if (!RST_N) begin
    iDmaLock <= #1 1'b0 ;
  end
  else if(StartIdle) begin
    iDmaLock <= #1 1'b0 ;
  end
  else if(StartRead) begin
    iDmaLock <= #1 1'b1 ;
  end
end

always @(posedge CLk or negedge RST_N)
begin
  if (!RST_N) begin
    ReceiveCnt <= #1 4'b0 ;
  end
  else if(StartIdle) begin
    ReceiveCnt <= #1 4'b0 ;
  end
  else if(DoutVld) begin
    ReceiveCnt <= #1 ReceiveCnt + 1'b1 ;
  end
end

always @(posedge CLk or negedge RST_N)
begin
  if (!RST_N) begin
    SendCnt <= #1 4'b0 ;
  end
  else if(StartIdle) begin
    SendCnt <= #1 4'b0 ;
  end
  else if(ReadEn) begin
    SendCnt <= #1 SendCnt + 1'b1 ;
  end
end

integer       i      ;
always @(posedge CLk or negedge RST_N)
begin
  if (!RST_N) begin
    for(i = 0 ; i < BUF ; i = i + 1) 
      Fifo[i] <= #1 32'b0 ;
  end
  else if(DoutVld) begin
    Fifo[ReceiveCnt] <= #1 Dout  ;
  end
end

always @(posedge CLk or negedge RST_N)
begin
  if (!RST_N) begin
    iDin <= #1 32'b0 ;
  end
  else if(ReadEn) begin
    iDin <= #1 Fifo[SendCnt] ;
  end
end

assign   DmaBusy     = 1'b0     ;
assign   DmaLock     = iDmaLock ;
assign   Start       = iStart   ;
assign   WRSize      = iWRSize  ;
assign   WR          = iWR      ;
assign   WRAddr      = iWRAddr  ;
assign   WRLen       = iWRLen   ;
assign   WRBurst     = iWRBurst ;
assign   Din         = iDin     ;

assign   PRDATA      = iPRDATA  ;


endmodule
