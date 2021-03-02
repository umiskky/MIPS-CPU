`timescale 1ns / 1ps

`include "bus.v"
`include "cp0def.v"

module CP0ReadProxy (
    input       [`CP0_ADDR_BUS] cp0_read_addr,
    // from cp0
    input       [`DATA_BUS]     cp0_count_i,
    input       [`DATA_BUS]     cp0_status_i,
    input       [`DATA_BUS]     cp0_cause_i,
    input       [`DATA_BUS]     cp0_epc_i,
    input       [`DATA_BUS]     cp0_read_data_i,
    // from mem
    input                       mem_cp0_write_en,
    input       [`CP0_ADDR_BUS] mem_cp0_write_addr,
    input       [`DATA_BUS]     mem_cp0_write_data,
    // from wb
    input                       wb_cp0_write_en,
    input       [`CP0_ADDR_BUS] wb_cp0_write_addr,
    input       [`DATA_BUS]     wb_cp0_write_data,

    output      [`DATA_BUS]     cp0_count_o,
    output      [`DATA_BUS]     cp0_status_o,
    output      [`DATA_BUS]     cp0_cause_o,
    output      [`DATA_BUS]     cp0_epc_o,
    output      [`DATA_BUS]     cp0_read_data_o

);

    assign cp0_read_data_o = (mem_cp0_write_en && mem_cp0_write_addr == cp0_read_addr) ? mem_cp0_write_data :
                            (wb_cp0_write_en && wb_cp0_write_addr == cp0_read_addr) ? wb_cp0_write_data : cp0_read_data_i;
    
    // generate data output of cp0 registers (MEM stage)
    assign cp0_count_o =    (wb_cp0_write_en && wb_cp0_write_addr == `CP0_REG_COUNT) ? 
                            wb_cp0_write_data : cp0_count_i;
    assign cp0_status_o =   (wb_cp0_write_en && wb_cp0_write_addr == `CP0_REG_STATUS) ? 
                            wb_cp0_write_data : cp0_status_i;
    assign cp0_cause_o =    (wb_cp0_write_en && wb_cp0_write_addr == `CP0_REG_CAUSE) ? 
                            wb_cp0_write_data : cp0_cause_i;
    assign cp0_epc_o =      (wb_cp0_write_en && wb_cp0_write_addr == `CP0_REG_EPC) ? 
                            wb_cp0_write_data : cp0_epc_i;
    
endmodule // CP0ReadProxy