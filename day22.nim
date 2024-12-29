import strutils, bitops, sequtils, algorithm, tables, sets

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


# mapping sequence of 4 changes to 8 digit numbers by adding 10 to each change
func next(secret: var int, changes: var int, price: var int) =
  let oldPrice = secret mod 10
  secret = next secret
  price = secret mod 10
  let change = (price - oldPrice) + 10
  changes = (changes*100 + change) mod 10000_0000

func asChanges(num: int): seq[int] =
  var num = num
  while num > 0:
    result.add (num mod 100 - 10)
    num = num div 100
  result.reversed

tsecret = 123
var tchange = 0
var tprice = 0
for _ in 1 .. 9:
  next(tsecret, tchange, tprice)
  echo tchange.asChanges


proc getPriceTable(secrets: seq[int]): CountTable[int] =
  result = initCountTable[int]()
  for secret in secrets:
    var seen = initHashSet[int]()
    var secret = secret
    var price = 0
    var change = 0
    for _ in 1 .. 4:
      next(secret, change, price)
    result.inc(change, price)
    seen.incl change
    for _ in 1 .. 1996: # or 1995?
      next(secret, change, price)
      if change notIn seen:
        result.inc(change, price)
      seen.incl change

proc part2(secrets: seq[int]): int =
  let priceTable = secrets.getPriceTable
  for v in priceTable.values:
    if v > result:
      result = v

func asNum(changes: seq[int]): int =
  for change in changes:
    result = result*100 + change + 10

const tchangeNum = @[-2, 1, -1, 3].asNum
echo tchangeNum
echo tchangeNum.asChanges

echo @[1, 2, 3, 2024].part2 #24?
block:
  let tab = @[1].getPriceTable
  echo tab[tchangeNum]
block:
  let tab = @[2].getPriceTable
  echo tab[tchangeNum]
block:
  let tab = @[3].getPriceTable
  echo tab[tchangeNum]
block:
  let tab = @[2024].getPriceTable
  echo tab[tchangeNum]

echo "input/22.txt".readFile.split("\n").mapIt(it.parseInt).part2
