`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/26 23:58:26
// Design Name: 
// Module Name: wisecore_soc
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


module wisecore_soc(
    input wire rst,
    input wire clk
    );

//wisecore与inst_rom连接总线    
wire l2_ce;
wire[31:0] l2_pc;
wire[31:0] l2_inst;

wisecore wisecore_inst0(
    .rst(rst),
    .clk(clk),
    .i_inst(l2_inst),
    
    .o_rom_ce(l2_ce),
    .o_pc(l2_pc)
);

inst_rom inst_rom_inst0(
    .ce(l2_ce),
    .addr(l2_pc),
    .inst(l2_inst)
);
endmodule
