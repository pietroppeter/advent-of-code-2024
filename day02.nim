import jsony

type
  Report = seq[int]

let input = "input/02.json".readFile.fromJson(seq[Report])
echo input[0 .. 10]