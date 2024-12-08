import std / [tables, sets, strutils]

type
  Vec = tuple[x, y: int]
  Map = object
    w,h: int
    ants: Table[char, seq[Vec]]
  Nodes = HashSet[Vec]

func parse(text: string): Map =
  let lines = text.split('\n')
  result.h = len lines
  result.w = len lines[0]
  for y in 0 ..< result.h:
    for x in 0 ..< result.w:
      let c = lines[y][x]
      if c != '.':
        if c in result.ants:
          result.ants[c].add (x, y)  
        else:
          result.ants[c] = @[(x, y)]

let
  tMap = "test/08.txt".readFile.parse
  map = "input/08.txt".readFile.parse

func antinode(a, b: Vec): Vec =
  (b.x + (b.x - a.x), b.y + (b.y - a.y))

func `!=`(a, b: Vec): bool =
  a.x != b.x or a.y != b.y

func inside(a: Vec, map: Map): bool =
  a.x >= 0 and a.y >= 0 and a.x < map.w and a.y < map.h

func part1(map: Map): int =
  var nodes = initHashSet[Vec]()
  for c in map.ants.keys:
    for a in map.ants[c]:
      for b in map.ants[c]:
        if a != b:
          let n = antinode(a, b)
          if n.inside map:
            nodes.incl n
  len nodes

echo tMap.part1
echo map.part1

func allNodes(map: Map, a, b: Vec): seq[Vec] =
  result.add b
  let (dx, dy) = (b.x - a.x, b.y - a.y)
  var n: Vec = (b.x + dx, b.y + dy)
  while n.inside(map):
    result.add n
    n = (n.x + dx, n.y + dy)

func part2(map: Map): int =
  var nodes = initHashSet[Vec]()
  for c in map.ants.keys:
    for a in map.ants[c]:
      for b in map.ants[c]:
        if a != b:
          for n in map.allNodes(a, b):
            nodes.incl n
  len nodes

echo tMap.part2
echo map.part2

