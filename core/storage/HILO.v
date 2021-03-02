`timescale 1ns / 1ps

`include "../../include/bus.v"

module HILO (
    input                       clk,
    input                       rst,

    input                       write_en,
    input       [`DATA_BUS]     hi_i,
    input       [`DATA_BUS]     lo_i,

    output      [`DATA_BUS]     hi_o,
    output      [`DATA_BUS]     lo_o
);

    reg [`DATA_BUS] hi;
    reg [`DATA_BUS] lo;
    
    assign hi_o = hi;
    assign lo_o = lo;

    always @(posedge clk) begin
        if(rst) begin
            hi <= 0;
            lo <= 0;
        end else if (write_en) begin
            hi <= hi_i;
            lo <= lo_i;
        end
    end
    
endmodule // HILO