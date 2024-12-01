import std / [algorithm, sugar, tables]
import jsony

## parsing with possum
# possum 01.possum input/01.txt > input/01.json
type
  Pair = object
    left, right: int

## reading into nim and transforming into two sequences
let input = "input/01.json".readFile.fromJson(seq[Pair])

var left, right: seq[int]
for pair in input:
  left.add pair.left
  right.add pair.right

## sort the sequences
sort left
sort right

## solve part1
var part1 = 0
for i in left.low .. left.high:
  part1 += abs(left[i] - right[i])

dump part1

## part2 is a twist
let counts = right.toCountTable
var part2 = 0
for n in left:
  part2 += n*counts[n]

dump part2


