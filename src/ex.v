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
    
    
    input wire[31:0] i_hi,
    input wire[31:0] i_lo,
    
    input wire i_wb_whilo,
    input wire[31:0] i_wb_hi,
    input wire[31:0] i_wb_lo,
    input wire i_mem_whilo,
    input wire[31:0] i_mem_hi,
    input wire[31:0] i_mem_lo,
    
    output reg o_wreg,
    output reg[4:0] o_wreg_addr,
    output reg[31:0] o_wreg_data,
    
    output reg o_whilo,
    output reg[31:0] o_hi,
    output reg[31:0] o_lo
    );

reg[31:0] logic_res;
reg[31:0] shift_res;
reg[31:0] move_res;
reg[31:0] HI;
reg[31:0] LO;

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

//process move operations
always @(*)
begin
    if (rst == 1'b1)
        begin
            move_res <= 32'h0;
            o_whilo <= 1'b0;
            o_hi <= 32'h0;
            o_lo <= 32'h0;
        end
    else
        begin
            case (i_aluop)
            /*
            	movn   |--000000--|----rs----|----rt----|----rd----|--00000--|-001011-|  ==> movn rd, rs, rt # if rt != 0 then rd <- rs
            */
            `OP_MOVN:
                begin
                    if (i_reg1_data != 0)
                        begin
                            move_res <= i_reg2_data;
                        end
                end
            /*
                movz   |--000000--|----rs----|----rt----|----rd----|--00000--|-001010-|  ==> movz rd, rs, rt # if rt == 0 then rd <- rs
            */
            `OP_MOVZ:
                begin
                    if (i_reg1_data == 0)
                        begin
                            move_res <= i_reg2_data;
                        end
                end
            /*
                mfhi   |--000000--|---00000--|---00000--|----rd----|--00000--|-010000-|  ==> mfhi rd # rd <- hi
            */
            `OP_MFHI:
                begin
                    move_res <= HI;
                end
            /*
                mflo   |--000000--|---00000--|---00000--|----rd----|--00000--|-010010-|  ==> mflo rd # rd <- lo
            */
            `OP_MFLO:
                begin
                    move_res <= LO;
                end
            /*
                mthi   |--000000--|----rs----|---00000--|---00000--|--00000--|-010001-|  ==> mthi rs # hi <- rs
            */
            `OP_MTHI:
                begin
                    o_whilo <= 1'b1;
                    o_hi <= i_reg1_data;
                end
            /*
                mtlo   |--000000--|----rs----|---00000--|---00000--|--00000--|-010011-|  ==> mtlo rs # lo <- rs
            */
            `OP_MTLO:
                begin
                    o_whilo <= 1'b1;
                    o_lo <= i_reg1_data;
                end
            default:
                begin
                end
            endcase
        end
end

always @(*)
begin
    if (rst == 1'b1)
        begin
            HI <= 32'h0;
            LO <= 32'h0;
        end
    else
        begin
            //解决EX和MEM的数据依赖
            if (i_mem_whilo == 1'b1)
                begin
                    HI <= i_mem_hi;
                    LO <= i_mem_lo;
                end
            //解决EX和WB的数据依赖
            else if (i_wb_whilo == 1'b1)
                begin
                    HI <= i_wb_hi;
                    LO <= i_wb_lo;
                end
            else
                begin
                    HI <= i_hi;
                    LO <= i_lo;
                end
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
        `OP_TYPE_MOVE:
            begin
                o_wreg_data <= move_res;
            end
        default:
            begin
                o_wreg_data <= 32'h0; 
            end
    endcase
end
endmodule
