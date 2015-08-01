//================================================================================
// Created by         : Ltd.com
// Filename           : apbslaver.v
// Author             : Python_Wang
// Created On         : 2009-06-09 14:52
// Last Modified      : 2009-06-09 15:56
// Description        : for sim
//                      
//                      
//================================================================================
module apbslaver(
input        PCLK            , //clock
input        PRST_N          , //reset
input        PSEL            , 
input        PENABLE         ,
input        PWRITE          ,
input  [31:0]PADDR           ,
input  [31:0]PWDATA          ,
output [31:0]PRDATA          
);
reg    [31:0]iPRDATA         ;

reg    [31:0]mem[2047:0]     ;
integer      i               ;

always @(posedge PCLK or negedge PRST_N)
begin
  if (!PRST_N) begin
    for(i = 0; i < 2048 ; i = i + 1)
      mem[i] <= #1 32'b0 ;
  end
  else if(PSEL & PENABLE & PWRITE ) begin
    mem[PADDR[10:0]] <= #1 PWDATA ;
  end
end

always @(posedge PCLK or negedge PRST_N)
begin
  if (!PRST_N) begin
    iPRDATA <= #1 32'b0 ;
  end
  else if(PSEL & ~PWRITE) begin
    iPRDATA <= #1 mem[PADDR[10:0]] ;
  end
end

assign PRDATA = iPRDATA ;

endmodule
