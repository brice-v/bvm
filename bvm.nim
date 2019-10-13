## This is an attempt to make a cpu/iss simulator in nim

import unittest
import strformat


const MEM_SIZE* = 1024 * 16 ## MEM_SIZE is the total memory
                            ## allocated for the ram of the cpu (16k currently)


const NUM_REG* = 32 ## NUM_REG is the total number of general
                    ## purpose registers for the cpu


type INX* = enum
  ## INX is the instruction opcode
  ## for now this opcode will be decided by an enum
  NOP,
  ADD_R,
  ADD_I,
  SUB_R,
  SUB_I,
  LDR_I,
  LDR_M,
  STR_I,
  STR_R,
  INV_R,
  AND_R,
  AND_I,
  OR_R,
  OR_I,
  XOR_R,
  XOR_I,
  TEST_R,
  JMP_R,
  JMP_I,
  JEQ_R,
  JEQ_I,
  JNE_R,
  JNE_I,
  JLT_R,
  JLT_I,
  JGT_R,
  JGT_I,
  JLTE_R,
  JLTE_I,
  JGTE_R,
  JGTE_I


type CCR* = object
  ## CCR - the code condition register, made up of flags
  zf: bool  ## zero flag
  ltf: bool ## less than flag
  nf: bool  ## negative flag

# CPU object and newCPU function
type CPU* = object
  ## CPU - the central processing uint, 32 general purpose regs,
  ## indx register, program counter, zc
  reg: array[0..NUM_REG, uint32] ## 32 general purpose registers
  pc: uint32 ## program counter
  mem: array[0..MEM_SIZE, uint32] ## memory
  ccr: CCR

proc newCPU*(): CPU =
  ## newCPU returns a fully initalized (zero'd) cpu
  var x = CPU()

  # initializing to zero
  for i in 0..NUM_REG:
    x.reg[i] = 0
  for i in 0..MEM_SIZE:
    x.mem[i] = 0

  x.pc = 0
  x.ccr.zf = false # flags would normally be satisfied by a 1 bit value
  x.ccr.ltf = false # when theyre all together it would be like 1 32 bit reg
  x.ccr.nf = false

  return x


# Instructions

proc nop*(cpu: var CPU) =
  ## `nop` is a `no operation`
  # just for some deubgging
  # when isMainModule:
  #   echo "NOP"
  return

#[
  Getting data into the registers/memory
]#

proc ldr_imm*(cpu: var CPU, reg_src, imm_val: uint32) =
  ## `ldr_imm` loads the register source with the 32 bit immediate value
  cpu.reg[reg_src] = imm_val

proc ldr_mem*(cpu: var CPU, reg_src, mem_addr: uint32) =
  ## `ldr_mem` loads the register source with a 32 bit value from memory
  cpu.reg[reg_src] = cpu.mem[mem_addr]
  # TODO could do a check before this to make sure mem_addr can work
  # for now we will assume its always correct

proc str_imm*(cpu: var CPU, imm_val, mem_addr: uint32) =
  ## `str_imm` takes the 32 bit immediate value and places it at the
  ## memory address
  cpu.mem[mem_addr] = imm_val

proc str_reg*(cpu: var CPU, reg_src, mem_addr: uint32) =
  ## `str_reg` takes the 32 bit value located at reg_src and places
  ## it at the memory address location
  cpu.mem[mem_addr] = cpu.reg[reg_src]


#[
  Basic instructions between registers and immediate values
]#

proc add_reg*(cpu: var CPU, reg_src, reg_dest: uint32) =
  ## `add_reg` adds the register destination and source together and
  ## places the result in the register source
  cpu.reg[reg_src] += cpu.reg[reg_dest]

proc add_imm*(cpu: var CPU, reg_src, imm_val: uint32) =
  ## `add_imm` adds an immediate 32 bit value to the register source
  cpu.reg[reg_src] += imm_val


proc sub_reg*(cpu: var CPU, reg_src, reg_dest: uint32) =
  ## `sub_reg` subtracts the register destination from the source
  ## and stores the result in the register source
  cpu.reg[reg_src] -= cpu.reg[reg_dest]

proc sub_imm*(cpu: var CPU, reg_src, imm_val: uint32) =
  ## `sub_imm` subtracts immediate value from the register source
  cpu.reg[reg_src] -= imm_val


proc inv_reg*(cpu: var CPU, reg_src: uint32) =
  ## `inv_reg` performs a bitwise NOT on the register source
  cpu.reg[reg_src] = not cpu.reg[reg_src]

proc and_reg*(cpu: var CPU, reg_src, reg_dest: uint32) =
  ## `and_reg` performs a bitwise AND between the register source
  ## and the register destination.  the result is stored in the
  ## register source
  cpu.reg[reg_src] = cpu.reg[reg_src] and cpu.reg[reg_dest]

proc and_imm*(cpu: var CPU, reg_src, imm_val: uint32) =
  ## `and_imm` performs a bitwise AND between the register source
  ## and the 32 bit immediate value.  the result is stored in the
  ## register source
  cpu.reg[reg_src] = cpu.reg[reg_src] and imm_val

proc or_reg*(cpu: var CPU, reg_src, reg_dest: uint32) =
  ## `or_reg` performs a bitwise OR between the register source
  ## and the register destination.  the result is stored in the
  ## register source
  cpu.reg[reg_src] = cpu.reg[reg_src] or cpu.reg[reg_dest]

proc or_imm*(cpu: var CPU, reg_src, imm_val: uint32) =
  ## `or_imm` performs a bitwise OR between the register source
  ## and the register destination.  the result is stored in the
  ## register source
  cpu.reg[reg_src] = cpu.reg[reg_src] or imm_val


proc xor_reg*(cpu: var CPU, reg_src, reg_dest: uint32) =
  ## `xor_reg` performs a bitwise XOR between the register source
  ## and the register destination.  the result is stored in the
  ## register source
  cpu.reg[reg_src] = cpu.reg[reg_src] xor cpu.reg[reg_dest]

proc xor_imm*(cpu: var CPU, reg_src, imm_val: uint32) =
  ## `xor_imm` performs a bitwise XOR between the register source
  ## and the register destination.  the result is stored in the
  ## register source
  cpu.reg[reg_src] = cpu.reg[reg_src] xor imm_val


# TODO Rename all of reg_src and reg_dest to r1, r2 or something
# like that
# TODO Determine if we need some sort of direct memory addressing
# mode - currently just can load and store

proc test_reg*(cpu: var CPU, reg_src, reg_dest: uint32) =
  ## `test_reg` will set the flags in the code condition register
  ## according to the result of a subtraction between the destination
  ## register and the source register (rs - rd)
  ##
  ## zero flag is set when they are equal
  ##
  ## less than flag is set when the destination register is less
  ## than the source register
  ##
  ## negative flag is set when there is a bit in the sign field as
  ## the result of source register - destination register
  ## (use a reg with zero as the dest to just check 1 register)
  cpu.ccr.ltf = if cpu.reg[reg_src] < cpu.reg[reg_dest]: true else: false

  let tmp_result = cpu.reg[reg_src] - cpu.reg[reg_dest]
  let sign_bit = 2_147_483_642'u32 # this is just a 1 in the 32nd position
  cpu.ccr.nf = if tmp_result >= sign_bit: true else: false

  cpu.ccr.zf = if tmp_result == 0: true else: false


#[
  CONDITIONAL JUMPS
]#

proc jmp_reg*(cpu: var CPU, reg_src: uint32) =
  ## `jmp_reg` jumps unconditionally to the 32 bit memory address in
  ## register source
  cpu.pc = cpu.reg[reg_src]

proc jmp_imm*(cpu: var CPU, imm_val: uint32) =
  ## `jmp_imm` jumps unconditionally to the immediate 32 bit memory address
  cpu.pc = imm_val

proc jeq_reg*(cpu: var CPU, reg_src: uint32) =
  ## `jeq_reg` jumps to the 32 bit memory address in
  ## register source if the zero flag is set
  if cpu.ccr.zf == true: cpu.pc = cpu.reg[reg_src]

proc jeq_imm*(cpu: var CPU, imm_val: uint32) =
  ## `jeq_imm` jumps to the immediate 32 bit memory address
  ## if the zero flag is set
  if cpu.ccr.zf == true: cpu.pc = imm_val

proc jne_reg*(cpu: var CPU, reg_src: uint32) =
  ## `jne_reg` jumps the 32 bit memory address in
  ## register source if the zero flag is not set
  if cpu.ccr.zf == false: cpu.pc = cpu.reg[reg_src]

proc jne_imm*(cpu: var CPU, imm_val: uint32) =
  ## `jne_imm` jumps to the immediate 32 bit memory address
  ## if the zero flag is not set
  if cpu.ccr.zf == false: cpu.pc = imm_val

proc jlt_reg*(cpu: var CPU, reg_src: uint32) =
  ## `jlt_reg` jumps to the 32 bit memory address in
  ## register source if the less than flag is set
  if cpu.ccr.ltf == true: cpu.pc = cpu.reg[reg_src]

proc jlt_imm*(cpu: var CPU, imm_val: uint32) =
  ## `jlt_imm` jumps to the immediate 32 bit memory address
  ## if the less than flag is set
  if cpu.ccr.ltf == true: cpu.pc = imm_val

proc jgt_reg*(cpu: var CPU, reg_src: uint32) =
  ## `jgt_reg` jumps to the 32 bit memory address in
  ## register source if the less than flag is not set
  if cpu.ccr.ltf == false: cpu.pc = cpu.reg[reg_src]

proc jgt_imm*(cpu: var CPU, imm_val: uint32) =
  ## `jgt_imm` jumps to the immediate 32 bit memory address
  ## if the less than flag is not set
  if cpu.ccr.ltf == false: cpu.pc = imm_val

proc jlte_reg*(cpu: var CPU, reg_src: uint32) =
  ## `jlte_reg` jumps to the 32 bit memory address in
  ## register source if the less than flag is set or
  ## the zero flag is set
  if cpu.ccr.ltf == true or cpu.ccr.zf == true:
    cpu.pc = cpu.reg[reg_src]

proc jlte_imm*(cpu: var CPU, imm_val: uint32) =
  ## `jlte_imm` jumps to the immediate 32 bit memory address
  ## if the less than flag is set or the zero flag is set
  if cpu.ccr.ltf == true or cpu.ccr.zf == true:
    cpu.pc = imm_val

proc jgte_reg*(cpu: var CPU, reg_src: uint32) =
  ## `jgte_reg` jumps to the 32 bit memory address in
  ## register source if the less than flag is not set
  ## or the zero flag is set
  if cpu.ccr.ltf == false or cpu.ccr.zf == true:
    cpu.pc = cpu.reg[reg_src]

proc jgte_imm*(cpu: var CPU, imm_val: uint32) =
  ## `jgte_imm` jumps to the immediate 32 bit memory address
  ## if the less than flag is not set or the zero flag is set
  if cpu.ccr.ltf == false or cpu.ccr.zf == true:
    cpu.pc = imm_val

# Stuff related to running a program

#[
  VM related code, will still need an assembler to work
  well with this
]#

proc exec_inx(cpu: var CPU, inx: INX, rs, rd, imm_val: uint32 = 0) =
  ## `exec_inx` executes an instruction on the vm
  case inx
  of NOP:
    cpu.nop()
    cpu.pc += 1
  of ADD_I:
    cpu.add_imm(rs, imm_val)
    cpu.pc += 1
  of ADD_R:
    cpu.add_reg(rs, rd)
    cpu.pc += 1
  of SUB_I:
    cpu.sub_imm(rs, imm_val)
    cpu.pc += 1
  of SUB_R:
    cpu.sub_reg(rs, rd)
    cpu.pc += 1
  of LDR_I:
    cpu.ldr_imm(rs, imm_val)
    cpu.pc += 1
  of LDR_M:
    cpu.ldr_mem(rs, imm_val)
    cpu.pc += 1
  of STR_I:
    cpu.str_imm(rs, imm_val)
    cpu.pc += 1
  of STR_R:
    cpu.str_reg(rs, imm_val)
    cpu.pc += 1
  of INV_R:
    cpu.inv_reg(rs)
    cpu.pc += 1
  of AND_R:
    cpu.and_reg(rs, rd)
    cpu.pc += 1
  of AND_I:
    cpu.and_imm(rs, imm_val)
    cpu.pc += 1
  of OR_R:
    cpu.or_reg(rs, rd)
    cpu.pc += 1
  of OR_I:
    cpu.or_imm(rs, imm_val)
    cpu.pc += 1
  of XOR_R:
    cpu.xor_reg(rs, rd)
    cpu.pc += 1
  of XOR_I:
    cpu.xor_imm(rs, imm_val)
    cpu.pc += 1
  of TEST_R:
    cpu.test_reg(rs, rd)
    cpu.pc += 1
  of JMP_R:
    cpu.jmp_reg(rs)
  of JMP_I:
    cpu.jmp_imm(imm_val)
  of JEQ_R:
    cpu.jeq_reg(rs)
  of JEQ_I:
    cpu.jeq_imm(imm_val)
  of JNE_R:
    cpu.jne_reg(rs)
  of JNE_I:
    cpu.jne_imm(imm_val)
  of JLT_R:
    cpu.jlt_reg(rs)
  of JLT_I:
    cpu.jlt_imm(imm_val)
  of JGT_R:
    cpu.jgt_reg(rs)
  of JGT_I:
    cpu.jgt_imm(imm_val)
  of JLTE_R:
    cpu.jlte_reg(rs)
  of JLTE_I:
    cpu.jlte_imm(imm_val)
  of JGTE_R:
    cpu.jgte_reg(rs)
  of JGTE_I:
    cpu.jgte_imm(imm_val)

#[
  Main program mostly for debugging, could turn this
  into a more fun program, maybe a repl
]#

# main to run anything else
proc main() =
  echo "[bvm] - IN MAIN"
  var bvm = newCPU()
  echo "[bvm] Iniatialized new CPU..."
  echo "[bvm] mem: ", fmt"[{MEM_SIZE}: uint32] | {int((MEM_SIZE * 32)/1024)}K bytes"
  bvm.exec_inx(NOP)

# Just for running this file/main
when isMainModule:
  main()


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
    vm.str_imm(4321, 1234)
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
    cpu.exec_inx(STR_I, rs = 4321, imm_val = 1234) # imm_val is mem_addr
    check(cpu.mem[1234] == 4321)
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

