import std / [math, tables, sequtils]
import jsony

type
  Vec = tuple[x, y: int]
  Robot = tuple
    pos: Vec
    vel: Vec

let trobots = "test/14.json".readFile.fromJson(seq[Robot])
let robots = "input/14.json".readFile.fromJson(seq[Robot])

func `*`(a: int, v: Vec): Vec =
  (a*v.x, a*v.y)

func `+`(u, v : Vec): Vec =
  (u.x + v.x, u.y + v.y)

func move(r: Robot, secs: int = 1): Robot =
  (r.pos + secs*r.vel, r.vel)

func rem(n, M: int): int =
  ((n mod M) + M) mod M

func quad(x, w: int): int =
  let
    x = (x.rem w)
    h1 = w div 2
    h2 = h1 + w.rem 2
  if x < h1:
    1
  elif x >= h2:
    2
  else:
    0

func quadrant(v: Vec, space: Vec): int =
  let q = (quad(v.x, space.x)*quad(v.y, space.y)^2)
  if q == 0:
    -1
  else:
    q.float.log2.int

for n in [0, 1, 2, 3, 4]:
  #echo quad(n, 5)
  discard
  # 1 1 0 2 2

for x in [0, 2, 4]:
  for y in [0, 2, 4]:
    #echo (x, y), quadrant((x, y), (5, 5))
    discard
# 1 2
# 4 8

func part1(robots: seq[Robot], space: Vec): int =
  var c = [0, 0, 0, 0]
  for robot in robots:
    let later = robot.move(100)
    let q = quadrant(later.pos, space)
    if q >= 0:
      inc c[q]
  #debugEcho c
  c[0]*c[1]*c[2]*c[3]



func rem(pos: Vec, space: Vec): Vec =
  (pos.x.rem space.x, pos.y.rem space.y)

#echo ((2, 4), (2, -3)).move(5).pos.rem((11, 7))
const space = (101, 103)
when defined(part1):
  echo trobots.part1((11, 7))
  echo robots.part1(space)

proc countVec(robots: seq[Robot], space: Vec): CountTable[Vec] =
  for robot in robots:
    result.inc(robot.pos.rem space)

proc viz(t: CountTable[Vec], space: Vec): string =
  for y in 0 ..< space.y:
    for x in 0 ..< space.x:
      if t[(x, y)] == 0:
        result.add '.'
      elif t[(x, y)] < 10:
        result.add $t[(x, y)]
      else:
        result.add '*'
    result.add '\n'

var t = 100
while t < 10_000:
  echo "t = ", t
  echo robots.mapIt(it.move(t)).countVec(space).viz(space)
  inc t