import jsony

type
  PuzzleInput = object
    rules: seq[tuple[before, after: int]]
    updates: seq[seq[int]]

echo "test/05.json".readFile.fromJson(PuzzleInput)