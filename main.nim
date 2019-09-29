## This is an attempt to make a cpu/iss simulator in nim

import unittest

const MEM_SIZE* = 1048
## MEM_SIZE is the total memory allocated for the ram of the cpu

const NUM_REG* = 32
## NUM_REG is the total number of general purpose registers for the cpu


type CPU* = object
  ## CPU - the central processing uint, 32 general purpose regs,
  ## indx register, program counter, zc
  reg: array[0..NUM_REG, uint32]
  ## 32 general purpose registers
  indx: uint32
  ## index register
  pc: uint32
  ## program counter
  mem: array[0..MEM_SIZE, uint32]
  ## memory
  ccr: uint32
  ## code conditon register

proc newCPU*(): CPU =
  ## newCPU returns a fully initalized (zero'd) cpu
  var x = CPU()

  # initializing to zero
  for i in 0..NUM_REG:
    x.reg[i] = 0
  for i in 0..MEM_SIZE:
    x.mem[i] = 0

  x.indx = 0
  x.pc = 0
  x.ccr = 0

  return x


proc add_reg*(cpu: var CPU, reg_src: uint32, reg_dest: uint32) =
  ## add_reg adds the register destination and source together and
  ## places the result in the register source
  cpu.reg[reg_src] += cpu.reg[reg_dest]

proc add_imm*(cpu: var CPU, reg_src: uint32, imm_val: uint32) =
  ## add_imm adds an immediate 32 bit value to the cpu register (reg_src)
  cpu.reg[reg_src] += imm_val

# var bvm = newCPU()
# echo bvm.mem



suite "vmtest":
  echo "Starting VM tests..."

  setup:
    var testvm = newCPU()

#   teardown:
#     testvm = newCPU()


  test "test reg is equal to zero":
    # print a nasty message and move on, skipping
    # the remainder of this block
    check(testvm.reg[0] != 1)
    check(testvm.reg[0] == 0)

  test "add_reg":
    testvm.reg[0] = 1
    testvm.reg[1] = 2
    testvm.add_reg(0, 1)
    check(testvm.reg[0] == 3)

  test "add_imm":
    testvm.reg[0] = 1
    testvm.add_imm(0, 1234)
    check(testvm.reg[0] == 1235)

  echo "Finished VM tests..."
