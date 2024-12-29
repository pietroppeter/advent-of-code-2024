import re, strutils

type
  Input = object
    patterns: seq[string]
    designs: seq[string]

func parse(text: string): Input =
  let split2 = text.split("\n\n")
  result.patterns = split2[0].split(", ")
  result.designs = split2[1].splitLines

func part1(inp: Input): int =
  let pattern = re("^(" & inp.patterns.join("|") & ")+$")
  for design in inp.designs:
    if design.match(pattern):
      inc result

echo "test/19.txt".readFile.parse.part1
echo "input/19.txt".readFile.parse.part1
