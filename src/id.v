`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/26 17:42:09
// Design Name: 
// Module Name: id
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

module id(
    input wire rst,

    input wire[31:0] i_pc,
    input wire[31:0] i_inst,
    input wire[31:0] i_reg1_data,
    input wire[31:0] i_reg2_data,
    
    /*add port for dataforward from ex*/
    input wire i_ex_wreg,
    input wire[4:0] i_ex_wreg_addr,
    input wire[31:0] i_ex_wreg_data,
    /*add port for dataforward from mem*/
    input wire i_mem_wreg,
    input wire[4:0] i_mem_wreg_addr,
    input wire[31:0] i_mem_wreg_data,    
    
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
    R-type(Register format) instuction:
    Bits   |--31..26--|--25..21--|--20..16--|--15..11--|--10..6--|--5..0--|
    R-type |----op----|----rs----|----rt----|----rd----|--shamt--|--func--|
    and    |--000000--|----rs----|----rt----|----rd----|--00000--|-100100-|  ==> and rd, rs, rt # rd <- rs AND rt
    or     |--000000--|----rs----|----rt----|----rd----|--00000--|-100101-|  ==> or rd, rs, rt # rd <- rs OR rt
    xor    |--000000--|----rs----|----rt----|----rd----|--00000--|-100110-|  ==> xor rd, rs, rt # rd <- rs XOR rt
    nor    |--000000--|----rs----|----rt----|----rd----|--00000--|-100111-|  ==> nor rd, rs, rt # rd <- rs NOR rt
    
    sll    |--000000--|---00000--|----rt----|----rd----|---sa---|-000000-|  ==> sll rd, rt, sa # rd <- rt << sa(logic)
    srl    |--000000--|---00000--|----rt----|----rd----|---sa---|-000010-|  ==> srl rd, rt, sa # rd <- rt >> sa(logic)
    sra    |--000000--|---00000--|----rt----|----rd----|---sa---|-000011-|  ==> sra rd, rt, sa # rd <- rt >> sa(arithmetic)
    
    sllv   |--000000--|----rs---|----rt----|----rd----|--00000--|-000100-|  ==> sllv rd, rt, rs # rd <- rt << rs[4:0](logic)
    srlv   |--000000--|----rs---|----rt----|----rd----|--00000--|-000110-|  ==> srlv rd, rt, rs # rd <- rt >> rs[4:0](logic)
    srav   |--000000--|----rs---|----rt----|----rd----|--00000--|-000111-|  ==> srav rd, rt, rs # rd <- rt >> rs[4:0](logic)
    
    nop    |--000000--|--00000--|---00000--|---00000--|--00000--|-000000-|  ==> 
    ssnop  |--000000--|--00000--|---00000--|---00000--|--00001--|-000000-|  ==> 
    sync   |--000000--|--00000--|---00000--|---00000--|--00001--|-001111-|  ==> 
    perf   |--110011--|--base---|---hint---|-----------offset------------|  ==> 

    I-type(Immediate format) instuction:
    Bits   |--31..26--|--25..21--|--20..16--|--15..11--|--10..6--|--5..0--|
    I-type |----op----|----rs----|----rt----|---------immediate----------|
    ori    |--001101--|----rs----|----rt----|---------immediate----------|   ==>  ori rt, rs, immediate #rt <- rs OR zero_extend(immediate)
    andi   |--001100--|----rs----|----rt----|---------immediate----------|   ==>  andi rt, rs, immediate #rt <- rs AND zero_extend(immediate)
    xori   |--001110--|----rs----|----rt----|---------immediate----------|   ==>  xori rt, rs, immediate #rt <- rs XOR zero_extend(immediate)
    lui    |--001111--|---0000---|----rt----|---------immediate----------|   ==>  lui rt, immediate #rt(h16) <- (immediate), rt(l16) <- (0)

    J-type(Jump format) instuction:
    Bits   |--31..26--|--25..21--|--20..16--|--15..11--|--10..6--|--5..0--|
    J-type |----op----|----------------------address----------------------|
*/

wire[5:0] op = i_inst[31:26];

wire[4:0] shamt = i_inst[10:6];
wire[4:0] sa = i_inst[10:6];
wire[5:0] func = i_inst[5:0];
wire[4:0] rs = i_inst[25:21];
wire[4:0] rt = i_inst[20:16];
wire[4:0] rd = i_inst[15:11];

wire[15:0] l_immediate = i_inst[15:0];

wire[25:0] j_address = i_inst[25:0];

reg[31:0] imm; //保存指令执行需要的立即数
reg instvalid; //代表指令的有效性

always @(*)
begin
    if(rst == 1'b1)
        begin
            instvalid = 1'b0;
            imm = 32'h0;
        
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
            instvalid = 1'b1;
            imm = 32'h0;
        
            o_rreg1_en <= 1'b0;
            //o_rreg1_addr <= rs;
            o_rreg2_en <= 1'b0;
            //o_rreg2_addr <= rt;
            
            o_alusel <= 3'b0;
            o_aluop <= 8'b0;
            
            o_wreg <= 1'b0;
            o_wreg_addr <= rd;
                     
            case (op)
                //op = 0x000000, SPECIAL
                `R_TYPE_INSTS:
                    begin
                        case (func)
                            /*
                            and    |--000000--|----rs----|----rt----|----rd----|--00000--|-100100-|  ==> and rd, rs, rt # rd <- rs AND rt
                            */
                            `INST_AND:
                                begin
                                    o_wreg <= 1'b1;
                                    o_alusel <= `OP_TYPE_LOGIC;
                                    o_aluop <= `OP_AND;
                                    
                                    o_rreg1_en <= 1'b1;
                                    o_rreg2_en <= 1'b1;
                                    o_rreg1_addr <= rs;
                                    o_rreg2_addr <= rt;
                                    
                                    o_wreg_addr <= rd; //写的目的寄存器地址
                                    instvalid = 1'b1; //and指令是有效指令
                                end
                            /*
                            or     |--000000--|----rs----|----rt----|----rd----|--00000--|-100101-|  ==> or rd, rs, rt # rd <- rs OR rt
                            */
                            `INST_OR:
                                begin
                                    o_wreg <= 1'b1;
                                    o_alusel <= `OP_TYPE_LOGIC;
                                    o_aluop <= `OP_OR;
                                    
                                    o_rreg1_en <= 1'b1;
                                    o_rreg2_en <= 1'b1;
                                    o_rreg1_addr <= rs;
                                    o_rreg2_addr <= rt;
                                    
                                    o_wreg_addr <= rd; //写的目的寄存器地址
                                    instvalid = 1'b1; //or指令是有效指令
                                end
                            /*
                            xor    |--000000--|----rs----|----rt----|----rd----|--00000--|-100110-|  ==> xor rd, rs, rt # rd <- rs XOR rt
                            */
                            `INST_XOR:
                                begin
                                    o_wreg <= 1'b1;
                                    o_alusel <= `OP_TYPE_LOGIC;
                                    o_aluop <= `OP_XOR;
                                    
                                    o_rreg1_en <= 1'b1;
                                    o_rreg2_en <= 1'b1;
                                    o_rreg1_addr <= rs;
                                    o_rreg2_addr <= rt;
                                    
                                    o_wreg_addr <= rd; //写的目的寄存器地址
                                    instvalid = 1'b1; //xor指令是有效指令
                                end
                            /*
                            nor    |--000000--|----rs----|----rt----|----rd----|--00000--|-100111-|  ==> nor rd, rs, rt # rd <- rs NOR rt
                            */
                            `INST_NOR:
                                begin
                                    o_wreg <= 1'b1;
                                    o_alusel <= `OP_TYPE_LOGIC;
                                    o_aluop <= `OP_NOR;
                                    
                                    o_rreg1_en <= 1'b1;
                                    o_rreg2_en <= 1'b1;
                                    o_rreg1_addr <= rs;
                                    o_rreg2_addr <= rt;
                                    
                                    o_wreg_addr <= rd; //写的目的寄存器地址
                                    instvalid = 1'b1; //nor指令是有效指令
                                end                            
                            /*
                            sll    |--000000--|---00000--|----rt----|----rd----|---sa---|-000000-|  ==> sll rd, rt, sa # rd <- rt << sa(logic)
                            */
                            `INST_SLL:
                                begin
                                    o_wreg <= 1'b1;
                                    o_alusel <= `OP_TYPE_SHIFT;
                                    o_aluop <= `OP_SLL;
                                    
                                    o_rreg1_en <= 1'b1;
                                    o_rreg2_en <= 1'b0;
                                    o_rreg1_addr <= rt;
                                    o_rreg2_addr <= 5'b00000;
                                    
                                    imm <= sa;
                                    
                                    o_wreg_addr <= rd; //写的目的寄存器地址
                                    instvalid = 1'b1; //ori指令是有效指令
                                end                            
                            /*
                            srl    |--000000--|---00000--|----rt----|----rd----|---sa----|-000010-|  ==> srl rd, rt, sa # rd <- rt >> sa(logic)
                            nop    |--000000--|--00000---|---00000--|---00000--|--00000--|-000000-|  ==> 
                            ssnop  |--000000--|--00000---|---00000--|---00000--|--00001--|-000000-|  ==> 
                            */
                            `INST_SRL:
                                begin
                                    o_wreg <= 1'b1;
                                    o_alusel <= `OP_TYPE_SHIFT;
                                    o_aluop <= `OP_SRL;
                                    
                                    o_rreg1_en <= 1'b1;
                                    o_rreg2_en <= 1'b0;
                                    o_rreg1_addr <= rt;
                                    o_rreg2_addr <= 5'b00000;
                                    
                                    imm <= sa;
                                    
                                    o_wreg_addr <= rd; //写的目的寄存器地址
                                    instvalid = 1'b1; //ori指令是有效指令
                                end                            
                            /*
                            sra    |--000000--|---00000--|----rt----|----rd----|---sa---|-000011-|  ==> sra rd, rt, sa # rd <- rt >> sa(arithmetic)
                            */
                            `INST_SRA:
                                begin
                                    o_wreg <= 1'b1;
                                    o_alusel <= `OP_TYPE_SHIFT;
                                    o_aluop <= `OP_SRA;
                                    
                                    o_rreg1_en <= 1'b1;
                                    o_rreg2_en <= 1'b0;
                                    o_rreg1_addr <= rt;
                                    o_rreg2_addr <= 5'b00000;
                                    
                                    o_wreg_addr <= rd; //写的目的寄存器地址
                                    instvalid = 1'b1; //ori指令是有效指令
                                end                            
                            /*
                            sllv   |--000000--|----rs---|----rt----|----rd----|--00000--|-000100-|  ==> sllv rd, rt, rs # rd <- rt << rs[4:0](logic)
                            */
                            `INST_SLLV:
                                begin
                                    o_wreg <= 1'b1;
                                    o_alusel <= `OP_TYPE_SHIFT;
                                    o_aluop <= `OP_SLLV;
                                    
                                    o_rreg1_en <= 1'b1;
                                    o_rreg2_en <= 1'b1;
                                    o_rreg1_addr <= rt;
                                    o_rreg2_addr <= rs;
                                    
                                    o_wreg_addr <= rd; //写的目的寄存器地址
                                    instvalid = 1'b1; //ori指令是有效指令
                                end                            
                            /*
                            srlv   |--000000--|----rs---|----rt----|----rd----|--00000--|-000110-|  ==> srlv rd, rt, rs # rd <- rt >> rs[4:0](logic)
                            */
                            `INST_SRLV:
                                begin
                                    o_wreg <= 1'b1;
                                    o_alusel <= `OP_TYPE_SHIFT;
                                    o_aluop <= `OP_SRLV;
                                    
                                    o_rreg1_en <= 1'b1;
                                    o_rreg2_en <= 1'b1;
                                    o_rreg1_addr <= rt;
                                    o_rreg2_addr <= rs;
                                    
                                    o_wreg_addr <= rd; //写的目的寄存器地址
                                    instvalid = 1'b1; //ori指令是有效指令
                                end                            
                            /*
                            srav   |--000000--|----rs---|----rt----|----rd----|--00000--|-000111-|  ==> srav rd, rt, rs # rd <- rt >> rs[4:0](arithmetic)
                            */
                            `INST_SRAV:
                                begin
                                    o_wreg <= 1'b1;
                                    o_alusel <= `OP_TYPE_SHIFT;
                                    o_aluop <= `OP_SRAV;
                                    
                                    o_rreg1_en <= 1'b1;
                                    o_rreg2_en <= 1'b1;
                                    o_rreg1_addr <= rt;
                                    o_rreg2_addr <= rs;
                                    
                                    o_wreg_addr <= rd; //写的目的寄存器地址
                                    instvalid = 1'b1; //ori指令是有效指令
                                end                            
                            /*
                            sync   |--000000--|--00000--|---00000--|---00000--|--00001--|-001111-|
                            */
                            `INST_SYNC:
                                begin
                                    o_wreg <= 1'b0;
                                    o_alusel <= `OP_TYPE_NOP;
                                    o_aluop <= `OP_NOP;
                                    
                                    o_rreg1_en <= 1'b0;
                                    o_rreg2_en <= 1'b0;
                                    
                                    o_wreg_addr <= 5'b00000;
                                    instvalid = 1'b1;
                                end                            
                            /*
                                movn   |--000000--|----rs----|----rt----|----rd----|--00000--|-001011-|  ==> movn rd, rs, rt # if rt != 0 then rd <- rs
                            */
                            `INST_MOVN:
                                begin
                                    instvalid = 1'b1;
                                    
                                    o_wreg <= 1'b1;
                                    o_wreg_addr <= rd;
                                    
                                    o_alusel <= `OP_TYPE_MOVE;
                                    o_aluop <= `OP_MOVN;
                                    
                                    o_rreg1_en <= 1'b1;
                                    o_rreg2_en <= 1'b1;
                                    o_rreg1_addr <= rt;
                                    o_rreg2_addr <= rs;                         
                                end
                            /*
                                movz   |--000000--|----rs----|----rt----|----rd----|--00000--|-001010-|  ==> movz rd, rs, rt # if rt == 0 then rd <- rs
                            */
                            `INST_MOVZ:
                                begin
                                    instvalid = 1'b1;
                                
                                    o_wreg <= 1'b1;
                                    o_wreg_addr <= rd;
                                    
                                    o_alusel <= `OP_TYPE_MOVE;
                                    o_aluop <= `OP_MOVZ;
                                    
                                    o_rreg1_en <= 1'b1;
                                    o_rreg2_en <= 1'b1;
                                    o_rreg1_addr <= rt;
                                    o_rreg2_addr <= rs;
                                end
                            /*
                                mfhi   |--000000--|---00000--|---00000--|----rd----|--00000--|-010000-|  ==> mfhi rd # rd <- hi
                            */
                            `INST_MFHI:
                                begin
                                    instvalid = 1'b1;
                                
                                    o_wreg <= 1'b1;
                                    o_wreg_addr <= rd;
                                    
                                    o_alusel <= `OP_TYPE_MOVE;
                                    o_aluop <= `OP_MFHI;
                                    
                                    o_rreg1_en <= 1'b0;
                                    o_rreg2_en <= 1'b0;
                                    o_rreg1_addr <= 5'b00000;
                                    o_rreg2_addr <= 5'b00000;
                                end
                            /*
                                mflo   |--000000--|---00000--|---00000--|----rd----|--00000--|-010010-|  ==> mflo rd # rd <- lo
                            */
                            `INST_MFLO:
                                begin
                                    instvalid = 1'b1;
                            
                                    o_wreg <= 1'b1;
                                    o_wreg_addr <= rd;
                                    
                                    o_alusel <= `OP_TYPE_MOVE;
                                    o_aluop <= `OP_MFLO;
                                    
                                    o_rreg1_en <= 1'b0;
                                    o_rreg2_en <= 1'b0;
                                    o_rreg1_addr <= 5'b00000;
                                    o_rreg2_addr <= 5'b00000;
                                end
                            /*
                                mthi   |--000000--|----rs----|---00000--|---00000--|--00000--|-010001-|  ==> mthi rs # hi <- rs
                            */
                            `INST_MTHI:
                                begin
                                    instvalid = 1'b1;
                            
                                    o_wreg <= 1'b0;
                                    o_wreg_addr <= 5'b00000;
                                    
                                    o_alusel <= `OP_TYPE_MOVE;
                                    o_aluop <= `OP_MTHI;
                                    
                                    o_rreg1_en <= 1'b1;
                                    o_rreg2_en <= 1'b0;
                                    o_rreg1_addr <= rs;
                                    o_rreg2_addr <= 5'b00000;
                                end
                            /*
                                mtlo   |--000000--|----rs----|---00000--|---00000--|--00000--|-010011-|  ==> mtlo rs # lo <- rs
                            */
                            `INST_MTLO:
                                begin
                                    instvalid = 1'b1;
                        
                                    o_wreg <= 1'b0;
                                    o_wreg_addr <= 5'b00000;
                                    
                                    o_alusel <= `OP_TYPE_MOVE;
                                    o_aluop <= `OP_MTLO;
                                    
                                    o_rreg1_en <= 1'b1;
                                    o_rreg2_en <= 1'b0;
                                    o_rreg1_addr <= rs;
                                    o_rreg2_addr <= 5'b00000;
                                end
                            default:
                                begin
                                    o_wreg <= 1'b0;
                                    o_alusel <= `OP_TYPE_NOP;
                                    o_aluop <= `OP_NOP;
                                    
                                    o_rreg1_en <= 1'b0;
                                    o_rreg2_en <= 1'b0;
                                    
                                    imm <= {l_immediate, 16'h00};
                                    o_wreg_addr <= 5'b0;
                                    instvalid = 1'b1;
                                end
                        endcase
                    end
                //op = 0x001101, ori    |--001101--|----rs----|----rt----|---------immediate----------|   ==>  ori rt, rs, immediate #rt <- rs OR zero_extend(immediate)
                `INST_ORI:
                    begin
                        o_wreg <= 1'b1;
                        o_alusel <= `OP_TYPE_LOGIC;
                        o_aluop <= `OP_ORI;
                        
                        o_rreg1_en <= 1'b1;
                        o_rreg2_en <= 1'b0;
                        o_rreg1_addr <= rs;
                        o_rreg2_addr <= rt;
                        
                        imm <= {16'h00, l_immediate};
                        o_wreg_addr <= rt;
                        instvalid = 1'b1;
                    end
                //op = 0x001100, andi   |--001100--|----rs----|----rt----|---------immediate----------|   ==>  andi rt, rs, immediate #rt <- rs AND zero_extend(immediate)
                `INST_ANDI:
                    begin
                        o_wreg <= 1'b1;
                        o_alusel <= `OP_TYPE_LOGIC;
                        o_aluop <= `OP_ANDI;
                        
                        o_rreg1_en <= 1'b1;
                        o_rreg2_en <= 1'b0;
                        o_rreg1_addr <= rs;
                        o_rreg2_addr <= rt;
                        
                        imm <= {16'h00, l_immediate};
                        o_wreg_addr <= rt;
                        instvalid = 1'b1;
                    end
                //op = 0x001110, xori   |--001110--|----rs----|----rt----|---------immediate----------|   ==>  xori rt, rs, immediate #rt <- rs XOR zero_extend(immediate)
                `INST_XORI:
                    begin
                        o_wreg <= 1'b1;
                        o_alusel <= `OP_TYPE_LOGIC;
                        o_aluop <= `OP_XORI;
                        
                        o_rreg1_en <= 1'b1;
                        o_rreg2_en <= 1'b0;
                        o_rreg1_addr <= rs;
                        o_rreg2_addr <= rt;
                        
                        imm <= {16'h00, l_immediate};
                        o_wreg_addr <= rt;
                        instvalid = 1'b1;
                    end
                //op = 0x001111, lui    |--001111--|---0000---|----rt----|---------immediate----------|   ==>  lui rt, immediate #rt(h16) <- (immediate), rt(l16) <- (0)
                `INST_LUI:
                    begin
                        o_wreg <= 1'b1;
                        o_alusel <= `OP_TYPE_LOGIC;
                        o_aluop <= `OP_LUI;
                        
                        o_rreg1_en <= 1'b0;
                        o_rreg2_en <= 1'b0;
                        o_rreg1_addr <= rs;
                        o_rreg2_addr <= rt;
                        
                        imm <= {l_immediate, 16'h00};
                        o_wreg_addr <= rt;
                        instvalid = 1'b1;
                    end                
                //op = 0x110011, perf
                `INST_PREF:
                    begin
                        o_wreg <= 1'b0;
                        o_alusel <= `OP_TYPE_NOP;
                        o_aluop <= `OP_NOP;
                        
                        o_rreg1_en <= 1'b0;
                        o_rreg2_en <= 1'b0;
                        
                        o_wreg_addr <= 5'b00000;
                        instvalid = 1'b1;
                    end                
                default:
                    begin
                        o_wreg <= 1'b0;
                        o_alusel <= `OP_TYPE_NOP;
                        o_aluop <= `OP_NOP;
                        
                        o_rreg1_en <= 1'b0;
                        o_rreg2_en <= 1'b0;
                        
                        imm <= {l_immediate, 16'h00};
                        o_wreg_addr <= 5'b0;
                        instvalid = 1'b1;
                    end
            endcase
        end
end

//确定运算操作的源操作数1
always @(*)
begin
    if (rst == 1'b1)
        begin
            o_reg1_data <= 32'h0;
        end
    //解决ID和EX的数据依赖
    else if((o_rreg1_en == 1'b1) && (i_ex_wreg == 1'b1) && (o_rreg1_addr == i_ex_wreg_addr))
        begin
            o_reg1_data <= i_ex_wreg_data;
        end
    //解决ID和MEM的数据依赖
    else if((o_rreg1_en == 1'b1) && (i_mem_wreg == 1'b1) && (o_rreg1_addr == i_mem_wreg_addr))
        begin
            o_reg1_data <= i_mem_wreg_data;
        end
    else if(o_rreg1_en == 1'b1)
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
end

//确定运算操作的源操作数2
always @(*)
begin
    if (rst == 1'b1)
        begin
            o_reg2_data <= 32'h0;
        end
    //解决ID和EX的数据依赖
    else if((o_rreg2_en == 1'b1) && (i_ex_wreg == 1'b1) && (o_rreg2_addr == i_ex_wreg_addr))
        begin
            o_reg2_data <= i_ex_wreg_data;
        end
    //解决ID和MEM的数据依赖
    else if((o_rreg2_en == 1'b1) && (i_mem_wreg == 1'b1) && (o_rreg2_addr == i_mem_wreg_addr))
        begin
            o_reg2_data <= i_mem_wreg_data;
        end
    else if(o_rreg2_en == 1'b1)
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

endmodule
