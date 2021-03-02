`timescale 1ns / 1ps

`include "bus.v"
`include "opcode.v"
`include "funct.v"
`include "regimm.v"

module OperandGen(
  input       [`ADDR_BUS]       addr,
  input       [`INST_OP_BUS]    op,
  input       [`REG_ADDR_BUS]   rt,
  input       [`FUNCT_BUS]      funct,
  input       [`HALF_DATA_BUS]  imm,
  input       [`DATA_BUS]       reg_data_1,
  input       [`DATA_BUS]       reg_data_2,
  output  reg [`DATA_BUS]       operand_1,
  output  reg [`DATA_BUS]       operand_2
);

  // calculate link address
  wire[`ADDR_BUS] link_addr = addr + 8;

  // extract immediate from instruction
  wire[`DATA_BUS] zero_ext_imm_hi = {imm, 16'b0};
  wire[`DATA_BUS] zero_ext_imm_lo = {16'b0, imm};
  wire[`DATA_BUS] sign_ext_imm = {{16{imm[15]}}, imm};

  // generate operand_1
  always @(*) begin
    case (op)
      // immediate
      `OP_ADDIU, `OP_LUI, `OP_ADDI, 
      `OP_SLTI, `OP_SLTIU,
      `OP_ANDI, `OP_ORI, `OP_XORI,
      // memory accessing
      `OP_LB, `OP_LW, `OP_LBU, `OP_SB, `OP_SW,
      `OP_LH, `OP_LHU, `OP_LWL, `OP_LWR, `OP_SWL, `OP_SWR,
      `OP_SH: begin
        operand_1 <= reg_data_1;
      end
      `OP_SPECIAL: begin
        operand_1 <= funct == `FUNCT_JALR ? link_addr : reg_data_1;
      end
      `OP_REGIMM: begin
        operand_1 <= rt == `REGIMM_BLTZAL || rt == `REGIMM_BGEZAL ? link_addr : 0;
      end
      `OP_JAL: begin
        operand_1 <= link_addr;
      end
      default: begin
        operand_1 <= 0;
      end
    endcase
  end

  // generate operand_2
  always @(*) begin
    case (op)
      `OP_LUI: begin
        operand_2 <= zero_ext_imm_hi;
      end
      `OP_ANDI, `OP_XORI, `OP_ORI: begin
        operand_2 <= zero_ext_imm_lo;
      end
      // arithmetic & logic (immediate)
      `OP_ADDIU, `OP_ADDI,
      `OP_SLTI, `OP_SLTIU,
      // memory accessing
      `OP_LB, `OP_LW, `OP_LBU, `OP_SB, `OP_SW,
      `OP_LH, `OP_LHU, `OP_LWL, `OP_LWR, `OP_SWL, `OP_SWR,
      `OP_SH: begin
        operand_2 <= sign_ext_imm;
      end
      `OP_SPECIAL: begin
        operand_2 <= reg_data_2;
      end
      default: begin
        operand_2 <= 0;
      end
    endcase
  end

endmodule // OperandGen
