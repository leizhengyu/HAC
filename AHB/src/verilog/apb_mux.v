//================================================================================
// Created by         : Ltd.com
// Filename           : apb_mux.v
// Author             : Python_Wang
// Created On         : 2009-06-09 15:11
// Last Modified      : 2009-06-09 15:20
// Description        : 
//                      
//                      
//================================================================================
module apb_mux(
input        PCLK            , //clock
input        PRST_N          , //reset
input  [15:0]PSEL            , 
input  [31:0]S0_PRDATA       ,
input  [31:0]S1_PRDATA       ,
input  [31:0]S2_PRDATA       ,
input  [31:0]S3_PRDATA       ,
input  [31:0]S4_PRDATA       ,
input  [31:0]S5_PRDATA       ,
input  [31:0]S6_PRDATA       ,
input  [31:0]S7_PRDATA       ,
input  [31:0]S8_PRDATA       ,
input  [31:0]S9_PRDATA       ,
input  [31:0]S10_PRDATA      ,
input  [31:0]S11_PRDATA      ,
input  [31:0]S12_PRDATA      ,
input  [31:0]S13_PRDATA      ,
input  [31:0]S14_PRDATA      ,
input  [31:0]S15_PRDATA      ,
output [31:0]PRDATA           
);

reg    [31:0]iPRDATA         ;

always @(*)
begin
  case(PSEL)
    16'b0000_0000_0000_0001 :  iPRDATA =  S0_PRDATA  ;
    16'b0000_0000_0000_0010 :  iPRDATA =  S1_PRDATA  ;
    16'b0000_0000_0000_0100 :  iPRDATA =  S2_PRDATA  ;
    16'b0000_0000_0000_1000 :  iPRDATA =  S3_PRDATA  ;
    16'b0000_0000_0001_0000 :  iPRDATA =  S4_PRDATA  ;
    16'b0000_0000_0010_0000 :  iPRDATA =  S5_PRDATA  ;
    16'b0000_0000_0100_0000 :  iPRDATA =  S6_PRDATA  ;
    16'b0000_0000_1000_0000 :  iPRDATA =  S7_PRDATA  ;
    16'b0000_0001_0000_0000 :  iPRDATA =  S8_PRDATA  ;
    16'b0000_0010_0000_0000 :  iPRDATA =  S9_PRDATA  ;
    16'b0000_0100_0000_0000 :  iPRDATA =  S10_PRDATA ;
    16'b0000_1000_0000_0000 :  iPRDATA =  S11_PRDATA ;
    16'b0001_0000_0000_0000 :  iPRDATA =  S12_PRDATA ;
    16'b0010_0000_0000_0000 :  iPRDATA =  S13_PRDATA ;
    16'b0100_0000_0000_0000 :  iPRDATA =  S14_PRDATA ;
    16'b1000_0000_0000_0000 :  iPRDATA =  S15_PRDATA ;
    default                 :  iPRDATA =  32'b0     ;
  endcase
end

assign  PRDATA = iPRDATA ;
endmodule
