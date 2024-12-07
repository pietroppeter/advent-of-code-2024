import std / [math]
import jsony

type
  Equation = object
    test: int
    numbers: seq[int]

func isSatisfiable(eq: Equation): bool =
  if eq.numbers.len == 2:
    if eq.numbers.sum == eq.test or eq.numbers[0]*eq.numbers[1] == eq.test:
      return true
    else:
      return false
  if eq.numbers.sum > eq.test:
    return false
  let last = eq.numbers[^1]
  let testMultiply =
    if eq.test mod last == 0:
      isSatisfiable(Equation(test: eq.test div last, numbers: eq.numbers[0 ..< ^1]))
    else:
      false
  return testMultiply or isSatisfiable(Equation(test: eq.test - last, numbers: eq.numbers[0 ..< ^1]))

func part1(eqs: seq[Equation]): int =
  for eq in eqs:
    if eq.isSatisfiable:
      result.inc eq.test

echo "test/07.json".readFile.fromJson(seq[Equation]).part1
echo "input/07.json".readFile.fromJson(seq[Equation]).part1 # nope
