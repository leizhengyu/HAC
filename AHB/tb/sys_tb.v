//================================================================================
// Created by         : Ltd.com
// Filename           : sys_tb.v
// Author             : Python_Wang
// Created On         : 2009-06-04 18:54
// Last Modified      : 2009-07-23 21:04
// Description        : for sim
//                      
//                      
//================================================================================

module sys_tb ;
parameter    P = 7          ;
reg          hclk            ;
reg          hrst_n          ;

initial begin
  hclk   = 1'b1 ;
  hrst_n = 1'b1 ;
  #3  
  hrst_n = 1'b0 ;
  #33 
  hrst_n = 1'b1 ;
end

always #(P/2) hclk = ~hclk   ;
////////////////////////////////////////////////
//to slaver
wire   [15:0]wHSEL           ;
wire   [ 3:0]wHMASTER        ;
wire         wHMASTERLOCK    ;
wire   [31:0]wHADDR          ;
wire   [ 2:0]wHSIZE          ;
wire         wHWRITE         ;
wire   [ 1:0]wHTRANS         ;
wire   [ 2:0]wHBURST         ;
wire   [ 3:0]wHPROT          ;
wire   [31:0]wHWDATA         ;
//to master
wire   [15:0]wHGRANT         ;
wire   [ 1:0]wHRESP          ;
wire   [15:0]wHSPLIT         ;
wire   [31:0]wHRDATA         ;
//to both
wire         wHREADY         ;
//to apb slaver
wire   [31:0]wPADDR          ;
wire   [31:0]wPWDATA         ;
wire         wPENABLE        ;
wire         wPWRITE         ;
wire   [15:0]wPSEL           ;
wire   [31:0]wPRDATA         ;
//////////////////////////////////////////
wire         wRxd            ;
wire         wTxd            ;
//////////////////////////////////////////
wire   [31:0]s0_PRDATA       ;
wire   [31:0]s1_PRDATA       ;
wire   [31:0]s2_PRDATA       ;
wire   [31:0]s3_PRDATA       ;
wire   [31:0]s4_PRDATA       ;
wire   [31:0]s5_PRDATA       ;
wire   [31:0]s6_PRDATA       ;
wire   [31:0]s7_PRDATA       ;
wire   [31:0]s8_PRDATA       ;
wire   [31:0]s9_PRDATA       ;
wire   [31:0]s10_PRDATA      ;
wire   [31:0]s11_PRDATA      ;
wire   [31:0]s12_PRDATA      ;
wire   [31:0]s13_PRDATA      ;
wire   [31:0]s14_PRDATA      ;
wire   [31:0]s15_PRDATA      ; 

////////////////////////////////////////////////
wire         m0_Request      ;
wire         m0_Lock         ;
wire         m0_Burst        ;
wire         m0_Busy         ;
wire         m0_Write        ;
wire   [ 2:0]m0_Beat         ;
wire   [ 2:0]m0_Size         ;
wire   [31:0]m0_Addr         ;
wire   [31:0]m0_DataIn       ;
wire   [31:0]m0_DataOut      ;
wire         m0_DataReady    ;
wire         m0_Grant        ;
wire         m0_Okay         ;
wire         m0_Error        ;
wire         m0_Retry        ;
wire         m0_HBUSREQ      ;
wire         m0_HLOCK        ;
wire   [31:0]m0_HADDR        ;
wire   [ 1:0]m0_HTRANS       ;
wire   [ 2:0]m0_HBURST       ;
wire   [ 2:0]m0_HSIZE        ;
wire         m0_HWRITE       ;
wire   [ 3:0]m0_HPROT        ;
wire   [31:0]m0_HWDATA       ;

reg          m0_Start        ;
reg    [ 2:0]m0_WRSize       ;
reg          m0_WR           ;
reg    [31:0]m0_WRAddr       ;
reg    [ 9:0]m0_WRLen        ;
reg          m0_WRBurst      ;
reg    [31:0]m0_Din          ;      
wire         m0_ReadEn       ;
wire         m0_DoutVld      ;
wire   [31:0]m0_Dout         ;
wire         m0_Done         ;

mst_if mst0 (
.CLK        (hclk         )     , //clock
.RST_N      (hrst_n       )     , //reset
.Start      (m0_Start     )     ,
.WRSize     (m0_WRSize    )     ,
.WR         (m0_WR        )     ,
.WRAddr     (m0_WRAddr    )     ,
.WRLen      (m0_WRLen     )     ,
.WRBurst    (m0_WRBurst   )     ,
.ReadEn     (m0_ReadEn    )     ,
.Din        (m0_Din       )     ,      
.DoutVld    (m0_DoutVld   )     ,
.Dout       (m0_Dout      )     ,
.Done       (m0_Done      )     ,
.Request    (m0_Request   )     ,
.Addr       (m0_Addr      )     ,
.Size       (m0_Size      )     ,
.Write      (m0_Write     )     ,
.Burst      (m0_Burst     )     ,
.Busy       (m0_Busy      )     ,
.DataIn     (m0_DataIn    )     ,
.DataOut    (m0_DataOut   )     ,
.Grant      (m0_Grant     )     ,
.Okay       (m0_Okay      )     ,
.Retry      (m0_Retry     )      
);


ahb_mst dma0(
.HCLK       (hclk         )     , //clock
.HRST_N     (hrst_n       )     , //reset
.HGRANT     (wHGRANT[0]   )     ,
.HREADY     (wHREADY      )     ,
.HRESP      (wHRESP       )     ,
.HRDATA     (wHRDATA      )     ,
.HBUSREQ    (m0_HBUSREQ   )     ,
.HLOCK      (m0_HLOCK     )     ,
.HADDR      (m0_HADDR     )     ,
.HTRANS     (m0_HTRANS    )     ,
.HBURST     (m0_HBURST    )     ,
.HSIZE      (m0_HSIZE     )     ,
.HWRITE     (m0_HWRITE    )     ,
.HPROT      (m0_HPROT     )     ,
.HWDATA     (m0_HWDATA    )     ,
.Request    (m0_Request   )     ,
.Burst      (m0_Burst     )     ,
.Busy       (m0_Busy      )     ,
.Write      (m0_Write     )     ,
.Size       (m0_Size      )     ,
.Addr       (m0_Addr      )     ,
.DataIn     (m0_DataIn    )     ,
.DataOut    (m0_DataOut   )     ,
.Grant      (m0_Grant     )     ,
.Okay       (m0_Okay      )     ,
.Retry      (m0_Retry     )      
);
////////////////////////////////////////////////
wire         m1_Request      ;
wire         m1_Lock         ;
wire         m1_Burst        ;
wire         m1_Busy         ;
wire         m1_Write        ;
wire   [ 2:0]m1_Beat         ;
wire   [ 2:0]m1_Size         ;
wire   [31:0]m1_Addr         ;
wire   [31:0]m1_DataIn       ;
wire   [31:0]m1_DataOut      ;
wire         m1_DataReady    ;
wire         m1_Grant        ;
wire         m1_Okay         ;
wire         m1_Error        ;
wire         m1_Retry        ;
wire         m1_HBUSREQ      ;
wire         m1_HLOCK        ;
wire   [31:0]m1_HADDR        ;
wire   [ 1:0]m1_HTRANS       ;
wire   [ 2:0]m1_HBURST       ;
wire   [ 2:0]m1_HSIZE        ;
wire         m1_HWRITE       ;
wire   [ 3:0]m1_HPROT        ;
wire   [31:0]m1_HWDATA       ;

wire         m1_DmaBusy      ;
wire         m1_DmaLock      ;
wire         m1_Start        ;
wire   [ 2:0]m1_WRSize       ;
wire         m1_WR           ;
wire   [31:0]m1_WRAddr       ;
wire   [ 9:0]m1_WRLen        ;
wire         m1_WRBurst      ;
wire   [31:0]m1_Din          ;
wire         m1_ReadEn       ;
wire         m1_DoutVld      ;
wire   [31:0]m1_Dout         ;
wire         m1_Done         ;

//dmaif #(.BURST   (1'b1),
//        .ADDRESS (32'hFB_00_11_00),
//	.DATA    (32'hBB_00_11_00),
//	.BEAT    (3'd2)  ,
//        .LENGTH  (11'd7)
//       ) mst1(
//.CLK        (hclk         )    , //clock
//.RST_N      (hrst_n       )    , //reset
//.Request    (m1_Request   )    ,
//.Lock       (m1_Lock      )    ,
//.Burst      (m1_Burst     )    ,
//.Busy       (m1_Busy      )    ,
//.Write      (m1_Write     )    ,
//.Beat       (m1_Beat      )    ,
//.Size       (m1_Size      )    ,
//.Addr       (m1_Addr      )    ,
//.DataIn     (m1_DataIn    )    ,
//.DataOut    (m1_DataOut   )    ,
//.DataReady  (m1_DataReady )    ,
//.Grant      (m1_Grant     )    ,
//.Okay       (m1_Okay      )    ,
//.Error      (m1_Error     )    ,
//.Retry      (m1_Retry     )     
//);
//
//
ahb_dma #(
.SIMPLE_DMA_CTRL_ADDR1(`AHB_SIMPLE_DMA_CTRL_ADDR1), 
.SIMPLE_DMA_CTRL_ADDR2(`AHB_SIMPLE_DMA_CTRL_ADDR2), 
.SIMPLE_DMA_CTRL_ADDR3(`AHB_SIMPLE_DMA_CTRL_ADDR3) 
) dma_ctrl (
.CLk          (hclk         )   , //clock
.RST_N        (hrst_n       )   , //reset
//
.PSEL         (wPSEL[5]     )   , 
.PENABLE      (wPENABLE     )   ,
.PWRITE       (wPWRITE      )   ,
.PADDR        (wPADDR       )   ,
.PWDATA       (wPWDATA      )   ,
.PRDATA       (s5_PRDATA    )   ,
//
.DmaBusy      (m1_DmaBusy   )   ,
.DmaLock      (m1_DmaLock   )   ,
.Start        (m1_Start     )   ,
.WRSize       (m1_WRSize    )   ,
.WR           (m1_WR        )   ,
.WRAddr       (m1_WRAddr    )   ,
.WRLen        (m1_WRLen     )   ,
.WRBurst      (m1_WRBurst   )   ,
.Din          (m1_Din       )   ,      
.ReadEn       (m1_ReadEn    )   ,
.DoutVld      (m1_DoutVld   )   ,
.Dout         (m1_Dout      )   ,
.Done         (m1_Done      )   
);

dma_if u_dma_if (
.CLK        (hclk         )     ,
.RST_N      (hrst_n       )     ,
//
.DmaBusy    (m1_DmaBusy   )  ,
.DmaLock    (m1_DmaLock   )  ,
.Start      (m1_Start     )  ,
.WRSize     (m1_WRSize    )  ,
.WR         (m1_WR        )  ,
.WRAddr     (m1_WRAddr    )  ,
.WRLen      (m1_WRLen     )  ,
.WRBurst    (m1_WRBurst   )  ,
.Din        (m1_Din       )  ,      
.ReadEn     (m1_ReadEn    )  ,
.DoutVld    (m1_DoutVld   )  ,
.Dout       (m1_Dout      )  ,
.Done       (m1_Done      )  ,
//
.Lock       (m1_Lock      )     ,
.Busy       (m1_Busy      )     ,
.Request    (m1_Request   )     ,
.Addr       (m1_Addr      )     ,
.Size       (m1_Size      )     ,
.Write      (m1_Write     )     ,
.Burst      (m1_Burst     )     ,
.Beat       (m1_Beat      )     ,
.DataIn     (m1_DataIn    )     ,
.DataOut    (m1_DataOut   )     ,
.DataReady  (m1_DataReady )     ,
.Grant      (m1_Grant     )     ,
.Okay       (m1_Okay      )     ,
.Error      (m1_Error     )     ,
.Retry      (m1_Retry     )      
);



dma2ahb dma1(
.HCLK       (hclk         )     , //clock
.HRST_N     (hrst_n       )     , //reset
.HGRANT     (wHGRANT[1]   )     ,
.HREADY     (wHREADY      )     ,
.HRESP      (wHRESP       )     ,
.HRDATA     (wHRDATA      )     ,
.HBUSREQ    (m1_HBUSREQ   )     ,
.HLOCK      (m1_HLOCK     )     ,
.HADDR      (m1_HADDR     )     ,
.HTRANS     (m1_HTRANS    )     ,
.HBURST     (m1_HBURST    )     ,
.HSIZE      (m1_HSIZE     )     ,
.HWRITE     (m1_HWRITE    )     ,
.HPROT      (m1_HPROT     )     ,
.HWDATA     (m1_HWDATA    )     ,
.Request    (m1_Request   )     ,
.Lock       (m1_Lock      )     ,
.Burst      (m1_Burst     )     ,
.Busy       (m1_Busy      )     ,
.Write      (m1_Write     )     ,
.Beat       (m1_Beat      )     ,
.Size       (m1_Size      )     ,
.Addr       (m1_Addr      )     ,
.DataIn     (m1_DataIn    )     ,
.DataOut    (m1_DataOut   )     ,
.DataReady  (m1_DataReady )     ,
.Grant      (m1_Grant     )     ,
.Okay       (m1_Okay      )     ,
.Error      (m1_Error     )     ,
.Retry      (m1_Retry     )      
);

////////////////////////////////////////////////
wire         m2_Request      ;
wire         m2_Lock         ;
wire         m2_Burst        ;
wire         m2_Busy         ;
wire         m2_Write        ;
wire   [ 2:0]m2_Beat         ;
wire   [ 2:0]m2_Size         ;
wire   [31:0]m2_Addr         ;
wire   [31:0]m2_DataIn       ;
wire   [31:0]m2_DataOut      ;
wire         m2_DataReady    ;
wire         m2_Grant        ;
wire         m2_Okay         ;
wire         m2_Error        ;
wire         m2_Retry        ;
wire         m2_HBUSREQ      ;
wire         m2_HLOCK        ;
wire   [31:0]m2_HADDR        ;
wire   [ 1:0]m2_HTRANS       ;
wire   [ 2:0]m2_HBURST       ;
wire   [ 2:0]m2_HSIZE        ;
wire         m2_HWRITE       ;
wire   [ 3:0]m2_HPROT        ;
wire   [31:0]m2_HWDATA       ;

reg          m2_Start        ;
reg    [ 2:0]m2_WRSize       ;
reg          m2_WR           ;
reg    [31:0]m2_WRAddr       ;
reg    [ 9:0]m2_WRLen        ;
reg          m2_WRBurst      ;
reg    [31:0]m2_Din          ;      
wire         m2_ReadEn       ;
wire         m2_DoutVld      ;
wire   [31:0]m2_Dout         ;
wire         m2_Done         ;

mst_if mst2 (
.CLK        (hclk         )     , //clock
.RST_N      (hrst_n       )     , //reset
.Start      (m2_Start     )     ,
.WRSize     (m2_WRSize    )     ,
.WR         (m2_WR        )     ,
.WRAddr     (m2_WRAddr    )     ,
.WRLen      (m2_WRLen     )     ,
.WRBurst    (m2_WRBurst   )     ,
.ReadEn     (m2_ReadEn    )     ,
.Din        (m2_Din       )     ,      
.DoutVld    (m2_DoutVld   )     ,
.Dout       (m2_Dout      )     ,
.Done       (m2_Done      )     ,
.Request    (m2_Request   )     ,
.Addr       (m2_Addr      )     ,
.Size       (m2_Size      )     ,
.Write      (m2_Write     )     ,
.Burst      (m2_Burst     )     ,
.Busy       (m2_Busy      )     ,
.DataIn     (m2_DataIn    )     ,
.DataOut    (m2_DataOut   )     ,
.Grant      (m2_Grant     )     ,
.Okay       (m2_Okay      )     ,
.Retry      (m2_Retry     )      
);

ahb_mst dma2(
.HCLK       (hclk         )     , //clock
.HRST_N     (hrst_n       )     , //reset
.HGRANT     (wHGRANT[2]   )     ,
.HREADY     (wHREADY      )     ,
.HRESP      (wHRESP       )     ,
.HRDATA     (wHRDATA      )     ,
.HBUSREQ    (m2_HBUSREQ   )     ,
.HLOCK      (m2_HLOCK     )     ,
.HADDR      (m2_HADDR     )     ,
.HTRANS     (m2_HTRANS    )     ,
.HBURST     (m2_HBURST    )     ,
.HSIZE      (m2_HSIZE     )     ,
.HWRITE     (m2_HWRITE    )     ,
.HPROT      (m2_HPROT     )     ,
.HWDATA     (m2_HWDATA    )     ,
.Request    (m2_Request   )     ,
.Burst      (m2_Burst     )     ,
.Busy       (m2_Busy      )     ,
.Write      (m2_Write     )     ,
.Size       (m2_Size      )     ,
.Addr       (m2_Addr      )     ,
.DataIn     (m2_DataIn    )     ,
.DataOut    (m2_DataOut   )     ,
.Grant      (m2_Grant     )     ,
.Okay       (m2_Okay      )     ,
.Retry      (m2_Retry     )      
);

////////////////////////////////////////////////
wire         m3_Request      ;
wire         m3_Lock         ;
wire         m3_Burst        ;
wire         m3_Busy         ;
wire         m3_Write        ;
wire   [ 2:0]m3_Beat         ;
wire   [ 2:0]m3_Size         ;
wire   [31:0]m3_Addr         ;
wire   [31:0]m3_DataIn       ;
wire   [31:0]m3_DataOut      ;
wire         m3_DataReady    ;
wire         m3_Grant        ;
wire         m3_Okay         ;
wire         m3_Error        ;
wire         m3_Retry        ;
wire         m3_HBUSREQ      ;
wire         m3_HLOCK        ;
wire   [31:0]m3_HADDR        ;
wire   [ 1:0]m3_HTRANS       ;
wire   [ 2:0]m3_HBURST       ;
wire   [ 2:0]m3_HSIZE        ;
wire         m3_HWRITE       ;
wire   [ 3:0]m3_HPROT        ;
wire   [31:0]m3_HWDATA       ;

ahb_duart #(
.STATUS_ADDR (`AHB_DUART_STATUS_ADDR) ,
.CTRL_ADDR   (`AHB_DUART_CTRL_ADDR  ) 
) mst3 (
.CLK         (hclk         )    , //clock
.RST_N       (hrst_n       )    , //reset
.HGRANT      (wHGRANT[3]   )    ,
.HREADY      (wHREADY      )    ,
.HRESP       (wHRESP       )    ,
.HRDATA      (wHRDATA      )    ,
.HBUSREQ     (m3_HBUSREQ   )    ,
.HLOCK       (m3_HLOCK     )    ,
.HADDR       (m3_HADDR     )    ,
.HTRANS      (m3_HTRANS    )    ,
.HBURST      (m3_HBURST    )    ,
.HSIZE       (m3_HSIZE     )    ,
.HWRITE      (m3_HWRITE    )    ,
.HPROT       (m3_HPROT     )    ,
.HWDATA      (m3_HWDATA    )    ,
.PCLK        (hclk         )    , //clock
.PRST_N      (hrst_n       )    , //reset
.PSEL        (wPSEL[4]     )    , 
.PENABLE     (wPENABLE     )    ,
.PWRITE      (wPWRITE      )    ,
.PADDR       (wPADDR       )    ,
.PWDATA      (wPWDATA      )    ,
.PRDATA      (s4_PRDATA    )    ,
.Rxd         (wRxd         )    ,
.Txd         (wTxd         )    
);


//mstif #(.BURST   (1'b0),
//        .ADDRESS (32'hFD_00_33_00),
//	.DATA    (32'hDD_00_33_00),
//        .LENGTH  (11'd20)
//       ) mst3(
//.CLK        (hclk         )    , //clock
//.RST_N      (hrst_n       )    , //reset
//.Request    (m3_Request   )    ,
//.Burst      (m3_Burst     )    ,
//.Busy       (m3_Busy      )    ,
//.Write      (m3_Write     )    ,
//.Size       (m3_Size      )    ,
//.Addr       (m3_Addr      )    ,
//.DataIn     (m3_DataIn    )    ,
//.DataOut    (m3_DataOut   )    ,
//.Active     (m3_Grant     )    ,
//.Okay       (m3_Okay      )    ,
//.Retry      (m3_Retry     )     
//);
//
//ahb_mst dma3(
//.HCLK       (hclk         )     , //clock
//.HRST_N     (hrst_n       )     , //reset
//.HGRANT     (wHGRANT[3]   )     ,
//.HREADY     (wHREADY      )     ,
//.HRESP      (wHRESP       )     ,
//.HRDATA     (wHRDATA      )     ,
//.HBUSREQ    (m3_HBUSREQ   )     ,
//.HLOCK      (m3_HLOCK     )     ,
//.HADDR      (m3_HADDR     )     ,
//.HTRANS     (m3_HTRANS    )     ,
//.HBURST     (m3_HBURST    )     ,
//.HSIZE      (m3_HSIZE     )     ,
//.HWRITE     (m3_HWRITE    )     ,
//.HPROT      (m3_HPROT     )     ,
//.HWDATA     (m3_HWDATA    )     ,
//.Request    (m3_Request   )     ,
//.Burst      (m3_Burst     )     ,
//.Busy       (m3_Busy      )     ,
//.Write      (m3_Write     )     ,
//.Size       (m3_Size      )     ,
//.Addr       (m3_Addr      )     ,
//.DataIn     (m3_DataIn    )     ,
//.DataOut    (m3_DataOut   )     ,
//.Grant      (m3_Grant     )     ,
//.Okay       (m3_Okay      )     ,
//.Retry      (m3_Retry     )      
//);
//
/////////////////////////////////////////
wire         s0_HREADY       ;
wire   [ 1:0]s0_HRESP        ;
wire   [31:0]s0_HRDATA       ;
wire   [15:0]s0_HSPLIT       ;

//assign       s0_HREADY    =  1'b1   ;
//assign       s0_HRESP     =  2'b0   ;
//assign       s0_HSPLIT    = 16'b0   ;
//assign       s0_HRDATA    = 32'b0   ;

ahb_sram  slv0 (
.HCLK      (hclk        )   ,
.HRST_N    (hrst_n      )   ,
.HSEL      (wHSEL[0]    )   ,
.HREADY    (wHREADY     )   ,
.HADDR     (wHADDR      )   ,
.HSIZE     (wHSIZE      )   ,
.HWRITE    (wHWRITE     )   ,
.HTRANS    (wHTRANS     )   ,
.HBURST    (wHBURST     )   ,
.HWDATA    (wHWDATA     )   ,
.HREADY_O  (s0_HREADY   )   ,
.HRESP     (s0_HRESP    )   ,
.HRDATA    (s0_HRDATA   )   ,
.HSPLIT    (s0_HSPLIT   )   
);

/////////////////////////////////////////
wire         s1_HREADY       ;
wire   [ 1:0]s1_HRESP        ;
wire   [15:0]s1_HSPLIT       ;
wire   [31:0]s1_HRDATA       ;

//assign       s1_HREADY    =  1'b1   ;
//assign       s1_HRESP     =  2'b0   ;
//assign       s1_HSPLIT    = 16'b0   ;
//assign       s1_HRDATA    = 32'b0   ;
slaver slv1 (
.HCLK      (hclk        )    ,
.HRST_N    (hrst_n      )    ,
.HSEL      (wHSEL[1]    )    ,
.HREADY    (wHREADY     )    ,
.HADDR     (wHADDR      )    ,
.HSIZE     (wHSIZE      )    ,
.HWRITE    (wHWRITE     )    ,
.HTRANS    (wHTRANS     )    ,
.HBURST    (wHBURST     )    ,
.HWDATA    (wHWDATA     )    ,
.HREADY_O  (s1_HREADY   )    ,
.HRESP     (s1_HRESP    )    ,
.HRDATA    (s1_HRDATA   )    ,
.HSPLIT    (s1_HSPLIT   )    
);
/////////////////////////////////////////
wire         s2_HREADY       ;
wire   [ 1:0]s2_HRESP        ;
wire   [15:0]s2_HSPLIT       ;
wire   [31:0]s2_HRDATA       ;

//assign       s2_HREADY    =  1'b1   ;
//assign       s2_HRESP     =  2'b0   ;
//assign       s2_HSPLIT    = 16'b0   ;
//assign       s2_HRDATA    = 32'b0   ;

ahb_sram  slv2 (
.HCLK      (hclk        )   ,
.HRST_N    (hrst_n      )   ,
.HSEL      (wHSEL[2]    )   ,
.HREADY    (wHREADY     )   ,
.HADDR     (wHADDR      )   ,
.HSIZE     (wHSIZE      )   ,
.HWRITE    (wHWRITE     )   ,
.HTRANS    (wHTRANS     )   ,
.HBURST    (wHBURST     )   ,
.HWDATA    (wHWDATA     )   ,
.HREADY_O  (s2_HREADY   )   ,
.HRESP     (s2_HRESP    )   ,
.HRDATA    (s2_HRDATA   )   ,
.HSPLIT    (s2_HSPLIT   )   
);

/////////////////////////////////////////
wire         s3_HREADY       ;
wire   [ 1:0]s3_HRESP        ;
wire   [15:0]s3_HSPLIT       ;
wire   [31:0]s3_HRDATA       ;

//assign       s3_HREADY    =  1'b1   ;
//assign       s3_HRESP     =  2'b0   ;
//assign       s3_HSPLIT    = 16'b0   ;
//assign       s3_HRDATA    = 32'b0   ;

ahb2apb slv3(
.HCLK      (hclk        )   ,
.HRST_N    (hrst_n      )   ,
.HSEL      (wHSEL[3]    )   ,
.HADDR     (wHADDR      )   ,
.HWRITE    (wHWRITE     )   ,
.HTRANS    (wHTRANS     )   ,
.HWDATA    (wHWDATA     )   ,
.HREADY    (wHREADY     )   ,
.HREADY_o  (s3_HREADY   )   ,
.HRESP     (s3_HRESP    )   ,
.HSPLIT    (s3_HSPLIT   )   ,
.HRDATA    (s3_HRDATA   )   ,
.PSEL      (wPSEL       )   ,
.PENABLE   (wPENABLE    )   ,
.PADDR     (wPADDR      )   ,
.PWRITE    (wPWRITE     )   ,
.PWDATA    (wPWDATA     )   ,
.PRDATA    (wPRDATA     ) 
);
////////////////////////////////////////

apb_mux  u_apb_mux (
.PCLK      (hclk        )     , //clock
.PRST_N    (hrst_n      )     , //reset
.PSEL      (wPSEL       )     , 
.S0_PRDATA (s0_PRDATA   )     ,
.S1_PRDATA (s1_PRDATA   )     ,
.S2_PRDATA (s2_PRDATA   )     ,
.S3_PRDATA (s3_PRDATA   )     ,
.S4_PRDATA (s4_PRDATA   )     ,
.S5_PRDATA (s5_PRDATA   )     ,
.S6_PRDATA (s6_PRDATA   )     ,
.S7_PRDATA (s7_PRDATA   )     ,
.S8_PRDATA (s8_PRDATA   )     ,
.S9_PRDATA (s9_PRDATA   )     ,
.S10_PRDATA(s10_PRDATA  )     ,
.S11_PRDATA(s11_PRDATA  )     ,
.S12_PRDATA(s12_PRDATA  )     ,
.S13_PRDATA(s13_PRDATA  )     ,
.S14_PRDATA(s14_PRDATA  )     ,
.S15_PRDATA(s15_PRDATA  )     ,
.PRDATA    (wPRDATA     )      
);
/////////////////////////////////////////
//apb slv0 
wire [31:0]GpioIn       ; 
wire [31:0]GpioOut      ; 
wire [31:0]GpioOEn      ; 
reg  [31:0]Gpio         ;
integer    r            ;

always@(*)
begin
  for(r = 0; r < 32 ; r = r + 1) begin
    Gpio[r] = GpioOEn[r] ? GpioOut[r] : 1'bz ;
  end
end

assign GpioIn = Gpio    ;

apb_gpio #(
.GPIO_ADDR    (`APB_GPIO_ADDR    ), 
.GPIO_DIR_ADDR(`APB_GPIO_DIR_ADDR) 
) apb_slv0 (
.PCLK      (hclk        )      , //clock
.PRST_N    (hrst_n      )      , //reset
.PSEL      (wPSEL[0]    )      , 
.PENABLE   (wPENABLE    )      ,
.PWRITE    (wPWRITE     )      ,
.PADDR     (wPADDR      )      ,
.PWDATA    (wPWDATA     )      ,
.PRDATA    (s0_PRDATA   )      ,
.GpioIn    (GpioIn      )      ,
.GpioOut   (GpioOut     )      ,
.GpioOEn   (GpioOEn     )      
);
//apb slv1
apbslaver apb_slv1 (
.PCLK      (hclk        )      , //clock
.PRST_N    (hrst_n      )      , //reset
.PSEL      (wPSEL[1]    )      , 
.PENABLE   (wPENABLE    )      ,
.PWRITE    (wPWRITE     )      ,
.PADDR     (wPADDR      )      ,
.PWDATA    (wPWDATA     )      ,
.PRDATA    (s1_PRDATA   )      
);
//apb slv2
wire         wRT             ;
wire         apb2_IRQ        ;
apb_uart #(
.CTRL_ADDR  (`APB_UART_CTRL_ADDR  ),
.STATUS_ADDR(`APB_UART_STATUS_ADDR),
.SCALER_ADDR(`APB_UART_SCALER_ADDR),
.RHOLD_ADDR (`APB_UART_RHOLD_ADDR ),
.THOLD_ADDR (`APB_UART_THOLD_ADDR )
) apb_slv2 (
.PCLK      (hclk        )    , //clock
.PRST_N    (hrst_n      )    , //reset
.PSEL      (wPSEL[2]    )    , 
.PENABLE   (wPENABLE    )    ,
.PWRITE    (wPWRITE     )    ,
.PADDR     (wPADDR      )    ,
.PWDATA    (wPWDATA     )    ,
.PRDATA    (s2_PRDATA   )    ,
.IRQ       (apb2_IRQ    )    ,
.ExtClk_i  (1'b0        )    ,
`ifdef APB_UART_SELF_TEST
.Rxd_i     (wRT         )    ,
.Txd_o     (wRT         )    
`endif
.Rxd_i     (wTxd        )    ,
.Txd_o     (wRxd        )    
);
/////////////////////////////////////////
wire         s4_HREADY       ;
wire   [ 1:0]s4_HRESP        ;
wire   [15:0]s4_HSPLIT       ;
wire   [31:0]s4_HRDATA       ;

//assign       s4_HREADY    =  1'b1   ;
//assign       s4_HRESP     =  2'b0   ;
//assign       s4_HSPLIT    = 16'b0   ;
//assign       s4_HRDATA    = 32'b0   ;

wire         wMISO           ;
wire         wMOSI           ;
wire         wSCK            ;
wire         wCSN            ;
wire         wInitialized    ;
wire         wDone           ;

ahb_spim #(
.CTRL_ADDR   (`AHB_SPIM_CTRL_ADDR   ), 
.tPOWERUP    (`AHB_SPIM_POWERUP     ) 
) slv4 (
.HCLK        (hclk        )   , //clock
.HRST_N      (hrst_n      )   , //reset
.HSEL        (wHSEL[4]    )   ,
.HREADY      (wHREADY     )   ,
.HADDR       (wHADDR      )   ,
.HSIZE       (wHSIZE      )   ,
.HWRITE      (wHWRITE     )   ,
.HTRANS      (wHTRANS     )   ,
.HBURST      (wHBURST     )   ,
.HWDATA      (wHWDATA     )   ,
.HREADY_O    (s4_HREADY   )   ,
.HRESP       (s4_HRESP    )   ,
.HRDATA      (s4_HRDATA   )   ,
.HSPLIT      (s4_HSPLIT   )   ,
.MISO        (wMISO       )   ,
.MOSI        (wMOSI       )   ,
.SCK         (wSCK        )   ,
.CSN         (wCSN        )   ,
.Initialized (wInitialized)   ,
.Done        (wDone       )   
);

s25fl008a u_s25fl008a (
.SCK         (wSCK        )  ,
.SI          (wMOSI       )  ,
.CSNeg       (wCSN        )  ,
.HOLDNeg     (1'b1        )  ,
.WNeg        (1'b0        )  ,
.SO          (wMISO       )   
);

/////////////////////////////////////////
////////////////////////////////////////////
wire         s5_HREADY       ;
wire   [ 1:0]s5_HRESP        ;
wire   [15:0]s5_HSPLIT       ;
wire   [31:0]s5_HRDATA       ;

//assign       s5_HREADY    =  1'b1   ;
//assign       s5_HRESP     =  2'b0   ;
//assign       s5_HSPLIT    = 16'b0   ;
//assign       s5_HRDATA    = 32'b0   ;
wire       wWPROT          ;
wire [31:0]wSDR_DATA_I     ;
wire       wSDR_CKE        ;
wire       wSDR_CS_N       ;
wire       wSDR_WE         ;
wire       wSDR_RAS_N      ;
wire       wSDR_CAS_N      ;
wire [ 3:0]wSDR_DQM        ;
wire [14:0]wSDR_ADDR       ;
wire       wSDR_DATA_O_EN  ;
wire [31:0]wSDR_DATA_O     ;
wire [31:0]wSDR_DATA       ;

assign     wWPROT = 1'b0   ;

assign     wSDR_DATA_I = wSDR_DATA ;

assign      wSDR_DATA   = wSDR_DATA_O_EN ? wSDR_DATA_O : 32'bz ;

ahb_sdrctrl slv5(
.HCLK         (hclk          ),
.HRST_N       (hrst_n        ),
.HSEL         (wHSEL[5]      ),
.HREADY       (wHREADY       ),
.HADDR        (wHADDR        ),
.HSIZE        (wHSIZE        ),
.HWRITE       (wHWRITE       ),
.HTRANS       (wHTRANS       ),
.HBURST       (wHBURST       ),
.HWDATA       (wHWDATA       ),
.HREADY_O     (s5_HREADY     ),
.HRESP        (s5_HRESP      ),
.HRDATA       (s5_HRDATA     ),
.HSPLIT       (s5_HSPLIT     ),
.WPROT        (wWPROT        ),
.SDR_CKE      (wSDR_CKE      ),
.SDR_CS_N     (wSDR_CS_N     ),
.SDR_WE       (wSDR_WE       ),
.SDR_RAS_N    (wSDR_RAS_N    ),
.SDR_CAS_N    (wSDR_CAS_N    ),
.SDR_DQM      (wSDR_DQM      ),
.SDR_ADDR     (wSDR_ADDR     ),
.SDR_DATA_I   (wSDR_DATA_I   ),
.SDR_DATA_O_EN(wSDR_DATA_O_EN),
.SDR_DATA_O   (wSDR_DATA_O   )
);

mt48lc4m32b2  sdram_model 
(
.Clk   (hclk            ),
.Cke   (wSDR_CKE        ),
.Cs_n  (wSDR_CS_N       ),
.We_n  (wSDR_WE         ),
.Ras_n (wSDR_RAS_N      ),
.Cas_n (wSDR_CAS_N      ),
.Dqm   (wSDR_DQM        ),
.Dq    (wSDR_DATA       ),
.Addr  (wSDR_ADDR[11:0] ),
.Ba    (wSDR_ADDR[14:13])
);


////////////////////////////////////////////
`define  NAND_PAGE_RD1   8'h00 
`define  NAND_PAGE_RD2   8'h30 
`define  NAND_RD_COPY    8'h35 
`define  NAND_RD_ID      8'h90 
`define  NAND_FLASH_RST  8'hFF 
`define  NAND_PAGE_WR1   8'h80 
`define  NAND_PAGE_WR2   8'h10 
`define  NAND_CACHE_WR   8'h15 
`define  NAND_BLK_ERS1   8'h60 
`define  NAND_BLK_ERS2   8'hD0 
`define  NAND_RAND_WR    8'h85 
`define  NAND_RAND_RD1   8'h05 
`define  NAND_RAND_RD2   8'hE0 
`define  NAND_RD_STATUS  8'h70 

wire         s6_HREADY       ;
wire   [ 1:0]s6_HRESP        ;
wire   [15:0]s6_HSPLIT       ;
wire   [31:0]s6_HRDATA       ;

wire         nandCE_N        ;
wire         nandALE         ;
wire         nandCLE         ;
wire         nandRE_N        ;
wire         nandWE_N        ;
wire         nandDataEn      ;
wire   [ 7:0]nandDataOut     ;
wire         nandRB          ;
wire   [ 7:0]nandDataIn      ;
wire   [ 7:0]nandData        ;
wire         nandIRQ         ;

assign       nandDataIn = nandData  ;
assign       nandData   = nandDataEn ? nandDataOut : 8'hzz ;

//assign       s6_HREADY    =  1'b1   ;
//assign       s6_HRESP     =  2'b0   ;
//assign       s6_HSPLIT    = 16'b0   ;
//assign       s6_HRDATA    = 32'b0   ;

ahb_nandflash #(
.PAGE_RD1    (`NAND_PAGE_RD1        ),
.PAGE_RD2    (`NAND_PAGE_RD2        ),
.RD_COPY     (`NAND_RD_COPY         ),
.RD_ID       (`NAND_RD_ID           ),
.FLASH_RST   (`NAND_FLASH_RST       ),
.PAGE_WR1    (`NAND_PAGE_WR1        ),
.PAGE_WR2    (`NAND_PAGE_WR2        ),
.CACHE_WR    (`NAND_CACHE_WR        ),
.BLK_ERS1    (`NAND_BLK_ERS1        ),
.BLK_ERS2    (`NAND_BLK_ERS2        ),
.RAND_WR     (`NAND_RAND_WR         ),
.RAND_RD1    (`NAND_RAND_RD1        ),
.RAND_RD2    (`NAND_RAND_RD2        ),
.RD_STATUS   (`NAND_RD_STATUS       ),
.CMD_ADDR    (`AHB_NAND_CMD_ADDR    ),
.CFG_ADDR    (`AHB_NAND_CFG_ADDR    ),
.ADR_ADDR    (`AHB_NAND_ADR_ADDR    ),
.STATUS_ADDR (`AHB_NAND_STATUS_ADDR ),
.LEN_ADDR    (`AHB_NAND_LEN_ADDR    ),
.DATA_ADDR   (`AHB_NAND_DATA_ADDR   )
) slv6 (
.HCLK        (hclk        )   , //clock
.HRST_N      (hrst_n      )   , //reset
.HSEL        (wHSEL[6]    )   ,
.HREADY      (wHREADY     )   ,
.HADDR       (wHADDR      )   ,
.HSIZE       (wHSIZE      )   ,
.HWRITE      (wHWRITE     )   ,
.HTRANS      (wHTRANS     )   ,
.HBURST      (wHBURST     )   ,
.HWDATA      (wHWDATA     )   ,
.HREADY_O    (s6_HREADY   )   ,
.HRESP       (s6_HRESP    )   ,
.HRDATA      (s6_HRDATA   )   ,
.HSPLIT      (s6_HSPLIT   )   ,

.CE_N        (nandCE_N    )   ,
.ALE         (nandALE     )   ,
.CLE         (nandCLE     )   ,
.RE_N        (nandRE_N    )   ,
.WE_N        (nandWE_N    )   ,
.DataEn      (nandDataEn  )   ,
.DataOut     (nandDataOut )   ,
.RB          (nandRB      )   ,
.DataIn      (nandDataIn  )   ,
.IRQ         (nandIRQ     )
);

//k9d1g08  nand_flash (
//.IO7    (nandData[7]) ,
//.IO6    (nandData[6]) ,
//.IO5    (nandData[5]) ,
//.IO4    (nandData[4]) ,
//.IO3    (nandData[3]) ,
//.IO2    (nandData[2]) ,
//.IO1    (nandData[1]) ,
//.IO0    (nandData[0]) ,
//.CENeg  (nandCE_N   ) ,
//.ALE    (nandALE    ) ,
//.CLE    (nandCLE    ) ,
//.RENeg  (nandRE_N   ) ,
//.WENeg  (nandWE_N   ) ,
//.WPNeg  (1'b1       ) ,
//.R      (nandRB     )
// );
s30ms01gp00 nand_flash (
.IO7     (nandData[7]) ,
.IO6     (nandData[6]) ,
.IO5     (nandData[5]) ,
.IO4     (nandData[4]) ,
.IO3     (nandData[3]) ,
.IO2     (nandData[2]) ,
.IO1     (nandData[1]) ,
.IO0     (nandData[0]) ,
.CENeg   (nandCE_N   ) ,
.ALE     (nandALE    ) ,
.CLE     (nandCLE    ) ,
.RENeg   (nandRE_N   ) ,
.WENeg   (nandWE_N   ) ,
.WPNeg   (1'b1       ) ,
.RY      (nandRB     ) ,
.PRE     (1'b0       )
 );
////////////////////////////////////////////
wire         s7_HREADY       ;
wire   [ 1:0]s7_HRESP        ;
wire   [15:0]s7_HSPLIT       ;
wire   [31:0]s7_HRDATA       ;

assign       s7_HREADY    =  1'b1   ;
assign       s7_HRESP     =  2'b0   ;
assign       s7_HSPLIT    = 16'b0   ;
assign       s7_HRDATA    = 32'b0   ;

////////////////////////////////////////////
wire         s8_HREADY       ;
wire   [ 1:0]s8_HRESP        ;
wire   [15:0]s8_HSPLIT       ;
wire   [31:0]s8_HRDATA       ;

assign       s8_HREADY    =  1'b1   ;
assign       s8_HRESP     =  2'b0   ;
assign       s8_HSPLIT    = 16'b0   ;
assign       s8_HRDATA    = 32'b0   ;

////////////////////////////////////////////
wire         s9_HREADY       ;
wire   [ 1:0]s9_HRESP        ;
wire   [15:0]s9_HSPLIT       ;
wire   [31:0]s9_HRDATA       ;

assign       s9_HREADY    =  1'b1   ;
assign       s9_HRESP     =  2'b0   ;
assign       s9_HSPLIT    = 16'b0   ;
assign       s9_HRDATA    = 32'b0   ;

////////////////////////////////////////////
wire         s10_HREADY       ;
wire   [ 1:0]s10_HRESP        ;
wire   [15:0]s10_HSPLIT       ;
wire   [31:0]s10_HRDATA       ;

assign       s10_HREADY    =  1'b1   ;
assign       s10_HRESP     =  2'b0   ;
assign       s10_HSPLIT    = 16'b0   ;
assign       s10_HRDATA    = 32'b0   ;

////////////////////////////////////////////
wire         s11_HREADY       ;
wire   [ 1:0]s11_HRESP        ;
wire   [15:0]s11_HSPLIT       ;
wire   [31:0]s11_HRDATA       ;

assign       s11_HREADY    =  1'b1   ;
assign       s11_HRESP     =  2'b0   ;
assign       s11_HSPLIT    = 16'b0   ;
assign       s11_HRDATA    = 32'b0   ;

////////////////////////////////////////////
wire         s12_HREADY       ;
wire   [ 1:0]s12_HRESP        ;
wire   [15:0]s12_HSPLIT       ;
wire   [31:0]s12_HRDATA       ;

assign       s12_HREADY    =  1'b1   ;
assign       s12_HRESP     =  2'b0   ;
assign       s12_HSPLIT    = 16'b0   ;
assign       s12_HRDATA    = 32'b0   ;

////////////////////////////////////////////
wire         s13_HREADY       ;
wire   [ 1:0]s13_HRESP        ;
wire   [15:0]s13_HSPLIT       ;
wire   [31:0]s13_HRDATA       ;

assign       s13_HREADY    =  1'b1   ;
assign       s13_HRESP     =  2'b0   ;
assign       s13_HSPLIT    = 16'b0   ;
assign       s13_HRDATA    = 32'b0   ;

////////////////////////////////////////////
wire         s14_HREADY       ;
wire   [ 1:0]s14_HRESP        ;
wire   [15:0]s14_HSPLIT       ;
wire   [31:0]s14_HRDATA       ;

assign       s14_HREADY    =  1'b1   ;
assign       s14_HRESP     =  2'b0   ;
assign       s14_HSPLIT    = 16'b0   ;
assign       s14_HRDATA    = 32'b0   ;

////////////////////////////////////////////
wire         s15_HREADY       ;
wire   [ 1:0]s15_HRESP        ;
wire   [15:0]s15_HSPLIT       ;
wire   [31:0]s15_HRDATA       ;

assign       s15_HREADY    =  1'b1   ;
assign       s15_HRESP     =  2'b0   ;
assign       s15_HSPLIT    = 16'b0   ;
assign       s15_HRDATA    = 32'b0   ;

////////////////////////////////////////////
ahb  amba_ahb(
.HCLK       (hclk         )     ,//clock
.HRST_N     (hrst_n       )     ,//reset
//to slaver
.HSEL       (wHSEL        )     ,
.HMASTER    (wHMASTER     )     ,
.HMASTERLOCK(wHMASTERLOCK )     ,
.HADDR      (wHADDR       )     ,
.HSIZE      (wHSIZE       )     ,
.HWRITE     (wHWRITE      )     ,
.HTRANS     (wHTRANS      )     ,
.HBURST     (wHBURST      )     ,
.HPROT      (wHPROT       )     ,
.HWDATA     (wHWDATA      )     ,
//to mster
.HGRANT     (wHGRANT      )     ,
.HRESP      (wHRESP       )     ,
.HSPLIT     (wHSPLIT      )     ,
.HRDATA     (wHRDATA      )     ,
//both
.HREADY     (wHREADY      )     ,
//mst0
.M0_HBUSREQ (m0_HBUSREQ   )     ,
.M0_HLOCK   (m0_HLOCK     )     ,
.M0_HADDR   (m0_HADDR     )     ,
.M0_HSIZE   (m0_HSIZE     )     ,
.M0_HWRITE  (m0_HWRITE    )     ,
.M0_HTRANS  (m0_HTRANS    )     ,
.M0_HBURST  (m0_HBURST    )     ,
.M0_HPROT   (m0_HPROT     )     ,
.M0_HWDATA  (m0_HWDATA    )     ,
//mst1       /mst1
.M1_HBUSREQ (m1_HBUSREQ   )     ,
.M1_HLOCK   (m1_HLOCK     )     ,
.M1_HADDR   (m1_HADDR     )     ,
.M1_HSIZE   (m1_HSIZE     )     ,
.M1_HWRITE  (m1_HWRITE    )     ,
.M1_HTRANS  (m1_HTRANS    )     ,
.M1_HBURST  (m1_HBURST    )     ,
.M1_HPROT   (m1_HPROT     )     ,
.M1_HWDATA  (m1_HWDATA    )     ,
//mst2       /mst2
.M2_HBUSREQ (m2_HBUSREQ   )     ,
.M2_HLOCK   (m2_HLOCK     )     ,
.M2_HADDR   (m2_HADDR     )     ,
.M2_HSIZE   (m2_HSIZE     )     ,
.M2_HWRITE  (m2_HWRITE    )     ,
.M2_HTRANS  (m2_HTRANS    )     ,
.M2_HBURST  (m2_HBURST    )     ,
.M2_HPROT   (m2_HPROT     )     ,
.M2_HWDATA  (m2_HWDATA    )     ,
//mst3       /mst3
.M3_HBUSREQ (m3_HBUSREQ   )     ,
.M3_HLOCK   (m3_HLOCK     )     ,
.M3_HADDR   (m3_HADDR     )     ,
.M3_HSIZE   (m3_HSIZE     )     ,
.M3_HWRITE  (m3_HWRITE    )     ,
.M3_HTRANS  (m3_HTRANS    )     ,
.M3_HBURST  (m3_HBURST    )     ,
.M3_HPROT   (m3_HPROT     )     ,
.M3_HWDATA  (m3_HWDATA    )     ,
//slv0       /slv0
.S0_HREADY  (s0_HREADY    )     ,
.S0_HRESP   (s0_HRESP     )     ,
.S0_HSPLIT  (s0_HSPLIT    )     ,
.S0_HRDATA  (s0_HRDATA    )     ,
//slv1       /slv1
.S1_HREADY  (s1_HREADY    )     ,
.S1_HRESP   (s1_HRESP     )     ,
.S1_HSPLIT  (s1_HSPLIT    )     ,
.S1_HRDATA  (s1_HRDATA    )     ,
//slv2       /slv2
.S2_HREADY  (s2_HREADY    )     ,
.S2_HRESP   (s2_HRESP     )     ,
.S2_HSPLIT  (s2_HSPLIT    )     ,
.S2_HRDATA  (s2_HRDATA    )     ,
//slv3       /slv3
.S3_HREADY  (s3_HREADY    )     ,
.S3_HRESP   (s3_HRESP     )     ,
.S3_HSPLIT  (s3_HSPLIT    )     ,
.S3_HRDATA  (s3_HRDATA    )     , 
//slv4       
.S4_HREADY  (s4_HREADY    )     ,
.S4_HRESP   (s4_HRESP     )     ,
.S4_HSPLIT  (s4_HSPLIT    )     ,
.S4_HRDATA  (s4_HRDATA    )     , 
//slv5       
.S5_HREADY  (s5_HREADY    )     ,
.S5_HRESP   (s5_HRESP     )     ,
.S5_HSPLIT  (s5_HSPLIT    )     ,
.S5_HRDATA  (s5_HRDATA    )     , 
//slv6       
.S6_HREADY  (s6_HREADY    )     ,
.S6_HRESP   (s6_HRESP     )     ,
.S6_HSPLIT  (s6_HSPLIT    )     ,
.S6_HRDATA  (s6_HRDATA    )     , 
//slv7       
.S7_HREADY  (s7_HREADY    )     ,
.S7_HRESP   (s7_HRESP     )     ,
.S7_HSPLIT  (s7_HSPLIT    )     ,
.S7_HRDATA  (s7_HRDATA    )     , 
//slv8       
.S8_HREADY  (s8_HREADY    )     ,
.S8_HRESP   (s8_HRESP     )     ,
.S8_HSPLIT  (s8_HSPLIT    )     ,
.S8_HRDATA  (s8_HRDATA    )     , 
//slv9       
.S9_HREADY  (s9_HREADY    )     ,
.S9_HRESP   (s9_HRESP     )     ,
.S9_HSPLIT  (s9_HSPLIT    )     ,
.S9_HRDATA  (s9_HRDATA    )     , 
//slv10       
.S10_HREADY (s10_HREADY   )     ,
.S10_HRESP  (s10_HRESP    )     ,
.S10_HSPLIT (s10_HSPLIT   )     ,
.S10_HRDATA (s10_HRDATA   )     , 
//slv11       
.S11_HREADY (s11_HREADY   )     ,
.S11_HRESP  (s11_HRESP    )     ,
.S11_HSPLIT (s11_HSPLIT   )     ,
.S11_HRDATA (s11_HRDATA   )     , 
//slv12       
.S12_HREADY (s12_HREADY   )     ,
.S12_HRESP  (s12_HRESP    )     ,
.S12_HSPLIT (s12_HSPLIT   )     ,
.S12_HRDATA (s12_HRDATA   )     , 
//slv13       
.S13_HREADY (s13_HREADY   )     ,
.S13_HRESP  (s13_HRESP    )     ,
.S13_HSPLIT (s13_HSPLIT   )     ,
.S13_HRDATA (s13_HRDATA   )     , 
//slv14       
.S14_HREADY (s14_HREADY   )     ,
.S14_HRESP  (s14_HRESP    )     ,
.S14_HSPLIT (s14_HSPLIT   )     ,
.S14_HRDATA (s14_HRDATA   )     , 
//slv15       
.S15_HREADY (s15_HREADY   )     ,
.S15_HRESP  (s15_HRESP    )     ,
.S15_HSPLIT (s15_HSPLIT   )     ,
.S15_HRDATA (s15_HRDATA   )     
);

initial begin
  $fsdbDumpfile("wave.fsdb") ;
  $fsdbDumpvars;
end

parameter BYTE0     = 2'b00 ;
parameter BYTE1     = 2'b01 ;
parameter BYTE2     = 2'b10 ;
parameter BYTE3     = 2'b11 ;
parameter HALFWORD0 = 2'b01 ;
parameter HALFWORD1 = 2'b10 ;
parameter BYTE      = 3'b000 ;
parameter HALFWORD  = 3'b001 ;
parameter WORD      = 3'b010 ;
parameter WRITE     = 1'b1   ;
parameter READ      = 1'b0   ;

reg [31:0]mst0_addr ;
initial begin:mst0_read_write
  m0_Start     =  0   ;
  m0_WRAddr    =  0   ;
  m0_WRSize    =  0   ;
  m0_WR        =  0   ;
  m0_WRLen     =  0   ;
  m0_WRBurst   =  0   ;
  m0_Din       =  0   ;   
  @(posedge hrst_n);
  #40 ;
//slv0
  mst0_addr = $random ;
  mst0_wr({ `AHB_SLV0_BASE,mst0_addr[27:2],BYTE0}, BYTE, WRITE, 16'd3, 32'b0);
  mst0_wr({ `AHB_SLV0_BASE,mst0_addr[27:2],BYTE0}, BYTE, READ, 16'd3, 32'b0);
  mst0_addr = $random ;
  mst0_wr({ `AHB_SLV0_BASE,mst0_addr[27:2],BYTE1}, BYTE, WRITE, 16'd3, 32'b0);
  mst0_wr({ `AHB_SLV0_BASE,mst0_addr[27:2],BYTE1}, BYTE, READ, 16'd3, 32'b0);
  mst0_addr = $random ;
  mst0_wr({ `AHB_SLV0_BASE,mst0_addr[27:2],BYTE2}, BYTE, WRITE, 16'd3, 32'b0);
  mst0_wr({ `AHB_SLV0_BASE,mst0_addr[27:2],BYTE2}, BYTE, READ, 16'd3, 32'b0);
  mst0_addr = $random ;
  mst0_wr({ `AHB_SLV0_BASE,mst0_addr[27:2],BYTE3}, BYTE, WRITE, 16'd3, 32'b0);
  mst0_wr({ `AHB_SLV0_BASE,mst0_addr[27:2],BYTE3}, BYTE, READ, 16'd3, 32'b0);
  mst0_addr = $random ;
  mst0_wr({ `AHB_SLV0_BASE,mst0_addr[27:2],HALFWORD0}, HALFWORD, WRITE, 16'd3, 32'b0);
  mst0_wr({ `AHB_SLV0_BASE,mst0_addr[27:2],HALFWORD0}, HALFWORD, READ, 16'd3, 32'b0);
  mst0_addr = $random ;
  mst0_wr({ `AHB_SLV0_BASE,mst0_addr[27:2],HALFWORD1}, HALFWORD, WRITE, 16'd3, 32'b0);
  mst0_wr({ `AHB_SLV0_BASE,mst0_addr[27:2],HALFWORD1}, HALFWORD, READ, 16'd3, 32'b0);
  mst0_addr = $random ;
  mst0_wr({ `AHB_SLV0_BASE,mst0_addr[27:0]}, WORD, WRITE, 16'd3, 32'b0);
  mst0_wr({ `AHB_SLV0_BASE,mst0_addr[27:0]}, WORD, READ, 16'd3, 32'b0);
//slv1
  mst0_addr = $random ;
  mst0_wr({ `AHB_SLV1_BASE,mst0_addr[27:0]}, WORD, WRITE, 16'd10, 32'b0);
  mst0_wr({ `AHB_SLV1_BASE,mst0_addr[27:0]}, WORD, READ, 16'd10, 32'b0);
//apb_gpio
  Gpio = 32'b0    ;
  mst0_wr({`AHB_SLV3_BASE,`APB_SLV0_BASE,18'b0,`APB_GPIO_DIR_ADDR}, WORD, WRITE, 16'd1,32'h0000);
  Gpio = 32'hADADADAD ;
  mst0_wr({`AHB_SLV3_BASE,`APB_SLV0_BASE,18'b0,`APB_GPIO_ADDR}, WORD, READ, 16'd1,32'h0000);
  mst0_wr({`AHB_SLV3_BASE,`APB_SLV0_BASE,18'b0,`APB_GPIO_ADDR}, WORD, WRITE, 16'd1,32'hBCBCBCBC);
  mst0_wr({`AHB_SLV3_BASE,`APB_SLV0_BASE,18'b0,`APB_GPIO_DIR_ADDR}, WORD, WRITE, 16'd1,32'hFFFFFFFF);
//ahb_spim
  @(posedge wInitialized)
  ////初始化
  mst0_wr({`AHB_SLV4_BASE,1'b1,21'b0,`AHB_SPIM_CTRL_ADDR}, WORD, WRITE, 16'd1, {5'b0,1'b0,1'b0,8'h03,16'd10});
  mst0_addr=0;
  repeat(5) begin
    mst0_wr({`AHB_SLV4_BASE,mst0_addr[27:0]}, BYTE, READ, 16'd1, 32'b0);
    mst0_addr = mst0_addr + 1'b1 ;
    @(posedge wDone);
  end
  repeat(5) begin
    mst0_wr({`AHB_SLV4_BASE,mst0_addr[27:0]}, HALFWORD, READ, 16'd1, 32'b0);
    mst0_addr = mst0_addr + 1'b1 ;
    @(posedge wDone);
  end
  repeat(5) begin
    mst0_wr({`AHB_SLV4_BASE,mst0_addr[27:0]}, WORD, READ, 16'd1, 32'b0);
    mst0_addr = mst0_addr + 1'b1 ;
    @(posedge wDone);
  end
  mst0_wr({`AHB_SLV4_BASE,28'b0}, BYTE, READ, 16'd10, 32'b0);
    @(posedge wDone);
  mst0_wr({`AHB_SLV4_BASE,28'b0}, HALFWORD, READ, 16'd10, 32'b0);
    @(posedge wDone);
  mst0_wr({`AHB_SLV4_BASE,28'b0}, WORD, READ, 16'd10, 32'b0);
    @(posedge wDone);
end


reg [31:0]mst2_addr ;
reg [31:0]uu_addr   ;
reg [31:0]dir_addr  ;
reg [31:0]src_addr  ;
reg  [3:0]TracePtr  ;
reg  flash_status   ;
initial begin:mst2_read_write
  m2_Start     =  0   ;
  m2_WRAddr    =  0   ;
  m2_WRSize    =  0   ;
  m2_WR        =  0   ;
  m2_WRLen     =  0   ;
  m2_WRBurst   =  0   ;
  m2_Din       =  0   ;   
  TracePtr     =  0   ;
  flash_status =  0   ;
  @(posedge hrst_n);
  #60 ;
//slv2
   mst2_wr({`AHB_SLV5_BASE,28'hFFFFFFF}, WORD, WRITE, 16'b1,{1'b1,1'b1,3'b110,1'b1,3'b0,2'b0,3'b0,1'b0,17'h1000});
  repeat(5) begin
    mst2_addr = $random ;
    mst2_wr({`AHB_SLV2_BASE,mst2_addr[27:2],BYTE0}, BYTE, WRITE, 16'd1, $random);
  end
  repeat(5) begin
    mst2_addr = $random ;
    mst2_wr({`AHB_SLV2_BASE,mst2_addr[27:2],BYTE1}, BYTE, WRITE, 16'd1, $random);
  end
  repeat(5) begin
    mst2_addr = $random ;
    mst2_wr({`AHB_SLV2_BASE,mst2_addr[27:2],BYTE2}, BYTE, WRITE, 16'd1, $random);
  end
  repeat(5) begin
    mst2_addr = $random ;
    mst2_wr({`AHB_SLV2_BASE,mst2_addr[27:2],BYTE3}, BYTE, WRITE, 16'd1, $random);
  end
  repeat(5) begin
    mst2_addr = $random ;
    mst2_wr({`AHB_SLV2_BASE,mst2_addr[27:2],HALFWORD0}, HALFWORD, WRITE, 16'd1, $random);
  end
  repeat(5) begin
    mst2_addr = $random ;
    mst2_wr({`AHB_SLV2_BASE,mst2_addr[27:2],HALFWORD1}, HALFWORD, WRITE, 16'd1, $random);
  end
  repeat(5) begin
    mst2_addr = $random ;
    mst2_wr({`AHB_SLV2_BASE,mst2_addr[27:0]},WORD, WRITE, 16'd1, $random);
  end
//slv3
//apb1
  mst2_addr = $random ;
  mst2_wr({`AHB_SLV3_BASE,`APB_SLV1_BASE, 13'b0,  mst2_addr[10:0]}, WORD, WRITE, 16'd6, 32'b0);
  #200
  mst2_wr({`AHB_SLV3_BASE,`APB_SLV1_BASE, 13'b0,  mst2_addr[10:0]}, WORD, READ, 16'd6, 32'b0);
//apb2
  mst2_wr({`AHB_SLV3_BASE,`APB_SLV2_BASE,18'b0,`APB_UART_CTRL_ADDR}, WORD, WRITE, 16'd1,{27'b0,5'b11000});
  mst2_wr({`AHB_SLV3_BASE,`APB_SLV2_BASE,18'b0,`APB_UART_SCALER_ADDR}, WORD, WRITE, 16'd1,32'h0002);
  `ifdef APB_UART_SELF_TEST
     //write data
     mst2_wr({`AHB_SLV3_BASE,`APB_SLV2_BASE,18'b0,`APB_UART_THOLD_ADDR}, WORD, WRITE, 16'd1,32'h00AA);
     mst2_wr({`AHB_SLV3_BASE,`APB_SLV2_BASE,18'b0,`APB_UART_THOLD_ADDR}, WORD, WRITE, 16'd1,32'h00BB);
     mst2_wr({`AHB_SLV3_BASE,`APB_SLV2_BASE,18'b0,`APB_UART_THOLD_ADDR}, WORD, WRITE, 16'd1,32'h00CC);
     mst2_wr({`AHB_SLV3_BASE,`APB_SLV2_BASE,18'b0,`APB_UART_THOLD_ADDR}, WORD, WRITE, 16'd1,32'h00DD);
     //receive data
     @(posedge apb2_IRQ)
     mst2_wr({`AHB_SLV3_BASE,`APB_SLV2_BASE,18'b0,`APB_UART_RHOLD_ADDR}, WORD, READ, 16'b1,32'b0);
     @(posedge apb2_IRQ)
     mst2_wr({`AHB_SLV3_BASE,`APB_SLV2_BASE,18'b0,`APB_UART_RHOLD_ADDR}, WORD, READ, 16'b1,32'b0);
     @(posedge apb2_IRQ)
     mst2_wr({`AHB_SLV3_BASE,`APB_SLV2_BASE,18'b0,`APB_UART_RHOLD_ADDR}, WORD, READ, 16'b1,32'b0);
     @(posedge apb2_IRQ)
     mst2_wr({`AHB_SLV3_BASE,`APB_SLV2_BASE,18'b0,`APB_UART_RHOLD_ADDR}, WORD, READ, 16'b1,32'b0);
   `endif
     //ahb_duart initial
     mst2_wr({`AHB_SLV3_BASE,`APB_SLV4_BASE,18'b0,`AHB_DUART_CTRL_ADDR}, WORD, WRITE, 16'd1,32'h0001);
     //ahb_duart baud rate auto get
     mst2_wr({`AHB_SLV3_BASE,`APB_SLV2_BASE,18'b0,`APB_UART_THOLD_ADDR}, WORD, WRITE, 16'd1,32'h00AA);
     mst2_wr({`AHB_SLV3_BASE,`APB_SLV2_BASE,18'b0,`APB_UART_THOLD_ADDR}, WORD, WRITE, 16'd1,32'h00AA);
     //apb_uart通过串口写数据给ahb_duart
     //8-7:10,读，11,写 ，6-0:数据长度
     mst2_wr({`AHB_SLV3_BASE,`APB_SLV2_BASE,18'b0,`APB_UART_THOLD_ADDR}, WORD, WRITE, 16'd1,32'h00C1);
     //32bit 地址
     mst2_wr({`AHB_SLV3_BASE,`APB_SLV2_BASE,18'b0,`APB_UART_THOLD_ADDR}, WORD, WRITE, 16'd1,32'h00AA);
     //32bit 地址
     mst2_wr({`AHB_SLV3_BASE,`APB_SLV2_BASE,18'b0,`APB_UART_THOLD_ADDR}, WORD, WRITE, 16'd1,32'h00BB);
     //32bit 地址
     mst2_wr({`AHB_SLV3_BASE,`APB_SLV2_BASE,18'b0,`APB_UART_THOLD_ADDR}, WORD, WRITE, 16'd1,32'h00CC);
     //32bit 地址
     mst2_wr({`AHB_SLV3_BASE,`APB_SLV2_BASE,18'b0,`APB_UART_THOLD_ADDR}, WORD, WRITE, 16'd1,32'h00DD);
     //32bit数据 
     #30000
     wait(apb2_IRQ == 1'b0)
     mst2_wr({`AHB_SLV3_BASE,`APB_SLV2_BASE,18'b0,`APB_UART_THOLD_ADDR}, WORD, WRITE, 16'd1,32'h00EE);
     wait(apb2_IRQ == 1'b0)
     //32bit数据 
     mst2_wr({`AHB_SLV3_BASE,`APB_SLV2_BASE,18'b0,`APB_UART_THOLD_ADDR}, WORD, WRITE, 16'd1,32'h00EE);
     wait(apb2_IRQ == 1'b0)
     //32bit数据 
     mst2_wr({`AHB_SLV3_BASE,`APB_SLV2_BASE,18'b0,`APB_UART_THOLD_ADDR}, WORD, WRITE, 16'd1,32'h00EE);
     wait(apb2_IRQ == 1'b0)
     //32bit数据 
     mst2_wr({`AHB_SLV3_BASE,`APB_SLV2_BASE,18'b0,`APB_UART_THOLD_ADDR}, WORD, WRITE, 16'd1,32'h00EE);
     #70000
     //8-7:10,读，11,写 ，6-0:数据长度
     uu_addr = {`AHB_SLV3_BASE,`APB_SLV0_BASE,18'b0,`APB_GPIO_ADDR};
     mst2_wr({`AHB_SLV3_BASE,`APB_SLV2_BASE,18'b0,`APB_UART_THOLD_ADDR}, WORD, WRITE, 16'd1,32'h0081);
     //32bit 地址
     mst2_wr({`AHB_SLV3_BASE,`APB_SLV2_BASE,18'b0,`APB_UART_THOLD_ADDR}, WORD, WRITE, 16'd1,{24'b0, uu_addr[31:24]});
     //32bit 地址
     mst2_wr({`AHB_SLV3_BASE,`APB_SLV2_BASE,18'b0,`APB_UART_THOLD_ADDR}, WORD, WRITE, 16'd1,{24'b0, uu_addr[23:16]});
     //32bit 地址
     mst2_wr({`AHB_SLV3_BASE,`APB_SLV2_BASE,18'b0,`APB_UART_THOLD_ADDR}, WORD, WRITE, 16'd1,{24'b0, uu_addr[15:8]});
     //32bit 地址
     mst2_wr({`AHB_SLV3_BASE,`APB_SLV2_BASE,18'b0,`APB_UART_THOLD_ADDR}, WORD, WRITE, 16'd1,{24'b0, uu_addr[7:0]});
     //ahb_duart读取gpio口的数据传输给apb_uart，apb uart产生中断，然后读取接收
     //数据
     //@(posedge apb2_IRQ)
     //mst2_wr({`AHB_SLV3_BASE,`APB_SLV2_BASE,18'b0,`APB_UART_RHOLD_ADDR}, WORD, READ, 16'b1,32'b0);
     //@(posedge apb2_IRQ)
     //mst2_wr({`AHB_SLV3_BASE,`APB_SLV2_BASE,18'b0,`APB_UART_RHOLD_ADDR}, WORD, READ, 16'b1,32'b0);
     //@(posedge apb2_IRQ)
     //mst2_wr({`AHB_SLV3_BASE,`APB_SLV2_BASE,18'b0,`APB_UART_RHOLD_ADDR}, WORD, READ, 16'b1,32'b0);
     //@(posedge apb2_IRQ)
     //mst2_wr({`AHB_SLV3_BASE,`APB_SLV2_BASE,18'b0,`APB_UART_RHOLD_ADDR}, WORD, READ, 16'b1,32'b0);
     //@(negedge m2_Done);
     @(posedge apb2_IRQ)
     mst2_wr({`AHB_SLV3_BASE,`APB_SLV2_BASE,18'b0,`APB_UART_RHOLD_ADDR}, WORD, READ, 16'b1,32'b0);
     mst2_wr({`AHB_SLV3_BASE,`APB_SLV2_BASE,18'b0,`APB_UART_RHOLD_ADDR}, WORD, READ, 16'b1,32'b0);
     mst2_wr({`AHB_SLV3_BASE,`APB_SLV2_BASE,18'b0,`APB_UART_RHOLD_ADDR}, WORD, READ, 16'b1,32'b0);
     mst2_wr({`AHB_SLV3_BASE,`APB_SLV2_BASE,18'b0,`APB_UART_RHOLD_ADDR}, WORD, READ, 16'b1,32'b0);
//sdram
  //#60000
  mst2_addr = 32'b0 ;
  mst2_wr({`AHB_SLV5_BASE,mst2_addr[27:0]}, WORD, WRITE, 16'd200,$random);
  mst2_wr({`AHB_SLV5_BASE,mst2_addr[27:0]}, WORD, READ, 16'd200,$random);
//dma_ctrl 从sdram处读取16 word字，然后以halfword写入sram0
  //apb_slv5
  //`define AHB_SIMPLE_DMA_CTRL_ADDR1  6'b110001 
  //`define AHB_SIMPLE_DMA_CTRL_ADDR2  6'b110010 
  //`define AHB_SIMPLE_DMA_CTRL_ADDR3  6'b110100
  src_addr={`AHB_SLV5_BASE,28'd10} ;
  dir_addr={`AHB_SLV0_BASE,28'd1};//全0地址不能读写
  mst2_wr({`AHB_SLV3_BASE,`APB_SLV5_BASE,18'b0,`AHB_SIMPLE_DMA_CTRL_ADDR1}, WORD, WRITE, 16'd1,src_addr);
  mst2_wr({`AHB_SLV3_BASE,`APB_SLV5_BASE,18'b0,`AHB_SIMPLE_DMA_CTRL_ADDR2}, WORD, WRITE, 16'd1,dir_addr);
  mst2_wr({`AHB_SLV3_BASE,`APB_SLV5_BASE,18'b0,`AHB_SIMPLE_DMA_CTRL_ADDR3}, WORD, WRITE, 16'd1,
          {17'b0, 1'b1,10'd16,2'd1, 2'd2});
//nand flash
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_CFG_ADDR}, WORD, WRITE, 16'd1, {17'd0, 3'd2, 3'd3, 3'd2, 3'd0, 3'd1});
  //read id
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_CMD_ADDR}, WORD, WRITE, 16'd1, `NAND_RD_ID);
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_ADR_ADDR}, WORD, WRITE, 16'd1, 32'd0);
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_DATA_ADDR}, WORD, READ, 16'd1, 32'd0);
  //page write
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_CMD_ADDR}, WORD, WRITE, 16'd1, `NAND_PAGE_WR1);
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_ADR_ADDR}, WORD, WRITE, 16'd1, 32'd0);
  repeat(50) begin
    mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_DATA_ADDR}, WORD, WRITE, 16'd1,$random);
  end
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_CMD_ADDR}, WORD, WRITE, 16'd1, `NAND_PAGE_WR2);
  @(posedge nandIRQ);
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_CMD_ADDR}, WORD, WRITE, 16'd1, `NAND_RD_STATUS);
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_DATA_ADDR}, WORD, READ, 16'd1, 32'b0);
  //page read
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_CMD_ADDR}, WORD, WRITE, 16'd1, `NAND_PAGE_RD1);
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_ADR_ADDR}, WORD, WRITE, 16'd1, 32'd0);
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_CMD_ADDR}, WORD, WRITE, 16'd1, `NAND_PAGE_RD2);
  @(posedge nandIRQ);
  repeat(24) begin
    mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_DATA_ADDR}, WORD, READ, 16'd1,32'b0);
  end
  //block erase
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_CMD_ADDR}, WORD, WRITE, 16'd1, `NAND_BLK_ERS1);
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_ADR_ADDR}, WORD, WRITE, 16'd1, 32'd0);
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_CMD_ADDR}, WORD, WRITE, 16'd1, `NAND_BLK_ERS2);
  @(posedge nandIRQ);
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_CMD_ADDR}, WORD, WRITE, 16'd1, `NAND_RD_STATUS);
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_DATA_ADDR}, WORD, READ, 16'd1,32'b0);
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_STATUS_ADDR}, WORD, READ, 16'd1,32'b0);
  //cache write
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_CMD_ADDR}, WORD, WRITE, 16'd1, `NAND_PAGE_WR1);
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_ADR_ADDR}, WORD, WRITE, 16'd1, 32'd0);
  repeat(50) begin
    mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_DATA_ADDR}, WORD, WRITE, 16'd1,$random);
  end
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_CMD_ADDR}, WORD, WRITE, 16'd1, `NAND_CACHE_WR);
  @(posedge nandIRQ);
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_CMD_ADDR}, WORD, WRITE, 16'd1, `NAND_RD_STATUS);
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_DATA_ADDR}, WORD, READ, 16'd1,32'b0);
  //cache write
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_CMD_ADDR}, WORD, WRITE, 16'd1, `NAND_PAGE_WR1);
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_ADR_ADDR}, WORD, WRITE, 16'd1, 32'd3000);
  repeat(50) begin
    mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_DATA_ADDR}, WORD, WRITE, 16'd1,$random);
  end
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_CMD_ADDR}, WORD, WRITE, 16'd1, `NAND_CACHE_WR);
  @(posedge nandIRQ);
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_CMD_ADDR}, WORD, WRITE, 16'd1, `NAND_RD_STATUS);
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_DATA_ADDR}, WORD, READ, 16'd1,32'b0);
  //cache write
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_CMD_ADDR}, WORD, WRITE, 16'd1, `NAND_PAGE_WR1);
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_ADR_ADDR}, WORD, WRITE, 16'd1, 32'd5000);
  repeat(50) begin
    mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_DATA_ADDR}, WORD, WRITE, 16'd1,$random);
  end
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_CMD_ADDR}, WORD, WRITE, 16'd1, `NAND_PAGE_WR2);
  @(posedge nandIRQ);
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_CMD_ADDR}, WORD, WRITE, 16'd1, `NAND_RD_STATUS);
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_DATA_ADDR}, WORD, READ, 16'd1,32'b0);
  //random read
  TracePtr = 4 ;
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_CMD_ADDR}, WORD, WRITE, 16'd1, `NAND_PAGE_RD1);
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_ADR_ADDR}, WORD, WRITE, 16'd1, 32'd3000);
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_CMD_ADDR}, WORD, WRITE, 16'd1, `NAND_PAGE_RD2);
  @(posedge nandIRQ) ;
  repeat(5) begin
    mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_DATA_ADDR}, WORD, READ, 16'd1,32'b0);
  end
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_CMD_ADDR}, WORD, WRITE, 16'd1, `NAND_RAND_RD1);
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_ADR_ADDR}, WORD, WRITE, 16'd1, 32'd3012);
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_CMD_ADDR}, WORD, WRITE, 16'd1, `NAND_RAND_RD2);
  repeat(6) begin
    mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_DATA_ADDR}, WORD, READ, 16'd1,32'b0);
  end
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_CMD_ADDR}, WORD, WRITE, 16'd1, `NAND_RAND_RD1);
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_ADR_ADDR}, WORD, WRITE, 16'd1, 32'd3022);
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_CMD_ADDR}, WORD, WRITE, 16'd1, `NAND_RAND_RD2);
  repeat(8) begin
    mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_DATA_ADDR}, WORD, READ, 16'd1,32'b0);
  end
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_CMD_ADDR}, WORD, WRITE, 16'd1, `NAND_RAND_RD1);
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_ADR_ADDR}, WORD, WRITE, 16'd1, 32'd3032);
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_CMD_ADDR}, WORD, WRITE, 16'd1, `NAND_RAND_RD2);
  repeat(9) begin
    mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_DATA_ADDR}, WORD, READ, 16'd1,32'b0);
  end
  //copy back
  TracePtr = 5 ;
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_CMD_ADDR}, WORD, WRITE, 16'd1, `NAND_PAGE_RD1);
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_ADR_ADDR}, WORD, WRITE, 16'd1, 32'd0);
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_CMD_ADDR}, WORD, WRITE, 16'd1, `NAND_RD_COPY);
  @(posedge nandIRQ) ;
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_CMD_ADDR}, WORD, WRITE, 16'd1, `NAND_RAND_WR);
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_ADR_ADDR}, WORD, WRITE, 16'd1, 32'd3000);
  repeat(50) begin
    mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_DATA_ADDR}, WORD, WRITE, 16'd1,$random);
  end
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_CMD_ADDR}, WORD, WRITE, 16'd1, `NAND_RAND_WR);
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_ADR_ADDR}, WORD, WRITE, 16'd1, 32'd3200);
  repeat(50) begin
    mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_DATA_ADDR}, WORD, WRITE, 16'd1,$random);
  end
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_CMD_ADDR}, WORD, WRITE, 16'd1, `NAND_PAGE_WR2);
  @(posedge nandIRQ);
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_CMD_ADDR}, WORD, WRITE, 16'd1, `NAND_RD_STATUS);
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_DATA_ADDR}, WORD, READ, 16'd1,32'b0);
  //core reset
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_CMD_ADDR}, WORD, WRITE, 16'd1, `NAND_PAGE_WR1);
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_ADR_ADDR}, WORD, WRITE, 16'd1, 32'd8000);
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_DATA_ADDR}, WORD, WRITE, 16'd1,$random);
  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_STATUS_ADDR}, WORD, WRITE, 16'd1,{30'b0, 1'b1, 1'b0});
  @(posedge nandIRQ) ;
  ////random write
  //mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_CMD_ADDR}, WORD, WRITE, 16'd1, `NAND_PAGE_WR1);
  //mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_ADR_ADDR}, WORD, WRITE, 16'd1, 32'd0);
  //repeat(5) begin
  //  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_DATA_ADDR}, WORD, WRITE, 16'd1,$random);
  //end
  //mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_CMD_ADDR}, WORD, WRITE, 16'd1, `NAND_RAND_WR);
  //mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_ADR_ADDR}, WORD, WRITE, 16'd1, 32'd2140);
  //mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_LEN_ADDR}, WORD, WRITE, 16'd1, 32'd6);
  //repeat(6) begin
  //  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_DATA_ADDR}, WORD, WRITE, 16'd1,$random);
  //end
  //mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_CMD_ADDR}, WORD, WRITE, 16'd1, `NAND_RAND_WR);
  //mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_ADR_ADDR}, WORD, WRITE, 16'd1, 32'd2240);
  //mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_LEN_ADDR}, WORD, WRITE, 16'd1, 32'd8);
  //repeat(8) begin
  //  mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_DATA_ADDR}, WORD, WRITE, 16'd1,$random);
  //end
  //mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_CMD_ADDR}, WORD, WRITE, 16'd1, `NAND_PAGE_WR2);
  //mst2_wr({`AHB_SLV6_BASE, 22'b0, `AHB_NAND_CMD_ADDR}, WORD, WRITE, 16'd1, `NAND_RD_STATUS);
end


task mst0_wr;
  input   [31:0]Addr  ;
  input   [ 2:0]Size  ;
  input         Write ;
  input   [15:0]Len   ;
  input   [31:0]Data  ;
  integer       i     ;
  begin
    fork 
      begin
        @(posedge hclk) ;
	#1 ;
        m0_Start     = 1'b1  ;
	m0_WRAddr    = Addr  ;
	m0_WRSize    = Size  ;
	m0_WR        = Write ;
	m0_WRLen     = Len   ;
	m0_WRBurst   = (Len > 1) ? 1'b1 : 1'b0;
        @(posedge hclk) ;
	#1 ;
        m0_Start     =  0   ;
        m0_WRAddr    =  0   ;
        m0_WRSize    =  0   ;
        m0_WR        =  0   ;
        m0_WRLen     =  0   ;
        m0_WRBurst   =  0   ;
      end
      begin : write_mst
	if(Write) begin
	  i= 0 ;
	  if(Len == 1) begin
	    while (i< Len ) begin
	      @(posedge hclk)
	      if(m0_ReadEn)  begin
	        m0_Din = #1 Data ;
		$display("Write Data From Mst0 : %h",m0_Din) ;
		i = i + 1 ;
	      end
	    end
	  end
	  else begin
	    while (i< Len ) begin
	      @(posedge hclk)
	      if(m0_ReadEn) begin
	        m0_Din = #1 $random ;
	        i = i + 1 ;
	      end
	    end
	  end
	end
      end
      begin : read_mst
	if(~Write) begin
	  i= 0 ;
	  while (i< Len ) begin
	    @(posedge hclk)
	    if(m0_DoutVld) begin
	      i = i + 1;
	      $display("Receive Data From Mst0 : %h",m0_Dout) ;
	    end
	  end
	end
      end
    join
    @(posedge m0_Done);
  end
endtask

task mst2_wr;
  input   [31:0]Addr  ;
  input   [ 2:0]Size  ;
  input         Write ;
  input   [15:0]Len   ;
  input   [31:0]Data  ;
  integer       i     ;
  begin
    fork 
      begin
        @(posedge hclk) ;
	#1 ;
        m2_Start     = 1'b1  ;
	m2_WRAddr    = Addr  ;
	m2_WRSize    = Size  ;
	m2_WR        = Write ;
	m2_WRLen     = Len   ;
	m2_WRBurst   = (Len > 1) ? 1'b1 : 1'b0;
        @(posedge hclk) ;
	#1 ;
        m2_Start     =  0   ;
        m2_WRAddr    =  0   ;
        m2_WRSize    =  0   ;
        m2_WR        =  0   ;
        m2_WRLen     =  0   ;
        m2_WRBurst   =  0   ;
      end
      begin : write_mst
	if(Write)  begin
	  i= 0 ;
	  if(Len == 1) begin
	    while (i< Len ) begin
	     @(posedge hclk)
	     if(m2_ReadEn)  begin
	       m2_Din = #1 Data ;
	       i = i + 1 ;
	     end
	   end
	  end
	  else begin
	    while (i< Len ) begin
	      @(posedge hclk)
	      if(m2_ReadEn) begin
	        m2_Din = #1 $random ;
	        i = i + 1 ;
		$display("Write Data From Mst2 : %h",m2_Din) ;
	      end
	    end
	  end
	end
      end
      begin : read_mst
	if(~Write) begin
	  i= 0 ;
	  while (i< Len ) begin
	    @(posedge hclk)
	    if(m2_DoutVld) begin
	      i = i + 1;
	      $display("Receive Data From Mst2 : %h",m2_Dout) ;
	    end
	  end
	end
      end
    join
    @(posedge m2_Done);
  end
endtask


endmodule
