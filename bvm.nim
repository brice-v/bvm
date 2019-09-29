## This is an attempt to make a cpu/iss simulator in nim

import unittest
import strformat

const MEM_SIZE* = 1048 * 16
## MEM_SIZE is the total memory allocated for the ram of the cpu

const NUM_REG* = 32
## NUM_REG is the total number of general purpose registers for the cpu

type INX* = enum
  ## INX is the instruction opcode
  ## for now this opcode will be decided by an enum
  NOP,
  ADD_R,
  ADD_I,
  SUB_R,
  SUB_I,
  LDR_I,
  LDR_M



# CPU object and newCPU function
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


# Instructions

proc nop*(cpu: var CPU) =
  ## nop is a `no operation`
  # just for some deubgging
  # when isMainModule:
  #   echo "NOP"
  return


proc ldr_imm*(cpu: var CPU, reg_src, imm_val: uint32) =
  ## ldr_imm loads the register source with the 32 bit immediate value
  cpu.reg[reg_src] = imm_val

proc ldr_mem*(cpu: var CPU, reg_src, mem_addr: uint32) =
  ## ldr_mem loads the register source with a 32 bit value from memory
  cpu.reg[reg_src] = cpu.mem[mem_addr]
  # TODO could do a check before this to make sure mem_addr can work
  # for now we will assume its always correct


proc add_reg*(cpu: var CPU, reg_src, reg_dest: uint32) =
  ## add_reg adds the register destination and source together and
  ## places the result in the register source
  cpu.reg[reg_src] += cpu.reg[reg_dest]

proc add_imm*(cpu: var CPU, reg_src, imm_val: uint32) =
  ## add_imm adds an immediate 32 bit value to the cpu register (reg_src)
  cpu.reg[reg_src] += imm_val


proc sub_reg*(cpu: var CPU, reg_src, reg_dest: uint32) =
  ## sub_reg subtracts the register destination from the source
  ## and stores the result in the register source
  cpu.reg[reg_src] -= cpu.reg[reg_dest]

proc sub_imm*(cpu: var CPU, reg_src, imm_val: uint32) =
  ## sub_imm subtracts immediate value from the register source
  cpu.reg[reg_src] -= imm_val


# Stuff related to running a program

proc exec_inx(cpu: var CPU, inx: INX, rs, rd, imm_val: uint32 = 0) =
  ## TODO docs
  case inx
  of NOP:
    cpu.nop()
  of ADD_I:
    cpu.add_imm(rs, imm_val)
  of ADD_R:
    cpu.add_reg(rs, rd)
  else:
    echo "Case not handled. inx: ", inx

  # always increment the program counter
  # eventually maybe we will simulate different
  # instructions have different number of cycles
  cpu.pc += 1



# main to run anything else
proc main() =
  echo "[bvm] - IN MAIN"
  var bvm = newCPU()
  echo "[bvm] Iniatialized new CPU..."
  echo "[bvm] mem: ", fmt"[{MEM_SIZE}: uint32]"
  bvm.exec_inx(NOP)



## Just for running this file/main
when isMainModule:
  main()



## Testing
suite "vmtest":
  echo "Starting VM tests..."

  setup:
    var vm = newCPU()

  test "test reg is equal to zero":
    # print a nasty message and move on, skipping
    # the remainder of this block
    check(vm.reg[0] != 1)
    check(vm.reg[0] == 0)

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

  test "make sure program counter increments":
    vm.exec_inx(NOP)
    check(vm.pc == 1)
    vm.exec_inx(NOP)
    vm.exec_inx(NOP)
    vm.exec_inx(NOP)
    vm.exec_inx(ADD_I, 0, 0, 1)
    check(vm.pc == 5)

  echo "Finished VM tests..."
