import jsony

type
  Pair = object
    left, right: int
# possum 01.possum input/01.txt > input/01.json

let input = "input/01.json".readFile.fromJson(seq[Pair])
echo input