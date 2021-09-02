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

`include "inst_define.vh"

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

reg[31:0] logic_res;
reg[31:0] shift_res;

//process logic operations
always @(*)
begin
    if (rst == 1'b1)
        begin
            logic_res <= 32'h0;
        end
    else
        begin
            case (i_aluop)
                /*
                    or     |--000000--|----rs----|----rt----|----rd----|--00000--|-100101-|  ==> or rd, rs, rt # rd <- rs OR rt
                */
                `OP_OR:
                    begin
                        logic_res <= i_reg1_data | i_reg2_data;
                    end
                /*
                    and    |--000000--|----rs----|----rt----|----rd----|--00000--|-100100-|  ==> and rd, rs, rt # rd <- rs AND rt
                */
                `OP_AND:
                    begin
                        logic_res <= i_reg1_data & i_reg2_data;
                    end
                /*
                    xor    |--000000--|----rs----|----rt----|----rd----|--00000--|-100110-|  ==> xor rd, rs, rt # rd <- rs XOR rt
                */
                `OP_XOR:
                    begin
                        logic_res <= i_reg1_data ^ i_reg2_data;
                    end
                /*
                    xori   |--001110--|----rs----|----rt----|---------immediate----------|   ==>  xori rt, rs, immediate #rt <- rs XOR zero_extend(immediate)
                */
                `OP_XORI:
                    begin
                        logic_res <= i_reg1_data ^ i_reg2_data;
                    end
                /*
                    nor    |--000000--|----rs----|----rt----|----rd----|--00000--|-100111-|  ==> nor rd, rs, rt # rd <- rs NOR rt
                */
                `OP_NOR:
                    begin
                        logic_res <= ~(i_reg1_data | i_reg2_data);
                    end
                /*
                    andi   |--001100--|----rs----|----rt----|---------immediate----------|   ==>  andi rt, rs, immediate #rt <- rs AND zero_extend(immediate)
                */
                `OP_ANDI:
                    begin
                        logic_res <= i_reg1_data & i_reg2_data;
                    end
                /*
                    ori    |--001101--|----rs----|----rt----|---------immediate----------|   ==>  ori rt, rs, immediate #rt <- rs OR zero_extend(immediate)
                */
                `OP_ORI:
                    begin
                        logic_res <= i_reg1_data | i_reg2_data;
                    end
                /*
                    lui    |--001111--|---0000---|----rt----|---------immediate----------|   ==>  lui rt, immediate #rt(h16) <- (immediate), rt(l16) <- (0)
                */
                `OP_LUI:
                    begin
                        logic_res <= i_reg1_data;
                    end
                default:
                    begin
                        logic_res <= 32'h0;
                    end
            endcase
        end
end

//process shift operations
always @(*)
begin
    if (rst == 1'b1)
        begin
            shift_res <= 32'h0;
        end
    else
        begin
            case (i_aluop)
                /*
                    sll    |--000000--|---00000--|----rt----|----rd----|---sa---|-000000-|  ==> sll rd, rt, sa # rd <- rt << sa(logic)
                */
                `OP_SLL:
                    begin
                        shift_res <= i_reg1_data << i_reg2_data;
                    end
                /*
                    sllv   |--000000--|----rs---|----rt----|----rd----|--00000--|-000100-|  ==> sllv rd, rt, rs # rd <- rt << rs[4:0](logic)
                */                
                `OP_SLLV:
                    begin
                        shift_res <= i_reg1_data << i_reg2_data[4:0];
                    end
                /*
                    srl    |--000000--|---00000--|----rt----|----rd----|---sa----|-000010-|  ==> srl rd, rt, sa # rd <- rt >> sa(logic)
                */                
                `OP_SRL:
                    begin
                        shift_res <= i_reg1_data >> i_reg2_data;
                    end
                /*
                    srlv   |--000000--|----rs---|----rt----|----rd----|--00000--|-000110-|  ==> srlv rd, rt, rs # rd <- rt >> rs[4:0](logic)
                */
                `OP_SRLV:
                    begin
                        shift_res <= i_reg1_data >> i_reg2_data[4:0];
                    end
               /*
                    sra    |--000000--|---00000--|----rt----|----rd----|---sa---|-000011-|  ==> sra rd, rt, sa # rd <- rt >> sa(arithmetic)
               */
                `OP_SRA:
                    begin
                        shift_res <= i_reg1_data[31] | (i_reg1_data >> i_reg2_data);
                    end
                /*
                    srav   |--000000--|----rs---|----rt----|----rd----|--00000--|-000111-|  ==> srav rd, rt, rs # rd <- rt >> rs[4:0](arithmetic)
                */
                `OP_SRAV:
                    begin
                        shift_res <= i_reg1_data[31] | (i_reg1_data >> i_reg2_data[4:0]);
                    end
                default:
                    begin
                    end
            endcase
        end
end

always @(*)
begin
    o_wreg <= i_wreg;
    o_wreg_addr <= i_wreg_addr;
    case (i_alusel)
        `OP_TYPE_LOGIC:
            begin
                o_wreg_data <= logic_res;
            end
        `OP_TYPE_SHIFT:
            begin
                o_wreg_data <= shift_res;
            end
        default:
            begin
                o_wreg_data <= 32'h0; 
            end
    endcase
end
endmodule
