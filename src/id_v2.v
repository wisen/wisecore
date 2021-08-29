`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/28 19:43:21
// Design Name: 
// Module Name: id_v2
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


module id_v2(
    input wire rst,

    input wire[31:0] i_pc,
    input wire[31:0] i_inst,
    input wire[31:0] i_reg1_data,
    input wire[31:0] i_reg2_data,
    
    output reg[2:0] o_alusel,
    output reg[7:0] o_aluop,
    output reg[31:0] o_reg1_data,
    output reg[31:0] o_reg2_data,
    output reg o_wreg,
    output reg[4:0] o_wreg_addr,
    output reg o_rreg1_en,
    output reg[4:0] o_rreg1_addr,
    output reg o_rreg2_en,
    output reg[4:0] o_rreg2_addr
    );

/*
R-type instuction:
Bits   |--31..26--|--25..21--|--20..16--|--15..11--|--10..6--|--5..0--|
R-type |----op----|----rs----|----rt----|----rd----|--shamt--|--func--|
shamt: shift amount��λλ��

l-type instuction:
Bits   |--31..26--|--25..21--|--20..16--|--15..11--|--10..6--|--5..0--|
l-type |----op----|----rs----|----rt----|---------immediate----------|

j-type instuction:
Bits   |--31..26--|--25..21--|--20..16--|--15..11--|--10..6--|--5..0--|
l-type |----op----|----------------------address----------------------|
*/
wire[5:0] op = i_inst[31:26];

wire[4:0] shamt = i_inst[10:6];
wire[5:0] func = i_inst[5:0];
wire[4:0] rs = i_inst[25:21];
wire[4:0] rt = i_inst[20:16];
wire[4:0] rd = i_inst[15:11];

wire[15:0] l_immediate = i_inst[15:0];

wire[25:0] j_address = i_inst[25:0];

reg[31:0] imm; //����ָ��ִ����Ҫ��������
reg instvalid; //����ָ�����Ч��

always @(*)
begin
    if(rst == 1'b1)
        begin
            instvalid <= 1'b0;
            imm <= 32'h0;
        
            o_rreg1_en <= 1'b0;
            o_rreg1_addr <= 5'b0;
            o_rreg2_en <= 1'b0;
            o_rreg2_addr <= 5'b0;
            
            o_alusel <= 3'b0;
            o_aluop <= 8'b0;
            
            o_reg1_data <= 32'h00000000;
            o_reg2_data <= 32'h00000000;
            
            o_wreg <= 1'b0;
            o_wreg_addr <= 5'b0;
        end
    else
        begin
            instvalid <= 1'b1;
            imm <= 32'h0;
            
            o_rreg1_en <= 1'b0;
            o_rreg1_addr <= rs;
            o_rreg2_en <= 1'b0;
            o_rreg2_addr <= rt;
            
            o_alusel <= 3'b0;
            o_aluop <= 8'b0;
            
            o_wreg <= 1'b0;
            o_wreg_addr <= rd;
            
            case (op)
                6'b001101:
                    begin
                        o_wreg <= 1'b1;
                        o_alusel <= 3'b001; //�����������߼�����
                        o_aluop <= 8'b00100101; //�������������߼�'��'����
                        
                        o_rreg1_en <= 1'b1; //��Ҫ��reg1
                        o_rreg2_en <= 1'b0; //����Ҫ��reg2
                        
                        imm <= {16'h00, l_immediate}; //��������չ��32λ����λ��0
                        o_wreg_addr <= rt; //д��Ŀ�ļĴ�����ַ
                        instvalid <= 1'b1; //oriָ������Чָ��
                    end
                default:
                    begin
                    end
            endcase
            
            //ȷ�����������Դ������1
            if(o_rreg1_en == 1'b1)
                begin
                    o_reg1_data <= i_reg1_data;
                end
            else if(o_rreg1_en == 1'b0)
                begin
                    o_reg1_data <= imm;
                end
            else
                begin
                    o_reg1_data <= 32'h0;
                end
        
            //ȷ�����������Դ������2
            if(o_rreg2_en == 1'b1)
                begin
                    o_reg2_data <= i_reg2_data;
                end
            else if(o_rreg2_en == 1'b0)
                begin
                    o_reg2_data <= imm;
                end
            else
                begin
                    o_reg2_data <= 32'h0;
                end
        end
end

endmodule
