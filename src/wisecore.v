`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/26 22:20:32
// Design Name: 
// Module Name: openmips_core
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module wisecore(
    input wire rst,
    input wire clk,
    input wire[31:0] i_inst,
    
    output wire o_rom_ce,
    output wire[31:0] o_pc
    );

//全局内部总线
wire l_rst; //openmips_core rst
wire l_clk; //openmips_core clk
wire l_ce; //openmips_core o_rom_ce
wire[31:0] l_inst; //openmips_core i_inst

//IF模块与IF_ID模块连接总线
wire[31:0] l_if_pc_ifid; //openmips_core o_pc

//IF_ID模块与ID模块连接总线
wire[31:0] l_ifid_pc_id;
wire[31:0] l_ifid_inst_id;

//ID模块与ID_EX模块连接总线
wire[2:0] l_id_alusel_idex;
wire[7:0] l_id_aluop_idex;
wire[31:0] l_id_reg1data_idex;
wire[31:0] l_id_reg2data_idex;
wire l_id_wreg_idex;
wire[4:0] l_id_wreg_addr_idex;

//ID_EX模块与EX模块连接总线
wire[2:0] l_idex_alusel_ex;
wire[7:0] l_idex_aluop_ex;
wire[31:0] l_idex_reg1data_ex;
wire[31:0] l_idex_reg2data_ex;
wire l_idex_wreg_ex;
wire[4:0] l_idex_wreg_addr_ex;

//EX模块与EX_MEM模块连接总线
wire l_ex_wreg_exmem;
wire[4:0] l_ex_wreg_addr_exmem;
wire[31:0] l_ex_wreg_data_exmem;

wire l_ex_whilo_exmem;
wire[31:0] l_ex_hi_exmem;
wire[31:0] l_ex_lo_exmem;

//EX_MEM模块与MEM模块连接总线
wire l_exmem_wreg_mem;
wire[4:0] l_exmem_wreg_addr_mem;
wire[31:0] l_exmem_wreg_data_mem;

wire l_exmem_whilo_mem;
wire[31:0] l_exmem_hi_mem;
wire[31:0] l_exmem_lo_mem;

//MEM模块与MEM_WB模块连接总线
wire l_mem_wreg_wb;
wire[4:0] l_mem_wreg_addr_wb;
wire[31:0] l_mem_wreg_data_wb;

wire l_mem_whilo_wb;
wire[31:0] l_mem_hi_wb;
wire[31:0] l_mem_lo_wb;

//MEM_WB模块与RegFile模块连接总线
wire l_wb_wen_rf;
wire[4:0] l_wb_waddr_rf;
wire[31:0] l_wb_wdata_rf;

//MEM_WB模块与Hilo模块连接总线
wire l_wb_whilo;
wire[31:0] l_wb_hi;
wire[31:0] l_wb_lo;

//RegFile模块与ID模块连接总线
wire l_id_en1_rf;
wire[4:0] l_id_raddr1_rf;
wire l_id_en2_rf;
wire[4:0] l_id_raddr2_rf;
wire[31:0] l_rf_reg1data_id;
wire[31:0] l_rf_reg2data_id;

//Hilo模块与EX模块连接总线
wire [31:0] l_ex_hi_hilo;
wire [31:0] l_ex_lo_hilo;

//IF模块实例化
ifetch ifetch_inst0(
    .rst(rst),
    .clk(clk),
    .pc(o_pc),
    .ce(o_rom_ce)
);

//IF_ID模块实例化
if_id if_id_inst0(
    .rst(rst),
    .clk(clk),
    .i_pc(o_pc),
    .i_inst(i_inst),
    .o_pc(l_ifid_pc_id),
    .o_inst(l_ifid_inst_id)
);

//ID模块实例化
id id_inst0(
    .rst(rst),
    .i_pc(l_ifid_pc_id),
    .i_inst(l_ifid_inst_id),
    .i_reg1_data(l_rf_reg1data_id),
    .i_reg2_data(l_rf_reg2data_id),
  
    /*add port for dataforward from ex*/
    .i_ex_wreg(l_ex_wreg_exmem),
    .i_ex_wreg_addr(l_ex_wreg_addr_exmem),
    .i_ex_wreg_data(l_ex_wreg_data_exmem),

    /*add port for dataforward from mem*/
    .i_mem_wreg(l_mem_wreg_wb),
    .i_mem_wreg_addr(l_mem_wreg_addr_wb),
    .i_mem_wreg_data(l_mem_wreg_data_wb),      
    
    .o_alusel(l_id_alusel_idex),
    .o_aluop(l_id_aluop_idex),
    .o_reg1_data(l_id_reg1data_idex),
    .o_reg2_data(l_id_reg2data_idex),
    .o_wreg(l_id_wreg_idex),
    .o_wreg_addr(l_id_wreg_addr_idex),
    .o_rreg1_en(l_id_en1_rf),
    .o_rreg1_addr(l_id_raddr1_rf),
    .o_rreg2_en(l_id_en2_rf),
    .o_rreg2_addr(l_id_raddr2_rf)
);


//ID_V2模块实例化
/*
id_v2 id_v2_inst0(
    .rst(rst),
    .i_pc(l_ifid_pc_id),
    .i_inst(l_ifid_inst_id),
    .i_reg1_data(l_rf_reg1data_id),
    .i_reg2_data(l_rf_reg2data_id),
    
    .o_alusel(l_id_alusel_idex),
    .o_aluop(l_id_aluop_idex),
    .o_reg1_data(l_id_reg1data_idex),
    .o_reg2_data(l_id_reg2data_idex),
    .o_wreg(l_id_wreg_idex),
    .o_wreg_addr(l_id_wreg_addr_idex),
    .o_rreg1_en(l_id_en1_rf),
    .o_rreg1_addr(l_id_raddr1_rf),
    .o_rreg2_en(l_id_en2_rf),
    .o_rreg2_addr(l_id_raddr2_rf)
);
*/


//RegFile模块实例化
regfile regfile_inst0(
    .rst(rst),
    .clk(clk),
    .i_rreg1_en(l_id_en1_rf),
    .i_rreg1_addr(l_id_raddr1_rf),
    .i_rreg2_en(l_id_en2_rf),
    .i_rreg2_addr(l_id_raddr2_rf),
    
    .i_wreg_en(l_wb_wen_rf),
    .i_wreg_addr(l_wb_waddr_rf),
    .i_wreg_data(l_wb_wdata_rf),
    
    .o_reg1_data(l_rf_reg1data_id),
    .o_reg2_data(l_rf_reg2data_id)
);

//ID_EX模块实例化
id_ex id_ex_inst0(
    .rst(rst),
    .clk(clk),

    .i_alusel(l_id_alusel_idex),
    .i_aluop(l_id_aluop_idex),
    .i_reg1_data(l_id_reg1data_idex),
    .i_reg2_data(l_id_reg2data_idex),
    .i_wreg(l_id_wreg_idex),
    .i_wreg_addr(l_id_wreg_addr_idex),
  
    .o_alusel(l_idex_alusel_ex),
    .o_aluop(l_idex_aluop_ex),
    .o_reg1_data(l_idex_reg1data_ex),
    .o_reg2_data(l_idex_reg2data_ex),
    .o_wreg(l_idex_wreg_ex),
    .o_wreg_addr(l_idex_wreg_addr_ex)
);

//EX模块实例化
ex ex_inst0(
    .rst(rst),
    .i_alusel(l_idex_alusel_ex),
    .i_aluop(l_idex_aluop_ex),
    .i_reg1_data(l_idex_reg1data_ex),
    .i_reg2_data(l_idex_reg2data_ex),
    .i_wreg(l_idex_wreg_ex),
    .i_wreg_addr(l_idex_wreg_addr_ex),

    .i_hi(l_ex_hi_hilo),
    .i_lo(l_ex_lo_hilo),
    
    .i_wb_whilo(l_wb_whilo),
    .i_wb_hi(l_wb_hi),
    .i_wb_lo(l_wb_lo),
    .i_mem_whilo(l_mem_whilo_wb),
    .i_mem_hi(l_mem_hi_wb),
    .i_mem_lo(l_mem_lo_wb),
    
    .o_wreg(l_ex_wreg_exmem),
    .o_wreg_addr(l_ex_wreg_addr_exmem),
    .o_wreg_data(l_ex_wreg_data_exmem),
    
    .o_whilo(l_ex_whilo_exmem),
    .o_hi(l_ex_hi_exmem),
    .o_lo(l_ex_lo_exmem)
);

//EX_MEM模块实例化
ex_mem ex_mem_inst0(
    .rst(rst),
    .clk(clk),
    .i_wreg(l_ex_wreg_exmem),
    .i_wreg_addr(l_ex_wreg_addr_exmem),
    .i_wreg_data(l_ex_wreg_data_exmem),
    
    .i_whilo(l_ex_whilo_exmem),
    .i_hi(l_ex_hi_exmem),
    .i_lo(l_ex_lo_exmem),
    
    .o_wreg(l_exmem_wreg_mem),
    .o_wreg_addr(l_exmem_wreg_addr_mem),
    .o_wreg_data(l_exmem_wreg_data_mem),
    
    .o_whilo(l_exmem_whilo_mem),
    .o_hi(l_exmem_hi_mem),
    .o_lo(l_exmem_lo_mem)
);

//MEM模块实例化
mem mem_inst0(
    .rst(rst),
    .i_wreg(l_exmem_wreg_mem),
    .i_wreg_addr(l_exmem_wreg_addr_mem),
    .i_wreg_data(l_exmem_wreg_data_mem),
    
    .i_whilo(l_exmem_whilo_mem),
    .i_hi(l_exmem_hi_mem),
    .i_lo(l_exmem_lo_mem),

    .o_wreg(l_mem_wreg_wb),
    .o_wreg_addr(l_mem_wreg_addr_wb),
    .o_wreg_data(l_mem_wreg_data_wb),
    
    .o_whilo(l_mem_whilo_wb),
    .o_hi(l_mem_hi_wb),
    .o_lo(l_mem_lo_wb)
);

//MEM_WB实例化
mem_wb mem_wb_inst0(
.rst(rst),
.clk(clk),
.i_wreg(l_mem_wreg_wb),
.i_wreg_addr(l_mem_wreg_addr_wb),
.i_wreg_data(l_mem_wreg_data_wb),

.i_whilo(l_mem_whilo_wb),
.i_hi(l_mem_hi_wb),
.i_lo(l_mem_lo_wb),

.o_wreg(l_wb_wen_rf),
.o_wreg_addr(l_wb_waddr_rf),
.o_wreg_data(l_wb_wdata_rf),

.o_whilo(l_wb_whilo),
.o_hi(l_wb_hi),
.o_lo(l_wb_lo)
);

//HILO实例化
hilo hilo_inst0(
.rst(rst),
.clk(clk),
.i_ce(l_wb_whilo),
.i_hi(l_wb_hi),
.i_lo(l_wb_lo),
   
.o_hi(l_ex_hi_hilo),
.o_lo(l_ex_lo_hilo)
);
endmodule
