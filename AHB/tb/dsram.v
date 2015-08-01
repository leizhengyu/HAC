//================================================================================
// Created by         : Ltd.com
// Filename           : dsram.v
// Author             : Python_Wang
// Created On         : 2009-06-07 18:42
// Last Modified      : 2009-07-18 11:28
// Description        : for sim
//                      
//                      
//================================================================================

module dsram(
CLK                          ,
CEN                          ,
WEN                          ,
WA                           ,
D                            ,
OEN                          ,
RA                           ,
Q
);
parameter  aw = 32 ;
parameter  dw = 8  ;
parameter  depth = 512 ;
input          CLK           ; //clock
input          CEN           ;
input          WEN           ;
input          OEN           ;
input  [aw-1:0]WA            ;
input  [aw-1:0]RA            ;
input  [dw-1:0]D             ;
output [dw-1:0]Q             ;
reg    [dw-1:0]Q             ;

reg    [dw-1:0]m[depth-1:0]  ;
integer        i             ;
initial begin
  for(i=0; i<depth; i=i+1) begin
    m[i] = {dw{1'b0}} ;
  end
end

always@(posedge CLK)
begin
  if(~CEN & ~WEN) begin
    m[WA] <= #1 D ;
    $display("Write Data : %h at Address: %h",D,WA);
  end
end

always@(posedge CLK)
begin
  if(~CEN & ~OEN)
    Q <= #1 m[RA] ;
  else
    Q <= #1 {dw{1'b0}} ;
end


endmodule
