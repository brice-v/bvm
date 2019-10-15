import ../as/assembler
# import ../bvm
import unittest

suite "asm lex tests":
  # setup:
  #   var cpu = newCPU()
  test "ld r1 1234":
    check(lex_input("ld r1 1234") == [Tok.LD, Tok.REG, Tok.IVAL])
  test "ld r1 [1234]":
    check(lex_input("ld r1 [1234]") == [Tok.LD, Tok.REG, Tok.ADDR])
  test "str 1234 [1234]":
    check(lex_input("str 1234 [1234]") == [Tok.STR, Tok.IVAL, Tok.ADDR])
  test "str r0 [1234]":
    check(lex_input("str r0 [1234]") == [Tok.STR, Tok.REG, Tok.ADDR])
  test "and r0 r1":
    check(lex_input("and r0 r1") == [Tok.AND, Tok.REG, Tok.REG])
  test "and r0 1234":
    check(lex_input("and r0 1234") == [Tok.AND, Tok.REG, Tok.IVAL])
  test "or r0 r1":
    check(lex_input("or r0 r1") == [Tok.OR, Tok.REG, Tok.REG])
  test "or r0 1234":
    check(lex_input("or r0 1234") == [Tok.OR, Tok.REG, Tok.IVAL])
  test "xor r0 r1":
    check(lex_input("xor r0 r1") == [Tok.XOR, Tok.REG, Tok.REG])
  test "xor r0 1234":
    check(lex_input("xor r0 1234") == [Tok.XOR, Tok.REG, Tok.IVAL])
  test "sub r0 r1":
    check(lex_input("sub r0 r1") == [Tok.SUB, Tok.REG, Tok.REG])
  test "sub r0 1234":
    check(lex_input("sub r0 1234") == [Tok.SUB, Tok.REG, Tok.IVAL])
  test "test r0 r1":
    check(lex_input("test r0 r1") == [Tok.TEST, Tok.REG, Tok.REG])
  test "jmp r0":
    check(lex_input("jmp r0") == [Tok.JMP, Tok.REG, Tok.NOP])
  test "jmp 1234":
    check(lex_input("jmp 1234") == [Tok.JMP, Tok.IVAL, Tok.NOP])
  test "jeq r0":
    check(lex_input("jeq r0") == [Tok.JEQ, Tok.REG, Tok.NOP])
  test "jeq 1234":
    check(lex_input("jeq 1234") == [Tok.JEQ, Tok.IVAL, Tok.NOP])
  test "jne r0":
    check(lex_input("jne r0") == [Tok.JNE, Tok.REG, Tok.NOP])
  test "jne 1234":
    check(lex_input("jne 1234") == [Tok.JNE, Tok.IVAL, Tok.NOP])
  test "jlt r0":
    check(lex_input("jlt r0") == [Tok.JLT, Tok.REG, Tok.NOP])
  test "jlt 1234":
    check(lex_input("jlt 1234") == [Tok.JLT, Tok.IVAL, Tok.NOP])
  test "jgt r0":
    check(lex_input("jgt r0") == [Tok.JGT, Tok.REG, Tok.NOP])
  test "jgt 1234":
    check(lex_input("jgt 1234") == [Tok.JGT, Tok.IVAL, Tok.NOP])
  test "jlte r0":
    check(lex_input("jlte r0") == [Tok.JLTE, Tok.REG, Tok.NOP])
  test "jlte 1234":
    check(lex_input("jlte 1234") == [Tok.JLTE, Tok.IVAL, Tok.NOP])
  test "jgte r0":
    check(lex_input("jgte r0") == [Tok.JGTE, Tok.REG, Tok.NOP])
  test "jgte 1234":
    check(lex_input("jgte 1234") == [Tok.JGTE, Tok.IVAL, Tok.NOP])
