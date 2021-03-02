`timescale 1ns / 1ps

`include "bus.v"
`include "opcode.v"
`include "exception.v"

module MEM(
  input       [`DATA_BUS]     ram_read_data_in,
  // memory accessing signals
  input                       mem_read_flag_in,
  input                       mem_write_flag_in,
  input                       mem_sign_ext_flag_in,
  input       [`MEM_SEL_BUS]  mem_sel_in,
  input       [`DATA_BUS]     mem_write_data,
  input       [`INST_OP_BUS]  mem_op,
  // from EX stage
  input       [`DATA_BUS]     result_in,
  input                       reg_write_en_in,
  input       [`REG_ADDR_BUS] reg_write_addr_in,
  input       [`ADDR_BUS]     current_pc_addr_in,
  input                       delayslot_flag_in,
  // HI & LO control
  input                       hilo_write_en_in,
  input       [`DATA_BUS]     hi_in,
  input       [`DATA_BUS]     lo_in,
  // exception signalss
  input       [`EXC_TYPE_BUS] exception_type_in,
  input       [`DATA_BUS]     cp0_status_in,
  input       [`DATA_BUS]     cp0_cause_in,
  input       [`DATA_BUS]     cp0_epc_in,
  //cp0
  input                       cp0_write_en_in,
  input       [`DATA_BUS]     cp0_write_data_in,
  input       [`CP0_ADDR_BUS] cp0_addr_in,
  
  output  reg [`DATA_BUS]     ram_read_data_out,
  // RAM control signals
  output                      ram_en,
  output      [`MEM_SEL_BUS]  ram_write_en,
  output      [`ADDR_BUS]     ram_addr,
  output  reg [`DATA_BUS]     ram_write_data,
  // to ID stage
  output                      mem_load_flag,
  // to WB stage
  output                      mem_read_flag_out,
  output                      mem_write_flag_out,
  output                      mem_sign_ext_flag_out,
  output      [`MEM_SEL_BUS]  mem_sel_out,
  // regfile
  output  reg [`DATA_BUS]     result_out,
  output                      reg_write_en_out,
  output      [`REG_ADDR_BUS] reg_write_addr_out,
  // debug signals
  output      [`ADDR_BUS]     current_pc_addr_out,
  // HI & LO control
  output                      hilo_write_en_out,
  output      [`DATA_BUS]     hi_out,
  output      [`DATA_BUS]     lo_out,
  // exception signalss
  output  reg [`EXC_TYPE_BUS] exception_type_out,
  output                      delayslot_flag_out,
  // cp0
  output                      cp0_write_en_out,
  output      [`DATA_BUS]     cp0_write_data_out,
  output      [`CP0_ADDR_BUS] cp0_addr_out,
  output      [`ADDR_BUS]     cp0_epc_out,
  output  reg [`DATA_BUS]     cp0_badvaddr_write_data_out
);

  // HI & LO control
  assign hilo_write_en_out = hilo_write_en_in;
  assign hi_out = hi_in;
  assign lo_out = lo_in;

  // internal ram_write_sel control signal
  reg[`MEM_SEL_BUS] ram_write_sel;

  // to ID stage
  assign mem_load_flag = mem_read_flag_in;
  // to WB stage
  assign mem_read_flag_out = mem_read_flag_in;
  assign mem_write_flag_out = mem_write_flag_in;
  assign mem_sign_ext_flag_out = mem_sign_ext_flag_in;
  assign mem_sel_out = mem_sel_in;
  assign reg_write_en_out = reg_write_en_in;
  assign reg_write_addr_out = reg_write_addr_in;
  assign current_pc_addr_out = current_pc_addr_in;
  assign cp0_write_en_out = cp0_write_en_in;
  assign cp0_write_data_out = cp0_write_data_in;
  assign cp0_addr_out = cp0_addr_in;

  wire[`ADDR_BUS] address = result_in;

  // generate ram_en signal
  assign ram_en = mem_write_flag_in || mem_read_flag_in;

  // generate ram_write_en signal
  assign ram_write_en = mem_write_flag_in ? ram_write_sel : 0;

  // generate ram_write_addr signal
  assign ram_addr = mem_write_flag_in || mem_read_flag_in
      ? {address[31:2], 2'b00} : 0;

  // generate ram_write_sel signal
  always @(*) begin
    if (mem_write_flag_in) begin
      if (mem_sel_in == 4'b0001) begin   // byte
        case (address[1:0])
          2'b00: ram_write_sel <= 4'b0001;
          2'b01: ram_write_sel <= 4'b0010;
          2'b10: ram_write_sel <= 4'b0100;
          2'b11: ram_write_sel <= 4'b1000;
          default: ram_write_sel <= 4'b0000;
        endcase
      end
      else if (mem_sel_in == 4'b0011) begin   // half word
        case (address[1:0])
          2'b00: ram_write_sel <= 4'b0011;
          2'b10: ram_write_sel <= 4'b1100;
          default: ram_write_sel <= 4'b0000;
        endcase
      end
      else if (mem_sel_in == 4'b1111) begin   // word
        // SWL, SWR
        case (mem_op)
          `OP_SWL:
            case (address[1:0])
              2'b00: ram_write_sel <= 4'b0001;
              2'b01: ram_write_sel <= 4'b0011;
              2'b10: ram_write_sel <= 4'b0111;
              2'b11: ram_write_sel <= 4'b1111;
            endcase
          `OP_SWR:
            case (address[1:0])
              2'b00: ram_write_sel <= 4'b1111;
              2'b01: ram_write_sel <= 4'b1110;
              2'b10: ram_write_sel <= 4'b1100;
              2'b11: ram_write_sel <= 4'b1000;
            endcase
          default:
            case (address[1:0])
              2'b00: ram_write_sel <= 4'b1111;
              default: ram_write_sel <= 4'b0000;
            endcase
        endcase
      end
      else begin
        ram_write_sel <= 4'b0000;
      end
    end
    else begin
      ram_write_sel <= 4'b0000;
    end
  end

  // generate ram_write_data signal
  always @(*) begin
    if (mem_write_flag_in) begin
      if (mem_sel_in == 4'b0001) begin
        case (address[1:0])
          2'b00: ram_write_data <= mem_write_data;
          2'b01: ram_write_data <= mem_write_data << 8;
          2'b10: ram_write_data <= mem_write_data << 16;
          2'b11: ram_write_data <= mem_write_data << 24;
        endcase
      end
      else if (mem_sel_in == 4'b0011) begin
        case (address[1:0])
          2'b00: ram_write_data <= mem_write_data;
          2'b10: ram_write_data <= mem_write_data << 16;
          default: ram_write_data <= 0;
        endcase
      end
      else if (mem_sel_in == 4'b1111) begin
        // SWL, SWR
        case (mem_op)
          `OP_SWL:
            case (address[1:0])
              2'b00: ram_write_data <= mem_write_data >> 24;
              2'b01: ram_write_data <= mem_write_data >> 16;
              2'b10: ram_write_data <= mem_write_data >> 8;
              2'b11: ram_write_data <= mem_write_data;
            endcase
          `OP_SWR:
            case (address[1:0])
              2'b00: ram_write_data <= mem_write_data;
              2'b01: ram_write_data <= mem_write_data << 8;
              2'b10: ram_write_data <= mem_write_data << 16;
              2'b11: ram_write_data <= mem_write_data << 24;
            endcase
          default:
            case (address[1:0])
              2'b00: ram_write_data <= mem_write_data;
              default: ram_write_data <= 0;
            endcase
        endcase
      end
      else begin
        ram_write_data <= 0;
      end
    end
    else begin
      ram_write_data <= 0;
    end
  end

  // generate ram_read_data_out signal
  always @(*) begin
    case (mem_op)
      `OP_LWL: begin
        case(address[1:0])
          2'b00: ram_read_data_out <= {ram_read_data_in[7:0], mem_write_data[23:0]};
          2'b01: ram_read_data_out <= {ram_read_data_in[15:0], mem_write_data[15:0]};
          2'b10: ram_read_data_out <= {ram_read_data_in[23:0], mem_write_data[7:0]};
          2'b11: ram_read_data_out <= ram_read_data_in;
        endcase
      end
      `OP_LWR: begin
        case(address[1:0])
          2'b00: ram_read_data_out <= ram_read_data_in;
          2'b01: ram_read_data_out <= {mem_write_data[31:24], ram_read_data_in[31:8]};
          2'b10: ram_read_data_out <= {mem_write_data[31:16], ram_read_data_in[31:16]};
          2'b11: ram_read_data_out <= {mem_write_data[31:8], ram_read_data_in[31:24]};
        endcase
      end
      default: ram_read_data_out <= ram_read_data_in;
    endcase
  end

  // generate result_out
  always @(*) begin
    case(mem_op) 
      `OP_LWL, `OP_LWR: result_out <= {result_in[31:2], 2'b0};
      default: result_out <= result_in;
    endcase
  end


  // generate exception signalss
  reg adel_flag, ades_flag;
  assign cp0_epc_out = cp0_epc_in;
  assign delayslot_flag_out = delayslot_flag_in;
  assign int_occured = |(cp0_cause_in[`CP0_SEG_INT] & cp0_status_in[`CP0_SEG_IM]);
  assign int_enabled = !cp0_status_in[`CP0_SEG_EXL] && cp0_status_in[`CP0_SEG_IE];

  // adel, ades
  always @(*) begin
      if(|current_pc_addr_in[1:0]) begin
          {adel_flag, ades_flag} <= 2'b10;
          cp0_badvaddr_write_data_out <= current_pc_addr_in;
      end
      else if(mem_sel_in == 4'b0011 && address[0]) begin
          {adel_flag, ades_flag} <= {mem_read_flag_in, mem_write_flag_in};
          cp0_badvaddr_write_data_out <= address;
      end
      else if (mem_sel_in == 4'b1111 && |address[1:0] && !(mem_op == `OP_LWL || mem_op == `OP_LWR ||  mem_op == `OP_SWL || mem_op == `OP_SWR)) begin
          {adel_flag, ades_flag} <= {mem_read_flag_in, mem_write_flag_in};
          cp0_badvaddr_write_data_out <= address;
      end
      else begin
          {adel_flag, ades_flag} <= 2'b00;
          cp0_badvaddr_write_data_out <= 0;
      end
  end

  // exception_type_out
  always @(*) begin
      if(int_occured && int_enabled) begin
          exception_type_out <= `EXC_TYPE_INT;
      end
      else if (|current_pc_addr_in[1:0]) begin
          exception_type_out <= `EXC_TYPE_IF;
      end
      else if (exception_type_in[`EXC_TYPE_POS_RI]) begin
          exception_type_out <= `EXC_TYPE_RI;
      end 
      else if (exception_type_in[`EXC_TYPE_POS_OV]) begin
          exception_type_out <= `EXC_TYPE_OV;
      end
      else if (exception_type_in[`EXC_TYPE_POS_BP]) begin
          exception_type_out <= `EXC_TYPE_BP;
      end
      else if (exception_type_in[`EXC_TYPE_POS_SYS]) begin
          exception_type_out <= `EXC_TYPE_SYS;
      end
      else if (adel_flag) begin
          exception_type_out <= `EXC_TYPE_ADEL;
      end
      else if (ades_flag) begin
          exception_type_out <= `EXC_TYPE_ADES;
      end
      else if (exception_type_in[`EXC_TYPE_POS_ERET]) begin
          exception_type_out <= `EXC_TYPE_ERET;
      end
      else begin
          exception_type_out <= `EXC_TYPE_NULL;
      end
  end


endmodule // MEM
