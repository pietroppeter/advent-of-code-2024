import std / [math, lists]

template dbg(things: varargs[untyped]) =
  when defined(dbg):
    debugEcho things

type
  Block = object
    id: int # id >= 0 if file -1 if empty
    len8: int8
  Disk = DoublyLinkedList[Block]

func parse(text: string): Disk =
  var id = 0
  var len8 = 0.int8
  for i, c in text:
    len8 = (ord(c) - ord('0')).int8
    if i mod 2 == 0:
      result.add Block(id: id, len8: len8)
      inc id
    else:
      result.add Block(id: -1, len8: len8)

let
  t1 = "12345".parse
  t2 = "2333133121414131402".parse
  inp = "input/09.txt".readFile().parse

proc diagnostic(disk: Disk) =
  var
    l = 0
    t = 0
  for b in disk:
    inc l
    t += b.len8.int
  echo "len: ", l
  echo "sum: ", t

for d in [t1, t2, inp]:
  diagnostic d

func toStr(d: Disk): string =
  for b in d:
    if b.id == -1:
      for _ in 1 .. b.len8:
        result.add '.'
    else:
      for _ in 1 .. b.len8:
        result.add $(b.id)


func isEmpty(b: Block): bool = b.id == -1

proc fix(head: var DoublyLinkedNode[Block], tail: var DoublyLinkedNode[Block]) =
  assert head.value.isEmpty
  assert not tail.value.isEmpty
  if tail.value.len8 == head.value.len8:
    var
      newTail = newDoublyLinkedNode[Block](Block(id: -1, len8: tail.value.len8))
    newTail.prev = tail.prev
    newTail.next = tail.next
    var
      newHead = newDoublyLinkedNode[Block](Block(id: tail.value.id, len8: head.value.len8))
    newHead.prev = head.prev
    newHead.next = head.next
    head = newHead
    if head.prev != nil:
      head.prev.next = head
    if head.next != nil:
      head.next.prev = head
    tail = newTail
    if tail.prev != nil:
      tail.prev.next = tail
    if tail.next != nil:
      tail.next.prev = tail
  elif tail.value.len8 < head.value.len8:
    var
      newTail = newDoublyLinkedNode[Block](Block(id: -1, len8: tail.value.len8))
    newTail.prev = tail.prev
    newTail.next = tail.next
    tail = newTail
    if tail.prev != nil:
      tail.prev.next = tail
    if tail.next != nil:
      tail.next.prev = tail
    var
      newHead = newDoublyLinkedNode[Block](Block(id: tail.value.id, len8: tail.value.len8))
      newHead2 = newDoublyLinkedNode[Block](Block(id: -1, len8: head.value.len8 - tail.value.len8))
    newHead.prev = head.prev
    newHead.next = newHead2
    newHead2.prev = newHead
    newHead2.next = head.next
    head = newHead
    if head.prev != nil:
      head.prev.next = head
    if head.next.next != nil:
      head.next.next.prev = head.next
  else: # tail > head
    var
      newTail = newDoublyLinkedNode[Block](Block(id: tail.value.id, len8: tail.value.len8 - head.value.len8))
      newTail2 = newDoublyLinkedNode[Block](Block(id: -1, len8: head.value.len8))
    newTail.prev = tail.prev
    newTail.next = newTail2
    newTail2.prev = newTail
    newTail2.next = tail.next
    tail = newTail
    if tail.prev != nil:
      tail.prev.next = tail
    if tail.next.next != nil:
      tail.next.next.prev = tail.next
    var
      newHead = newDoublyLinkedNode[Block](Block(id: tail.value.id, len8: head.value.len8))
    newHead.prev = head.prev
    newHead.next = head.next
    head = newHead
    if head.prev != nil:
      head.prev.next = head
    if head.next != nil:
      head.next.prev = head

func compact(disk: Disk): Disk =
  var disk = disk
  var head = disk.head
  var tail = disk.tail
  # find next empty spot in head (quit if reached tail)
  while head != tail and head != nil:
    dbg "head: ", head.value
    if not head.value.isEmpty:
      head = head.next
    else:
      # find next file from tail (no need to quit?)
      while tail.value.isEmpty:
        if tail == head:
          return # just to be safe
        tail = tail.prev
      dbg "tail: ", tail.value
      fix(head, tail)
      dbg "after fix: ", disk.toStr
      dbg "new tail: ", tail.value
      dbg "new head: ", head.value
      head = head.next
  
  result = disk

for d in [t1]:#, t2]:
  #echo d
  echo d.toStr
  echo d.compact.toStr
