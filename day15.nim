import std / [tables, strutils]
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



let w0 = t0.parse
discard part1(w0, true)
let w1 = t1.parse
echo part1(w1)
let inp = "input/15.txt".readFile.parse
echo part1(inp)