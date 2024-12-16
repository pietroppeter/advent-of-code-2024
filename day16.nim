import std / [sets, strutils, heapqueue, tables]

type
  Vec = tuple[x, y: int]
  Dir = enum
    East, South, West, North
  Map = object
    w, h: int
    start, fin: Vec
    path: HashSet[Vec]

func parse(text: string): Map =
  let lines = text.split('\n')
  result.h = lines.len
  result.w = lines[0].len
  for y in 0 ..< result.h:
    for x in 0 ..< result.w:
      case lines[y][x]
      of '.':
        result.path.incl (x, y)
      of 'S':
        result.path.incl (x, y)
        result.start = (x, y)
      of 'E':
        result.path.incl (x, y)
        result.fin = (x, y)
      else:
        discard

let map0 = """
###############
#.......#....E#
#.#.###.#.###.#
#.....#.#...#.#
#.###.#####.#.#
#.#.#.......#.#
#.#.#####.###.#
#...........#.#
###.#.#####.#.#
#...#.....#.#.#
#.#.#.###.#.#.#
#.....#...#.#.#
#.###.#.#.#.#.#
#S..#.....#...#
###############""".parse

type
  Node = ref object
    pos: Vec
    dir: Dir
    dist: int
  Move = object
    next: Node
    cost: int

proc `<`(a, b: Node): bool = a.dist < b.dist

func `+`(v: Vec, d: Dir): Vec =
  case d
  of North:
    (v.x, v.y - 1)
  of South:
    (v.x, v.y + 1)
  of West:
    (v.x - 1, v.y)
  of East:
    (v.x + 1, v.y)
  
func movesFrom(m: Map, n: Node): seq[Move] =
  for dir in Dir:
    let nextPos = (n.pos + dir)
    if nextPos in m.path:
      let cost = if dir == n.dir: 1 else: 1001
      let next = Node(pos: nextPos, dir: dir, dist: n.dist + cost)
      result.add Move(next: next, cost: cost)

func withDist(n: Node, d: int): Node =
  result = n
  result.dist = d

func part1(map: Map): int =
  let start = Node(pos: map.start, dir: East, dist: 0)
  var q = initHeapQueue[Node]()
  var dist = initTable[Vec, int]()
  var visited = initHashSet[Vec]()
  q.push start
  while q.len > 0:
    let here = q.pop()
    if here.pos in visited:
      continue
    visited.incl here.pos

    if here.pos == map.fin:
      break

    for move in map.movesFrom(here):
      let newDist = here.dist + move.cost
      if move.next.pos notIn dist or newDist < dist[move.next.pos]:
        dist[move.next.pos] = newDist
        q.push(move.next.withDist(newDist))
  
  return dist[map.fin]

echo part1(map0) # ok 7036

let map1 = """
#################
#...#...#...#..E#
#.#.#.#.#.#.#.#.#
#.#.#.#...#...#.#
#.#.#.#.###.#.#.#
#...#.#.#.....#.#
#.#.#.#.#.#####.#
#.#...#.#.#.....#
#.#.#####.#.###.#
#.#.#.......#...#
#.#.###.#####.###
#.#.#...#.....#.#
#.#.#.#####.###.#
#.#.#.........#.#
#.#.#.#########.#
#S#.............#
#################""".parse

echo part1(map1) # ok 7036
echo "input/16.txt".readFile.parse.part1