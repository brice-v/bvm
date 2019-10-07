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
  LDR_M

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

proc str_imm*(cpu: var CPU, mem_addr, imm_val: uint32) =
  ## `str_imm` takes the 32 bit immediate value and places it at the
  ## memory address
  cpu.mem[mem_addr] = imm_val

proc str_reg*(cpu: var CPU, mem_addr, reg_src: uint32) =
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
  ## `add_imm` adds an immediate 32 bit value to the cpu register (reg_src)
  cpu.reg[reg_src] += imm_val


proc sub_reg*(cpu: var CPU, reg_src, reg_dest: uint32) =
  ## `sub_reg` subtracts the register destination from the source
  ## and stores the result in the register source
  cpu.reg[reg_src] -= cpu.reg[reg_dest]

proc sub_imm*(cpu: var CPU, reg_src, imm_val: uint32) =
  ## `sub_imm` subtracts immediate value from the register source
  cpu.reg[reg_src] -= imm_val


proc inv_reg*(cpu: var CPU, reg_src: uint32) =
  ## `inv_reg` performs a bitwise NOT on the `reg_src`
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
  cpu.ccr.ltf = if cpu.reg[reg_src] > cpu.reg[reg_dest]: true else: false

  let tmp_result = cpu.reg[reg_src] - cpu.reg[reg_dest]
  let sign_bit = 2_147_483_642'u32 # this is just a 1 in the 32nd position
  cpu.ccr.nf = if tmp_result >= sign_bit: true else: false

  cpu.ccr.zf = if tmp_result == 0: true else: false


#[
  CONDITIONAL JUMPS
]#

proc jmp_reg*(cpu: var CPU, reg_src: uint32) =
  ## `jmp_reg` jumps to the 32 bit memory address in
  ## register source
  cpu.pc = cpu.reg[reg_src]

proc jmp_imm*(cpu: var CPU, imm_val: uint32) =
  ## `jmp_imm` jumps to the immediate 32 bit memory address
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
  ## `jlt_reg` jumps the 32 bit memory address in
  ## register source if the less than flag is set
  if cpu.ccr.ltf == true: cpu.pc = cpu.reg[reg_src]

proc jlt_imm*(cpu: var CPU, imm_val: uint32) =
  ## `jlt_imm` jumps to the immediate 32 bit memory address
  ## if the less than flag is set
  if cpu.ccr.ltf == true: cpu.pc = imm_val

proc jgt_reg*(cpu: var CPU, reg_src: uint32) =
  ## `jgt_reg` jumps the 32 bit memory address in
  ## register source if the less than flag is not set
  if cpu.ccr.ltf == false: cpu.pc = cpu.reg[reg_src]

proc jgt_imm*(cpu: var CPU, imm_val: uint32) =
  ## `jgt_imm` jumps  to the immediate 32 bit memory address
  ## if the less than flag is not set
  if cpu.ccr.ltf == false: cpu.pc = imm_val

proc jlte_reg*(cpu: var CPU, reg_src: uint32) =
  ## `jlte_reg` jumps the 32 bit memory address in
  ## register source if the less than flag is set
  ## or the zero flag is set
  if cpu.ccr.ltf == true or cpu.ccr.zf == true:
    cpu.pc = cpu.reg[reg_src]

proc jlte_imm*(cpu: var CPU, imm_val: uint32) =
  ## `jlte_imm` jumps to the immediate 32 bit memory address
  ## if the less than flag is set or the zero flag is set
  if cpu.ccr.ltf == true or cpu.ccr.zf == true:
    cpu.pc = imm_val

proc jgte_reg*(cpu: var CPU, reg_src: uint32) =
  ## `jgte_reg` jumps the 32 bit memory address in
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
