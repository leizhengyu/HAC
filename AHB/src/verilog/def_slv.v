//================================================================================
// Created by         : Ltd.com
// Filename           : def_slv.v
// Author             : Python_Wang
// Created On         : 2009-06-03 16:57
// Last Modified      : 2009-06-08 19:48
// Description        : 
//                      
//                      
//================================================================================
module def_slv(
input         HCLK           , //clock
input         HRST_N         , //reset
input         HREADY         ,
input   [ 1:0]HTRANS         ,
input         DefaultSlv     ,
//to ahb
output        HREADY_O       ,
output  [ 1:0]HRESP          ,
output  [31:0]HRDATA         ,
output  [15:0]HSPLIT          
);

reg           iHREADY        ;
reg           iHREADY_O      ;
reg     [ 1:0]iHRESP         ;
reg     [31:0]iHRDATA        ;
reg     [15:0]iHSPLIT        ;
reg     [ 1:0]rHTRANS        ; 

always @(posedge HCLK or negedge HRST_N)
begin
  if (!HRST_N) begin
    rHTRANS <= #1 `HTRANS_IDLE ;
  end
  else if(HREADY) begin
    rHTRANS <= #1 HTRANS       ;
  end
end

always @(*)
begin
  iHRESP    =  `HRESP_OKAY ;
  iHREADY   =  iHREADY_O   ;
  iHRDATA   =  32'b0       ;
  iHSPLIT   =  32'b0       ;
  if(DefaultSlv && (rHTRANS == `HTRANS_NONSEQ || rHTRANS == `HTRANS_SEQ)) begin
    iHRESP    <= #1 `HRESP_ERROR;
    iHREADY   <= #1 ~iHREADY_O  ;
  end
end

always @(posedge HCLK or negedge HRST_N)
begin
  if (!HRST_N) begin
    iHREADY_O <= #1 1'b1 ;
  end
  else begin
    iHREADY_O <= #1 iHREADY ;
  end
end


assign   HREADY_O =  iHREADY        ;
assign   HRESP    =  iHRESP         ;
assign   HRDATA   =  iHRDATA        ;
assign   HSPLIT   =  iHSPLIT        ;

endmodule
