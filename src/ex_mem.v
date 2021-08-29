`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/26 21:59:47
// Design Name: 
// Module Name: ex_mem
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


module ex_mem(
    input wire rst,
    input wire clk,
    input wire i_wreg,
    input wire[4:0] i_wreg_addr,
    input wire[31:0] i_wreg_data,
  
    output reg o_wreg,
    output reg[4:0] o_wreg_addr,
    output reg[31:0] o_wreg_data
    );
    
always @(posedge clk)
begin
    if (rst == 1'b1)
        begin
            o_wreg <= 1'b0;
            o_wreg_addr <= 5'b0;
            o_wreg_data <= 32'h0;
        end
    else
        begin
            o_wreg <= i_wreg;
            o_wreg_addr <= i_wreg_addr;
            o_wreg_data <= i_wreg_data;
        end
end
endmodule
