//================================================================================
// Created by         : Ltd.com
// Filename           : defines.v
// Author             : Python_Wang
// Created On         : 2009-06-07 21:44
// Last Modified      : 2009-07-18 11:13
// Description        : 
//                      
//                      
//================================================================================
//传输类型定义
`define  HTRANS_IDLE     2'b00
`define  HTRANS_BUSY     2'b01
`define  HTRANS_NONSEQ   2'b10
`define  HTRANS_SEQ      2'b11
//定义突发类型
`define  HBURST_SINGLE   3'b000
`define  HBURST_INCR     3'b001
`define  HBURST_WRAP4    3'b010
`define  HBURST_INCR4    3'b011
`define  HBURST_WRAP8    3'b100
`define  HBURST_INCR8    3'b101
`define  HBURST_WRAP16   3'b110
`define  HBURST_INCR16   3'b111
//定义传输大小
`define  HSIZE_BYTE      3'b000
`define  HSIZE_HWORD     3'b001
`define  HSIZE_WORD      3'b010
`define  HSIZE_DWORD     3'b011
`define  HSIZE_4WORD     3'b100
`define  HSIZE_8WORD     3'b101
`define  HSIZE_16WORD    3'b110
//定义响应类型
`define  HRESP_OKAY      2'b00
`define  HRESP_ERROR     2'b01
`define  HRESP_RETRY     2'b10
`define  HRESP_SPLIT     2'b11
`define AHB_ADDR_H       31 
`define AHB_ADDR_L       `AHB_ADDR_H - 3
`define APB_ADDR_H       27
`define APB_ADDR_L       `APB_ADDR_H - 3
/////////////////////////////////////////////
// EASY Peripherals address decoding values:
//[30:27]
`define AHB_SLV0_BASE    4'b0000
`define AHB_SLV1_BASE    4'b0001
`define AHB_SLV2_BASE    4'b0010
`define AHB_SLV3_BASE    4'b0011
`define AHB_SLV4_BASE    4'b0100
`define AHB_SLV5_BASE    4'b0101
`define AHB_SLV6_BASE    4'b0110
`define AHB_SLV7_BASE    4'b0111
`define AHB_SLV8_BASE    4'b1000
`define AHB_SLV9_BASE    4'b1001
`define AHB_SLV10_BASE   4'b1010
`define AHB_SLV11_BASE   4'b1011
`define AHB_SLV12_BASE   4'b1100
`define AHB_SLV13_BASE   4'b1101
`define AHB_SLV14_BASE   4'b1110
`define AHB_SLV15_BASE   4'b1111
//[26:23]
`define APB_SLV0_BASE    4'b0000
`define APB_SLV1_BASE    4'b0001
`define APB_SLV2_BASE    4'b0010
`define APB_SLV3_BASE    4'b0011
`define APB_SLV4_BASE    4'b0100
`define APB_SLV5_BASE    4'b0101
`define APB_SLV6_BASE    4'b0110
`define APB_SLV7_BASE    4'b0111
`define APB_SLV8_BASE    4'b1000
`define APB_SLV9_BASE    4'b1001
`define APB_SLV10_BASE   4'b1010
`define APB_SLV11_BASE   4'b1011
`define APB_SLV12_BASE   4'b1100
`define APB_SLV13_BASE   4'b1101
`define APB_SLV14_BASE   4'b1110
`define APB_SLV15_BASE   4'b1111
/////////////////////////////////////////////
//ahb slaver's address
`define AHB_SPIM_CTRL_ADDR         6'b000110 
`define AHB_SPIM_POWERUP           32'd5000

//apb slaver's address
//slv0
`define APB_GPIO_ADDR              6'b011000 
`define APB_GPIO_DIR_ADDR          6'b011100
//slv1
//apbslaver
//slv2
`define APB_UART_CTRL_ADDR         6'b000001
`define APB_UART_STATUS_ADDR       6'b000010
`define APB_UART_SCALER_ADDR       6'b000100
`define APB_UART_RHOLD_ADDR        6'b001000
`define APB_UART_THOLD_ADDR        6'b010000
//slv4
`define AHB_DUART_STATUS_ADDR      6'b100000 
`define AHB_DUART_CTRL_ADDR        6'b110000 
//slv5
`define AHB_SIMPLE_DMA_CTRL_ADDR1  6'b110001 
`define AHB_SIMPLE_DMA_CTRL_ADDR2  6'b110010 
`define AHB_SIMPLE_DMA_CTRL_ADDR3  6'b110100
//slv6
`define AHB_NAND_CMD_ADDR          6'b001000 
`define AHB_NAND_CFG_ADDR          6'b010010 
`define AHB_NAND_ADR_ADDR          6'b001010 
`define AHB_NAND_STATUS_ADDR       6'b001110 
`define AHB_NAND_LEN_ADDR          6'b101001 
`define AHB_NAND_DATA_ADDR         6'b010101 




