import std / [strutils, sets, deques]

type
  Vec = tuple[x, y: int]
  Map = object
    w, h: int
    topo: seq[seq[int]]


func parse(text: string): Map =
  let lines = text.split('\n')
  result.h = len lines
  result.w = len lines[0]
  var horiz: seq[int]
  for y in 0 ..< result.h:
    horiz = newSeq[int](result.w)  
    for x in 0 ..< result.w:
      horiz[x] = ord(lines[y][x]) - ord('0')
    result.topo.add horiz

let t0 = """
0123
1234
8765
9876""".parse

echo t0

type
  BfsOut = object
    explored: HashSet[Vec] # for debugging
    peaks: HashSet[Vec]

func `[]`(m: Map, v: Vec): int =
  if v.x >= 0 and v.x < m.w and v.y >= 0 and v.y < m.h:
    m.topo[v.y][v.x]
  else:
    -1

func trailFrom(m: Map, now: Vec): seq[Vec] =
  for (dx, dy) in [(0, 1), (1, 0), (-1, 0), (0, -1)]:
    let next = (now.x + dx, now.y + dy)
    if m[next] == m[now] + 1:
      result.add next

func bfs(start: Vec, map: Map): BfsOut =
  var q = initDeque[Vec]()
  result.explored.incl start
  q.addLast start
  while q.len > 0:
    let now = q.popFirst()
    for next in map.trailFrom(now):
      if next notin result.explored:
        result.explored.incl next
        q.addLast next
        if map[next] == 9:
          result.peaks.incl next

func part1(m: Map): int =
  for y in 0 ..< m.h:
    for x in 0 ..< m.w:
      if m[(x, y)] == 0:
        let bfsOut = (x, y).bfs(m)
        result.inc bfsOut.peaks.len

echo t0.part1
echo "test/10.txt".readFile.parse.part1
echo "input/10.txt".readFile.parse.part1

type
  DfsOut = object
    numPaths: int

func dfs(start: Vec, map: Map): DfsOut =
  var stack = newSeq[Vec]()
  stack.add start
  while stack.len > 0:
    let now = stack.pop
    for next in map.trailFrom(now):
      stack.add next
      if map[next] == 9:
        result.numPaths.inc

func part2(m: Map): int =
  for y in 0 ..< m.h:
    for x in 0 ..< m.w:
      if m[(x, y)] == 0:
        let dfsOut = (x, y).dfs(m)
        result.inc dfsOut.numPaths

echo "test/10.txt".readFile.parse.part2
echo "input/10.txt".readFile.parse.part2
