`timescale 1ns / 1ps

`include "bus.v"
`include "opcode.v"
`include "funct.v"
`include "cp0def.v"
`include "regimm.v"

module ExceptionGen (
	input   	[`INST_BUS]		inst,
	input		[`INST_OP_BUS]	op,
	input       [`FUNCT_BUS]    funct,
	input       [`REG_ADDR_BUS] inst_rt,
	input       [`REG_ADDR_BUS] inst_rs,
    //exception signal
    output      [`EXC_TYPE_BUS] exception_type
);

	wire eret_flag, syscall_flag, break_flag, overflow_flag;
    reg invalid_inst_flag;
    assign exception_type ={
        eret_flag, /* ADE */ 1'b0,
        syscall_flag, break_flag, /* TP */ 1'b0,
        overflow_flag, invalid_inst_flag, /* IF */ 1'b0};

    assign eret_flag = (inst == `CP0_ERET_FULL) ? 1 : 0;
    assign syscall_flag = (op == `OP_SPECIAL && funct == `FUNCT_SYSCALL) ? 1 : 0;
    assign break_flag = (op == `OP_SPECIAL && funct == `FUNCT_BREAK) ? 1 : 0;
    assign overflow_flag = ((op == `OP_SPECIAL && (funct == `FUNCT_ADD || funct == `FUNCT_SUB)) 
                            || (op == `OP_ADDI)) ? 1 : 0;

    // 判断指令是否存在
    always @(*) begin
        case (op)
            `OP_SPECIAL: begin
                case (funct)
                    `FUNCT_SLL, `FUNCT_SRL, `FUNCT_SRA, `FUNCT_SLLV,
                    `FUNCT_SRLV, `FUNCT_SRAV, `FUNCT_JR, `FUNCT_JALR,
                    `FUNCT_ADD, `FUNCT_SUB,
                    `FUNCT_MFHI, `FUNCT_MTHI, `FUNCT_MFLO, `FUNCT_MTLO,
                    `FUNCT_MULT, `FUNCT_MULTU, `FUNCT_DIV, `FUNCT_DIVU,
                    `FUNCT_ADDU, `FUNCT_SUBU, `FUNCT_AND, `FUNCT_OR,
                    `FUNCT_XOR, `FUNCT_NOR, `FUNCT_SLT, `FUNCT_SLTU,
                    `FUNCT_SYSCALL, `FUNCT_BREAK: begin
                        invalid_inst_flag <= 0;
                    end
                    default: invalid_inst_flag <= 1;
                endcase
            end 

            `OP_REGIMM: begin
                case (inst_rt)
                    `REGIMM_BLTZ, `REGIMM_BLTZAL, 
                    `REGIMM_BGEZ, `REGIMM_BGEZAL: begin
                        invalid_inst_flag <= 0;
                    end 
                    default: invalid_inst_flag <= 1;
                endcase
            end

            `OP_CP0: begin
                case (inst_rs)
                    `CP0_MFC0, `CP0_MTC0, `CP0_ERET: begin
                        invalid_inst_flag <= 0;
                    end
                    default: invalid_inst_flag <= 1;
                endcase
            end

            `OP_J, `OP_JAL, `OP_BEQ, `OP_BNE, `OP_BLEZ, `OP_BGTZ,
            `OP_ADDIU, `OP_SLTI, `OP_SLTIU, `OP_ANDI, `OP_ORI,
            `OP_XORI, `OP_LUI, `OP_LB, `OP_LH, `OP_LW, `OP_LBU,
            `OP_LHU, `OP_SB, `OP_SH, `OP_SW, `OP_ADDI: begin
                invalid_inst_flag <= 0;
            end

            default: invalid_inst_flag <= 1;
        endcase
    end
    
endmodule // ExceptionGen