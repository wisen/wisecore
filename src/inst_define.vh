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
	srav   |--000000--|----rs---|----rt----|----rd----|--00000--|-000111-|  ==> srav rd, rt, rs # rd <- rt >> rs[4:0](arithmetic)
	
	nop    |--000000--|--00000--|---00000--|---00000--|--00000--|-000000-|  ==> 
	ssnop  |--000000--|--00000--|---00000--|---00000--|--00001--|-000000-|  ==> 
	sync   |--000000--|--00000--|---00000--|---00000--|--00001--|-001111-|  ==> 
	perf   |--110011--|--base---|---hint---|-----------offset------------|  ==> 
*/

/*
    I-type(Immediate format) instuction:
    Bits   |--31..26--|--25..21--|--20..16--|--15..11--|--10..6--|--5..0--|
    I-type |----op----|----rs----|----rt----|---------immediate----------|
    ori    |--001101--|----rs----|----rt----|---------immediate----------|   ==>  ori rt, rs, immediate #rt <- rs OR zero_extend(immediate)
    andi   |--001100--|----rs----|----rt----|---------immediate----------|   ==>  andi rt, rs, immediate #rt <- rs AND zero_extend(immediate)
    xori   |--001110--|----rs----|----rt----|---------immediate----------|   ==>  xori rt, rs, immediate #rt <- rs XOR zero_extend(immediate)
    lui    |--001111--|---0000---|----rt----|---------immediate----------|   ==>  lui rt, immediate #rt(h16) <- (immediate), rt(l16) <- (0)
*/
/*
    J-type(Jump format) instuction:
    Bits   |--31..26--|--25..21--|--20..16--|--15..11--|--10..6--|--5..0--|
    J-type |----op----|----------------------address----------------------|
*/

//Instruction define
`define INST_AND    6'b100100
`define INST_OR     6'b100101
`define INST_XOR    6'b100110
`define INST_NOR    6'b100111
`define INST_ANDI   6'b001100
`define INST_ORI    6'b001101
`define INST_XORI   6'b001110
`define INST_LUI    6'b001111

`define INST_SLL    6'b000000
`define INST_SLLV   6'b000100
`define INST_SRL    6'b000010
`define INST_SRLV   6'b000110
`define INST_SRA    6'b000011
`define INST_SRAV   6'b000111
`define INST_SYNC   6'b001111
`define INST_PREF   6'b110011

`define INST_NOP    6'b000000
`define INST_SSNOP  32'b00000000000000000000000001000000

`define R_TYPE_INSTS        6'b000000
`define REGIMM_TYPE_INST    6'b000001
`define SPECIAL2_TYPE_INST  6'b011100

//AluOp
`define OP_AND  8'b00000001
`define OP_OR   8'b00000010
`define OP_XOR  8'b00000011
`define OP_NOR  8'b00000100
`define OP_ANDI 8'b00000101
`define OP_ORI  8'b00000110
`define OP_XORI 8'b00000111
`define OP_LUI  8'b00001000   

`define OP_SLL  8'b00001001
`define OP_SLLV 8'b00001010
`define OP_SRL  8'b00001011
`define OP_SRLV 8'b00001100
`define OP_SRA  8'b00001101
`define OP_SRAV 8'b00001110

`define OP_NOP  8'b00000000

//AluSel, Operation type: nop,logic,shift,arithmrtic
`define OP_TYPE_NOP     3'b000
`define OP_TYPE_LOGIC   3'b001
`define OP_TYPE_SHIFT   3'b010
