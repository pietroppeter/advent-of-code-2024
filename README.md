# advent-of-code-2024

Code and thoughts for AoC 2024

Parsing done with [possum](https://github.com/mulias/possum_parser_language), see [puzzling with possum](https://mulias.github.io/blog/puzzling-with-possum-pt1/).

Solving done with [nim](https://nim-lang.org/).

To reproduce solution for day01:
- put your input puzzle in `input/01.txt`
- run `possum 01.possum input/01.txt > input/01.json`
- `nim r day01`

Thinking focuses on making an effort to connect the puzzle to some Operations Research ([OR]) concept. Thinking might be recorded in some markdown file (like `01.md`).
I call this thinking *Feasibility thoughts* because I have a working hypothesis that
the most important part in apply OR techniques in the Industry is the focus on
constraints and as such on feasibility of the solution.
Contrast with the traditional approach in the Academy where the focus is on Optimality.

**day 3 update**: skipping the feasibility thoughts and going with a parsing thoughts. I think the thoughts sections will become something with variable content.

[OR]: https://en.wikipedia.org/wiki/Operations_research
