require "spec"
require "../src/grid"

CASES = [
  {
    "Surrounds two consecutive in a row",
    "
..00..
......
......
..11..
    ",
    "
.1001.
......
......
.0110.
    ",
  },
  {
    "Surrounds two consecutive in a column",
    "
....
....
0..1
0..1
....
....
    ",
    "
....
1..0
0..1
0..1
1..0
....
    ",
  },
  {
    "Fills in the center in a row",
    "
..0.0...
........
........
..1.1...
    ",
    "
..010...
........
........
..101...
    ",
  },
  {
    "Fills in the center in a column",
    "
....
....
0..1
....
0..1
....
....
....
    ",
    "
....
....
0..1
1..0
0..1
....
....
....
    ",
  },
  {
    "Fills full rows",
    "
0.0.0.
......
......
1.1.1.
    ",
    "
010101
......
......
101010
    ",
  },
  {
    "Fills full columns",
    "
0..1
....
0..1
....
0..1
....
    ",
    "
0..1
1..0
0..1
1..0
0..1
1..0
    ",
  },
  {
    "Prevents three-in-a-row in rows",
    "
110...
......
......
001...
    ",
    "
110..0
......
......
001..1
    ",
  },
  {
    "Prevents three-in-a-row in columns",
    "
1..0
1..0
0..1
....
....
....
    ",
    "
1..0
1..0
0..1
....
....
0..1
    ",
  },
  {
    "Prevents equal rows",
    "
1010..
......
......
......
......
101010
    ",
    "
101001
......
......
......
......
101010
    ",
  },
  {
    "Prevents equal columns",
    "
1....1
0....0
1....1
0....0
.....1
.....0
    ",
    "
1....1
0....0
1....1
0....0
0....1
1....0
    ",
  },
  {
    # Prevents a regression of a bug I had where I was only checking one side
    # (so {1, -1} is necessary in the multipliers list)
    "Chains both sides of a row",
    "
......
...1..
...1..
......
..1...
..1...
......
......
    ",
    "
...0..
...1..
...1..
.1001.
..1...
..1...
..0...
......
    ",
  },
  {
    # Prevents a regression of a bug I had where I was only checking one side
    # (so {1, -1} is necessary in the multipliers list)
    "Chains both sides of a column",
    "
........
........
.....11.
..11....
........
........
    ",
    "
........
....1...
....0110
.0110...
....1...
........
    ",
  },
  {
    # Large test, makes sure everything works together.
    # If this test fails and no earlier test does,
    # should probably reduce the failure to make a new test case.
    "Solves 12x12",
    "
0....11..0..
...1...0....
.0....1...00
1..1..11...1
.........1..
0.0...1.....
....0.......
....01.0....
..00..0.0..0
.....1....1.
10.0........
..1....1..00
    ",
    "
010101101001
010101001011
101010110100
100100110011
011011001100
010010110011
101100101010
001101001101
110010010110
010101101010
101010010101
101011010100
    ",
  },
  {
    # Large test, makes sure everything works together.
    # If this test fails and no earlier test does,
    # should probably reduce the failure to make a new test case.
    "Solves 14x14",
    "
..0...0.....1.
1....0....0.11
...1...0......
1...0.........
......0..1.0.0
1..11..1..1...
........0.....
1.1..1...11...
1......1......
..0.1..1.0...1
..0..0....1...
1........1.00.
.....00......0
.00......11..0
    ",
    "
01010101100110
10101001010011
01011010101100
10100110100101
01100101011010
10011001101001
01011010010101
10100110011010
10100101100101
01011001100101
01011010011010
10100110011001
01101001100110
10010110011010
    ",
  },
]

describe Grid do
  CASES.each { |desc, input, expected|
    it desc do
      grid = Grid.parse(input)
      grid.solve
      grid.to_s.should eq(expected.strip)
    end
  }
end
