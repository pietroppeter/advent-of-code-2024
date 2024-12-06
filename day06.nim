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

func inside(guard: Guard, map: Map): bool =
  guard.pos.x >= 0 and guard.pos.x < map.w and guard.pos.y >= 0 and guard.pos.y < map.h

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
    dbg "-> turning right at ", guard.pos
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

func opposite(dir: Dir): Dir =
  case dir
    of Up: Down
    of Down: Up
    of Left: Right
    of Right: Left

proc part2(map: Map, guard: Guard): int =
  var visits = initHashSet[Vec2]()
  var path = initHashSet[Guard]()
  var guard = guard
  let startPos = guard.pos
  visits.incl guard.pos
  path.incl guard
  var ghost = Guard(pos: guard.pos, dir: guard.dir.opposite)
  dbg " >+ adding ghost path ", ghost
  ghost.pos = ghost.pos + toVec[ghost.dir]
  while ghost.inside(map) and ghost.pos notin map.obstacles:
    path.incl Guard(pos: ghost.pos, dir: guard.dir)
    visits.incl ghost.pos
    ghost.pos = ghost.pos + toVec[ghost.dir]
  dbg " <+ finish adding ghost path ", ghost
  dbg "guard starts: ", guard
  while guard.inside(map):
    let prev = guard
    guard.move(map)
    if guard.dir != prev.dir: # if it has turned
      # add ghost path direction
      var ghost = Guard(pos: guard.pos, dir: guard.dir.opposite)
      dbg " >+ adding ghost path ", ghost
      ghost.pos = ghost.pos + toVec[ghost.dir]
      while ghost.inside(map) and ghost.pos notin map.obstacles:
        path.incl Guard(pos: ghost.pos, dir: guard.dir)
        visits.incl ghost.pos
        ghost.pos = ghost.pos + toVec[ghost.dir]
      dbg " <+ finish adding ghost path ", ghost
    elif guard.pos != prev.pos and guard.pos in visits: # if it has moved into an already visited place
      dbg "* already visited (or ghost visited): ", guard
      # if next step is inside the map
      let next = guard.pos + toVec[guard.dir]
      let ghost = Guard(pos: next)
      if ghost.inside(map):
        # if turning right would put on a previous path I have a loop
        if Guard(pos: guard.pos, dir: guard.dir.turnRight) in path:
          dbg "OOO obstacle here would loop: ", guard.pos
          # I should check not putting obstacles where guard startPos is but that is not the bug I have!
          inc result
        else:
          dbg " X no loop cross", ghost
    visits.incl guard.pos
    path.incl guard

echo part2(tMap, tGuard)
when not defined(dbg):
  echo part2(map, guard) # 437 not right answer, 436 either, too low!
