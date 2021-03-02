`timescale 1ns / 1ps

`include "bus.v"
`include "funct.v"

module MultDiv (
    input                           clk,
    input                           rst,
    input                           stall_all,
    input                           flush,
    input       [`FUNCT_BUS]        funct,
    input       [`DATA_BUS]         operand_1,
    input       [`DATA_BUS]         operand_2,

    output                          done,
    output  reg [`DOUBLE_DATA_BUS]  result              
);

    parameter kDivCycle = 33, kMultCycle = 1;

    reg [kDivCycle - 1 : 0] cycle_counter;
    wire [`DOUBLE_DATA_BUS] mult_result;
    wire [`DATA_BUS] quotient, remainder;
    wire div_done;
    reg done_flag;
    
    wire div_en = (funct == `FUNCT_DIV || funct == `FUNCT_DIVU) && cycle_counter == 0 && !done_flag;
    wire sign_flag = (funct == `FUNCT_MULT || funct == `FUNCT_DIV);
    wire result_neg_flag = sign_flag && (operand_1[31] ^ operand_2[31]);
    wire remainder_neg_flag = sign_flag && (operand_1[31] ^ remainder[31]);
    wire [`DATA_BUS] op_1 = (sign_flag && operand_1[31]) ? -operand_1 : operand_1;
    wire [`DATA_BUS] op_2 = (sign_flag && operand_2[31]) ? -operand_2 : operand_2;
    assign done = done_flag;

    DivGen div_gen(
        .aclk                   (clk),
        .aresetn                (!(rst | flush)),
        .s_axis_dividend_tdata  (op_1),
        .s_axis_dividend_tvalid (div_en),
        .s_axis_divisor_tdata   (op_2),
        .s_axis_divisor_tvalid  (div_en),

        .m_axis_dout_tdata      ({quotient, remainder}),
        .m_axis_dout_tvalid     (div_done)
    );

    MultGen mult_gen(
        .CLK        (clk),
        .A          (op_1),
        .B          (op_2),

        .P          (mult_result)
    );

    always @(*) begin
        case (funct)
            `FUNCT_MULT, `FUNCT_MULTU: begin
                result <= result_neg_flag ? -mult_result : mult_result;
            end 
            `FUNCT_DIV, `FUNCT_DIVU: begin
                result <= {
                    remainder_neg_flag ? -remainder : remainder,
                    result_neg_flag    ? -quotient  : quotient
                };
            end
            default: result <= 0;
        endcase       
    end

    always @(posedge clk) begin
        if (rst || flush) begin
            cycle_counter <= 0;
        end
        else if (stall_all) begin
            if (cycle_counter == 1) begin
                cycle_counter <= cycle_counter;
            end else if (cycle_counter)  begin
                cycle_counter <= cycle_counter >> 1;
            end
            else begin
                cycle_counter <= cycle_counter;
            end
        end
        else if (cycle_counter) begin
            cycle_counter <= cycle_counter >> 1;
        end
        else begin
            case (funct)
                `FUNCT_MULT, `FUNCT_MULTU: begin
                    cycle_counter <= 1'b1 << (kMultCycle - 1);
                end
                `FUNCT_DIV, `FUNCT_DIVU: begin
                    cycle_counter <= 1'b1 << (kDivCycle - 1);
                end
                default: begin
                    cycle_counter <= 0;
                end
            endcase
        end
    end

    always @(posedge clk) begin
        if (rst || flush) begin
            done_flag <= 0;
        end
        else if (cycle_counter) begin
            done_flag <= cycle_counter[0];
        end
        else begin
            done_flag <= 0;
        end
    end
    
endmodule