// coprocessor instructions
`define CP0_MFC0                 5'b00000
`define CP0_MTC0                 5'b00100
`define CP0_ERET                 5'b10000
`define CP0_ERET_FULL            32'h42000018

// coprocessor 0 register address definitions
`define CP0_REG_BADVADDR         8'b01000000
`define CP0_REG_COUNT            8'b01001000
`define CP0_REG_COMPARE          8'b01011000
`define CP0_REG_STATUS           8'b01100000
`define CP0_REG_CAUSE            8'b01101000
`define CP0_REG_EPC              8'b01110000
`define CP0_REG_PRID             8'b01111000
`define CP0_REG_EBASE            8'b01111001
`define CP0_REG_CONFIG0          8'b10000000
`define CP0_REG_CONFIG1          8'b10000001

// ExcCode definitions
`define CP0_EXCCODE_INT          8'h00
`define CP0_EXCCODE_ADEL         8'h04
`define CP0_EXCCODE_ADES         8'h05
`define CP0_EXCCODE_SYS          8'h08
`define CP0_EXCCODE_BP           8'h09
`define CP0_EXCCODE_RI           8'h0a
`define CP0_EXCCODE_OV           8'h0c

// coprocessor 0 register value & write mask
`define CP0_REG_BADVADDR_VALUE   32'h00000000
`define CP0_REG_BADVADDR_MASK    32'h00000000
`define CP0_REG_STATUS_VALUE     32'h0040ff00
`define CP0_REG_STATUS_MASK      32'h0040ff03
`define CP0_REG_CAUSE_VALUE      32'h00000000
`define CP0_REG_CAUSE_MASK       32'h00000300
`define CP0_REG_EPC_VALUE        32'h00000000
`define CP0_REG_EPC_MASK         32'hffffffff

// coprocessor 0 segment definitions of STATUS & CAUSE
`define CP0_SEG_BEV              22      // STATUS 启动异常向量？
`define CP0_SEG_IM               15:8    // STATUS 8位中断屏蔽
`define CP0_SEG_EXL              1       // STATUS 异常级？
`define CP0_SEG_IE               0       // STATUS 中断使能
`define CP0_SEG_BD               31      // CAUSE 异常指令是否处于分支延迟槽
`define CP0_SEG_HWI              15:10   // CAUSE 硬件中断发生？
`define CP0_SEG_SWI              9:8     // CAUSE 软件中断发生？
`define CP0_SEG_INT              15:8    // CAUSE 软硬件中断发生？
`define CP0_SEG_EXCCODE          6:2     // CAUSE 异常类型
