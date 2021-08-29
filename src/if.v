`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/26 17:21:41
// Design Name: 
// Module Name: if
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

module ifetch(
        input wire rst,
        input wire clk,
        output reg[31:0] pc,
        output reg ce
    );

always @(posedge clk)
begin
    if (rst == 1'b1)
        begin
            ce <= 1'b0;
        end
    else
        begin
            ce <= 1'b1;
        end
end

always @(posedge clk)
begin
    if (ce == 1'b0)
        begin
            pc <= 32'h0;
        end
    else
        begin
            pc <= pc + 4;
        end
end

endmodule
