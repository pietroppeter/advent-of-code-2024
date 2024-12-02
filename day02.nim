import jsony
import std / sugar

type
  Report = seq[int]

let input = "input/02.json".readFile.fromJson(seq[Report])

# is a report safe
func isSafe(report: Report): bool =
  let direction = report[1] > report[0]
  for i in report.low .. report.high - 1:
    if (report[i + 1] > report[i]) != direction:
      return false
    if abs(report[i + 1] - report[i]) not_in [1, 2, 3]:
      return false
  return true
  
# solve part1
var part1 = 0
for report in input:
  if report.isSafe:
    part1 += 1

dump part1

# damp a specific level
func damp(report: Report, i: int): Report =
  report[0 ..< i] & report[(i + 1) .. report.high]

func isSafeWithDampener(report: Report): bool =
  if isSafe(report):
    return true
  for i in report.low .. report.high:
    if isSafe(report.damp(i)):
      return true
  return false

# solve part2
var part2 = 0
for report in input:
  if report.isSafeWithDampener:
    part2 += 1

dump part2
