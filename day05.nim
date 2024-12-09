import std  / [tables, intsets, algorithm, heapqueue]
import jsony

type
  Rule = tuple[before, after: int]
  PuzzleInput = object
    rules: seq[Rule]
    updates: seq[seq[int]]


type
  Update = object
    data: seq[int]
    pages: IntSet
    pageIndex: Table[int, int]
  RuleBook = object
    data: seq[Rule]
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


when defined(part1):
  echo "test/05.json".readFile.fromJson(PuzzleInput).toLookup.part1
  echo "input/05.json".readFile.fromJson(PuzzleInput).toLookup.part1

# plan for part2
# (topological ordering)
# push pages on a queue (first pages should be the first out)
# process queue by finding first element which does not have dependencies

# let's start with an example coming from test set
let
  tInput = "test/05.json".readFile.fromJson(PuzzleInput)
  input = "input/05.json".readFile.fromJson(PuzzleInput)
  ex0 = tInput.updates[0]

echo ex0

# extract rule set that applies in a structure that tracks
# on which pages a certain page depends on
type
  Depends = Table[int, IntSet] # ex

func filter(rules: seq[Rule], update: seq[int]): Depends =
  for page in update:
    if page notin result:
      result[page] = initIntSet()
    for rule in rules:
      if page == rule.after and rule.before in update:
        result[page].incl rule.before

let
  dep0 = tInput.rules.filter(ex0)

# actually it seems filtered rules force a complete ordering
func check(dep: Depends): bool =
  var depsLen = initIntSet()
  for page, deps in dep:
    depsLen.incl deps.len
  result = depsLen.len == dep.len
  if not result:
    debugEcho depsLen

func check(inp: PuzzleInput): bool =
  for upd in inp.updates:
    if not inp.rules.filter(upd).check:
      debugEcho upd
      debugecho inp.rules.filter(upd)
      return false
  return true

# both are true!
echo tInput.check
echo input.check

# ok then let's proceed with the ordering indeed
# still useful to use a queue, but I can use
type
  Page = object
   value: int
   depsLen: int

func `<`(p, q: Page): bool = p.depsLen < q.depsLen

func sort(dep: Depends): seq[int] =
  var q = initHeapQueue[Page]()
  for val, deps in dep:
    q.push(Page(value: val, depsLen: deps.len))
  while q.len > 0:
    result.add q.pop().value

echo dep0
echo dep0.sort

func part2(inp: PuzzleInput): int =
  for upd in inp.updates:
    let
      deps = inp.rules.filter(upd)
      updSorted = sort deps
      midPage = updSorted[updSorted.len div 2]
    if upd != updSorted:
      when defined(dbg):
        debugEcho "upd: ", upd
        debugEcho "deps: ", deps
        debugEcho "updSorted: ", updSorted
        debugEcho "midPage: ", midPage
      result.inc midPage

echo tInput.part2
#echo 47 + 29 + 47 = 123
when not defined(dbg):
  echo input.part2
