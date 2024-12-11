import std / [math, tables, algorithm]

func digits(n: int): int =
  len $n

func blink(n: int): seq[int] =
  if n == 0:
    @[1]
  elif n.digits mod 2 == 0:
    let d = n.digits div 2
    @[n div 10^d, n mod 10^d]
  else:
    @[n*2024]

type
  BlinkInput = tuple[n: int, logTime: int]
  BlinkTable = Table[BlinkInput, seq[int]]

func logs(n: int): seq[int] =
  var
    n = n
    l = 1
  while n > 0:
    if n mod 2 == 1:
      result.add l
    n = n div 2
    l = l * 2
  reverse result

func blink(t: var BlinkTable, n, times: int): seq[int] =
  var
    next: seq[int]
    temp: seq[int]
    temp2: seq[int]
  result = @[n]
  for l in times.logs:
    next = @[]
    for m in result:
      if (m, l) in t:
        next.add t[(m, l)]
      elif l == 1:
        temp = blink m
        t[(m, 1)] = temp
        next.add temp
      else:
        temp = blink(t, m, l div 2)
        for m2 in temp:
          temp2 = blink(t, m2, l div 2)
          next.add temp2
    result = next

func blink(t: var BlinkTable, s: seq[int], times: int): seq[int] =
  for n in s:
    result.add t.blink(n, times)

var t = initTable[BlinkInput, seq[int]]()
echo t.blink(@[125, 17], 6) # ok
echo t.blink(@[125, 17], 25).len # ok 55312

import input / inp11
echo t.blink(inp11seq, 25).len # ok part1

proc blinkCounts(t: var BlinkTable, s: seq[int], times: int): CountTable[int] =
  t.blink(s, times).toCountTable

proc part2(t: var BlinkTable, s: seq[int]): int =
  var
    counts = t.blinkCounts(s, 25)
    counts2 = initCountTable[int]()
  for n, c in counts:
    for m, d in t.blinkCounts(@[n], 25):
      counts2.inc(m, d*c)
  counts = counts2
  counts2 = initCountTable[int]()
  for n, c in counts:
    for m, d in t.blinkCounts(@[n], 25):
      counts2.inc(m, d*c)
  counts = counts2
  for _, c in counts:
    result.inc c

echo t.part2(inp11seq)
# ok part 2