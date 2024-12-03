import jsony

let input = "input/03.json".readFile.fromJson(seq[(int, int)])

var part1 = 0
for op in input:
  part1 += op[0]*op[1]
echo part1

type
  Op = object
    op: string
    args: seq[int]

let input2 = "input/03_2.json".readFile.fromJson(seq[Op])

var part2 = 0
var enable = true
for op in input2:
  if op.op == "do":
    enable = true
  elif op.op == "dont":
    enable = false
  elif op.op == "mul":
    if enable:
      part2 += op.args[0]*op.args[1]
echo part2
