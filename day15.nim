import std / [tables, strutils, algorithm]
import test / t15

type
  Vec = tuple[x, y: int]
  Map = object
    w, h: int
    data: Table[Vec, char]
    robot: Vec
  Dir = enum
    Up = "^", Down = "V", Left = "<", Right = ">"
  Whouse = object
    map: Map
    dirs: seq[Dir]
    t: int


const
  wall = '#'
  robot = '@'
  box = 'O'

# another odd example of something where LSP says it has side effects when it doesn't (compiler does not complain)
func parseMap(text: string): Map =
  let lines = text.split('\n')
  result.h = len lines
  result.w = len lines[0]
  for y in 0 ..< result.h:
    for x in 0 ..< result.w:
      if lines[y][x] in [wall, box]:
        result.data[(x, y)] = lines[y][x]
      elif lines[y][x] == robot:
        result.robot = (x, y)

func `[]`(m: Map, v: Vec): char =
  if v == m.robot:
    robot
  elif v in m.data:
    m.data[v]
  else:
    '.'

func `$`(map: Map): string =
  for y in 0 ..< map.h:
    for x in 0 ..< map.w:
      result.add map[(x, y)]
    result.add '\n'

func `$`(w: Whouse): string =
  if w.t == 0:
    result.add "Initial state:\n"
  else:
    result.add "Move " & $(w.dirs[w.t - 1]) & ":\n"
  result.add $w.map

func parseDir(text: string): seq[Dir] =
  for c in text:
    if c == '^':
      result.add Up
    elif c == 'v':
      result.add Down
    elif c == '<':
      result.add Left
    elif c == '>':
      result.add Right

func parse(text: string): Whouse =
  let two = text.split("\n\n")
  result.map = two[0].parseMap
  result.dirs = two[1].parseDir

func `+`(v: Vec, d: Dir): Vec =
  case d
  of Up:
    (v.x, v.y - 1)
  of Down:
    (v.x, v.y + 1)
  of Left:
    (v.x - 1, v.y)
  of Right:
    (v.x + 1, v.y)

# algorithm to move the robot
# if there is something blocking the robot
# try move that something
# if there is something else blocking something
# try move something else

proc doMove(w: var Whouse, v: Vec, d: Dir) =
  if v == w.map.robot:
    w.map.robot = v + d
  elif v in w.map.data:
    w.map.data[v + d] = w.map.data[v]
    w.map.data.del v

proc tryMove(w: var Whouse, v: Vec, d: Dir, again=false): bool =
  if (v + d) in w.map.data:
    if w.map.data[v + d] != wall and not again:
      if not tryMove(w, v+d, d):
        discard tryMove(w, v+d, d, true)
  else:
    doMove(w, v, d)
    result = true

proc tick(w: var Whouse) =
  if not tryMove(w, w.map.robot, w.dirs[w.t]):
    discard tryMove(w, w.map.robot, w.dirs[w.t], again=true)
  inc w.t

func gps(v: Vec): int =
  100*v.y + v.x

func part1(w: Whouse, verbose=false): int =
  var w = w
  if verbose:
    debugecho w
  while w.t < w.dirs.len:
    tick w
    if verbose:
      debugecho w
  for v, c in w.map.data:
    if c == box:
      result.inc gps(v)


when defined(part1):
  let w0 = t0.parse
  let w1 = t1.parse
  let inp = "input/15.txt".readFile.parse
  discard part1(w0, true)
  echo part1(w1)
  echo part1(inp)

func parseMap2(text: string): Map =
  let lines = text.split('\n')
  result.h = lines.len
  result.w = 2*lines[0].len
  for y in 0 ..< result.h:
    for x in 0 ..< (result.w div 2):
      if lines[y][x] == wall:
        result.data[(2*x, y)] = '#'
        result.data[(2*x + 1, y)] = '#'
      elif lines[y][x] == box:
        result.data[(2*x, y)] = '['
        result.data[(2*x + 1, y)] = ']'
      elif lines[y][x] == robot:
        result.robot = (2*x, y)

func parse2(text: string): Whouse =
  let two = text.split("\n\n")
  result.map = two[0].parseMap2
  result.dirs = two[1].parseDir

func stuck(m: Map, v: Vec): bool =
  m[v] == '#'

func next(m: Map, v: Vec, d: Dir): seq[Vec] =
  let u = v + d
  if u in m.data:
    result.add u
    if m.data[u] == '[':
      result.add u + Right
    elif m.data[u] == ']':
      result.add u + Left

proc sort1(u, v: Vec): int =
  cmp(u.y, v.y)

proc sort2(u, v: Vec): int =
  cmp(v.y, u.y)

func dfs(map: Map, v: Vec, d: Dir): seq[Vec] =
  assert d in [Up, Down]
  var stack = @[v]
  while stack.len > 0:
    let now = stack.pop
    result.add now
    for next in map.next(now, d):
      if map.stuck(next):
        return @[]
      stack.add next
  if d == Up:
    result.sort(sort2)
  else:
    result.sort(sort1)

proc doMove2(w: var Whouse, v: Vec) =
  let d = w.dirs[w.t]
  assert d in [Up, Down]
  if v == w.map.robot:
    w.map.robot = v + d
  elif v in w.map.data:
    w.map.data[v + d] = w.map.data[v]
    w.map.data.del v
    if w.map[v] == '[':
      w.map.data[v + d + Right] = w.map.data[v + Right]
      w.map.data.del (v + Right)
    elif w.map[v] == ']':
      w.map.data[v + d + Left] = w.map.data[v + Left]
      w.map.data.del (v + Left)

proc tick2(w: var Whouse) =
  var moves = dfs(w.map, w.map.robot, w.dirs[w.t])
  while moves.len > 0:
    doMove2(w, moves.pop())
  inc w.t

func gps2(v: Vec): int =
  100*v.y + v.x

func part2(w: Whouse, verbose=false): int =
  var w = w
  if verbose:
    debugecho w
  while w.t < w.dirs.len:
    if w.dirs[w.t] in [Left, Right]:
      tick w
    else:
      tick2 w
    if verbose:
      debugecho w
  for v, c in w.map.data:
    if c == '[':
      result.inc gps(v)

when not defined(part1):
  let w1 = t1.parse2
  let inp = "input/15.txt".readFile.parse2
  #echo w1.map
  let w2 = t2.parse2
  #echo w2.map
  #echo part1(w2, true) # fun that part1 works although it scrambles boxes
  #echo part2(w2, true) 
  echo part2(w1)
  echo part2(inp)
