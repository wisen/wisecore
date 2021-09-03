`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/26 22:04:06
// Design Name: 
// Module Name: mem
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


module mem(
    input wire rst,
    input wire i_wreg,
    input wire[4:0] i_wreg_addr,
    input wire[31:0] i_wreg_data,
    
    input wire i_whilo,
    input wire[31:0] i_hi,
    input wire[31:0] i_lo,
    
    output reg o_wreg,
    output reg[4:0] o_wreg_addr,
    output reg[31:0] o_wreg_data,
    
    output reg o_whilo,
    output reg[31:0] o_hi,
    output reg[31:0] o_lo
    );

always @(*)
begin
    if (rst == 1'b1)
    begin
        o_wreg <= 1'b0;
        o_wreg_addr <= 5'b0;
        o_wreg_data <= 32'h0;
        
        o_whilo <= 1'b0;
        o_hi <= 32'h0;
        o_lo <= 32'h0;        
    end
else
    begin
        o_wreg <= i_wreg;
        o_wreg_addr <= i_wreg_addr;
        o_wreg_data <= i_wreg_data;
    
        o_whilo <= i_whilo;
        o_hi <= i_hi;
        o_lo <= i_lo;    
    end
end

endmodule
