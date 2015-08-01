//================================================================================
// Created by         : Ltd.com
// Filename           : ahb2apb.v
// Author             : Python_Wang
// Created On         : 2009-06-04 23:10
// Last Modified      : 2009-06-09 17:42
// Description        : 
//                      
//                      
//================================================================================

module ahb2apb(
HCLK         ,
HRST_N       ,

HSEL         ,
HWRITE       ,
HADDR        ,
HTRANS       ,
HWDATA       ,
HREADY       ,

HREADY_o     ,
HRESP        ,
HRDATA       ,
HSPLIT       ,

PADDR        ,
PWRITE       ,
PWDATA       ,
PSEL         ,
PENABLE      ,

PRDATA     
);

input         HCLK    ;
input         HRST_N  ;

input  [31:0] HADDR   ;
input  [1 :0] HTRANS  ;
input  [31:0] HWDATA  ;
input         HSEL    ;
input         HWRITE  ;
input  [31:0] PRDATA  ;
input         HREADY  ;

output        HREADY_o;
output [1 :0] HRESP   ;
output [31:0] HRDATA  ;
output [15:0] HSPLIT  ;

output [31:0] PADDR   ;
output [31:0] PWDATA  ;
output        PENABLE ;
output        PWRITE  ;
output [15:0] PSEL    ;


//apb output register
reg [31:0] PADDR   ;
reg [31:0] PWDATA  ;
reg        PENABLE ;
reg        PWRITE  ;
reg [15:0] PSEL    ;
reg        HREADY_o;
//
reg [31:0] addr_r    ; //地址寄存器
reg        wr_r      ;//读写控制器
reg [15:0] psel_r    ;
reg        write_en  ;

wire [31:0] addr_mux_r;
wire        valid_wr  ;//有效读写
wire        setup_en  ;//读写操作setup段使能 
wire        enable_en ;//读写操作enable段使能
wire        ready_en  ;//apb桥的ready输出信号

reg    [3 :0] CS , NS;

parameter  IDLE               = 4'b0000, //空闲状态
           READ_SETUP         = 4'b0001, //读setup（包含连续读）
	   READ_ENABLE        = 4'b0010, //读enable（包含连续读）
	   WRITE_WAIT         = 4'b0100, //写等待，因为写apb要在地址段和数据段数据都传输后开始
	   WRITE_SETUP        = 4'b0101, //单笔写setup
	   WRITE_ENABLE       = 4'b1001, //单笔写enable
	   BURST_WRITE_SETUP  = 4'b1100, //连续写setup
	   BURST_WRITE_ENABLE = 4'b1110; //连续写enable

// a valid transfer is noseq or  seq
// 一个有效的操作必须是连续的或者非连续的读写
assign  valid_wr = (HSEL && HREADY && (HTRANS == `HTRANS_NONSEQ || HTRANS == `HTRANS_SEQ)) ? 1'b1 : 1'b0; 

//apb write or read  setup 
//下一个状态是读setup，或者突发写setup，或者写setup，说明setup段要开始了
assign  setup_en  = (NS == READ_SETUP || NS == BURST_WRITE_SETUP || NS == WRITE_SETUP) ? 1'b1 : 1'b0;

//apb write or read enable 
//下一个状态是读enable段，突发写enable段，写enable段，说明enable段开始
assign  enable_en = (NS == READ_ENABLE || NS == BURST_WRITE_ENABLE || NS == WRITE_ENABLE) ? 1'b1 : 1'b0;

//apb ready output enable
assign  ready_en   =  (NS == READ_SETUP || NS == BURST_WRITE_SETUP || 
                      (NS == BURST_WRITE_ENABLE && 
		      ((HWRITE == 1'b0 && valid_wr == 1'b1) || wr_r == 1'b0))) ? 1'b0 : 1'b1;

//
assign  addr_mux_r = (NS == READ_SETUP && 
                     (CS == IDLE || CS == READ_ENABLE || CS == WRITE_ENABLE)) ? HADDR : addr_r;

//

always@(posedge HCLK or negedge HRST_N) 
begin : register_addr_control
  if(!HRST_N) begin
    addr_r <= #1  'b0;
    wr_r   <= #1  'b0;
  end
  else if(valid_wr) begin
    addr_r <= #1  HADDR;
    wr_r   <= #1  HWRITE ;
  end
  else if(NS == IDLE) begin
    addr_r <= #1  'b0;
    wr_r   <= #1  'b0;
  end
end


always@(posedge HCLK or negedge HRST_N) 
begin : set_current_state
  if(!HRST_N) begin
    CS <= #1  IDLE;
  end
  else begin
    CS <= #1  NS;
  end
end

always@(*)
begin : set_next_state
  NS = CS;
  case(CS)
    IDLE               : begin 
      if(valid_wr) begin
	// valid read or write
	if(HWRITE) 
	  // valid write
	  NS = WRITE_WAIT; 
	else
	  //valid read
	  NS = READ_SETUP;
      end
      else begin
	NS = IDLE;
      end
    end
    READ_SETUP         : begin 
      NS = READ_ENABLE;
    end
    READ_ENABLE        : begin 
      if(valid_wr) begin
	if(HWRITE) 
	   NS = WRITE_WAIT;
        else
	   NS = READ_SETUP;
      end
      else begin
	NS = IDLE;
      end
    end
    WRITE_WAIT         : begin 
      if(valid_wr) begin
	NS = BURST_WRITE_SETUP;
      end
      else begin
	NS = WRITE_SETUP;
      end
    end
    WRITE_SETUP        : begin 
      if(valid_wr) begin
	NS = BURST_WRITE_ENABLE;
      end
      else begin
	NS = WRITE_ENABLE;
      end
    end
    WRITE_ENABLE       : begin 
      if(valid_wr) begin
	if(HWRITE) begin
	  NS = BURST_WRITE_SETUP;
	end
	else begin
	  NS = READ_SETUP;
	end
      end
      else begin
	NS = IDLE;
      end
    end
    BURST_WRITE_SETUP  : begin 
      NS = BURST_WRITE_ENABLE;
    end
    BURST_WRITE_ENABLE : begin 
      if(wr_r) begin
	if(valid_wr)
	  NS = BURST_WRITE_SETUP;
	else
	  NS = WRITE_SETUP;
      end
      else begin
	NS = READ_SETUP;
      end
    end
    default            : begin
      NS = IDLE;
    end
  endcase
end

always@(posedge HCLK or negedge HRST_N) 
begin : set_penable
  if(!HRST_N) begin
    PENABLE <= #1  1'b0;
  end
  else begin
    PENABLE <= #1  enable_en;
  end
end


always@(posedge HCLK or negedge HRST_N) 
begin : set_paddr
  if(!HRST_N) begin
    PADDR <= #1  'b0;
  end
  else if(setup_en) begin
    //PADDR <= #1  addr_r;
    PADDR <= #1  addr_mux_r;
  end
  else if(NS == IDLE) begin
    PADDR <= #1   32'b0 ;
  end
end

always@(posedge HCLK or negedge HRST_N) 
begin : set_pwdata
  if(!HRST_N) begin
    PWDATA <= #1  'b0;
  end
  else if(setup_en) begin
    PWDATA <= #1  HWDATA;
  end
  else if(NS == IDLE) begin
    PWDATA <= #1   32'b0 ;
  end
end

always@(*)
begin :set_write_en
  case(NS)
    //WRITE_WAIT          : begin
    //  write_en   =  1'b1;
    //end
    //IDLE,READ_SETUP                : write_en = 1'b0 ;
    WRITE_SETUP, BURST_WRITE_SETUP : write_en = 1'b1 ;
    BURST_WRITE_ENABLE  : begin
      if(wr_r) begin
	write_en = 1'b1;
      end
      else begin
	write_en = 1'b0;
      end
    end
    default             : begin
	write_en = 1'b0;
    end
  endcase
end

always@(posedge HCLK or negedge HRST_N) 
begin : set_pwrite
  if(!HRST_N) begin
    PWRITE <= #1  1'b0;
  end
  else if(setup_en)begin
    PWRITE <= #1  write_en;
  end
  else if(NS == IDLE) begin
    PWRITE <= #1   1'b0 ;
  end
end

always@(posedge HCLK or negedge HRST_N) 
begin :set_HREADY_output
  if(!HRST_N) begin
    HREADY_o <= #1  'b0;
  end
  else begin
    HREADY_o <= #1  ready_en;
  end
end


always@(*)
begin : set_psel_r
  psel_r = 'b0;
  case(addr_mux_r[`APB_ADDR_H:`APB_ADDR_L])
    `APB_SLV0_BASE : psel_r[0]  = 1'b1 ;  
    `APB_SLV1_BASE : psel_r[1]  = 1'b1 ;  
    `APB_SLV2_BASE : psel_r[2]  = 1'b1 ;  
    `APB_SLV3_BASE : psel_r[3]  = 1'b1 ;  
    `APB_SLV4_BASE : psel_r[4]  = 1'b1 ;  
    `APB_SLV5_BASE : psel_r[5]  = 1'b1 ;  
    `APB_SLV6_BASE : psel_r[6]  = 1'b1 ;  
    `APB_SLV7_BASE : psel_r[7]  = 1'b1 ;  
    `APB_SLV8_BASE : psel_r[8]  = 1'b1 ;  
    `APB_SLV9_BASE : psel_r[9]  = 1'b1 ;  
    `APB_SLV10_BASE: psel_r[10] = 1'b1 ;  
    `APB_SLV11_BASE: psel_r[11] = 1'b1 ;  
    `APB_SLV12_BASE: psel_r[12] = 1'b1 ;  
    `APB_SLV13_BASE: psel_r[13] = 1'b1 ;  
    `APB_SLV14_BASE: psel_r[14] = 1'b1 ;  
    `APB_SLV15_BASE: psel_r[15] = 1'b1 ;  
    default        : psel_r     =  'b0 ;  
  endcase
end

always@(posedge HCLK or negedge HRST_N) 
begin : set_psel_output
  if(!HRST_N) begin
    PSEL  <= #1  'b0;
  end
  else if(setup_en)begin
    PSEL  <= #1  psel_r;
  end
  else if(NS == IDLE || NS == WRITE_WAIT) begin
    PSEL  <= #1  'b0;
  end
end

assign  HRDATA = PRDATA;
assign  HRESP  = `HRESP_OKAY;
assign  HSPLIT = 16'b0    ;

endmodule
