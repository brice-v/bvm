# from ../bvm import INX

# type assembler = object
#   input: seq[string]
#   output: seq[INX]


# proc new_as(): assembler =
#   result = assembler(input: @["ld r1 1234"], output: @[NOP])

# when isMainModule:
#   echo new_as()
import strutils

type Token = enum ## Token enumerator of possible lex states
  NOP,            ## NOP Instruction
  LD,             ## Load Instruction
  REG,            ## General Purpose Register
  IVAL,           ## Immediate Value
  STR,            ## Store instruction
  ADDR,           ## Address Value


let input = "ld r1 1234"


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

proc lex_word(w: string): Token =
  if w[0] == '[' and w[w.high] == ']':
    if lex_inner_num(w):
      return ADDR
    else:
      echo "Failed to lex inner number for word that looks like addr: ", w
      # raise new ValueError
  if lex_num(w):
    return IVAL


proc lex_input(input: string): array[3, Token] =
  ## `lex_input` takes a string and converts it to tokens to be parsed
  ## an array of 3 Tokens is used as the return becuase it can
  ## cover the possible cases

  for word in input.split():
    var indx = 0
    case word:
    of "ld":
      result[indx] = LD
    of "str":
      result[indx] = STR
    else:
      result[indx] = lex_word(word)
      echo "Unexpected word: ", word
    indx += 1
  return






when isMainModule:
  discard lex_input(input)
