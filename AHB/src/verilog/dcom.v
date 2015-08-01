//================================================================================
// Created by         : Ltd.com
// Filename           : dcom.v
// Author             : Python_Wang
// Created On         : 2009-05-31 08:33
// Last Modified      : 2009-06-11 16:24
// Description        : 
//                      
//                      
//================================================================================
module dcom(
input        CLK             , //clock
input        RST_N           , //reset
//com
output       Write           ,
output [ 7:0]DataOut         ,
output       Read            ,
input  [ 7:0]DataIn          ,
input        DataReady       ,
input        THEmpty         ,
//ahb
output       AhbReq          ,
output       AhbBurst        ,
output       AhbBusy         ,
output       AhbWrite        ,
output [ 2:0]AhbSize         ,
output [31:0]AhbAddr         ,
output [31:0]AhbOut          ,
input  [31:0]AhbIn           ,
input        Okay              
);

parameter    ADDR_SIZE  = 4  ; //byte
parameter    DATA_SIZE  = 4  ; //byte

reg    [ 3:0]ReceiveCnt      ;
reg    [ 3:0]TransmitCnt     ;
reg    [ 5:0]DataLen         ;
reg    [ 5:0]DataCnt         ;
reg    [31:0]iAhbOut         ;
reg    [31:0]iAhbAddr        ;
reg          iAhbWrite       ;
reg          iAhbReq         ;
reg    [31:0]AhbInQ          ;

reg          StateIdle       ;
reg          StateReadAddr   ;
reg          StateReadAhb    ;
reg          StateWriteMst   ;
reg          StateReadMst    ;
reg          StateWriteAhb   ;

wire         StartIdle       ;
wire         StartReadAddr   ;
wire         StartReadAhb    ;
wire         StartWriteMst   ;
wire         StartReadMst    ;
wire         StartWriteAhb   ;

assign       StartReadAddr = StateIdle & DataReady & DataIn[7] ;
assign       StartReadMst  = (  StateReadAddr && (ReceiveCnt == ADDR_SIZE - 1) && DataReady && iAhbWrite
                             || StateWriteAhb && Okay && (DataCnt != DataLen - 1)
			     )? 1'b1 : 1'b0 ;
assign       StartWriteAhb = StateReadMst && (ReceiveCnt == DATA_SIZE - 1) && DataReady ? 1'b1 : 1'b0 ;
assign       StartReadAhb  = (  StateReadAddr && (ReceiveCnt == ADDR_SIZE - 1) && DataReady && ~iAhbWrite
                             || StateWriteMst && THEmpty && (TransmitCnt == DATA_SIZE - 1) && (DataCnt != DataLen - 1)  
                             )? 1'b1 : 1'b0 ;
assign       StartWriteMst = StateReadAhb  && Okay ? 1'b1 : 1'b0 ;
assign       StartIdle     = (  StateWriteMst && THEmpty && (TransmitCnt == DATA_SIZE -1) && (DataCnt == DataLen -1)
                             || StateWriteAhb &&  Okay && (DataCnt == DataLen -1)
			     )? 1'b1 : 1'b0 ;

always @(posedge CLK or negedge RST_N)
begin
  if (!RST_N) begin
    StateIdle      <= #1 1'b1 ;
    StateReadAddr  <= #1 1'b0 ;
    StateReadAhb   <= #1 1'b0 ;
    StateWriteMst  <= #1 1'b0 ;
    StateReadMst   <= #1 1'b0 ;
    StateWriteAhb  <= #1 1'b0 ;
  end
  else begin
    if(StartReadAddr)                StateIdle     <= #1 1'b0 ;
    else if(StartIdle)               StateIdle     <= #1 1'b1 ;

    if(StartReadAhb | StartReadMst)  StateReadAddr <= #1 1'b0 ;
    else if(StartReadAddr)           StateReadAddr <= #1 1'b1 ;

    if(StartWriteMst)                StateReadAhb  <= #1 1'b0 ;
    else if(StartReadAhb)            StateReadAhb  <= #1 1'b1 ;

    if(StartIdle | StartReadAhb)     StateWriteMst <= #1 1'b0 ;
    else if(StartWriteMst)           StateWriteMst <= #1 1'b1 ;

    if(StartWriteAhb)                StateReadMst  <= #1 1'b0 ;
    else if(StartReadMst)            StateReadMst  <= #1 1'b1 ;

    if(StartIdle | StartReadMst)     StateWriteAhb <= #1 1'b0 ;
    else if(StartWriteAhb)           StateWriteAhb <= #1 1'b1 ;
  end
end

always @(posedge CLK or negedge RST_N)
begin
  if (!RST_N) begin
    iAhbWrite  <= #1 'b0   ;
    DataLen    <= #1 'b0   ;
    ReceiveCnt <= #1 4'b0  ;
    TransmitCnt<= #1 4'b0  ;
    DataCnt    <= #1 6'b0  ;
    iAhbOut    <= #1 32'b0 ;
    iAhbAddr   <= #1 32'b0 ;
    AhbInQ     <= #1 32'b0 ;
  end
  else begin
    case({StateWriteMst, StateReadAhb, StateWriteAhb, StateReadMst,  StateReadAddr, StateIdle})
      6'b000001 : begin //idle
	if(StartReadAddr) begin
	  iAhbWrite  <= #1 DataIn[6]   ;
	  DataLen    <= #1 DataIn[5:0] ;
	  ReceiveCnt <= #1 4'b0        ;
	  DataCnt    <= #1 6'b0        ;
	  TransmitCnt <= #1 4'b0       ;
	end
      end
      6'b000010 : begin //read addr
	if(StartReadAhb | StartReadMst)  ReceiveCnt <= #1 4'b0              ;
	else if(DataReady)               ReceiveCnt <= #1 ReceiveCnt + 1'b1 ;

	if(DataReady)  iAhbAddr <= #1 {iAhbAddr[23:0], DataIn} ;
      end
      6'b000100 : begin //read master
	if(StartWriteAhb)                ReceiveCnt <= #1 4'b0              ;
	else if(DataReady)               ReceiveCnt <= #1 ReceiveCnt + 1'b1 ;

	if(DataReady)  iAhbOut  <= #1 {iAhbOut[23:0], DataIn} ;
      end
      6'b001000 : begin //write ahb
	if(StartIdle)          DataCnt <= #1 6'b0           ;
	else if(Okay) DataCnt <= #1 DataCnt + 1'b1 ;

	if(StartIdle)          iAhbAddr <= #1 32'b0                ;
	else if(StartReadMst)  iAhbAddr <= #1 iAhbAddr + DATA_SIZE ;
      end
      6'b010000 : begin //read ahb
	if(Okay)  AhbInQ <= #1 AhbIn  ;
      end
      6'b100000 : begin //wire master
        if(THEmpty) begin
	  AhbInQ   <= #1 {AhbInQ[23:0], 8'b0} ;
	  TransmitCnt <= #1 TransmitCnt + 1'b1 ;
	  //DataCnt  <= #1 DataCnt + 1'b1       ;
        end
	if(StartReadAhb)  TransmitCnt <= #1 'b0 ;
	if(THEmpty && (TransmitCnt == DATA_SIZE - 1))  DataCnt <= #1 DataCnt + 1'b1 ;
      end
    endcase
  end
end

always @(*)
begin
  iAhbReq = 1'b0 ;
  if(StateReadAhb & StartWriteMst | StateWriteAhb & (StartReadMst | StartIdle))  iAhbReq = 1'b0 ;
  else if(StateReadAhb | StateWriteAhb) iAhbReq = 1'b1 ;
end

assign   Write      = StateWriteMst & THEmpty      ;
assign   DataOut    = AhbInQ[31:24]                ;
assign   Read       = (StateIdle | StateReadMst | StateReadAddr) & DataReady     ;
assign   AhbReq     = iAhbReq                      ;
assign   AhbBurst   = 1'b0                         ;
assign   AhbBusy    = 1'b0                         ;
assign   AhbWrite   = iAhbWrite                    ;
assign   AhbSize    = 3'b10                        ;
assign   AhbAddr    = iAhbAddr                     ;
assign   AhbOut     = iAhbOut                      ;

endmodule
