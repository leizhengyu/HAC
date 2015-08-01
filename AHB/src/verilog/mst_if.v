//================================================================================
// Created by         : Ltd.com
// Filename           : mst_if.v
// Author             : Python_Wang
// Created On         : 2009-06-06 16:40
// Last Modified      : 2009-07-19 13:16
// Description        : 
//                      
//                      
//================================================================================

module mst_if(
input        CLK             , //clock
input        RST_N           , //reset
//if
input        Start           ,
input  [ 2:0]WRSize          ,
input        WR              ,
input  [31:0]WRAddr          ,
input  [ 9:0]WRLen           ,
input        WRBurst         ,
output       ReadEn          ,
input  [31:0]Din             ,      
output       DoutVld         ,
output [31:0]Dout            ,
output       Done            ,
//dma
output       Request         ,
output [31:0]Addr            ,
output [ 2:0]Size            ,
output       Write           ,
output       Burst           ,
output       Busy            ,
output [31:0]DataIn          ,
input  [31:0]DataOut         ,
input        Grant           ,
input        Okay            ,
input        Retry            
);

reg    [ 2:0]rWRSize         ;
reg          rWR             ;
reg    [31:0]rWRAddr         ;
reg          rWRBurst        ;
reg    [ 9:0]LenCnt          ;

//reg    [31:0]iDataIn         ;

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
  else if(NS == IDLE) begin
    rWRAddr    <= #1 32'b0     ;
    rWRSize    <= #1  3'b0     ;
    rWR        <= #1  1'b0     ;
    rWRBurst   <= #1  1'b0     ;
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

//always @(posedge CLK or negedge RST_N)
//begin
//  if (!RST_N)     iDataIn <= #1 32'b0   ;
//  else if(Grant)  iDataIn <= #1 Din     ;
//  else if(Okay)   iDataIn <= #1 32'b0   ;
//end

//mst
assign  Request =  (CS == OP_PHASE) ? 1'b1 : 1'b0 ;
assign  Addr    =  rWRAddr          ;
assign  Size    =  rWRSize         ;
assign  Write   =  rWR             ;
assign  Burst   =  rWRBurst        ;
assign  Busy    =  1'b0            ;
assign  DataIn  =  (CS == IDLE) ? 32'b0 : Din ;
//assign  DataIn  =  iDataIn         ;
//if
assign  ReadEn  = (CS == IDLE && NS == OP_PHASE && WR ) || (CS == OP_PHASE && Okay && rWR) ? 1'b1 : 1'b0 ;
assign  Done    = (CS == IDLE) ? 1'b1 : 1'b0 ;
//assign  Done    = (CS == END_PHASE && NS == IDLE) ? 1'b1 : 1'b0 ;
assign  DoutVld = Okay & ~rWR      ;
assign  Dout    = DataOut          ;


endmodule
