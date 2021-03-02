# MIPS-CPU

Extension version of TinyMIPS processor, which is an implementation of  for USTB computer composition principle course design.

## MIPS-CPU's ISA

1. 算术运算指令

 - [x] ADD    2021-2-21    1
 - [x] ADDI    2021-2-21    2
 - [x] ADDU
 - [x] ADDIU
 - [x] SUB     2021-2-21    3
 - [x] SUBU
 - [x] SLT
 - [x] SLTI     2021-2-21    4
 - [x] SLTU
 - [x] SLTIU     2021-2-21    5
 - [x] DIV     2021-2-24    5
 - [x] DIVU     2021-2-24    6
 - [x] MULT     2021-2-24    7
 - [x] MULTU     2021-2-24    8

2. 逻辑运算指令

 - [x] AND
 - [x] ANDI    2021-2-21    6
 - [x] LUI
 - [x] NOR    2021-2-21    7
 - [x] OR
 - [x] ORI    2021-2-21    8
 - [x] XOR
 - [x] XORI    2021-2-21    9

3. 移位指令

 - [x] SLL
 - [x] SLLV
 - [x] SRA    2021-2-21    10
 - [x] SRAV
 - [x] SRL    2021-2-21    11
 - [x] SRLV

4. 分支跳转指令

 - [x] BEQ
 - [x] BNE
 - [x] BGEZ    2021-2-22    3
 - [x] BLTZ    2021-2-22    4
 - [x] BLTZAL    2021-2-22    5
 - [x] BGEZAL    2021-2-22    6
 - [x] BGTZ    2021-2-22    1
 - [x] BLEZ    2021-2-22    2
 - [x] J    2021-2-22    7
 - [x] JAL
 - [x] JR    2021-2-22    8
 - [x] JALR

5. 访存指令

 - [x] LB
 - [x] LBU
 - [x] LH    2021-2-22    9
 - [x] LHU    2021-2-22    10
 - [x] LW
 - [x] LWL    2021-2-23    1
 - [x] LWR    2021-2-23    2
 - [x] SB
 - [x] SH    2021-2-22    11
 - [x] SW
 - [x] SWL    2021-2-23    3
 - [x] SWR    2021-2-23    4

6. 数据移动指令

 - [x] MFHI    2021-2-24    1
 - [x] MFLO     2021-2-24    2
 - [x] MTHI     2021-2-24    3
 - [x] MTLO     2021-2-24    4

7. 自陷指令

 - [x] BREAK     2021-2-24    9
 - [x] SYSCALL     2021-2-24    10

8. 特权指令

 - [x] ERET     2021-2-24    11
 - [x] MFC0     2021-2-24    12
 - [x] MTC0     2021-2-24    13