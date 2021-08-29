`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/26 22:08:11
// Design Name: 
// Module Name: regfile
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


module regfile(
    input wire rst,
    input wire clk,
    input wire i_rreg1_en,
    input wire[4:0] i_rreg1_addr,
    input wire i_rreg2_en,
    input wire[4:0] i_rreg2_addr,
    
    input wire i_wreg_en,
    input wire[4:0] i_wreg_addr,
    input wire[31:0] i_wreg_data,
    
    output reg[31:0] o_reg1_data,
    output reg[31:0] o_reg2_data
    );

reg[31:0] regs[31:0];

always @(posedge clk)
begin
    if(rst == 1'b0)
        begin
            if((i_wreg_en == 1'b1) && (i_wreg_addr != 5'b0))
                begin
                    regs[i_wreg_addr] <= i_wreg_data;
                end
        end
end

always @(*)
begin
    if (rst == 1'b1)
        begin
            o_reg1_data <= 32'h0;
        end
    else if (i_rreg1_addr == 5'b0)
        begin
            o_reg1_data <= 32'h0;
        end
    else if ((i_rreg1_addr == i_wreg_addr) && (i_wreg_en == 1'b1) && (i_rreg1_en == 1'b1))
        begin
            o_reg1_data <= i_wreg_data;
        end
    else if (i_rreg1_en == 1'b1)
        begin
            o_reg1_data <= regs[i_rreg1_addr];
        end
    else
        begin
            o_reg1_data <= 32'h0;
        end
end

always @(*)
begin
    if (rst == 1'b1)
        begin
            o_reg2_data <= 32'h0;
        end
    else if (i_rreg2_addr == 5'b0)
        begin
            o_reg2_data <= 32'h0;
        end
    else if ((i_rreg2_addr == i_wreg_addr) && (i_wreg_en == 1'b1) && (i_rreg2_en == 1'b1))
        begin
            o_reg2_data <= i_wreg_data;
        end
    else if (i_rreg2_en == 1'b1)
        begin
            o_reg2_data <= regs[i_rreg2_addr];
        end
    else
        begin
            o_reg2_data <= 32'h0;
        end
end
endmodule
