`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/26 17:33:41
// Design Name: 
// Module Name: if_id
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


module if_id(
    input wire rst,
    input wire clk,
    
    input wire[31:0] i_pc,
    input wire[31:0] i_inst,
    
    output reg[31:0] o_pc,
    output reg[31:0] o_inst
    );

always @(posedge clk)
begin
    if (rst == 1'b1)
        begin
            o_pc <= 32'h0;
            o_inst <= 32'h0;
        end
    else
        begin
            o_pc <= i_pc;
            o_inst <= i_inst;
        end
end

endmodule
