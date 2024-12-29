import strutils, algorithm

type
  Lock = seq[int]
  Key = seq[int]
  Schematics = object
    locks: seq[Lock]
    keys: seq[Key]

func isLock(chunk: string): bool = chunk.startsWith("#")

func parseShape(lines: seq[string]): seq[int] =
  result = newSeq[int](len(lines[0]))
  for i in 1 .. lines.high:
    for j in 0 ..< result.len:
      if lines[i][j] == '#':
        inc result[j]

func parse(text: string): Schematics =
  for chunk in text.split("\n\n"):
    if chunk.isLock:
      result.locks.add chunk.split("\n").parseShape
    else:
      result.keys.add chunk.split("\n").reversed.parseShape

func fit(lock: Lock, key: Key): bool =
  for i, v in lock:
    if v + key[i] > 5:
      return false
  true

func part1(inp: Schematics): int =
  for lock in inp.locks:
    for key in inp.keys:
      if lock.fit key:
        inc result


let tschematics = "test/25.txt".readFile.parse
echo tschematics.part1
echo "input/25.txt".readFile.parse.part1
