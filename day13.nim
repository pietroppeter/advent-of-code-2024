import std / sequtils
import jsony

type
  Vec = tuple[x, y: int]
  Machine = object
    buttA, buttB, prize: Vec

let tmachines = "test/13.json".readFile.fromJson(seq[Machine])
let machines = "input/13.json".readFile.fromJson(seq[Machine])

func hit(m: Machine, a, b: int): bool =
  (m.buttA.x*a + m.buttB.x*b == m.prize.x) and (m.buttA.y*a + m.buttB.y*b == m.prize.y)

func solve(m: Machine): seq[Vec] =
  for b in 0 .. 100:
    for a in 0 .. 100:
      if m.hit(a, b):
        result.add (a, b)

func part1(machines: seq[Machine]): int =
  for machine in machines:
    let sol = solve machine
    if len(sol) > 0:
      result.inc min(sol.mapIt(3*it.x + it.y))

echo tmachines.part1
echo machines.part1