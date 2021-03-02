`timescale 1ns / 1ps

`include "../../include/bus.v"


module HILOReadProxy (
    input       [`DATA_BUS]     hi_i,
    input       [`DATA_BUS]     lo_i,

    input                       mem_hilo_write_en,
    input       [`DATA_BUS]     mem_hi_i,
    input       [`DATA_BUS]     mem_lo_i,

    input                       wb_hilo_write_en,
    input       [`DATA_BUS]     wb_hi_i,
    input       [`DATA_BUS]     wb_lo_i,

    output      [`DATA_BUS]     hi_o,
    output      [`DATA_BUS]     lo_o

);

    assign hi_o =   mem_hilo_write_en ? mem_hi_i :
                    wb_hilo_write_en  ? wb_hi_i  : 
                    hi_i;

    assign lo_o =   mem_hilo_write_en ? mem_lo_i :
                    wb_hilo_write_en  ? wb_lo_i  : 
                    lo_i;
    
endmodule // HILOReadProxy