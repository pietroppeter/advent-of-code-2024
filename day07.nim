import std / [math, strutils]
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

#echo "test/07.json".readFile.fromJson(seq[Equation]).part1
#echo "input/07.json".readFile.fromJson(seq[Equation]).part1 # nope
# 21572034122397 (case with 1 that has sum bigger)
# 21572148763543


func cat(a, b: int): int =
  a*10^len($b) + b

func modCat(t, a: int): bool =
  ($t).endsWith($a)

func divCat(t, a: int): int =
  t div 10^len($a)

func isSat2(eq: Equation, verbose = false): bool =
  if eq.numbers.len == 2:
    if eq.numbers.sum == eq.test:
      vdbg "  sum 2 ok: ", eq.test, " ", eq.numbers
      return true
    elif eq.numbers[0]*eq.numbers[1] == eq.test:
      vdbg "  mul 2 ok: ", eq.test, " ", eq.numbers
      return true
    elif cat(eq.numbers[0], eq.numbers[1]) == eq.test:
      vdbg "  cat 2 ok: ", eq.test, " ", eq.numbers
      return true
    else:
      return false
  let last = eq.numbers[^1]
  let testCat =
    if eq.test.modCat last:
      vdbg "  test cat: ", Equation(test: eq.test.divCat last, numbers: eq.numbers[0 ..< ^1])
      isSat2(Equation(test: eq.test.divCat last, numbers: eq.numbers[0 ..< ^1]), verbose=verbose)
    else:
      false
  let testMultiply =
    if eq.test mod last == 0:
      vdbg "  test mul: ", Equation(test: eq.test div last, numbers: eq.numbers[0 ..< ^1])
      isSat2(Equation(test: eq.test div last, numbers: eq.numbers[0 ..< ^1]), verbose=verbose)
    else:
      false
  let testSum = block:
    vdbg "  test sum: ", Equation(test: eq.test - last, numbers: eq.numbers[0 ..< ^1])
    isSat2(Equation(test: eq.test - last, numbers: eq.numbers[0 ..< ^1]), verbose=verbose)
  return testCat or testMultiply or testSum

func part2(eqs: seq[Equation]): int =
  for eq in eqs:
    if eq.isSat2:
      dbg "eq: ", eq
      dbg eq.isSat2(verbose = true)
      result.inc eq.test

echo "test/07.json".readFile.fromJson(seq[Equation]).part2
echo "input/07.json".readFile.fromJson(seq[Equation]).part2
