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
  NOP,            ## NOP Instruction
  LD,             ## Load Instruction
  REG,            ## General Purpose Register
  IVAL,           ## Immediate Value
  STR,            ## Store instruction
  ADDR,           ## Address Value


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
  for word in input.split():
    case word:
    of "ld":
      result[indx] = LD
    of "str":
      result[indx] = STR
    else:
      result[indx] = lex_word(word)
      # echo "Unexpected word: ", word
    indx += 1
    # echo "Indx: ", indx, ", Word: ", word
  return result




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
  let input = "ld r1 1234"
  let oinput = "str [1234]"
  echo "Lexed Input: ", lex_input(input)
  echo "Lexed OInput: ", lex_input(oinput)
