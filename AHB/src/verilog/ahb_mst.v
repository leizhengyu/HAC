//================================================================================
// Created by         : Ltd.com
// Filename           : ahb_mst.v
// Author             : Python_Wang
// Created On         : 2009-05-30 20:54
// Last Modified      : 2009-07-19 13:55
// Description        : 
//                      
//                      
//================================================================================
module ahb_mst(
input        HCLK            , //clock
input        HRST_N          , //reset
//ahb
input        HGRANT          ,
input        HREADY          ,
input  [ 1:0]HRESP           ,
input  [31:0]HRDATA          ,
output       HBUSREQ         ,
output       HLOCK           ,
output [31:0]HADDR           ,
output [ 1:0]HTRANS          ,
output [ 2:0]HBURST          ,
output [ 2:0]HSIZE           ,
output       HWRITE          ,
output [ 3:0]HPROT           ,
output [31:0]HWDATA          ,
//master
input        Request         ,
input        Burst           ,
input        Busy            ,
input        Write           ,
input  [ 2:0]Size            ,
input  [31:0]Addr            ,
input  [31:0]DataIn          ,
output [31:0]DataOut         ,
output       Grant           ,
output       Okay            ,
output       Retry            
);

reg          HGrantReg       ;
reg          iActive         ;
reg          iOkay           ;
reg          iRetry          ;
reg          iError          ;
reg          RetryReg        ;
reg    [ 1:0]iHTRANS         ;
reg    [31:0]iAddr           ;



always @(posedge HCLK or negedge HRST_N)
begin
  if (!HRST_N) begin
    HGrantReg <= #1 1'b0 ;
    iActive   <= #1 1'b0 ;
  end
  else if(HREADY) begin
    HGrantReg <= #1 HGRANT ;
    if(iHTRANS == `HTRANS_IDLE) begin
      iActive   <= #1 1'b0      ;
    end
    else begin
      iActive    <= #1 HGrantReg ;
    end
  end
end

always @(*)
begin
  iOkay       =  1'b0    ;
  iRetry      =  1'b0    ;
  iError      =  1'b0    ;
  if(iActive) begin
    if(HREADY) begin
      case(HRESP)
	`HRESP_OKAY  : iOkay = 1'b1 ;
	`HRESP_RETRY, `HRESP_SPLIT : iRetry = 1'b1 ;
	default     : begin iOkay = 1'b1 ; iError = 1'b1 ; end
      endcase
    end
  end
end

always @(posedge HCLK or negedge HRST_N)
begin
  if (!HRST_N) begin
    RetryReg <= #1 1'b0 ;
  end
  else if(~HREADY && (HRESP == `HRESP_SPLIT || HRESP == `HRESP_RETRY)) begin
    RetryReg <= #1 1'b1 ;
  end
  else begin
    RetryReg <= #1 1'b0 ;
  end
end

always @(*)
begin
  iHTRANS = `HTRANS_IDLE ;
  if(Request) begin
    iHTRANS = `HTRANS_NONSEQ ;
    if(iActive & Burst & ~RetryReg) begin
      if(Busy) begin
	      iHTRANS = `HTRANS_BUSY ;
      end
      else begin
	      iHTRANS = `HTRANS_SEQ  ;
      end
    end
    //else if(HGrantReg) begin
    //  iHTRANS = `HTRANS_NONSEQ ;
    //end
  end

  if(RetryReg) begin
    iHTRANS = `HTRANS_IDLE ;
  end
end

always @(posedge HCLK or negedge HRST_N)
begin
  if (!HRST_N) begin
    iAddr <= #1 'b0 ;
  end
  else begin
    if((iActive | HGrantReg & ~iActive) && Burst && Request && HREADY) begin
      case(Size)
	      3'b000  : iAddr <= #1 iAddr + 3'd1      ;
	      3'b001  : iAddr <= #1 iAddr + 3'd2      ;
	      3'b010  : iAddr <= #1 iAddr + 3'd4      ;
	      default : iAddr <= #1 iAddr + 3'd4      ;
      endcase
    end
    else if(~Request & ~iActive) begin
      iAddr <= #1 32'b0 ;
    end
    //else if(~iActive) begin
    //  iAddr <= #1 32'b0 ;
    //end
    if((RetryReg | ~HGrantReg & HGRANT) & HREADY) begin
      iAddr <= #1 Addr           ;
    end
  end
end


assign    HBUSREQ = Request  | (iActive & ~Request & ~iOkay) ;
assign    HADDR   = iAddr                                 ;
assign    HSIZE   = Size                                  ;
assign    HWRITE  = Write                                 ;
assign    HBURST  = Burst ? `HBURST_INCR : `HBURST_SINGLE ;
assign    HTRANS  = iHTRANS                               ;
assign    HWDATA  = DataIn                                ;
assign    HLOCK   = 1'b0                                  ;
assign    HPROT   = 4'b0000                               ;


assign    DataOut = HRDATA                                ;
assign    Okay    = iOkay                                 ;
assign    Retry   = iRetry                                ;
assign    Grant   = HREADY && HGrantReg && Request 
                    && (iHTRANS == `HTRANS_NONSEQ || iHTRANS == `HTRANS_SEQ) ;

endmodule
