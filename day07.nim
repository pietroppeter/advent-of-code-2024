import std / [math]
import jsony

type
  Equation = object
    test: int
    numbers: seq[int]

template dbg(things: varargs[untyped]) =
  when defined(dbg):
    debugEcho things

template vdbg(things: varargs[untyped]) =
  when defined(dbg):
    if verbose:
      debugEcho things

func isSatisfiable(eq: Equation, verbose = false): bool =
  if eq.numbers.len == 2:
    if eq.numbers.sum == eq.test:
      vdbg "  sum 2 ok: ", eq.test, " ", eq.numbers
      return true
    elif eq.numbers[0]*eq.numbers[1] == eq.test:
      vdbg "  mul 2 ok: ", eq.test, " ", eq.numbers
      return true
    else:
      return false
  #if eq.numbers.sum > eq.test:
  #  return false
  let last = eq.numbers[^1]
  let testMultiply =
    if eq.test mod last == 0:
      vdbg "  test mul: ", Equation(test: eq.test div last, numbers: eq.numbers[0 ..< ^1])
      isSatisfiable(Equation(test: eq.test div last, numbers: eq.numbers[0 ..< ^1]), verbose=verbose)
    else:
      false
  let testSum = block:
    vdbg "  test sum: ", Equation(test: eq.test - last, numbers: eq.numbers[0 ..< ^1])
    isSatisfiable(Equation(test: eq.test - last, numbers: eq.numbers[0 ..< ^1]), verbose=verbose)
  return testMultiply or testSum

func part1(eqs: seq[Equation]): int =
  for eq in eqs:
    if eq.isSatisfiable:
      dbg "eq: ", eq
      discard eq.isSatisfiable(verbose = true)
      result.inc eq.test

echo "test/07.json".readFile.fromJson(seq[Equation]).part1
echo "input/07.json".readFile.fromJson(seq[Equation]).part1 # nope
# 21572034122397 (case with 1 that has sum bigger)
# 21572148763543