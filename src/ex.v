`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/26 21:53:14
// Design Name: 
// Module Name: ex
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


module ex(
    input wire rst,
    input wire[2:0] i_alusel,
    input wire[7:0] i_aluop,
    input wire[31:0] i_reg1_data,
    input wire[31:0] i_reg2_data,
    input wire i_wreg,
    input wire[4:0] i_wreg_addr,
    
    output reg o_wreg,
    output reg[4:0] o_wreg_addr,
    output reg[31:0] o_wreg_data
    );

reg[31:0] logic_out;

always @(*)
begin
    if (rst == 1'b1)
        begin
            logic_out <= 32'h0;
        end
    else
        begin
            case (i_aluop)
                8'b00100101:
                    begin
                        logic_out <= i_reg1_data | i_reg2_data;
                    end
                default:
                    begin
                        logic_out <= 32'h0;
                    end
            endcase
        end
end

always @(*)
begin
    o_wreg <= i_wreg;
    o_wreg_addr <= i_wreg_addr;
    case (i_alusel)
        3'b001:
            begin
                o_wreg_data <= logic_out;
            end
        default:
            begin
                o_wreg_data <= 32'h0; 
            end
    endcase
end
endmodule
