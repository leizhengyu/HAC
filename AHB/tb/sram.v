//================================================================================
// Created by         : Ltd.com
// Filename           : sram.v
// Author             : Python_Wang
// Created On         : 2009-06-07 18:42
// Last Modified      : 2009-06-09 15:00
// Description        : for sim
//                      
//                      
//================================================================================

module sram(
CLK                          ,
CEN                          ,
WEN                          ,
A                            ,
D                            ,
OEN                          ,
Q
);
parameter  aw = 32 ;
parameter  dw = 8  ;
parameter  depth = 512 ;
input          CLK           ; //clock
input          CEN           ;
input          WEN           ;
input          OEN           ;
input  [aw-1:0]A             ;
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
    m[A] <= #1 D ;
    $display("Write Data : %h at Address: %h",D,A);
  end
end

always@(posedge CLK)
begin
  if(~CEN & ~OEN)
    Q <= #1 m[A] ;
  else
    Q <= #1 {dw{1'b0}} ;
end


endmodule
