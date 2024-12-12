import std / [strutils, sets, tables, algorithm]

type
  Map = object
    w, h: int
    data: seq[string]
  Vec = tuple[x, y: int]
  Dir = enum
    Up, Down, Left, Right
  Move = tuple
    vec: Vec
    dir: Dir
  Region = object
    tag: char
    area, perimeter: int
    data: HashSet[Vec]
    border: HashSet[Move]
    sides: Table[Dir, Table[int, seq[int]]]

func parse(text: string): Map =
  let lines = text.split('\n')
  result.h = len lines
  result.w = len lines[0]
  result.data = lines

func `[]`(m: Map, v: Vec): char =
  if v.x >= 0 and v.x < m.w and v.y >= 0 and v.y < m.h:
    m.data[v.y][v.x]
  else:
    '0'

let tMap = "test/12.txt".readFile.parse
let map = "input/12.txt".readFile.parse

proc explore(map: Map, u: Vec): Region =
  var q: seq[Vec]
  result.tag = map[u]
  #echo result.tag
  q.add u
  while q.len > 0:
    let v = q.pop()
    #echo v
    result.data.incl v
    inc result.area
    for move in [((v.x + 1, v.y), Right).Move, ((v.x - 1, v.y), Left), ((v.x, v.y + 1), Down), ((v.x, v.y - 1), Up)]:
      if move.vec notIn result.data and move.vec notIn q:
        if map[move.vec] == result.tag:
          q.add move.vec
        else:
          #echo "perimeter", w
          result.border.incl move
          inc result.perimeter

proc explore(map: Map): HashSet[Region] =
  var explored = initHashSet[Vec]()
  for y in 0 ..< map.h:
    for x in 0 ..< map.w:
      if (x, y) in explored:
        continue
      let region = explore(map, (x, y))
      result.incl region
      explored.incl region.data

proc part1(map: Map): int =
  for region in map.explore:
    #echo region.tag, " ", region.area, " ", region.perimeter
    result.inc region.area * region.perimeter

when defined(part1):
  echo tmap.part1
  echo map.part1
  quit()

func countSides(s: seq[int]): int =
  let s = sorted(s)
  var prev = -3
  for next in s:
    if next != prev + 1:
      inc result
    prev = next

proc getSides(region: var Region) =
  var
    sides = initTable[Dir, Table[int, seq[int]]]()
  for dir in Dir:
    sides[dir] = initTable[int, seq[int]]()

  for b in region.border:
    if b.dir in [Up, Down]:
      if b.vec.y notIn sides[b.dir]:
        sides[b.dir][b.vec.y] = @[]  
      sides[b.dir][b.vec.y].add b.vec.x
    if b.dir in [Left, Right]:
      if b.vec.x notIn sides[b.dir]:
        sides[b.dir][b.vec.x] = @[]  
      sides[b.dir][b.vec.x].add b.vec.y
  region.sides = sides

proc countSides(region: Region): int =
  var region = region
  region.getSides
  for dir in Dir:
    for key, val in region.sides[dir]:
      #echo key, val
      let c = countSides(val)
      #echo c
      result.inc c

proc part2(map: Map): int =
  for region in map.explore:
    #echo region.tag, " ", region.area, " ", region.perimeter
    result.inc region.area * region.countSides

let m0 = """
AAAA
BBCD
BBCC
EEEC""".parse
let r0 = m0.explore

echo m0.part2
echo tmap.part2
echo map.part2
