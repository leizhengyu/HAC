//================================================================================
// Created by         : Ltd.com
// Filename           : ahb_arbiter.v
// Author             : Python_Wang
// Created On         : 2009-06-02 13:25
// Last Modified      : 2009-07-22 00:46
// Description        : 
//                      
//                      
//================================================================================
module ahb_arbiter(
input        HCLK            , //clock
input        HRST_N          , //reset

input  [15:0]HBUSREQ         , //all master
output [15:0]HGRANT          , //all master
output       HMASTERLOCK     ,
output [ 3:0]HMASTER         ,
output       DefaultMst      ,
output       DefaultSlv      ,

input        HREADY          ,
input  [ 1:0]HRESP           ,
input  [15:0]HSPLIT          ,
input        HLOCK           ,
input  [ 1:0]HTRANS          ,
input  [ 2:0]HBURST          
);
//parameter    ROUND_ROBBIN  = 1 ;
reg    [15:0]iHGRANT         ; //all master
reg    [ 3:0]iHMASTER        ;
reg          iDefaultMst     ;
reg          iDefaultSlv     ;

reg    [ 1:0]Q1HTRANS        ;
reg    [ 1:0]Q2HTRANS        ;
reg    [ 1:0]Q3HTRANS        ;

reg    [ 3:0]CurrentMaster   ;
reg    [ 3:0]NextMaster      ;
reg          HlockAddr       ;
reg          HlockData       ;
reg    [15:0]MaskTmp         ;
reg    [15:0]Mask            ;
reg    [15:0]MaskQ           ;
reg    [15:0]BusreqTmp       ;
reg    [15:0]BusreqNoMask    ;
reg          Deadlock        ;
reg    [ 3:0]Beat            ;
reg          RequireArbiter  ;


always @(posedge HCLK or negedge HRST_N)
begin
  if (!HRST_N) begin
    Q1HTRANS <= #1 2'b0 ;
    Q2HTRANS <= #1 2'b0 ;
    Q3HTRANS <= #1 2'b0 ;
  end
  else if(HREADY) begin
    Q1HTRANS <= #1 HTRANS   ;
    Q2HTRANS <= #1 Q1HTRANS ;
    Q3HTRANS <= #1 Q2HTRANS ;
  end
end

always @(posedge HCLK or negedge HRST_N)
begin
  if (!HRST_N) begin
    HlockAddr <= #1 1'b0 ;
    HlockData <= #1 1'b0 ;
  end
  else if(HREADY) begin
    HlockAddr <= #1 HLOCK     ;
    HlockData <= #1 HlockAddr ;
  end
end

always @(posedge HCLK or negedge HRST_N)
begin
  if (!HRST_N) begin
    Deadlock <= #1 1'b0 ;
  end
  else if(Deadlock & (|BusreqNoMask)) begin
    Deadlock <= #1 1'b0 ;
  end
  else if(HlockData && (HRESP == `HRESP_SPLIT) ) begin
    Deadlock <= #1 1'b1 ;
  end
end

always @(posedge HCLK or negedge HRST_N)
begin
  if (!HRST_N) begin
    iDefaultMst <= #1 1'b1 ;
  end
  else if(Deadlock | (RequireArbiter & ~(|BusreqNoMask))) begin
    iDefaultMst <= #1 1'b1 ;
  end
  else if(HREADY & iDefaultMst & (|BusreqNoMask)) begin
    iDefaultMst <= #1 1'b0 ;
  end
end

always @(posedge HCLK or negedge HRST_N)
begin
  if (!HRST_N) begin
    MaskQ <= #1 16'b0 ;
  end
  else begin
    MaskQ <= #1 Mask  ;
  end
end

always @(*)
begin
  MaskTmp = 16'b0 ;
  BusreqTmp = HBUSREQ ;
  if(HRESP == `HRESP_SPLIT) MaskTmp[CurrentMaster] = 1'b1 ;//如果接收到split，屏蔽当前master
  if(Deadlock) BusreqTmp[CurrentMaster] = 1'b0 ; //如果产生死锁，屏蔽掉当前master的请求
  Mask = (MaskQ | MaskTmp) & ~HSPLIT ; //如果slaver发送Hsplit有效，清除屏蔽
  BusreqNoMask = HBUSREQ & ~Mask  ;
end

always @(posedge HCLK or negedge HRST_N)
begin
  if (!HRST_N) begin
    Beat <= #1 4'b0 ;
  end
  else begin
    if(HREADY) begin
      if(HTRANS == `HTRANS_IDLE || HTRANS == `HTRANS_NONSEQ)  Beat <= #1 4'b1 ;
      else if(HTRANS == `HTRANS_SEQ)                          Beat <= #1 Beat + 1'b1 ;
    end
  end
end

always @(*)
begin
  RequireArbiter = 1'b0 ;
  if(iDefaultMst & ~Deadlock) begin
    RequireArbiter = |BusreqNoMask ;
  end
  else if(~HlockAddr | ~Deadlock) begin
    case(HTRANS) 
      `HTRANS_IDLE   : RequireArbiter = 1'b1 ;
      `HTRANS_NONSEQ : begin
	      case(HBURST) 
	        `HBURST_SINGLE  : RequireArbiter = 1'b1 ;
	        `HBURST_INCR    : RequireArbiter = ~HBUSREQ[CurrentMaster] ;//根据是否还有请求
	      endcase
      end	
      `HTRANS_SEQ    : begin
	      case(HBURST)
	        `HBURST_INCR                   : RequireArbiter = ~HBUSREQ[CurrentMaster] ;
	        `HBURST_INCR4 , `HBURST_WRAP4  : RequireArbiter = (Beat == 3 ) ? 1'b1 : 1'b0 ;
	        `HBURST_INCR8 , `HBURST_WRAP8  : RequireArbiter = (Beat == 7 ) ? 1'b1 : 1'b0 ;
	        `HBURST_INCR16, `HBURST_WRAP16 : RequireArbiter = (Beat == 15) ? 1'b1 : 1'b0 ;
	      endcase
      end
    endcase
  end
end

always @(*)
begin
  NextMaster = CurrentMaster ;
  if(RequireArbiter) begin
    NextMaster = select_master(iDefaultMst, BusreqNoMask, CurrentMaster) ;
  end
end

always @(posedge HCLK or negedge HRST_N)
begin
  if (!HRST_N) begin
    CurrentMaster <= #1 4'b0 ;
  end
  else if(HREADY) begin
    CurrentMaster <= #1 NextMaster ;
  end
end

always @(*)
begin
  iHGRANT = 16'b0 ;
  if(|BusreqNoMask & ~iDefaultMst & ~iDefaultSlv)
    iHGRANT[NextMaster] = 1'b1 ;
  //if(~DefaultMst) 
  //  iHGRANT[NextMaster] = 1'b1 ;
end

always @(posedge HCLK or negedge HRST_N)
begin
  if (!HRST_N) begin
    iHMASTER <= #1 4'b0 ;
  end
  else if(HREADY) begin
    iHMASTER <= #1 NextMaster ;
  end
end

always @(posedge HCLK or negedge HRST_N)
begin
  if (!HRST_N) begin
    iDefaultSlv <= #1 1'b1 ;
  end
  else if(HREADY) begin
    iDefaultSlv <= #1 iDefaultMst ;
  end
end

assign  HGRANT      =  iHGRANT         ; //all master
assign  HMASTER     =  iHMASTER        ;
assign  HMASTERLOCK =  HlockAddr       ;
assign  DefaultMst  =  iDefaultMst     ;
assign  DefaultSlv  =  iDefaultSlv     ;

function [3:0]select_master;
  input       default_master;
  input [15:0]busreq_no_mask;
  input [ 4:0]current_master;
  reg   [ 4:0]i,j;
  reg   [31:0]busreqx2; 
  reg   [15:0]busreq_tmp;
  reg   [ 3:0]next_master;
  begin
    i = 5'b0 ; j = 5'b0 ;
    busreqx2    = 32'b0 ; 
    busreq_tmp  = 16'b0 ;
    next_master =  4'b0 ;
    if(default_master) begin
      for(i = 0 ; i < 16 ; i = i + 1) begin
        if(busreq_no_mask[i] == 1'b1)
          next_master = i;
      end
    end
    else begin
      busreqx2 = {busreq_no_mask,busreq_no_mask};//将2个输入的总线请求链接起来
      for(i = 0; i<16; i=i+1) begin
        if(i == current_master) begin
          busreq_tmp = busreqx2[i+:16];
          for(j=0;j<16; j=j+1) begin
            if(busreq_tmp[j] == 1'b1) begin
              if(current_master + j > 16) begin
                next_master = i + j - 16;
              end
              else begin
                next_master = i + j;
              end
            end
          end
        end
      end
    end
    if(|busreq_no_mask)  select_master = next_master ;
    else                 select_master = current_master ;
  end
endfunction

endmodule
