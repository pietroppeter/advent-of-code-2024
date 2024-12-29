import std / [sequtils, math, bitops, strutils, algorithm]

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
  #debugEcho opcode
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
    #debugEcho m
    discard
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

func reset(m: var Machine, a: int) =
  m.outt = @[]
  m.pnt = 0
  m.a = a

func quine(m: var Machine): bool =
  var lenout = m.outt.len
  while eval(m):
    if m.outt.len > m.prog.len:
      return false
    elif m.outt.len != lenout:
      if m.outt[m.outt.high] != m.prog[m.outt.high]:
        return false
  if m.outt == m.prog:
    return true

func part2basic(m: Machine, start=0): int =
  result = start
  var m = m
  var maxlen = 0
  var prev = result
  reset(m, result)
  while not quine(m):
    if m.outt.len >= maxlen:
      maxlen = m.outt.len
      debugEcho "a: ", result, " a mod prev ", (result mod prev), " lenout: ", maxlen
      prev = result
    inc result
    reset(m, result)

func part2(m: Machine, start=1): int =
  result = start
  var m = m
  var maxlen = 0
  var prev = result
  var prevMod = 0
  var prevMods = @[8, 255]
  var resultPlusMod = 0
  var strategyPrevMod = false
  reset(m, result)
  block outer:
    while not quine(m):
      if not strategyPrevMod:
        if m.outt.len >= maxlen:
          maxlen = m.outt.len
          prevMod = (result mod prev)
          debugEcho "a: ", result, " a mod prev ", prevMod, " lenout: ", maxlen
          if prevMod > 700 and prevMod notIn prevMods:
            debugEcho "NEW mod: ", prevMod, " len prevMods: ", len(prevMods), " prevMods: ", prevMods
            prevMods.add prevMod
            prevMods = reversed(sorted(prevMods))
          prev = result
        inc result
        reset(m, result)
        strategyPrevMod = true
      else:
        #debugecho "testing prevModes ", len(prevMods)
        for plusMod in prevMods:
          if plusMod < 8:
            continue
          resultPlusMod = result + plusMod
          reset(m, resultPlusMod)
          if quine(m):
            result = resultPlusMod
            break outer
          if m.outt.len >= maxlen:
            maxlen = m.outt.len
            prevMod = (result mod prev)
            debugEcho "a: ", result, " a mod prev ", prevMod, " PREVMOD! lenout: ", maxlen
            if prevMod > 700 and prevMod notIn prevMods:
              debugEcho "NEW mod: ", prevMod, " len prevMods: ", len(prevMods), " prevMods: ", prevMods
              prevMods.add prevMod
              prevMods = reversed(sorted(prevMods))
            prev = result
            break
        inc result
        reset(m, result)
        strategyPrevMod = false


let m1 = Machine(
  a: 2024,
  b: 0,
  c: 0,
  prog: @[0,3,5,4,3,0],
  pnt: 0
)
#echo m1.part2 # ok 117440
echo inp.part2(3287451)
#[
a: 0 lenout: 1
a: 10 lenout: 2
a: 778 lenout: 4
a: 10651 lenout: 5
a: 62218 lenout: 6
a: 3287451 lenout: 8
a: 137505179 lenout: 9
a: 1763797403 lenout: 10
a: 8328317084 lenout: 11
a: 42688055452 lenout: 12

a: 8328317083 a mod prev 0 lenout: 11
a: 8328317338 a mod prev 255 lenout: 11
a: 8328318721 a mod prev 1383 lenout: 11
a: 8328318729 a mod prev 8 lenout: 11
a: 8328980890 a mod prev 662161 lenout: 11
a: 8329079194 a mod prev 98304 lenout: 11

a: 42688055451 a mod prev 0 lenout: 12
a: 42688055706 a mod prev 255 lenout: 12
a: 42688057089 a mod prev 1383 lenout: 12
a: 42688057097 a mod prev 8 lenout: 12
a: 42688719258 a mod prev 662161 lenout: 12
a: 42688817562 a mod prev 98304 lenout: 12

]#