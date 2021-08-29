`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/26 21:44:45
// Design Name: 
// Module Name: id_ex
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


module id_ex(
    input wire rst,
    input wire clk,
    input wire[2:0] i_alusel,
    input wire[7:0] i_aluop,
    input wire[31:0] i_reg1_data,
    input wire[31:0] i_reg2_data,
    input wire i_wreg,
    input wire[4:0] i_wreg_addr,
    
    output reg[2:0] o_alusel,
    output reg[7:0] o_aluop,
    output reg[31:0] o_reg1_data,
    output reg[31:0] o_reg2_data,
    output reg o_wreg,
    output reg[4:0] o_wreg_addr
    );

always @(posedge clk)
begin
    if (rst == 1'b1)
        begin
            o_alusel <= 3'b0;
            o_aluop <= 8'b0;
            o_reg1_data <= 32'h0;
            o_reg2_data <= 32'h0;
            o_wreg <= 1'b0;
            o_wreg_addr <= 5'b0;
        end
    else
        begin
            o_alusel <= i_alusel;
            o_aluop <= i_aluop;
            o_reg1_data <= i_reg1_data;
            o_reg2_data <= i_reg2_data;
            o_wreg <= 1'b1;
            o_wreg_addr <= i_wreg_addr;
        end
end

endmodule
