import std / [sequtils, math, bitops, strutils]

type
  Machine = object
    a, b, c: int
    prog: seq[int]
    pnt: int
    outt: seq[int]
  Opcode = enum
    adv, bxl, bst, jnz, bxc, outt, bdv, cdv

let m0 = Machine(
  a: 729,
  b: 0,
  c: 0,
  prog: @[0, 1, 5, 4, 3, 0],
  pnt: 0
)

func literal(m: Machine): int = m.prog[m.pnt + 1]

func combo(m: Machine): int =
  case m.prog[m.pnt + 1]
  of 0 .. 3:
    m.prog[m.pnt + 1]
  of 4:
    m.a
  of 5:
    m.b
  of 6:
    m.c
  else:
    raise ValueError.newException("invalid combo: " & $m.prog[m.pnt + 1])

proc eval(m: var Machine): bool =
  if m.pnt > m.prog.len - 1:
    return false
  let opcode = OpCode(m.prog[m.pnt])
  var jump = false
  debugEcho opcode
  case opcode
  of adv:
    m.a = m.a div (2^(m.combo))
  of bxl:
    m.b = bitxor(m.b, m.literal)
  of bst:
    m.b = (m.combo mod 8)
  of jnz:
    if m.a == 0:
      discard
    else:
      m.pnt = m.literal
      jump = true
  of bxc:
    m.b = bitxor(m.b, m.c)
  of outt:
    m.outt.add (m.combo mod 8)
  of bdv:
    m.b = m.a div (2^(m.combo)) # unused?
  of cdv:
    m.c = m.a div (2^(m.combo))

  
  if not jump:
    m.pnt.inc 2
  true

func part1(m: Machine): string =
  var m = m
  while eval(m):
    debugEcho m
  result = m.outt.mapIt($it).join(",")

let inp = Machine(
  a: 33940147,
  b: 0,
  c: 0,
  prog: @[2,4,1,5,7,5,1,6,4,2,5,5,0,3,3,0],
  pnt: 0
)

echo m0.part1
echo inp.part1