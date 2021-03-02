`timescale 1ns / 1ps

`include "bus.v"
`include "cp0def.v"

module CP0Gen (
    input       [`INST_BUS]         inst,
    input       [`INST_OP_BUS]      op,
    input       [`REG_ADDR_BUS]     rs,
    input       [`REG_ADDR_BUS]     rd,
    input       [`DATA_BUS]         reg_data_1,

    output  reg                     cp0_write_en,
    output  reg                     cp0_read_en,
    output  reg [`CP0_ADDR_BUS]     cp0_addr,
    output  reg [`DATA_BUS]         cp0_write_data
);

    always @(*) begin
        case (op)
            `OP_CP0: begin
                if (rs == `CP0_MTC0 && inst[10:3] == 0) begin
                    cp0_write_en <= 1;
                    cp0_read_en <= 0;
                    cp0_write_data <= reg_data_1;
                    cp0_addr <= {rd, inst[2:0]};
                end
                else if (rs == `CP0_MFC0 && inst[10:3] == 0) begin
                    cp0_write_en <= 0;
                    cp0_read_en <= 1;
                    cp0_write_data <= 0;
                    cp0_addr <= {rd, inst[2:0]};
                end
                else begin
                    cp0_write_en <= 0;
                    cp0_read_en <= 0;
                    cp0_write_data <= 0;
                    cp0_addr <= 0;
                end
            end 
            default:begin
                cp0_write_en <= 0;
                cp0_read_en <= 0;
                cp0_write_data <= 0;
                cp0_addr <= 0;
            end 
        endcase
    end
    
endmodule // CP0Gen