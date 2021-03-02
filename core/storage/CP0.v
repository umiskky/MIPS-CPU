`timescale 1ns / 1ps

`include "bus.v"
`include "cp0def.v"
`include "exception.v"

module CP0 (
    input                       clk,
    input                       rst,
    // cp0 cnotrol
    input                       cp0_write_en,
    input       [`CP0_ADDR_BUS] cp0_read_addr,
    input       [`CP0_ADDR_BUS] cp0_write_addr,
    input       [`DATA_BUS]     cp0_write_data,

    // // External Interrupt
    // input       [5:0]           interrupt_i,

    // External signal
    input       [`ADDR_BUS]     cp0_badvaddr_write_data,
    input       [`EXC_TYPE_BUS] exception_type,
    input                       delayslot_flag,
    input       [`ADDR_BUS]     current_pc_addr,


    output  reg [`DATA_BUS]     data_o,
    output      [`DATA_BUS]     count_o,
    output      [`DATA_BUS]     status_o,
    output      [`DATA_BUS]     cause_o,
    output      [`DATA_BUS]     epc_o
);

    reg [`DATA_BUS] reg_badvaddr;
    reg [32:0]      reg_count;
    reg [`DATA_BUS] reg_compare;
    reg [`DATA_BUS] reg_status;
    reg [`DATA_BUS] reg_cause;
    reg [`DATA_BUS] reg_epc;

    wire [`ADDR_BUS] exc_epc;
    // reg timer_int;

    assign count_o  = reg_count[32:1];
    assign status_o = reg_status;
    assign cause_o = reg_cause;
    assign epc_o = reg_epc;
    assign exc_epc = delayslot_flag ? current_pc_addr - 4 : current_pc_addr;

    always @(posedge clk) begin
        if (rst) begin
            reg_badvaddr <= `CP0_REG_BADVADDR_VALUE;
            reg_count <= 33'h0;
            reg_compare <= 32'h0;
            reg_status <= `CP0_REG_STATUS_VALUE;
            reg_cause <= `CP0_REG_CAUSE_VALUE;
            reg_epc <= `CP0_REG_EPC_VALUE;
        end
        else begin
            // store the status of hardware interrupts
            // reg_cause[`CP0_SEG_HWI] <= {timer_int, interrupt_i};
            reg_count <= reg_count + 1;
            // reg_cause[15:10] <= interrupt_i;
            // if (reg_compare != 0 && reg_count[32:1] == reg_compare) begin
            //     // timer_int <= 1;
            // end
            if (cp0_write_en) begin
                case (cp0_write_addr)
                    `CP0_REG_COUNT: reg_count <= {cp0_write_data, 1'b0};
                    `CP0_REG_STATUS: begin
                        reg_status[22] <= cp0_write_data[22];
                        reg_status[15:8] <= cp0_write_data[15:8];
                        reg_status[1:0] <= cp0_write_data[1:0];
                    end
                    `CP0_REG_COMPARE: begin
                        reg_compare <= cp0_write_data;
                        // timer_int <= 0;
                    end
                    `CP0_REG_CAUSE: reg_cause[9:8] <= cp0_write_data[9:8];
                    `CP0_REG_EPC: reg_epc <= cp0_write_data;
                    default: ;
                endcase
            end

            case (exception_type[`EXC_TYPE_POS_INT])
                `EXC_TYPE_INT: begin
                    reg_epc <= exc_epc;
                    reg_cause[`CP0_SEG_BD] <= delayslot_flag;
                    reg_status[`CP0_SEG_EXL] <= 1;
                    reg_cause[`CP0_SEG_EXCCODE] <= `CP0_EXCCODE_INT;
                end
                `EXC_TYPE_IF, `EXC_TYPE_ADEL: begin
                    reg_epc <= exc_epc;
                    reg_cause[`CP0_SEG_BD] <= delayslot_flag;
                    reg_badvaddr <= cp0_badvaddr_write_data;
                    reg_status[`CP0_SEG_EXL] <= 1;
                    reg_cause[`CP0_SEG_EXCCODE] <= `CP0_EXCCODE_ADEL;
                end
                `EXC_TYPE_RI: begin
                    reg_epc <= exc_epc;
                    reg_cause[`CP0_SEG_BD] <= delayslot_flag;
                    reg_status[`CP0_SEG_EXL] <= 1;
                    reg_cause[`CP0_SEG_EXCCODE] <= `CP0_EXCCODE_RI;
                end
                `EXC_TYPE_OV: begin
                    reg_epc <= exc_epc;
                    reg_cause[`CP0_SEG_BD] <= delayslot_flag;
                    reg_status[`CP0_SEG_EXL] <= 1;
                    reg_cause[`CP0_SEG_EXCCODE] <= `CP0_EXCCODE_OV;
                end
                `EXC_TYPE_BP: begin
                    reg_epc <= exc_epc;
                    reg_cause[`CP0_SEG_BD] <= delayslot_flag;
                    reg_status[`CP0_SEG_EXL] <= 1;
                    reg_cause[`CP0_SEG_EXCCODE] <= `CP0_EXCCODE_BP;
                end
                `EXC_TYPE_SYS: begin
                    reg_epc <= exc_epc;
                    reg_cause[`CP0_SEG_BD] <= delayslot_flag;
                    reg_status[`CP0_SEG_EXL] <= 1;
                    reg_cause[`CP0_SEG_EXCCODE] <= `CP0_EXCCODE_SYS;
                end
                `EXC_TYPE_ADES: begin
                    reg_epc <= exc_epc;
                    reg_cause[`CP0_SEG_BD] <= delayslot_flag;
                    reg_badvaddr <= cp0_badvaddr_write_data;
                    reg_status[`CP0_SEG_EXL] <= 1;
                    reg_cause[`CP0_SEG_EXCCODE] <= `CP0_EXCCODE_ADES;
                end
                `EXC_TYPE_ERET: begin
                    reg_status[`CP0_SEG_EXL] <= 0;
                end
                default:;
            endcase
        end
    end

    always @(*) begin
        if(rst) begin
            data_o <= 32'b0;
        end
        else begin
            case (cp0_read_addr)
                `CP0_REG_BADVADDR:  data_o <= reg_badvaddr;
                `CP0_REG_COUNT: data_o <= reg_count;
                `CP0_REG_COMPARE: data_o <= reg_compare;
                `CP0_REG_STATUS: data_o <= reg_status;
                `CP0_REG_CAUSE: data_o <= reg_cause;
                `CP0_REG_EPC: data_o <= reg_epc;
                default: data_o <= 0;
            endcase
        end
    end

    
endmodule // CP0