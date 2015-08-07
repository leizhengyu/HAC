//================================================================================
// Created by         : Ltd.com
// Filename           : ahb_duart.v
// Author             : Python_Wang
// Created On         : 2009-06-01 11:07
// Last Modified      : 2009-06-09 23:01
// Description        : 
//                      
//                      
//================================================================================
module AHB_DUART(
input         CLK             , //clock
input         RST_N           , //reset
//ahb
input         HGRANT          ,
input         HREADY          ,
input  [ 1:0] HRESP           ,
input  [31:0] HRDATA          ,
output        HBUSREQ         ,
output        HLOCK           ,
output [31:0] HADDR           ,
output [ 1:0] HTRANS          ,
output [ 2:0] HBURST          ,
output [ 2:0] HSIZE           ,
output        HWRITE          ,
output [ 3:0] HPROT           ,
output [31:0] HWDATA          ,
//apb
input         PCLK            , //clock
input         PRST_N          , //reset
input         PSEL            , 
input         PENABLE         ,
input         PWRITE          ,
input  [31:0] PADDR           ,
input  [31:0] PWDATA          ,
output [31:0] PRDATA          ,
//uart
input         Rxd             ,
output        Txd             
);
parameter     STATUS_ADDR =  6'b100000 ;
parameter     CTRL_ADDR   =  6'b110000 ;

wire          wWrite           ;
wire   [ 7:0] wDataOut         ;
wire          wRead            ;
wire   [ 7:0] wDataIn          ;
wire          wDataReady       ;
wire          wTHEmpty         ;
wire          wAhbReq          ;
wire          wAhbBurst        ;
wire          wAhbBusy         ;
wire          wAhbWrite        ;
wire   [ 2:0] wAhbSize         ;
wire   [31:0] wAhbAddr         ;
wire   [31:0] wAhbOut          ;
wire   [31:0] wAhbIn           ;
wire          wActive          ;
wire          wOkay            ; 

AHB_MST U_AHB_MST(
    .HCLK         (CLK         )    , //clock
    .HRST_N       (RST_N       )    , //reset
    .HGRANT       (HGRANT      )    ,
    .HREADY       (HREADY      )    ,
    .HRESP        (HRESP       )    ,
    .HRDATA       (HRDATA      )    ,
    .HBUSREQ      (HBUSREQ     )    ,
    .HLOCK        (HLOCK       )    ,
    .HADDR        (HADDR       )    ,
    .HTRANS       (HTRANS      )    ,
    .HBURST       (HBURST      )    ,
    .HSIZE        (HSIZE       )    ,
    .HWRITE       (HWRITE      )    ,
    .HPROT        (HPROT       )    ,
    .HWDATA       (HWDATA      )    ,
    .Request      (wAhbReq     )    ,
    .Burst        (wAhbBurst   )    ,
    .Busy         (wAhbBusy    )    ,
    .Write        (wAhbWrite   )    ,
    .Size         (wAhbSize    )    ,
    .Addr         (wAhbAddr    )    ,
    .DataIn       (wAhbOut     )    ,
    .DataOut      (wAhbIn      )    ,
    .Grant        (            )    ,
    .Okay         (wOkay       )    ,
    .Retry        (            )     
    );

DCOM U_DCOM(
    .CLK          (CLK         )   , 
    .RST_N        (RST_N       )   , 
    .Write        (wWrite      )   ,
    .DataOut      (wDataOut    )   ,
    .Read         (wRead       )   ,
    .DataIn       (wDataIn     )   ,
    .DataReady    (wDataReady  )   ,
    .THEmpty      (wTHEmpty    )   ,
    .AhbReq       (wAhbReq     )   ,
    .AhbBurst     (wAhbBurst   )   ,
    .AhbBusy      (wAhbBusy    )   ,
    .AhbWrite     (wAhbWrite   )   ,
    .AhbSize      (wAhbSize    )   ,
    .AhbAddr      (wAhbAddr    )   ,
    .AhbOut       (wAhbOut     )   ,
    .AhbIn        (wAhbIn      )   ,
    .Okay         (wOkay       )     
    );

DCOM_UART #(
    .CTRL_ADDR (CTRL_ADDR),
    .STATUS_ADDR (STATUS_ADDR)
    ) U_DCOM_UART (
    .PCLK         (CLK         )     , 
    .PRST_N       (RST_N       )     , 
    .PSEL         (PSEL        )     , 
    .PENABLE      (PENABLE     )     ,
    .PWRITE       (PWRITE      )     ,
    .PADDR        (PADDR       )     ,
    .PWDATA       (PWDATA      )     ,
    .PRDATA       (PRDATA      )     ,
    .Read         (wRead       )     ,
    .Write        (wWrite      )     ,
    .DataIn       (wDataOut    )     ,
    .DataReady    (wDataReady  )     ,
    .DataOut      (wDataIn     )     ,
    .THEmpty      (wTHEmpty    )     ,
    .Rxd          (Rxd         )     ,
    .Txd          (Txd         )     
    );

endmodule 






