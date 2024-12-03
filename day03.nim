import jsony

let input = "input/03.json".readFile.fromJson(seq[(int, int)])

var part1 = 0
for op in input:
  part1 += op[0]*op[1]
echo part1
