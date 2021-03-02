`timescale 1ns / 1ps

`include "bus.v"

module EXMEM(
  input                   clk,
  input                   rst,
  input                   flush,
  input                   stall_current_stage,
  input                   stall_next_stage,
  // input from EX stage
  input                   mem_read_flag_in,
  input                   mem_write_flag_in,
  input                   mem_sign_ext_flag_in,
  input   [`MEM_SEL_BUS]  mem_sel_in,
  input   [`DATA_BUS]     mem_write_data_in,
  input   [`INST_OP_BUS]  mem_op_in,
  input   [`DATA_BUS]     result_in,
  input                   reg_write_en_in,
  input   [`REG_ADDR_BUS] reg_write_addr_in,
  input   [`ADDR_BUS]     current_pc_addr_in,
  // HI & LO control
  input                   hilo_write_en_in,
  input   [`DATA_BUS]     hi_in,
  input   [`DATA_BUS]     lo_in,
  // cp0
  input                   cp0_write_en_in,
  input   [`DATA_BUS]     cp0_write_data_in,
  input   [`CP0_ADDR_BUS] cp0_addr_in,
  // exception
  input   [`EXC_TYPE_BUS] exception_type_in,
  input                   delayslot_flag_in,

  // output to MEM stage
  output                  mem_read_flag_out,
  output                  mem_write_flag_out,
  output                  mem_sign_ext_flag_out,
  output  [`MEM_SEL_BUS]  mem_sel_out,
  output  [`DATA_BUS]     mem_write_data_out,
  output  [`INST_OP_BUS]  mem_op_out,
  // output to WB stage
  output  [`DATA_BUS]     result_out,
  output                  reg_write_en_out,
  output  [`REG_ADDR_BUS] reg_write_addr_out,
  output  [`ADDR_BUS]     current_pc_addr_out,
  // HI & LO control
  output                  hilo_write_en_out,
  output  [`DATA_BUS]     hi_out,
  output  [`DATA_BUS]     lo_out,
  // cp0
  output                  cp0_write_en_out,
  output  [`DATA_BUS]     cp0_write_data_out,
  output  [`CP0_ADDR_BUS] cp0_addr_out,
  // exception
  output  [`EXC_TYPE_BUS] exception_type_out,
  output                  delayslot_flag_out
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

  PipelineDeliver #(1) ff_cp0_write_en(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    cp0_write_en_in, cp0_write_en_out
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

  PipelineDeliver #(1) ff_hilo_write_en(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    hilo_write_en_in, hilo_write_en_out
  );

  PipelineDeliver #(`DATA_BUS_WIDTH) ff_hi(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    hi_in, hi_out
  );

  PipelineDeliver #(`DATA_BUS_WIDTH) ff_lo(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    lo_in, lo_out
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

  PipelineDeliver #(`DATA_BUS_WIDTH) ff_result(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    result_in, result_out
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

endmodule // EXMEM
