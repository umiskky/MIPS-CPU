`timescale 1ns / 1ps

`include "bus.v"

module IDEX(
  input                   clk,
  input                   rst,
  input                   flush,
  input                   stall_current_stage,
  input                   stall_next_stage,
  // input from ID stage
  input   [`FUNCT_BUS]    funct_in,
  input   [`SHAMT_BUS]    shamt_in,
  input   [`DATA_BUS]     operand_1_in,
  input   [`DATA_BUS]     operand_2_in,
  input                   mem_read_flag_in,
  input                   mem_write_flag_in,
  input                   mem_sign_ext_flag_in,
  input   [`MEM_SEL_BUS]  mem_sel_in,
  input   [`DATA_BUS]     mem_write_data_in,
  input   [`INST_OP_BUS]  mem_op_in,
  input                   reg_write_en_in,
  input   [`REG_ADDR_BUS] reg_write_addr_in,
  input   [`ADDR_BUS]     current_pc_addr_in,
  input                   cp0_write_en_in,
  input                   cp0_read_en_in,
  input   [`CP0_ADDR_BUS] cp0_addr_in,
  input   [`DATA_BUS]     cp0_write_data_in,
  input   [`DATA_BUS]     cp0_read_data_in,

  input   [`EXC_TYPE_BUS] exception_type_in,
  input                   delayslot_flag_in,
  input                   next_inst_delayslot_flag_in,
  // output to EX stage
  output  [`FUNCT_BUS]    funct_out,
  output  [`SHAMT_BUS]    shamt_out,
  output  [`DATA_BUS]     operand_1_out,
  output  [`DATA_BUS]     operand_2_out,
  output                  mem_read_flag_out,
  output                  mem_write_flag_out,
  output                  mem_sign_ext_flag_out,
  output  [`MEM_SEL_BUS]  mem_sel_out,
  output  [`DATA_BUS]     mem_write_data_out,
  output  [`INST_OP_BUS]  mem_op_out,
  output                  reg_write_en_out,
  output  [`REG_ADDR_BUS] reg_write_addr_out,
  output  [`ADDR_BUS]     current_pc_addr_out,
  output                  cp0_write_en_out,
  output                  cp0_read_en_out,
  output  [`CP0_ADDR_BUS] cp0_addr_out,
  output  [`DATA_BUS]     cp0_write_data_out,
  output  [`DATA_BUS]     cp0_read_data_out,

  output  [`EXC_TYPE_BUS] exception_type_out,
  output                  delayslot_flag_out,
  output                  next_inst_delayslot_flag_out
);

  PipelineDeliver #(`EXC_TYPE_BUS_WIDTH) ff_exception_type(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    exception_type_in, exception_type_out
  );

  PipelineDeliver #(1) ff_delayslot_flag(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    delayslot_flag_in, delayslot_flag_out
  );

  PipelineDeliver #(1) ff_next_inst_delayslot_flag(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    next_inst_delayslot_flag_in, next_inst_delayslot_flag_out
  );

  PipelineDeliver #(1) ff_cp0_write_en(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    cp0_write_en_in, cp0_write_en_out
  );

  PipelineDeliver #(1) ff_cp0_read_en(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    cp0_read_en_in, cp0_read_en_out
  );

  PipelineDeliver #(`CP0_ADDR_BUS_WIDTH) ff_cp0_addr(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    cp0_addr_in, cp0_addr_out
  );

  PipelineDeliver #(`DATA_BUS_WIDTH) ff_cp0_write_data(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    cp0_write_data_in, cp0_write_data_out
  );

  PipelineDeliver #(`DATA_BUS_WIDTH) ff_cp0_read_data(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    cp0_read_data_in, cp0_read_data_out
  );

  PipelineDeliver #(`FUNCT_BUS_WIDTH) ff_funct(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    funct_in, funct_out
  );

  PipelineDeliver #(`SHAMT_BUS_WIDTH) ff_shamt(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    shamt_in, shamt_out
  );

  PipelineDeliver #(`DATA_BUS_WIDTH) ff_operand_1(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    operand_1_in, operand_1_out
  );

  PipelineDeliver #(`DATA_BUS_WIDTH) ff_operand_2(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    operand_2_in, operand_2_out
  );

  PipelineDeliver #(1) ff_mem_read_flag(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    mem_read_flag_in, mem_read_flag_out
  );

  PipelineDeliver #(1) ff_mem_write_flag(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    mem_write_flag_in, mem_write_flag_out
  );

  PipelineDeliver #(1) ff_mem_sign_ext_flag(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    mem_sign_ext_flag_in, mem_sign_ext_flag_out
  );

  PipelineDeliver #(`MEM_SEL_BUS_WIDTH) ff_mem_sel(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    mem_sel_in, mem_sel_out
  );

  PipelineDeliver #(`DATA_BUS_WIDTH) ff_mem_write_data(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    mem_write_data_in, mem_write_data_out
  );

  PipelineDeliver #(`INST_OP_BUS_WIDTH) ff_mem_op(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    mem_op_in, mem_op_out
  );

  PipelineDeliver #(1) ff_reg_write_en(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    reg_write_en_in, reg_write_en_out
  );

  PipelineDeliver #(`REG_ADDR_BUS_WIDTH) ff_reg_write_addr(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    reg_write_addr_in, reg_write_addr_out
  );

  PipelineDeliver #(`ADDR_BUS_WIDTH) ff_current_pc_addr(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    current_pc_addr_in, current_pc_addr_out
  );

endmodule // IDEX
