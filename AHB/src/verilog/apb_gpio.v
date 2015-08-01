//================================================================================
// Created by         : Ltd.com
// Filename           : apb_gpio.v
// Author             : Python_Wang
// Created On         : 2009-06-09 23:12
// Last Modified      : 2009-06-10 19:17
// Description        : 
//                      
//                      
//================================================================================
module apb_gpio(
input        PCLK            , //clock
input        PRST_N          , //reset
input        PSEL            , 
input        PENABLE         ,
input        PWRITE          ,
input  [31:0]PADDR           ,
input  [31:0]PWDATA          ,
output [31:0]PRDATA          ,
input  [31:0]GpioIn          ,
output [31:0]GpioOut         ,
output [31:0]GpioOEn         
);
parameter    GPIO_ADDR     = 6'b011000 ;
parameter    GPIO_DIR_ADDR = 6'b011100 ;

reg    [31:0]INREG           ;      
reg    [31:0]OUTREG          ;
reg    [31:0]DIRREG          ;

reg    [31:0]GpioInQ1        ;
reg    [31:0]GpioInQ2        ;

reg    [31:0]iPRDATA         ;



always @(posedge PCLK or negedge PRST_N)
begin
  if (!PRST_N) begin
    GpioInQ1 <= #1 32'b0 ;
    GpioInQ2 <= #1 32'b0 ;
    INREG    <= #1 32'b0 ;
  end
  else begin
    GpioInQ1 <= #1 GpioIn   ;
    GpioInQ2 <= #1 GpioInQ1 ;
    INREG    <= #1 GpioInQ2 ;
  end
end

always @(posedge PCLK or negedge PRST_N)
begin
  if (!PRST_N) begin
    OUTREG <= #1 32'b0  ;
    DIRREG <= #1 32'b0  ;
  end
  else begin
    if(PSEL & PENABLE & PWRITE) begin
      case(PADDR[5:0]) 
	GPIO_ADDR      :  OUTREG <= #1 PWDATA ;
	GPIO_DIR_ADDR  :  DIRREG <= #1 PWDATA ;
      endcase
    end
  end
end

always @(*)
begin
  iPRDATA = 32'b0 ;
  if(PSEL & PENABLE & ~PWRITE)
    iPRDATA = INREG  ;
end

assign GpioOEn = DIRREG ;
assign GpioOut = OUTREG ;
assign PRDATA  = iPRDATA ;

endmodule
