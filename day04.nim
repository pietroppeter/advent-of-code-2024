import std / [strutils, sequtils, options]

let test = """
MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX"""

type
  Grid = object
    data: seq[char]
    xLen: int
    yLen: int

func toGrid(text: string): Grid =
  let lines = text.split('\n')
  result.xLen = lines[0].len
  result.yLen = lines.len
  for line in lines:
    result.data.add line.toSeq

func yLen(g: Grid): int = g.data.len

type Point = tuple[x,y: int]

func toGridIndex(p: Point, g: Grid): int =
  p.x + g.xLen * p.y

const null = '0'

func `[]`(g: Grid, p: Point): char =
  if p.x >= 0 and p.x < g.xLen and p.y >= 0 and p.y < g.yLen:
    let i = p.toGridIndex(g)
    g.data[i]
  else:
    null

func `+`(p, q: Point): Point = (p.x + q.x, p.y + q.y)

const directions: array[0..7, Point] = [(0, 1), (1, 0), (0, -1), (-1, 0), (1, 1), (-1, -1), (1, -1), (-1, 1)]

func toWord(g: Grid, p: Point, dir: Point, length = 4): string =
  var p = p
  for _ in 1 .. length:
    if g[p] != null:
      result.add g[p]
    p = p + dir

func part1(text: string): int =
  let g = text.toGrid
  for x in 0 ..< g.xLen:
    for y in 0 ..< g.yLen:
      if g[(x,y)] == 'X':
        for dir in directions:
          if g.toWord((x, y), dir) == "XMAS":
            inc result

echo test.part1
echo "input/04.txt".readFile.part1

func isCrossMas(g: Grid, p: Point): bool =
  for a in ["MMSS", "MSMS", "SSMM", "SMSM"]:
    if g[p] == 'A' and g[p + (-1, -1)] == a[0] and g[p + (-1, 1)] == a[1] and g[p + (1, -1)] == a[2] and g[p + (1, 1)] == a[3]:
      return true

func part2(text: string): int =
  let g = text.toGrid
  for x in 0 ..< g.xLen:
    for y in 0 ..< g.yLen:
      if g.isCrossMas((x,y)):
        inc result

echo test.part2
echo "input/04.txt".readFile.part2
