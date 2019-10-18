# from ../bvm import INX

# type assembler = object
#   input: seq[string]
#   output: seq[INX]


# proc new_as(): assembler =
#   result = assembler(input: @["ld r1 1234"], output: @[NOP])

# when isMainModule:
#   echo new_as()
import strutils

type Tok* = enum ## Token enumerator of possible lex states
  NOP,           ## NOP Instruction
  LD,            ## Load Instruction
  REG,           ## General Purpose Register
  IVAL,          ## Immediate Value
  STR,           ## Store instruction
  ADDR,          ## Address Value
  AND,           ## And Instruction
  OR,            ## Or Instruction
  XOR,           ## Xor Instruction
  SUB,           ## Subtraction Instruction
  INV,           ## Invert Instruction
  TEST,          ## Test Instruction
  JMP,           ## Jump Always Instruction
  JEQ,           ## Jump Equal Instruction
  JNE,           ## Jump Not Equal Instruction
  JLT,           ## Jump Less Than Instruction
  JGT,           ## Jump Greater Than Instruction
  JLTE,          ## Jump Less Than or Equal Instruction
  JGTE,          ## Jump Greater Than or Equal Instruction


proc lex_num(w: string): bool =
  try:
    discard w.parseUInt
    return true
  except ValueError:
    return false

proc lex_inner_num(w: string): bool =
  var inner_string = ""
  for i in 1 ..< w.high:
    inner_string.add(w[i])

  try:
    discard inner_string.parseUInt
    return true
  except ValueError:
    return false

proc lex_reg(w: string): bool =
  var tmp = ""
  for c in w[1] .. w[w.high]:
    tmp.add(c)
  try:
    let regnum = tmp.parseInt
    if regnum < 32:
      return true
  except ValueError:
    return false

proc lex_word(w: string): Tok =
  if w[0] == '[' and w[w.high] == ']':
    if lex_inner_num(w):
      return ADDR
    else:
      echo "Failed to lex inner number for word that looks like addr: ", w
  elif lex_num(w):
    return IVAL
  elif w[0] == 'r':
    if lex_reg(w):
      return REG


proc lex_input*(input: string): array[3, Tok] =
  ## `lex_input` takes a string and converts it to tokens to be parsed
  ## an array of 3 Tokens is used as the return becuase it can
  ## cover the possible cases

  var indx = 0
  for word in input.toLower().split():
    case word:
    of "ld":
      result[indx] = LD
    of "str":
      result[indx] = STR
    of "and":
      result[indx] = AND
    of "or":
      result[indx] = OR
    of "xor":
      result[indx] = XOR
    of "sub":
      result[indx] = SUB
    of "inv":
      result[indx] = INV
    of "test":
      result[indx] = TEST
    of "jmp":
      result[indx] = JMP
    of "jeq":
      result[indx] = JEQ
    of "jne":
      result[indx] = JNE
    of "jlt":
      result[indx] = JLT
    of "jgt":
      result[indx] = JGT
    of "jlte":
      result[indx] = JLTE
    of "jgte":
      result[indx] = JGTE
    else:
      result[indx] = lex_word(word)
      # echo "Unexpected word: ", word
    indx += 1
    # echo "Indx: ", indx, ", Word: ", word
  return result


proc parse_lexed_input*(input: array[3, Tok]) =
  ## `parse_lexed_input` takes the 3 ops returned from the
  ## lexer and turns it into the applicable bytecode for
  ## the vm to run.
  ##
  ## The common cases of the last 2 operands seem to be
  ## Notes: IVAL is 32 bits (this may be lowered to fit
  ##        the instruction into a single 32 bit value)
  ##        ADDR is 32 bits (same note as above)
  ##        REG takes up 5 bits (32 gp registers)
  ##        INX has 15 instructions to handle plus 3? bits
  ##        to cover the cases below
  ## INX - REG IVAL
  ## INX - REG ADDR
  ## INX - REG REG
  ## INX - REG NOP -> this just means that we dont care
  ##                  about the last operand
  ## INX - IVAL NOP
  let inx = input[0]
  echo inx


#[
  ASM


  ld r0 1234 # Register+Immediate addressing?
  ld 1234 # Immediate addressing?
  ld [1234] # Direct (but only for load) addressing
  str r0
  and r0 r1 # Register addressing? (inx that look like `_R` )
  and r0 1234
]#


when isMainModule:
  let
    input = "ld r1 1234"
    oinput = "str [1234]"
    linput = lex_input(input)
    loinput = lex_input(oinput)
  echo "Lexed Input: ", linput
  echo "Lexed OInput: ", loinput
  parse_lexed_input(linput)

