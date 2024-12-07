import std / [strutils, sequtils, strformat, algorithm, tables, sets]
import jsony

#possum 06.possum input/06.txt > input/06.json
#possum 06.possum test/06.txt > test/06.json
#echo "input/06.txt".readFile.fromJson()
#echo "test/06.txt".readFile.fromJson()

template dbg(things: varargs[untyped]) =
  when defined(dbg):
    debugEcho things

template dbg2(things: varargs[untyped]) =
  when defined(dbg2):
    debugEcho things

# no possum today
type
  Vec2 = tuple[x, y:int]
  Map = object
    w, h: int
    obstacles: Hashset[Vec2]
  Dir = enum
    Up, Down, Left, Right
  Guard = object
    pos: Vec2
    dir: Dir

# complains of side effects??
proc parse(text: string): (Map, Guard) =
  var map: Map
  var guard: Guard
  map.obstacles = initHashSet[Vec2]()
  let lines = text.split("\n")
  map.h = len(lines)
  map.w = lines[0].len
  for y in 0 ..< map.h:
    for x in 0 ..< map.w:
      if lines[y][x] == '#':
        map.obstacles.incl (x,y)
      elif lines[y][x] == '^':
        guard.pos = (x, y)
        guard.dir = Up
      elif lines[y][x] == 'v':
        guard.pos = (x, y)
        guard.dir = Down
      elif lines[y][x] == '>':
        guard.pos = (x, y)
        guard.dir = Right
      elif lines[y][x] == '<':
        guard.pos = (x, y)
        guard.dir = Left
  return (map, guard)


func inside(pos: Vec2, map: Map): bool =
  pos.x >= 0 and pos.x < map.w and pos.y >= 0 and pos.y < map.h

func inside(guard: Guard, map: Map): bool =
  guard.pos.inside(map)

func turnRight(d: Dir): Dir =
  case d
    of Up:
      Right
    of Right:
      Down
    of Down:
      Left
    of Left:
      Up

func `+`(v, w: Vec2): Vec2 = (v.x + w.x, v.y + w.y)

const toVec: array[Dir, Vec2] = [(0, -1), (0, 1), (-1, 0), (1, 0)]

proc move(guard: var Guard, map: Map) =
  let next = guard.pos + toVec[guard.dir]
  if next in map.obstacles:
    guard.dir = guard.dir.turnRight
  else:
    guard.pos = next

proc part1(map: Map, guard: Guard): int =
  var visits = initHashSet[Vec2]()
  var guard = guard
  visits.incl guard.pos
  while guard.inside(map):
    guard.move(map)
    visits.incl guard.pos
  return visits.len - 1

let (tMap, tGuard) = "test/06.txt".readFile.parse
#echo part1(tMap, tGuard)

let (map, guard) = "input/06.txt".readFile.parse
#echo part1(map, guard)

proc loops(guard: Guard, map: Map): bool =
  var path = initHashSet[Guard]()
  var guard = guard
  path.incl guard
  while guard.inside(map):
    guard.move(map)
    if guard in path:
      return true
    path.incl guard

proc addObstacle(map: Map, pos: Vec2): Map =
  result = map
  result.obstacles.incl pos

proc part2(map: Map, guard: Guard): int =
  var guard = guard
  var lobs = initHashSet[Vec2]()
  var visits = initHashSet[Vec2]()
  while guard.inside(map):
    visits.incl guard.pos
    let obs = guard.pos + toVec[guard.dir]
    if obs.inside(map) and obs notin visits and guard.loops(map.addObstacle(obs)):
      lobs.incl obs
    guard.move(map)
  result = len lobs

echo part2(tMap, tGuard)
echo part2(map, guard)
# 437 NO, 436 NO, 438 NO, 1867 NO, 1888 NO, 1887 NO, 1782 NO, 1711 YES!
