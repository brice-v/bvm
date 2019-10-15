import ../as/assembler
import ../bvm
import unittest

suite "asm tests":
  setup:
    var cpu = newCPU()
  test "ld r1 1234":
    check(lex_input("ld r1 1234") == [Tok.LD, Tok.REG, Tok.IVAL])
  test "str [1234]":
    check(lex_input("str [1234]") == [Tok.STR, Tok.ADDR, Tok.NOP])