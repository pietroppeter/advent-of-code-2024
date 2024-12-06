import std  / [tables, intsets, algorithm]
import jsony

type
  PuzzleInput = object
    rules: seq[tuple[before, after: int]]
    updates: seq[seq[int]]


type
  Update = object
    data: seq[int]
    pages: IntSet
    pageIndex: Table[int, int]
  RuleBook = object
    data: seq[tuple[before, after: int]]
    book: Table[int, IntSet]
  Lookup = object
    rules: RuleBook
    updates: seq[Update]

func toLookup(input: PuzzleInput): Lookup =
  result.rules.data = input.rules
  # put rules int a lookup book
  for rule in result.rules.data:
    let (before, after) = rule
    if before notIn result.rules.book:
      result.rules.book[before] = initIntSet()
    result.rules.book[before].incl after
  # create lookup updates
  for data in input.updates:
    var update = Update(data: data)
    for i, page in data:
      update.pages.incl page
      update.pageIndex[page] = i
    result.updates.add update

func check(update: Update, rules: RuleBook): bool =
  for i, page in update.data:
    if page in rules.book:
      let pagesAfter = rules.book[page]
      for after in pagesAfter:
        if after in update.pages and update.pageIndex[after] < i:
          return false
  return true

func midPage(update: Update): int =
  update.data[(update.data.len div 2)]

func part1(look: Lookup): int =
  for update in look.updates:
    if update.check(look.rules):
      #debugEcho "check ok: ", update.data
      result.inc update.midPage
      #debugEcho "  add ", update.midPageNumber


echo "test/05.json".readFile.fromJson(PuzzleInput).toLookup.part1
echo "input/05.json".readFile.fromJson(PuzzleInput).toLookup.part1
    