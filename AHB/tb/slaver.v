//================================================================================
// Created by         : Ltd.com
// Filename           : slaver.v
// Author             : Python_Wang
// Created On         : 2009-06-08 16:25
// Last Modified      : 2009-06-09 15:00
// Description        : for sim
//                      
//                      
//================================================================================
module slaver(
HCLK         ,
HRST_N       ,

HSEL         ,
HREADY       ,
HADDR        ,
HSIZE        ,
HWRITE       ,
HTRANS       ,
HBURST       ,
HWDATA       ,

HREADY_O     ,
HRESP        ,
HRDATA       ,
HSPLIT       
);
input         HCLK           ; //clock
input         HRST_N         ; //reset
input         HREADY         ;
input         HSEL           ;
input   [31:0]HADDR          ;
input   [ 2:0]HSIZE          ;
input         HWRITE         ;
input   [ 1:0]HTRANS         ;
input   [ 2:0]HBURST         ;
input   [31:0]HWDATA         ;
//to ahb
output        HREADY_O       ;
output  [ 1:0]HRESP          ;
output  [15:0]HSPLIT         ;
output  [31:0]HRDATA         ;

reg           iHREADY        ;
reg     [ 1:0]iHRESP         ;
reg     [15:0]iHSPLIT        ;
reg     [31:0]iHRDATA        ;

initial begin
    iHREADY = 1'b1                    ;
    iHRESP  = `HRESP_OKAY             ;
    iHSPLIT = 16'b0                   ;
    iHRDATA = 32'hBBBB                ;
    repeat(20)@(posedge HCLK)         ;
    respond(`HRESP_SPLIT)             ;
    $display("Slaver Respond Split!" );
    #80 
    $display("Slaver Set Split: 16'h01!" );
    iHSPLIT = 16'h01                  ;
    respond(`HRESP_OKAY)              ;
    respond(`HRESP_OKAY)              ;
    respond(`HRESP_OKAY)              ;
    #80 
    respond(`HRESP_OKAY)              ;
    respond(`HRESP_OKAY)              ;
    respond(`HRESP_OKAY)              ;
    #80 
    respond(`HRESP_ERROR)             ;
    respond(`HRESP_ERROR)             ;
    respond(`HRESP_ERROR)             ;
    #80 
    respond(`HRESP_ERROR)             ;
    respond(`HRESP_OKAY)              ;
end

task respond;
  input [1:0]resp ;
  begin
    iHREADY = 1'b1   ;
    iHRESP  = `HRESP_OKAY ;
    wait(HSEL & HREADY)      ;
    @(posedge HCLK)          ;
      #1 
      iHRESP  = resp         ;
      iHREADY = 1'b0         ;
    @(posedge HCLK) ;
      #1 
      iHRESP  = resp         ;
      iHREADY = 1'b1         ;
    @(posedge HCLK);
      #1 
      iHREADY = 1'b1         ;
      iHRESP  = `HRESP_OKAY  ;
  end
endtask

assign   HREADY_O   =   iHREADY    ;
assign   HRESP      =   iHRESP     ;
assign   HSPLIT     =   iHSPLIT    ;
assign   HRDATA     =   iHRDATA    ;

endmodule
