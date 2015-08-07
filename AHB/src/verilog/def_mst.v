//================================================================================
// Created by         : Ltd.com
// Filename           : def_mst.v
// Author             : Python_Wang
// Created On         : 2009-06-03 15:37
// Last Modified      : 2009-06-03 17:46
// Description        : 
//                      
//                      
//================================================================================

module DEF_MST(
output        HLOCK           ,
output [31:0] HADDR           ,
output [ 2:0] HSIZE           ,
output        HWRITE          ,
output [ 1:0] HTRANS          ,
output [ 2:0] HBURST          ,
output [ 3:0] HPROT           ,
output [31:0] HWDATA          
);
assign        HLOCK      =  1'b0          ;
assign        HADDR      = 32'b0          ;
assign        HTRANS     = `HTRANS_IDLE   ;
assign        HBURST     = `HBURST_SINGLE ;
assign        HSIZE      = `HSIZE_WORD    ;
assign        HWRITE     =  1'b0          ;
assign        HPROT      =  4'b0          ;
assign        HWDATA     = 32'b0          ;
endmodule
