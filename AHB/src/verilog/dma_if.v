//================================================================================
// Created by         : Ltd.com
// Filename           : dma_if.v
// Author             : Python_Wang
// Created On         : 2009-06-15 14:43
// Last Modified      : 2009-06-15 15:42
// Description        : 
//                      
//                      
//================================================================================
module dma_if(
input        CLK             ,
input        RST_N           ,
//if
input        DmaBusy         ,
input        DmaLock         ,
input        Start           ,
input  [ 2:0]WRSize          ,
input        WR              ,
input  [31:0]WRAddr          ,
input  [ 9:0]WRLen           ,
input        WRBurst         ,
input  [31:0]Din             ,      
output       ReadEn          ,
output       DoutVld         ,
output [31:0]Dout            ,
output       Done            ,
//mst
output       Lock            ,
output       Busy            ,
output       Request         ,
output [31:0]Addr            ,
output [ 2:0]Size            ,
output       Write           ,
output       Burst           ,
output [ 2:0]Beat            ,
output [31:0]DataIn          ,
input  [31:0]DataOut         ,
input        DataReady       ,
input        Grant           ,
input        Okay            ,
input        Error           ,
input        Retry            
);
reg    [ 2:0]rWRSize         ;
reg          rWR             ;
reg    [31:0]rWRAddr         ;
reg          rWRBurst        ;
reg    [ 9:0]LenCnt          ;
reg    [ 2:0]iBeat           ;

parameter    IDLE       = 2'b00 ,
             OP_PHASE   = 2'b01 , 
	     END_PHASE  = 2'b10 ;
reg    [ 1:0]CS, NS ;

always @(posedge CLK or negedge RST_N)
begin
  if (!RST_N) begin
    CS <= #1 IDLE ;
  end
  else begin
    CS <= #1 NS   ;
  end
end

always @(*)
begin
  NS = CS ;
  case(CS)
    IDLE      : begin
      if(Start) NS = OP_PHASE ;
      else      NS = IDLE     ;
    end 
    OP_PHASE  : begin
      if(LenCnt == 1 && Grant) NS = END_PHASE ;
      else                     NS = OP_PHASE  ;
    end
    END_PHASE : begin
      if(Okay)  NS = IDLE      ;
      else      NS = END_PHASE ;
    end
    default   : NS = IDLE      ;
  endcase
end

always @(posedge CLK or negedge RST_N)
begin
  if (!RST_N) begin
    rWRAddr    <= #1 32'b0     ;
    rWRSize    <= #1  3'b0     ;
    rWR        <= #1  1'b0     ;
    rWRBurst   <= #1  1'b0     ;
  end
  else if(CS == IDLE && NS == OP_PHASE) begin
    rWRAddr    <= #1 WRAddr    ;
    rWRSize    <= #1 WRSize    ;
    rWR        <= #1 WR        ;
    rWRBurst   <= #1 WRBurst   ;
  end
end

always @(posedge CLK or negedge RST_N)
begin
  if (!RST_N) begin
    LenCnt <= #1 16'b0 ;
  end
  else if(CS == IDLE && NS == OP_PHASE) begin
    LenCnt <= #1 WRLen ;
  end
  else if(CS == OP_PHASE && Grant) begin
    LenCnt <= #1 LenCnt - 1'b1 ;
  end
end


always @(*)
begin
  iBeat = 3'b000 ;
  if(Start) begin
    case(WRLen)
      10'd4   : iBeat = 3'b001  ;
      10'd8   : iBeat = 3'b010  ;
      10'd16  : iBeat = 3'b011  ;
      default : iBeat = 3'b000 ;
    endcase
  end
end

//mst
assign  Lock    = DmaLock   ;
assign  Busy    = DmaBusy   ;
assign  Request =  (CS == OP_PHASE) ? 1'b1 : 1'b0 ;
assign  Addr    =  rWRAddr         ;
assign  Size    =  rWRSize         ;
assign  Write   =  rWR             ;
assign  Burst   =  rWRBurst        ;
assign  Beat    =  iBeat           ;
assign  DataIn  =  Din             ;
//if
assign  ReadEn  = (CS == IDLE && NS == OP_PHASE && WR ) || (CS == OP_PHASE && Okay && rWR) ? 1'b1 : 1'b0 ;
assign  Done    = (CS == END_PHASE && NS == IDLE) ? 1'b1 : 1'b0 ;
assign  DoutVld = DataReady ; 
assign  Dout    = DataOut   ; 

endmodule
