`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/26 21:59:47
// Design Name: 
// Module Name: hilo
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

module hilo(
    input wire rst,
    input wire clk,
    input wire i_ce,
    input wire[31:0] i_hi,
    input wire[31:0] i_lo,
    
    output reg[31:0] o_hi,
    output reg[31:0] o_lo
    );
    
always @(posedge clk)
begin
    if (rst == 1'b1)
        begin
            o_hi <= 32'h0;
            o_lo <= 32'h0;
        end
    else if (i_ce == 1'b1) 
        begin
            o_hi <= i_hi;
            o_lo <= i_lo;        
        end
end
endmodule
