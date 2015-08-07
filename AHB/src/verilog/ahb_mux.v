//================================================================================
// Created by         : Ltd.com
// Filename           : ahb_mux.v
// Author             : Python_Wang
// Created On         : 2009-06-03 15:42
// Last Modified      : 2009-06-15 22:46
// Description        : 
//                      
//                      
//================================================================================
module AHB_MUX(
input         HCLK            ,//clock
input         HRST_N          ,//reset
input         DefaultMst      ,
input         DefaultSlv      ,
input  [ 3:0] HMASTER         ,

output [15:0] HSEL            ,
output [15:0] HBUSREQ         ,

output        HLOCK           ,
output [31:0] HADDR           ,
output [ 2:0] HSIZE           ,
output        HWRITE          ,
output [ 1:0] HTRANS          ,
output [ 2:0] HBURST          ,
output [ 3:0] HPROT           ,
output [31:0] HWDATA          ,

output        HREADY          ,
output [ 1:0] HRESP           ,
output [15:0] HSPLIT          ,
output [31:0] HRDATA          ,

//mst0
input         M0_HBUSREQ      ,
input         M0_HLOCK        ,
input  [31:0] M0_HADDR        ,
input  [ 2:0] M0_HSIZE        ,
input         M0_HWRITE       ,
input  [ 1:0] M0_HTRANS       ,
input  [ 2:0] M0_HBURST       ,
input  [ 3:0] M0_HPROT        ,
input  [31:0] M0_HWDATA       ,
//mst1
input         M1_HBUSREQ      ,
input         M1_HLOCK        ,
input  [31:0] M1_HADDR        ,
input  [ 2:0] M1_HSIZE        ,
input         M1_HWRITE       ,
input  [ 1:0] M1_HTRANS       ,
input  [ 2:0] M1_HBURST       ,
input  [ 3:0] M1_HPROT        ,
input  [31:0] M1_HWDATA       ,
//mst2
input         M2_HBUSREQ      ,
input         M2_HLOCK        ,
input  [31:0] M2_HADDR        ,
input  [ 2:0] M2_HSIZE        ,
input         M2_HWRITE       ,
input  [ 1:0] M2_HTRANS       ,
input  [ 2:0] M2_HBURST       ,
input  [ 3:0] M2_HPROT        ,
input  [31:0] M2_HWDATA       ,
//mst3
input         M3_HBUSREQ      ,
input         M3_HLOCK        ,
input  [31:0] M3_HADDR        ,
input  [ 2:0] M3_HSIZE        ,
input         M3_HWRITE       ,
input  [ 1:0] M3_HTRANS       ,
input  [ 2:0] M3_HBURST       ,
input  [ 3:0] M3_HPROT        ,
input  [31:0] M3_HWDATA       ,
//slv0
input         S0_HREADY       ,
input  [ 1:0] S0_HRESP        ,
input  [15:0] S0_HSPLIT       ,
input  [31:0] S0_HRDATA       ,
//slv1
input         S1_HREADY       ,
input  [ 1:0] S1_HRESP        ,
input  [15:0] S1_HSPLIT       ,
input  [31:0] S1_HRDATA       ,
//slv2
input         S2_HREADY       ,
input  [ 1:0] S2_HRESP        ,
input  [15:0] S2_HSPLIT       ,
input  [31:0] S2_HRDATA       ,
//slv3
input         S3_HREADY       ,
input  [ 1:0] S3_HRESP        ,
input  [15:0] S3_HSPLIT       ,
input  [31:0] S3_HRDATA       ,
//
input         S4_HREADY       ,
input  [ 1:0] S4_HRESP        ,
input  [15:0] S4_HSPLIT       ,
input  [31:0] S4_HRDATA       ,
//               
input         S5_HREADY       ,
input  [ 1:0] S5_HRESP        ,
input  [15:0] S5_HSPLIT       ,
input  [31:0] S5_HRDATA       ,
//               
input         S6_HREADY       ,
input  [ 1:0] S6_HRESP        ,
input  [15:0] S6_HSPLIT       ,
input  [31:0] S6_HRDATA       ,
//               
input         S7_HREADY       ,
input  [ 1:0] S7_HRESP        ,
input  [15:0] S7_HSPLIT       ,
input  [31:0] S7_HRDATA       ,
//               
input         S8_HREADY       ,
input  [ 1:0] S8_HRESP        ,
input  [15:0] S8_HSPLIT       ,
input  [31:0] S8_HRDATA       ,
//               
input         S9_HREADY       ,
input  [ 1:0] S9_HRESP        ,
input  [15:0] S9_HSPLIT       ,
input  [31:0] S9_HRDATA       ,
//                
input         S10_HREADY      ,
input  [ 1:0] S10_HRESP       ,
input  [15:0] S10_HSPLIT      ,
input  [31:0] S10_HRDATA      ,
//                
input         S11_HREADY      ,
input  [ 1:0] S11_HRESP       ,
input  [15:0] S11_HSPLIT      ,
input  [31:0] S11_HRDATA      ,
//                
input         S12_HREADY      ,
input  [ 1:0] S12_HRESP       ,
input  [15:0] S12_HSPLIT      ,
input  [31:0] S12_HRDATA      ,
//                
input         S13_HREADY      ,
input  [ 1:0] S13_HRESP       ,
input  [15:0] S13_HSPLIT      ,
input  [31:0] S13_HRDATA      ,
//               
input         S14_HREADY      ,
input  [ 1:0] S14_HRESP       ,
input  [15:0] S14_HSPLIT      ,
input  [31:0] S14_HRDATA      ,
//              
input         S15_HREADY      ,
input  [ 1:0] S15_HRESP       ,
input  [15:0] S15_HSPLIT      ,
input  [31:0] S15_HRDATA   
);
reg           iHLOCK          ;
reg    [31:0] iHADDR          ;
reg    [ 2:0] iHSIZE          ;
reg           iHWRITE         ;
reg    [ 1:0] iHTRANS         ;
reg    [ 2:0] iHBURST         ;
reg    [ 3:0] iHPROT          ;
reg    [31:0] iHWDATA         ;

reg           iHREADY         ;
reg    [15:0] iHSEL           ;
reg    [15:0] iHSELQ          ;
reg    [ 1:0] iHRESP          ;
reg    [15:0] iHSPLIT         ;
reg    [31:0] iHRDATA         ;

reg    [15:0] iHBUSREQ        ;
reg           DefaultMstQ     ;

wire          DEF_HLOCK       ;
wire   [31:0] DEF_HADDR       ;
wire   [ 2:0] DEF_HSIZE       ;
wire          DEF_HWRITE      ;
wire   [ 1:0] DEF_HTRANS      ;
wire   [ 2:0] DEF_HBURST      ;
wire   [ 3:0] DEF_HPROT       ;
wire   [31:0] DEF_HWDATA      ;

wire          DEF_HREADY      ;
wire   [ 1:0] DEF_HRESP       ;
wire   [15:0] DEF_HSPLIT      ;
wire   [31:0] DEF_HRDATA      ;

reg    [ 3:0]HMASTERQ        ;
always @(posedge HCLK or negedge HRST_N) begin
    if (!HRST_N) begin
        HMASTERQ <= #1 4'b0    ;
        DefaultMstQ <= #1 1'b0 ;
    end
    else if(iHREADY) begin
        HMASTERQ <= #1 HMASTER ;
        DefaultMstQ <= #1 DefaultMst ;
    end
end


//master
always @(*) begin
    if(DefaultMst) begin
        iHLOCK   = DEF_HLOCK   ;
        iHADDR   = DEF_HADDR   ; 
        iHSIZE   = DEF_HSIZE   ; 
        iHWRITE  = DEF_HWRITE  ; 
        iHTRANS  = DEF_HTRANS  ; 
        iHBURST  = DEF_HBURST  ; 
        iHPROT   = DEF_HPROT   ; 
    end
    else begin
        case(HMASTER)
            4'b0000 : begin 
                iHLOCK   = M0_HLOCK   ;
                iHADDR   = M0_HADDR   ; 
                iHSIZE   = M0_HSIZE   ; 
                iHWRITE  = M0_HWRITE  ; 
                iHTRANS  = M0_HTRANS  ; 
                iHBURST  = M0_HBURST  ; 
                iHPROT   = M0_HPROT   ; 
            end
            4'b0001 : begin 
                iHLOCK   = M0_HLOCK   ;
                iHADDR   = M1_HADDR   ; 
                iHSIZE   = M1_HSIZE   ; 
                iHWRITE  = M1_HWRITE  ; 
                iHTRANS  = M1_HTRANS  ; 
                iHBURST  = M1_HBURST  ; 
                iHPROT   = M1_HPROT   ; 
            end
            4'b0010 : begin 
                iHLOCK   = M0_HLOCK   ;
                iHADDR   = M2_HADDR   ; 
                iHSIZE   = M2_HSIZE   ; 
                iHWRITE  = M2_HWRITE  ; 
                iHTRANS  = M2_HTRANS  ; 
                iHBURST  = M2_HBURST  ; 
                iHPROT   = M2_HPROT   ; 
            end
            4'b0011 : begin 
                iHLOCK   = M0_HLOCK   ;
                iHADDR   = M3_HADDR   ; 
                iHSIZE   = M3_HSIZE   ; 
                iHWRITE  = M3_HWRITE  ; 
                iHTRANS  = M3_HTRANS  ; 
                iHBURST  = M3_HBURST  ; 
                iHPROT   = M3_HPROT   ; 
            end
            default : begin
                iHLOCK   = DEF_HLOCK  ;
                iHADDR   = DEF_HADDR  ; 
                iHSIZE   = DEF_HSIZE  ; 
                iHWRITE  = DEF_HWRITE ; 
                iHTRANS  = DEF_HTRANS ; 
                iHBURST  = DEF_HBURST ; 
                iHPROT   = DEF_HPROT  ; 
            end
        endcase
    end
end

always @(*) begin
    if(DefaultMstQ) begin
        iHWDATA = DEF_HWDATA     ;
    end
    else begin
        case(HMASTERQ)
            4'b0000 :  iHWDATA = M0_HWDATA   ;
            4'b0001 :  iHWDATA = M1_HWDATA   ;
            4'b0010 :  iHWDATA = M2_HWDATA   ;
            4'b0011 :  iHWDATA = M3_HWDATA   ;
            default :  iHWDATA = DEF_HWDATA  ;
        endcase
    end
end

always @(*) begin
    iHBUSREQ = 16'b0 ;
    iHBUSREQ[0] = M0_HBUSREQ  ;
    iHBUSREQ[1] = M1_HBUSREQ  ;
    iHBUSREQ[2] = M2_HBUSREQ  ;
    iHBUSREQ[3] = M3_HBUSREQ  ;
end
//slaver
always @(*) begin
    iHSEL = 16'b0 ;
    if(iHADDR)
        case(iHADDR[`AHB_ADDR_H:`AHB_ADDR_L]) 
            `AHB_SLV0_BASE :  iHSEL[ 0] =  1'b1 ;
            `AHB_SLV1_BASE :  iHSEL[ 1] =  1'b1 ;
            `AHB_SLV2_BASE :  iHSEL[ 2] =  1'b1 ;
            `AHB_SLV3_BASE :  iHSEL[ 3] =  1'b1 ;
            `AHB_SLV4_BASE :  iHSEL[ 4] =  1'b1 ;
            `AHB_SLV5_BASE :  iHSEL[ 5] =  1'b1 ;
            `AHB_SLV6_BASE :  iHSEL[ 6] =  1'b1 ;
            `AHB_SLV7_BASE :  iHSEL[ 7] =  1'b1 ;
            `AHB_SLV8_BASE :  iHSEL[ 8] =  1'b1 ;
            `AHB_SLV9_BASE :  iHSEL[ 9] =  1'b1 ;
            `AHB_SLV10_BASE:  iHSEL[10] =  1'b1 ;
            `AHB_SLV11_BASE:  iHSEL[11] =  1'b1 ;
            `AHB_SLV12_BASE:  iHSEL[12] =  1'b1 ;
            `AHB_SLV13_BASE:  iHSEL[13] =  1'b1 ;
            `AHB_SLV14_BASE:  iHSEL[14] =  1'b1 ;
            `AHB_SLV15_BASE:  iHSEL[15] =  1'b1 ;
            default        :  iHSEL     = 16'b0 ;
        endcase
    end
end

always @(posedge HCLK or negedge HRST_N) begin
    if (!HRST_N) begin
        iHSELQ <= #1 16'b0 ;
    end
    else if(iHREADY) begin
        iHSELQ <= #1 iHSEL ;
    end
end

always @(*) begin
    if(DefaultSlv) begin
        iHREADY     =   DEF_HREADY   ;
        iHRESP      =   DEF_HRESP    ;
        iHRDATA     =   DEF_HRDATA   ;
    end
    else begin
        case(iHSELQ) 
            16'b0000_0000_0000_0001  :  begin
                iHREADY     =   S0_HREADY   ;
                iHRESP      =   S0_HRESP    ;
                iHRDATA     =   S0_HRDATA   ;
            end
            16'b0000_0000_0000_0010  :  begin
                iHREADY     =   S1_HREADY   ;
                iHRESP      =   S1_HRESP    ;
                iHRDATA     =   S1_HRDATA   ;
            end
            16'b0000_0000_0000_0100  :  begin
                iHREADY     =   S2_HREADY   ;
                iHRESP      =   S2_HRESP    ;
                iHRDATA     =   S2_HRDATA   ;
            end
            16'b0000_0000_0000_1000  :  begin
                iHREADY     =   S3_HREADY   ;
                iHRESP      =   S3_HRESP    ;
                iHRDATA     =   S3_HRDATA   ;
            end
            16'b0000_0000_0001_0000  :  begin
                iHREADY     =   S4_HREADY   ;
                iHRESP      =   S4_HRESP    ;
                iHRDATA     =   S4_HRDATA   ;
            end
            16'b0000_0000_0010_0000  :  begin
                iHREADY     =   S5_HREADY   ;
                iHRESP      =   S5_HRESP    ;
                iHRDATA     =   S5_HRDATA   ;
            end
            16'b0000_0000_0100_0000  :  begin
                iHREADY     =   S6_HREADY   ;
                iHRESP      =   S6_HRESP    ;
                iHRDATA     =   S6_HRDATA   ;
            end
            16'b0000_0000_1000_0000  :  begin
                iHREADY     =   S7_HREADY   ;
                iHRESP      =   S7_HRESP    ;
                iHRDATA     =   S7_HRDATA   ;
            end
            16'b0000_0001_0000_0000  :  begin
                iHREADY     =   S8_HREADY   ;
                iHRESP      =   S8_HRESP    ;
                iHRDATA     =   S8_HRDATA   ;
            end
            16'b0000_0010_0000_0000  :  begin
                iHREADY     =   S9_HREADY   ;
                iHRESP      =   S9_HRESP    ;
                iHRDATA     =   S9_HRDATA   ;
            end
            16'b0000_0100_0000_0000  :  begin
                iHREADY     =   S10_HREADY  ;
                iHRESP      =   S10_HRESP   ;
                iHRDATA     =   S10_HRDATA  ;
            end
            16'b0000_1000_0000_0000  :  begin
                iHREADY     =   S11_HREADY  ;
                iHRESP      =   S11_HRESP   ;
                iHRDATA     =   S11_HRDATA  ;
            end
            16'b0001_0000_0000_0000  :  begin
                iHREADY     =   S12_HREADY  ;
                iHRESP      =   S12_HRESP   ;
                iHRDATA     =   S12_HRDATA  ;
            end
            16'b0010_0000_0000_0000  :  begin
                iHREADY     =   S13_HREADY  ;
                iHRESP      =   S13_HRESP   ;
                iHRDATA     =   S13_HRDATA  ;
            end
            16'b0100_0000_0000_0000  :  begin
                iHREADY     =   S14_HREADY  ;
                iHRESP      =   S14_HRESP   ;
                iHRDATA     =   S14_HRDATA  ;
            end
            16'b1000_0000_0000_0000  :  begin
                iHREADY     =   S15_HREADY  ;
                iHRESP      =   S15_HRESP   ;
                iHRDATA     =   S15_HRDATA  ;
            end
            default        :  begin
                iHREADY     =   DEF_HREADY  ;
                iHRESP      =   DEF_HRESP   ;
                iHRDATA     =   DEF_HRDATA  ;
            end
        endcase
    end
end

always @(*) begin
    iHSPLIT = DEF_HSPLIT | S0_HSPLIT | S1_HSPLIT | S2_HSPLIT | S3_HSPLIT 
                         | S4_HSPLIT | S5_HSPLIT | S6_HSPLIT | S7_HSPLIT 
                         | S8_HSPLIT | S9_HSPLIT | S10_HSPLIT| S11_HSPLIT 
                         | S12_HSPLIT| S13_HSPLIT| S14_HSPLIT| S15_HSPLIT  ;
end

assign   HSEL       =   iHSEL       ;
assign   HBUSREQ    =   iHBUSREQ    ;
assign   HLOCK      =   iHLOCK      ;
assign   HADDR      =   iHADDR      ;
assign   HSIZE      =   iHSIZE      ;
assign   HWRITE     =   iHWRITE     ;
assign   HTRANS     =   iHTRANS     ;
assign   HBURST     =   iHBURST     ;
assign   HPROT      =   iHPROT      ;
assign   HWDATA     =   iHWDATA     ;
assign   HREADY     =   iHREADY     ;
assign   HRESP      =   iHRESP      ;
assign   HSPLIT     =   iHSPLIT     ;
assign   HRDATA     =   iHRDATA     ;

DEF_MST DEFAULT_MASTER(
    .HLOCK     (DEF_HLOCK   )     ,
    .HADDR     (DEF_HADDR   )     ,
    .HSIZE     (DEF_HSIZE   )     ,
    .HWRITE    (DEF_HWRITE  )     ,
    .HTRANS    (DEF_HTRANS  )     ,
    .HBURST    (DEF_HBURST  )     ,
    .HPROT     (DEF_HPROT   )     ,
    .HWDATA    (DEF_HWDATA  )     
    );

DEF_SLV U_DEF_SLV (
    .HCLK      (HCLK        )     , 
    .HRST_N    (HRST_N      )     , 
    .HTRANS    (iHTRANS     )     ,
    .HREADY    (iHREADY     )     ,
    .DefaultSlv(DefaultSlv  )     ,
    .HREADY_O  (DEF_HREADY  )     ,
    .HRESP     (DEF_HRESP   )     ,
    .HRDATA    (DEF_HRDATA  )     ,
    .HSPLIT    (DEF_HSPLIT  )      
    );
endmodule
