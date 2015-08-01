//================================================================================
// Created by         : Ltd.com
// Filename           : ahb.v
// Author             : Python_Wang
// Created On         : 2009-06-04 11:40
// Last Modified      : 2009-06-10 20:15
// Description        : 
//                      
//                      
//================================================================================
module ahb(
input        HCLK            ,//clock
input        HRST_N          ,//reset
//to slaver
output [15:0]HSEL            ,
output [ 3:0]HMASTER         ,
output       HMASTERLOCK     ,
output [31:0]HADDR           ,
output [ 2:0]HSIZE           ,
output       HWRITE          ,
output [ 1:0]HTRANS          ,
output [ 2:0]HBURST          ,
output [ 3:0]HPROT           ,
output [31:0]HWDATA          ,
//to master
output [15:0]HGRANT          ,
output [ 1:0]HRESP           ,
output [15:0]HSPLIT          ,
output [31:0]HRDATA          ,
//to both
output       HREADY          ,
//mst0
input        M0_HBUSREQ      ,
input        M0_HLOCK        ,
input  [31:0]M0_HADDR        ,
input  [ 2:0]M0_HSIZE        ,
input        M0_HWRITE       ,
input  [ 1:0]M0_HTRANS       ,
input  [ 2:0]M0_HBURST       ,
input  [ 3:0]M0_HPROT        ,
input  [31:0]M0_HWDATA       ,
//mst1
input        M1_HBUSREQ      ,
input        M1_HLOCK        ,
input  [31:0]M1_HADDR        ,
input  [ 2:0]M1_HSIZE        ,
input        M1_HWRITE       ,
input  [ 1:0]M1_HTRANS       ,
input  [ 2:0]M1_HBURST       ,
input  [ 3:0]M1_HPROT        ,
input  [31:0]M1_HWDATA       ,
//mst2
input        M2_HBUSREQ      ,
input        M2_HLOCK        ,
input  [31:0]M2_HADDR        ,
input  [ 2:0]M2_HSIZE        ,
input        M2_HWRITE       ,
input  [ 1:0]M2_HTRANS       ,
input  [ 2:0]M2_HBURST       ,
input  [ 3:0]M2_HPROT        ,
input  [31:0]M2_HWDATA       ,
//mst3
input        M3_HBUSREQ      ,
input        M3_HLOCK        ,
input  [31:0]M3_HADDR        ,
input  [ 2:0]M3_HSIZE        ,
input        M3_HWRITE       ,
input  [ 1:0]M3_HTRANS       ,
input  [ 2:0]M3_HBURST       ,
input  [ 3:0]M3_HPROT        ,
input  [31:0]M3_HWDATA       ,
//slv0
input        S0_HREADY       ,
input  [ 1:0]S0_HRESP        ,
input  [15:0]S0_HSPLIT       ,
input  [31:0]S0_HRDATA       ,
//slv1
input        S1_HREADY       ,
input  [ 1:0]S1_HRESP        ,
input  [15:0]S1_HSPLIT       ,
input  [31:0]S1_HRDATA       ,
//slv2
input        S2_HREADY       ,
input  [ 1:0]S2_HRESP        ,
input  [15:0]S2_HSPLIT       ,
input  [31:0]S2_HRDATA       ,
//slv3
input        S3_HREADY       ,
input  [ 1:0]S3_HRESP        ,
input  [15:0]S3_HSPLIT       ,
input  [31:0]S3_HRDATA       ,
//
input        S4_HREADY       ,
input  [ 1:0]S4_HRESP        ,
input  [15:0]S4_HSPLIT       ,
input  [31:0]S4_HRDATA       ,
//              
input        S5_HREADY       ,
input  [ 1:0]S5_HRESP        ,
input  [15:0]S5_HSPLIT       ,
input  [31:0]S5_HRDATA       ,
//              
input        S6_HREADY       ,
input  [ 1:0]S6_HRESP        ,
input  [15:0]S6_HSPLIT       ,
input  [31:0]S6_HRDATA       ,
//              
input        S7_HREADY       ,
input  [ 1:0]S7_HRESP        ,
input  [15:0]S7_HSPLIT       ,
input  [31:0]S7_HRDATA       ,
//              
input        S8_HREADY       ,
input  [ 1:0]S8_HRESP        ,
input  [15:0]S8_HSPLIT       ,
input  [31:0]S8_HRDATA       ,
//              
input        S9_HREADY       ,
input  [ 1:0]S9_HRESP        ,
input  [15:0]S9_HSPLIT       ,
input  [31:0]S9_HRDATA       ,
//               
input        S10_HREADY      ,
input  [ 1:0]S10_HRESP       ,
input  [15:0]S10_HSPLIT      ,
input  [31:0]S10_HRDATA      ,
//               
input        S11_HREADY      ,
input  [ 1:0]S11_HRESP       ,
input  [15:0]S11_HSPLIT      ,
input  [31:0]S11_HRDATA      ,
//               
input        S12_HREADY      ,
input  [ 1:0]S12_HRESP       ,
input  [15:0]S12_HSPLIT      ,
input  [31:0]S12_HRDATA      ,
//               
input        S13_HREADY      ,
input  [ 1:0]S13_HRESP       ,
input  [15:0]S13_HSPLIT      ,
input  [31:0]S13_HRDATA      ,
//              
input        S14_HREADY      ,
input  [ 1:0]S14_HRESP       ,
input  [15:0]S14_HSPLIT      ,
input  [31:0]S14_HRDATA      ,
//             
input        S15_HREADY      ,
input  [ 1:0]S15_HRESP       ,
input  [15:0]S15_HSPLIT      ,
input  [31:0]S15_HRDATA   
);

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
wire   [15:0]wHGRANT         ;
wire   [ 1:0]wHRESP          ;
wire   [15:0]wHSPLIT         ;
wire   [31:0]wHRDATA         ;
wire         wHREADY         ;
wire         wDefaultSlv     ;
wire         wDefaultMst     ;
wire   [15:0]wHBUSREQ        ;


ahb_arbiter u_arbiter(
.HCLK         (HCLK          )   , //clock
.HRST_N       (HRST_N        )   , //reset
.HBUSREQ      (wHBUSREQ      )   , //all master
.HGRANT       (wHGRANT       )   , //all master
.HMASTERLOCK  (wHMASTERLOCK  )   ,
.HMASTER      (wHMASTER      )   ,
.DefaultMst   (wDefaultMst   )   ,
.DefaultSlv   (wDefaultSlv   )   ,
.HREADY       (wHREADY       )   ,
.HRESP        (wHRESP        )   ,
.HSPLIT       (wHSPLIT       )   ,
.HLOCK        (wHLOCK        )   ,
.HTRANS       (wHTRANS       )   ,
.HBURST       (wHBURST       )   
);


ahb_mux u_mux(
.HCLK         (HCLK          )   ,//clock
.HRST_N       (HRST_N        )   ,//reset
.DefaultMst   (wDefaultMst   )   ,
.DefaultSlv   (wDefaultSlv   )   ,
.HMASTER      (wHMASTER      )   ,
.HSEL         (wHSEL         )   ,
.HBUSREQ      (wHBUSREQ      )   ,
.HLOCK        (wHLOCK        )   ,
.HADDR        (wHADDR        )   ,
.HSIZE        (wHSIZE        )   ,
.HWRITE       (wHWRITE       )   ,
.HTRANS       (wHTRANS       )   ,
.HBURST       (wHBURST       )   ,
.HPROT        (wHPROT        )   ,
.HWDATA       (wHWDATA       )   ,
.HREADY       (wHREADY       )   ,
.HRESP        (wHRESP        )   ,
.HSPLIT       (wHSPLIT       )   ,
.HRDATA       (wHRDATA       )   ,
//
//
.M0_HBUSREQ   (M0_HBUSREQ    )   ,
.M0_HLOCK     (M0_HLOCK      )   ,
.M0_HADDR     (M0_HADDR      )   ,
.M0_HSIZE     (M0_HSIZE      )   ,
.M0_HWRITE    (M0_HWRITE     )   ,
.M0_HTRANS    (M0_HTRANS     )   ,
.M0_HBURST    (M0_HBURST     )   ,
.M0_HPROT     (M0_HPROT      )   ,
.M0_HWDATA    (M0_HWDATA     )   ,
//                           
.M1_HBUSREQ   (M1_HBUSREQ    )   ,
.M1_HLOCK     (M1_HLOCK      )   ,
.M1_HADDR     (M1_HADDR      )   ,
.M1_HSIZE     (M1_HSIZE      )   ,
.M1_HWRITE    (M1_HWRITE     )   ,
.M1_HTRANS    (M1_HTRANS     )   ,
.M1_HBURST    (M1_HBURST     )   ,
.M1_HPROT     (M1_HPROT      )   ,
.M1_HWDATA    (M1_HWDATA     )   ,
//                           
.M2_HBUSREQ   (M2_HBUSREQ    )   ,
.M2_HLOCK     (M2_HLOCK      )   ,
.M2_HADDR     (M2_HADDR      )   ,
.M2_HSIZE     (M2_HSIZE      )   ,
.M2_HWRITE    (M2_HWRITE     )   ,
.M2_HTRANS    (M2_HTRANS     )   ,
.M2_HBURST    (M2_HBURST     )   ,
.M2_HPROT     (M2_HPROT      )   ,
.M2_HWDATA    (M2_HWDATA     )   ,
//                           
.M3_HBUSREQ   (M3_HBUSREQ    )   ,
.M3_HLOCK     (M3_HLOCK      )   ,
.M3_HADDR     (M3_HADDR      )   ,
.M3_HSIZE     (M3_HSIZE      )   ,
.M3_HWRITE    (M3_HWRITE     )   ,
.M3_HTRANS    (M3_HTRANS     )   ,
.M3_HBURST    (M3_HBURST     )   ,
.M3_HPROT     (M3_HPROT      )   ,
.M3_HWDATA    (M3_HWDATA     )   ,
//                           
.S0_HREADY    (S0_HREADY     )   ,
.S0_HRESP     (S0_HRESP      )   ,
.S0_HSPLIT    (S0_HSPLIT     )   ,
.S0_HRDATA    (S0_HRDATA     )   ,
//                           
.S1_HREADY    (S1_HREADY     )   ,
.S1_HRESP     (S1_HRESP      )   ,
.S1_HSPLIT    (S1_HSPLIT     )   ,
.S1_HRDATA    (S1_HRDATA     )   ,
//                           
.S2_HREADY    (S2_HREADY     )   ,
.S2_HRESP     (S2_HRESP      )   ,
.S2_HSPLIT    (S2_HSPLIT     )   ,
.S2_HRDATA    (S2_HRDATA     )   ,
//                           
.S3_HREADY    (S3_HREADY     )   ,
.S3_HRESP     (S3_HRESP      )   ,
.S3_HSPLIT    (S3_HSPLIT     )   ,
.S3_HRDATA    (S3_HRDATA     )   ,
//slv4       
.S4_HREADY    (S4_HREADY     )   ,
.S4_HRESP     (S4_HRESP      )   ,
.S4_HSPLIT    (S4_HSPLIT     )   ,
.S4_HRDATA    (S4_HRDATA     )   , 
//slv5         
.S5_HREADY    (S5_HREADY     )   ,
.S5_HRESP     (S5_HRESP      )   ,
.S5_HSPLIT    (S5_HSPLIT     )   ,
.S5_HRDATA    (S5_HRDATA     )   , 
//slv6         
.S6_HREADY    (S6_HREADY     )   ,
.S6_HRESP     (S6_HRESP      )   ,
.S6_HSPLIT    (S6_HSPLIT     )   ,
.S6_HRDATA    (S6_HRDATA     )   , 
//slv7         
.S7_HREADY    (S7_HREADY     )   ,
.S7_HRESP     (S7_HRESP      )   ,
.S7_HSPLIT    (S7_HSPLIT     )   ,
.S7_HRDATA    (S7_HRDATA     )   , 
//slv8         
.S8_HREADY    (S8_HREADY     )   ,
.S8_HRESP     (S8_HRESP      )   ,
.S8_HSPLIT    (S8_HSPLIT     )   ,
.S8_HRDATA    (S8_HRDATA     )   , 
//slv9         
.S9_HREADY    (S9_HREADY     )   ,
.S9_HRESP     (S9_HRESP      )   ,
.S9_HSPLIT    (S9_HSPLIT     )   ,
.S9_HRDATA    (S9_HRDATA     )   , 
//slv10         
.S10_HREADY   (S10_HREADY    )   ,
.S10_HRESP    (S10_HRESP     )   ,
.S10_HSPLIT   (S10_HSPLIT    )   ,
.S10_HRDATA   (S10_HRDATA    )   , 
//slv11         
.S11_HREADY   (S11_HREADY    )   ,
.S11_HRESP    (S11_HRESP     )   ,
.S11_HSPLIT   (S11_HSPLIT    )   ,
.S11_HRDATA   (S11_HRDATA    )   , 
//slv12         
.S12_HREADY   (S12_HREADY    )   ,
.S12_HRESP    (S12_HRESP     )   ,
.S12_HSPLIT   (S12_HSPLIT    )   ,
.S12_HRDATA   (S12_HRDATA    )   , 
//slv13         
.S13_HREADY   (S13_HREADY    )   ,
.S13_HRESP    (S13_HRESP     )   ,
.S13_HSPLIT   (S13_HSPLIT    )   ,
.S13_HRDATA   (S13_HRDATA    )   , 
//slv14         
.S14_HREADY   (S14_HREADY    )   ,
.S14_HRESP    (S14_HRESP     )   ,
.S14_HSPLIT   (S14_HSPLIT    )   ,
.S14_HRDATA   (S14_HRDATA    )   , 
//slv15         
.S15_HREADY   (S15_HREADY    )   ,
.S15_HRESP    (S15_HRESP     )   ,
.S15_HSPLIT   (S15_HSPLIT    )   ,
.S15_HRDATA   (S15_HRDATA    )   
);



assign   HSEL         =  wHSEL         ;
assign   HMASTER      =  wHMASTER      ;
assign   HMASTERLOCK  =  wHMASTERLOCK  ;
assign   HADDR        =  wHADDR        ;
assign   HSIZE        =  wHSIZE        ;
assign   HWRITE       =  wHWRITE       ;
assign   HTRANS       =  wHTRANS       ;
assign   HBURST       =  wHBURST       ;
assign   HPROT        =  wHPROT        ;
assign   HWDATA       =  wHWDATA       ;
assign   HGRANT       =  wHGRANT       ;
assign   HRESP        =  wHRESP        ;
assign   HSPLIT       =  wHSPLIT       ;
assign   HRDATA       =  wHRDATA       ;
assign   HREADY       =  wHREADY       ;

endmodule
