# Name

[![Build Status](https://travis-ci.org/petertseng-dp/takuzu.svg?branch=master)](https://travis-ci.org/petertseng-dp/takuzu)

Solve some Takuzu puzzles.

# Notes

Interesting part is abstracting common parts between row and columns.

Interestingly, `Array(Row | Column | Cell)` gets turned into `Array(Tuple(UInt32?, UInt32?))` which isn't quite what I want.
I wish I could have had this as an enum instead, if the enum variants could have values associated with them.

For example, `Row of UInt32 | Column of UInt32 | Cell of Tuple(UInt32, UInt32)` - more like `data` in Haskell.

This code allows `m*n` grids, even if `m != n`, as long as both are even.

# Source

https://www.reddit.com/r/dailyprogrammer/comments/3pwf17/
