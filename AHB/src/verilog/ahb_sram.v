//================================================================================
// Created by         : Ltd.com
// Filename           : ahb_sram.v
// Author             : Python_Wang
// Created On         : 2009-02-20 15:46
// Last Modified      : 2009-06-12 12:51
// Description        : 
//                      
//                      
//================================================================================
module ahb_sram(
input         HCLK           , //clock
input         HRST_N         , //reset
input         HREADY          ,
input         HSEL             ,
input   [31:0]HADDR             ,
input   [ 2:0]HSIZE              ,
input         HWRITE              ,
input   [ 1:0]HTRANS               ,
input   [ 2:0]HBURST                ,
input   [31:0]HWDATA                ,
//to ahb                            ,
output        HREADY_O              ,
output  [ 1:0]HRESP                 ,
output  [15:0]HSPLIT                ,
output  [31:0]HRDATA                
);

//register
reg           hready         ;


wire          hsel = HREADY && HSEL && HTRANS[1] ;
reg           hsel_r         ;
always @(posedge HCLK or negedge HRST_N)
begin
  if (!HRST_N) begin
    hsel_r <= #1 'b0;
  end
  else if(HREADY) begin
    hsel_r <= #1 hsel ;
  end
end

reg           hwrite_r       ;
reg     [31:0]haddr_r        ;
reg     [ 2:0]hsize_r        ;

always @(posedge HCLK or negedge HRST_N)
begin
  if (!HRST_N) begin
    haddr_r  <= #1 'b0;
    hsize_r  <= #1 'b0;
    hwrite_r <= #1 'b0;
  end
  else if(HREADY) begin
    haddr_r  <= #1 HADDR ;
    hsize_r  <= #1 HSIZE ;
    hwrite_r <= #1 HWRITE & hsel ;
  end
end

always @(posedge HCLK or negedge HRST_N)
begin
  if (!HRST_N) begin
    hready <= #1 'b1;
  end
  else if(hwrite_r) begin
    hready <= #1 ~(hsel && ~HWRITE);
  end
  else begin
    hready <= #1 1'b1;
  end
end



wire   [31:0]ramdatao        ; //ram output data
reg    [31:0]ramdatai        ; //ram input data
reg    [31:0]ramaddr         ; //ram input address
reg    [ 3:0]ram_wr          ; //ram bank write 
reg    [ 3:0]ram_rd          ; //ram bank read
reg          ram_sel         ; //ram selsect

always @(*)
begin
  ram_wr  =  4'b0 ;
  ram_rd  =  4'b0 ;
  ramaddr = 32'b0 ;
  ram_sel =  1'b0 ;
  ramdatai = HWDATA ;

  if(hwrite_r) begin
    case(hsize_r)
      2'b00  : begin
      	case(haddr_r[1:0])
      	  2'b00  :  ram_wr[0] = 1'b1;
      	  2'b01  :  ram_wr[1] = 1'b1;
      	  2'b10  :  ram_wr[2] = 1'b1;
      	  2'b11  :  ram_wr[3] = 1'b1;
      	  default:  ram_wr    = 4'b0;
      	endcase
      end
      2'b01  : begin
        	ram_wr = {haddr_r[1],haddr_r[1],~haddr_r[1],~haddr_r[1]};
      end
      default: begin
        	ram_wr = 4'b1111;
      end
    endcase
  end
  
  if(hsel & ~HWRITE) begin
    case(HSIZE)
      2'b00  : begin
	case(HADDR[1:0])
	  2'b00  : ram_rd[0] = 1'b1;
	  2'b01  : ram_rd[1] = 1'b1;
	  2'b10  : ram_rd[2] = 1'b1;
	  2'b11  : ram_rd[3] = 1'b1;
	  default: ram_rd    = 4'b0;
	endcase
      end
      2'b01  : begin
	       ram_rd = {HADDR[1],HADDR[1],~HADDR[1],~HADDR[1]};
      end
      default: begin
        	ram_rd = 4'b1111;
      end
    endcase
  end

  if(hwrite_r || ~hready) begin
    ramaddr = {25'b0, haddr_r[6:0]} ;
  end
  else begin
    ramaddr = {25'b0, HADDR[6:0]}   ;
  end

  ram_sel = hsel & (~HWRITE) | hwrite_r ;
end

assign        HRESP    =  2'b0  ;
assign        HSPLIT   = 16'b0  ;
assign        HREADY_O = hready ;
assign        HRDATA   = ramdatao;

sram #(.aw(32), .dw(8), .depth(128)) ram0 (
.CLK    (HCLK          )  ,
.CEN    (~ram_sel      )  ,
.WEN    (~ram_wr[0]    )  ,
.A      (ramaddr       )  ,
.D      (ramdatai[7:0]   )  ,
.OEN    (~ram_rd[0]    )  ,
.Q      (ramdatao[7:0]  )
);

sram #(.aw(32), .dw(8), .depth(128)) ram1 (
.CLK    (HCLK          )  ,
.CEN    (~ram_sel      )  ,
.WEN    (~ram_wr[1]    )  ,
.A      (ramaddr       )  ,
.D      (ramdatai[15:8]  )  ,
.OEN    (~ram_rd[1]    )  ,
.Q      (ramdatao[15:8] )
);

sram #(.aw(32), .dw(8), .depth(128)) ram2 (
.CLK    (HCLK          )  ,
.CEN    (~ram_sel      )  ,
.WEN    (~ram_wr[2]    )  ,
.A      (ramaddr       )  ,
.D      (ramdatai[23:16] )  ,
.OEN    (~ram_rd[2]    )  ,
.Q      (ramdatao[23:16])
);

sram #(.aw(32), .dw(8), .depth(128)) ram3 (
.CLK    (HCLK          )  ,
.CEN    (~ram_sel      )  ,
.WEN    (~ram_wr[3]    )  ,
.A      (ramaddr       )  ,
.D      (ramdatai[31:24] )  ,
.OEN    (~ram_rd[3]    )  ,
.Q      (ramdatao[31:24])
);
endmodule
