import strutils, bitops, sequtils

func mix(a, b: int): int = bitxor(a, b)

func prune(a: int): int = a mod 16777216

func next(secret: int): int =
  result = mix(secret*64, secret).prune
  result = mix(result div 32, result).prune
  result = mix(result*2048, result).prune

var tsecret = 123
for _ in 1 .. 10:
  tsecret = next tsecret
  echo tsecret

func part1(secrets: seq[int]): int =
  for secret in secrets:
    var secret = secret
    for _ in 1 .. 2000:
      secret = next secret
    result.inc secret

echo @[1, 10, 100, 2024].part1
echo "input/22.txt".readFile.split("\n").mapIt(it.parseInt).part1