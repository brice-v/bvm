import ../bvm
import unittest

#[
  Just for Testing
  
  In here all the instructions should be tested.
  
  The VM related instructions and test should probably
  end up going in a file with them.
]#



# Testing
suite "vmtest":
  echo "Starting VM tests..."

  setup:
    var vm = newCPU()

  test "test reg is equal to zero":
    # print a nasty message and move on, skipping
    # the remainder of this block
    check(vm.reg[0] != 1)
    check(vm.reg[0] == 0)

  echo "[ Doing instructions 🤖...]"
  test "add_reg":
    vm.reg[0] = 1
    vm.reg[1] = 2
    vm.add_reg(0, 1)
    check(vm.reg[0] == 3)
  test "add_imm":
    vm.reg[0] = 1
    vm.add_imm(0, 1234)
    check(vm.reg[0] == 1235)
  test "sub_reg":
    vm.reg[0] = 3
    vm.reg[1] = 1
    vm.sub_reg(0, 1)
    check(vm.reg[0] == 2)
  test "sub_imm":
    vm.reg[0] = 3
    vm.sub_imm(0, 1)
    check(vm.reg[0] == 2)
  test "ldr_imm":
    vm.ldr_imm(0, 1234)
    check(vm.reg[0] == 1234)
  test "ldr_mem":
    vm.mem[1234] = 4321
    vm.ldr_mem(0, 1234)
    check(vm.reg[0] == 4321)
  test "str_imm":
    vm.str_imm(1234, 4321)
    check(vm.mem[1234] == 4321)
  test "str_reg":
    vm.reg[0] = 1234
    vm.str_reg(0, 4321)
    check(vm.mem[4321] == 1234)
  test "inv_reg":
    vm.reg[0] = 4294967295'u32
    vm.inv_reg(0)
    check(vm.reg[0] == 0x0000)
  test "and_reg":
    vm.reg[0] = 0xF0F0
    vm.reg[1] = 0x0F0F
    check(vm.reg[0] == 0xF0F0)
    check(vm.reg[1] == 0x0F0F)
    vm.and_reg(0, 1)
    check(vm.reg[0] == 0)
    check(vm.reg[1] == 0x0F0F)
  test "and_imm":
    vm.reg[0] = 0b01011
    vm.reg[1] = 0b01011
    vm.and_imm(0, 0b11111)
    vm.and_imm(1, 0b00000)
    check(vm.reg[0] == 0b01011)
    check(vm.reg[1] == 0b00000)
  test "or_reg":
    vm.reg[0] = 0b01011
    vm.reg[1] = 0b10100
    vm.or_reg(0, 1)
    check(vm.reg[0] == 0b11111)
  test "or_imm":
    vm.reg[0] = 0b1010
    vm.or_imm(0, 0b0101)
    check(vm.reg[0] == 0b1111)
  test "xor_reg":
    vm.reg[0] = 0b01011
    vm.reg[1] = 0b11110
    vm.xor_reg(0, 1)
    check(vm.reg[0] == 0b10101)
  test "xor_imm":
    vm.reg[0] = 0b01011
    vm.xor_imm(0, 0b11110)
    check(vm.reg[0] == 0b10101)
  test "jmp_reg":
    check(vm.pc == 0)
    vm.reg[0] = 0x1234
    vm.jmp_reg(0)
    check(vm.pc == 0x1234)
  test "jmp_imm":
    check(vm.pc == 0)
    vm.jmp_imm(0x1234)
    check(vm.pc == 0x1234)
  test "test_reg":
    vm.reg[0] = 100
    vm.reg[1] = 10
    vm.test_reg(0, 1)
    check(vm.reg[0] == 100)
    check(vm.ccr.ltf == false)
    check(vm.ccr.nf == false)
    check(vm.ccr.zf == false)
    vm.reg[2] = 100
    vm.reg[3] = 100
    vm.test_reg(2, 3)
    check(vm.ccr.zf == true)
    check(vm.ccr.ltf == false)
    check(vm.ccr.nf == false)
    vm.reg[4] = 10
    vm.reg[5] = 100
    vm.test_reg(4, 5)
    check(vm.ccr.zf == false)
    check(vm.ccr.ltf == true)
    check(vm.ccr.nf == true)
  test "jeq_reg":
    vm.reg[0] = 100
    vm.reg[1] = 100
    vm.reg[2] = 0x1234
    vm.test_reg(0, 1)
    vm.jeq_reg(2)
    check(vm.pc == 0x1234)
  test "jeq_imm":
    vm.reg[0] = 100
    vm.reg[1] = 100
    vm.test_reg(0, 1)
    vm.jeq_imm(0x1234)
    check(vm.pc == 0x1234)
  test "jne_reg":
    vm.reg[0] = 100
    vm.reg[1] = 101
    vm.reg[2] = 0x1234
    vm.test_reg(0, 1)
    vm.jne_reg(2)
    check(vm.pc == 0x1234)
  test "jne_imm":
    vm.reg[0] = 100
    vm.reg[1] = 101
    vm.test_reg(0, 1)
    vm.jne_imm(0x1234)
    check(vm.pc == 0x1234)
  test "jlt_reg":
    vm.reg[0] = 100
    vm.reg[1] = 101
    vm.reg[2] = 0x1234
    vm.test_reg(0, 1)
    vm.jlt_reg(2)
    check(vm.pc == 0x1234)
  test "jlt_imm":
    vm.reg[0] = 100
    vm.reg[1] = 101
    vm.test_reg(0, 1)
    vm.jlt_imm(0x1234)
    check(vm.pc == 0x1234)
  test "jgt_reg":
    vm.reg[0] = 101
    vm.reg[1] = 100
    vm.reg[2] = 0x1234
    vm.test_reg(0, 1)
    vm.jgt_reg(2)
    check(vm.pc == 0x1234)
  test "jgt_imm":
    vm.reg[0] = 101
    vm.reg[1] = 100
    vm.test_reg(0, 1)
    vm.jgt_imm(0x1234)
    check(vm.pc == 0x1234)
  test "jlte_reg":
    vm.reg[0] = 100
    vm.reg[1] = 101
    vm.reg[2] = 0x1234
    vm.test_reg(0, 1)
    vm.jlte_reg(2)
    check(vm.pc == 0x1234)
    vm.reg[3] = 100
    vm.reg[4] = 100
    vm.reg[5] = 0x4321
    vm.test_reg(3, 4)
    vm.jlte_reg(5)
    check(vm.pc == 0x4321)
  test "jlte_imm":
    vm.reg[0] = 100
    vm.reg[1] = 101
    vm.test_reg(0, 1)
    vm.jlte_imm(0x1234)
    check(vm.pc == 0x1234)
    vm.reg[3] = 100
    vm.reg[4] = 100
    vm.test_reg(3, 4)
    vm.jlte_imm(0x4321)
    check(vm.pc == 0x4321)
  test "jgte_reg":
    vm.reg[0] = 101
    vm.reg[1] = 100
    vm.reg[2] = 0x1234
    vm.test_reg(0, 1)
    vm.jgte_reg(2)
    check(vm.pc == 0x1234)
    vm.reg[3] = 100
    vm.reg[4] = 100
    vm.reg[5] = 0x4321
    vm.test_reg(3, 4)
    vm.jgte_reg(5)
    check(vm.pc == 0x4321)
  test "jgte_imm":
    vm.reg[0] = 101
    vm.reg[1] = 100
    vm.test_reg(0, 1)
    vm.jgte_imm(0x1234)
    check(vm.pc == 0x1234)
    vm.reg[3] = 100
    vm.reg[4] = 100
    vm.test_reg(3, 4)
    vm.jgte_imm(0x4321)
    check(vm.pc == 0x4321)

  echo "Finished VM tests..."


suite "Test running instructions":
  echo "Starting instruction tests..."
  setup:
    var cpu = newCPU()
  test "make sure program counter increments":
    cpu.exec_inx(NOP)
    check(cpu.pc == 1)
    cpu.exec_inx(NOP)
    cpu.exec_inx(NOP)
    cpu.exec_inx(NOP)
    cpu.exec_inx(ADD_I, 0, 0, 1)
    check(cpu.pc == 5)

  test "NOP":
    cpu.exec_inx(NOP)
    check(cpu.pc == 1)
  test "ADD_R":
    cpu.reg[0] = 1
    cpu.reg[1] = 2
    cpu.exec_inx(ADD_R, rs = 0, rd = 1)
    check(cpu.reg[0] == 3)
  test "ADD_I":
    cpu.reg[0] = 1
    cpu.exec_inx(ADD_I, imm_val = 1)
    check(cpu.reg[0] == 2)
  test "SUB_R":
    cpu.reg[0] = 3
    cpu.reg[1] = 2
    cpu.exec_inx(SUB_R, rs = 0, rd = 1)
    check(cpu.reg[0] == 1)
  test "SUB_I":
    cpu.reg[0] = 1
    cpu.exec_inx(SUB_I, imm_val = 1)
    check(cpu.reg[0] == 0)
  test "LDR_I":
    cpu.exec_inx(LDR_I, imm_val = 1234, rs = 0)
    check(cpu.reg[0] == 1234)
  test "LDR_M":
    cpu.mem[1234] = 19
    cpu.exec_inx(LDR_M, imm_val = 1234, rs = 0)
    check(cpu.reg[0] == 19)
  test "STR_I":
    # imm_val is mem_addr, rs is the imm_val
    cpu.exec_inx(STR_I, rs = 4321, imm_val = 1234)
    check(cpu.mem[4321] == 1234)
  test "STR_R":
    cpu.reg[0] = 1234
    cpu.exec_inx(STR_R, rs = 0, imm_val = 4321) # imm_val is mem_addr
    check(cpu.mem[4321] == 1234)
  test "INV_R":
    cpu.reg[0] = 0
    cpu.exec_inx(INV_R, rs = 0)
    check(cpu.reg[0] == 0xFFFF_FFFF'u32)
  test "AND_R":
    cpu.reg[0] = 0xF0F0
    cpu.reg[1] = 0x0F0F
    cpu.exec_inx(AND_R, rs = 0, rd = 1)
    check(cpu.reg[0] == 0)
  test "AND_I":
    cpu.reg[0] = 0xF0F0
    cpu.exec_inx(AND_I, rs = 0, imm_val = 0x0F0F)
    check(cpu.reg[0] == 0)
  test "OR_R":
    cpu.reg[0] = 0xF0F0
    cpu.reg[1] = 0x0F0F
    cpu.exec_inx(OR_R, rs = 0, rd = 1)
    check(cpu.reg[0] == 0xFFFF)
  test "OR_I":
    cpu.reg[0] = 0xF0F0
    cpu.exec_inx(OR_I, rs = 0, imm_val = 0x0F0F)
    check(cpu.reg[0] == 0xFFFF)
  test "XOR_R":
    cpu.reg[0] = 0b1010_1111
    cpu.reg[1] = 0b1111_1010
    cpu.exec_inx(XOR_R, rs = 0, rd = 1)
    check(cpu.reg[0] == 0b0101_0101)
  test "XOR_I":
    cpu.reg[0] = 0b1010_1111
    cpu.reg[1] = 0b1111_1010
    cpu.exec_inx(XOR_I, rs = 0, imm_val = 0b1111_1010)
    check(cpu.reg[0] == 0b0101_0101)
  test "TEST_R":
    cpu.reg[0] = 100
    cpu.reg[1] = 10
    cpu.exec_inx(TEST_R, rs = 0, rd = 1)
    check(cpu.ccr.ltf == false)
    check(cpu.ccr.nf == false)
    check(cpu.ccr.zf == false)
    cpu.reg[0] = 100
    cpu.reg[1] = 101
    cpu.exec_inx(TEST_R, rs = 0, rd = 1)
    check(cpu.ccr.ltf == true)
    check(cpu.ccr.nf == true)
    check(cpu.ccr.zf == false)
    cpu.reg[0] = 100
    cpu.reg[1] = 100
    cpu.exec_inx(TEST_R, rs = 0, rd = 1)
    check(cpu.ccr.ltf == false)
    check(cpu.ccr.nf == false)
    check(cpu.ccr.zf == true)
  test "JMP_R":
    cpu.reg[0] = 1234
    cpu.exec_inx(JMP_R, rs = 0)
    check(cpu.pc == 1234)
  test "JMP_I":
    cpu.exec_inx(JMP_I, imm_val = 1234)
    check(cpu.pc == 1234)
  test "JEQ_R":
    cpu.reg[0] = 100
    cpu.reg[1] = 100
    cpu.reg[2] = 1234
    cpu.exec_inx(TEST_R, rs = 0, rd = 1)
    cpu.exec_inx(JEQ_R, rs = 2)
    check(cpu.pc == 1234)
  test "JEQ_I":
    cpu.reg[0] = 100
    cpu.reg[1] = 100
    cpu.exec_inx(TEST_R, rs = 0, rd = 1)
    check(cpu.ccr.zf == true)
    cpu.exec_inx(JEQ_I, imm_val = 1234)
    check(cpu.pc == 1234)
  test "JNE_R":
    cpu.reg[0] = 100
    cpu.reg[1] = 101
    cpu.reg[2] = 1234
    cpu.exec_inx(TEST_R, rs = 0, rd = 1)
    cpu.exec_inx(JNE_R, rs = 2)
    check(cpu.pc == 1234)
  test "JNE_I":
    cpu.reg[0] = 100
    cpu.reg[1] = 101
    cpu.exec_inx(TEST_R, rs = 0, rd = 1)
    check(cpu.ccr.zf == false)
    cpu.exec_inx(JNE_I, imm_val = 1234)
    check(cpu.pc == 1234)
  test "JLT_R":
    cpu.reg[0] = 100
    cpu.reg[1] = 101
    cpu.reg[2] = 1234
    cpu.exec_inx(TEST_R, rs = 0, rd = 1)
    cpu.exec_inx(JLT_R, rs = 2)
    check(cpu.pc == 1234)
  test "JLT_I":
    cpu.reg[0] = 100
    cpu.reg[1] = 101
    cpu.exec_inx(TEST_R, rs = 0, rd = 1)
    cpu.exec_inx(JLT_I, imm_val = 1234)
    check(cpu.pc == 1234)
  test "JGT_R":
    cpu.reg[0] = 101
    cpu.reg[1] = 100
    cpu.reg[2] = 1234
    cpu.exec_inx(TEST_R, rs = 0, rd = 1)
    cpu.exec_inx(JGT_R, rs = 2)
  test "JGT_I":
    cpu.reg[0] = 101
    cpu.reg[1] = 100
    cpu.exec_inx(TEST_R, rs = 0, rd = 1)
    cpu.exec_inx(JGT_I, imm_val = 1234)
    check(cpu.pc == 1234)
  test "JLTE_R":
    cpu.reg[0] = 100
    cpu.reg[1] = 101
    cpu.reg[2] = 1234
    cpu.exec_inx(TEST_R, rs = 0, rd = 1)
    cpu.exec_inx(JLTE_R, rs = 2)
    check(cpu.pc == 1234)
    cpu.reg[0] = 100
    cpu.reg[1] = 100
    cpu.reg[2] = 4321
    cpu.exec_inx(TEST_R, rs = 0, rd = 1)
    cpu.exec_inx(JLTE_R, rs = 2)
    check(cpu.pc == 4321)
  test "JLTE_I":
    cpu.reg[0] = 100
    cpu.reg[1] = 101
    cpu.exec_inx(TEST_R, rs = 0, rd = 1)
    cpu.exec_inx(JLTE_I, imm_val = 1234)
    check(cpu.pc == 1234)
    cpu.reg[0] = 100
    cpu.reg[1] = 100
    cpu.exec_inx(TEST_R, rs = 0, rd = 1)
    cpu.exec_inx(JLTE_I, imm_val = 4321)
    check(cpu.pc == 4321)
  test "JGTE_R":
    cpu.reg[0] = 101
    cpu.reg[1] = 100
    cpu.reg[2] = 1234
    cpu.exec_inx(TEST_R, rs = 0, rd = 1)
    cpu.exec_inx(JGTE_R, rs = 2)
    check(cpu.pc == 1234)
    cpu.reg[0] = 100
    cpu.reg[1] = 100
    cpu.reg[2] = 4321
    cpu.exec_inx(TEST_R, rs = 0, rd = 1)
    cpu.exec_inx(JGTE_R, rs = 2)
    check(cpu.pc == 4321)
  test "JGTE_I":
    cpu.reg[0] = 101
    cpu.reg[1] = 100
    cpu.exec_inx(TEST_R, rs = 0, rd = 1)
    cpu.exec_inx(JGTE_I, imm_val = 1234)
    check(cpu.pc == 1234)
    cpu.reg[0] = 100
    cpu.reg[1] = 100
    cpu.exec_inx(TEST_R, rs = 0, rd = 1)
    cpu.exec_inx(JGTE_I, imm_val = 4321)
    check(cpu.pc == 4321)
