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
