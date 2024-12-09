template dbg(things: varargs[untyped]) =
  when defined(dbg):
    debugEcho things

type
  Disk = seq[int16]

func parse(text: string): Disk =
  var id = 0.int16
  var l = 0
  for i, c in text:
    l = (ord(c) - ord('0'))
    if i mod 2 == 0:
      for _ in 1 .. l:
        result.add id
      inc id
    else:
      for _ in 1 .. l:
        result.add -1.int16

let
  t1 = "12345".parse
  t2 = "2333133121414131402".parse
  inp = "input/09.txt".readFile().parse

for d in [t1, t2, inp]:
  echo d.len

func toStr(d: Disk): string =
  for n in d:
    if n == -1.int16:
       result.add '.'
    else:
      result.add $(n)

const empty = -1.int16

func isEmpty(disk: Disk, i: int): bool =
  disk[i] == empty

func compact(disk: Disk): Disk =
  result = disk
  var
    i = 0
    j = disk.len - 1
  while i < j:
    if not result.isEmpty(i):
      inc i
    elif result.isEmpty(j):
      dec j
    else:
      result[i] = result[j]
      result[j] = empty

for d in [t1, t2]:
  echo d.toStr
  echo d.compact.toStr

assert t1.compact.toStr == "022111222......"
assert t2.compact.toStr == "0099811188827773336446555566.............."

func checksum(disk: Disk): int =
  for i, id in disk:
    if id == empty:
      continue
    result.inc(i*id.int)

echo t1.compact.checksum
echo t2.compact.checksum
assert t2.compact.checksum == 1928

echo inp.compact.checksum

type
  EmptyLocation = tuple
    start, length: int
  FileLocation = tuple
    start, length: int
    id: int16

func findEmpty(disk: Disk, start: int): EmptyLocation = 
  var i = start
  while i < disk.len and not disk.isEmpty(i):
    inc i
  if i == disk.len:
    return (i, 0)
  var j = i
  while j < disk.len and disk.isEmpty(j):
    inc j
  return (i, j - i)

func findEmptyWithLen(disk: Disk, start: int, length: int): EmptyLocation =
  var
    i = start
    loc = findEmpty(disk, start)
  while loc.length > 0 and loc.length < length:
    i = loc.start + 1
    loc = findEmpty(disk, i)
  result = loc

func findFile(disk: Disk, start: int): FileLocation = 
  var j = start
  while j >= 0 and disk.isEmpty(j) :
    dec j
  if j < 0:
    return (0, 0, empty)
  var i = j
  let id = disk[i]
  while i >= 0 and not disk.isEmpty(i) and disk[i] == id:
    dec i
  return (i + 1, j - i, id)

echo t1.findEmpty(0) # 1, 2
echo t1.findFile(t1.high) # (10, 5, 2)
echo t1.findEmptyWithLen(0, 3) # (start: 6, length: 4)
echo t1.findEmptyWithLen(0, 5) # 1, 2

func move(disk: var Disk, file: FileLocation, space: EmptyLocation) =
  for i in space.start ..< (space.start + file.length):
    disk[i] = file.id
  for j in file.start ..< (file.start + file.length):
    disk[j] = empty

func defrag(disk: Disk): Disk =
  var
    j = disk.len - 1
    file = disk.findFile(j)
    emptyLoc = disk.findEmptyWithLen(0, file.length)
    i = emptyLoc.start
  result = disk
  
  while file.id != empty:
    dbg "file: ", file
    dbg "space: ", emptyLoc
    dbg "j: ", j
    dbg "i: ", i
    if i < j and emptyLoc.length > 0:
      result.move(file, emptyLoc)
      dbg "disk: ", result.toStr
    file = result.findFile(file.start - 1)
    j = file.start 
    emptyLoc = result.findEmptyWithLen(0, file.length)
    i = emptyLoc.start
    dbg "file: ", file
    dbg "space: ", emptyLoc
    dbg "j: ", j
    dbg "i: ", i

echo t2.defrag.toStr
assert "00992111777.44.333....5555.6666.....8888.." == t2.defrag.toStr

echo t2.defrag.checksum
echo inp.defrag.checksum