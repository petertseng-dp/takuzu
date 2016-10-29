class Grid
  alias Column = Tuple(UInt32, Nil)
  alias Row = Tuple(Nil, UInt32)
  alias Cell = Tuple(UInt32, UInt32)

  @rows : Array(Array(Bool?))
  @columns : Array(Array(Bool?))

  def self.parse(str)
    new(str.strip.lines.map { |line|
      line.chomp.chars.map { |c|
        case c
        when '.'; nil
        when '0'; false
        when '1'; true
        else      raise "Invalid character #{c}"
        end
      }
    })
  end

  def initialize(grid : Array(Array(Bool?)))
    @rows = grid.dup.map(&.dup)
    height = @rows.size
    width = @rows.first.size
    raise "Board is illogical, height is odd" if height.odd?
    raise "Board is illogical, width is odd" if width.odd?
    @rows.each { |r|
      raise "Uneven board, #{r.size} != #{width}" if r.size != width
    }
    @columns = (0...width).map { |x|
      (0...height).map { |y| @rows[y][x] }
    }
  end

  def solve
    queue = [] of Column | Row | Cell

    @rows.each_with_index { |row, y|
      y = y.to_u32
      row.each_with_index { |cell, x|
        next if cell.nil?
        x = x.to_u32
        self.class.expand(queue, [{y, x}])
      }
    }

    until queue.empty?
      y, x = queue.pop
      if y.nil?
        self.class.expand(queue, col(x.not_nil!))
      else
        if x.nil?
          self.class.expand(queue, row(y))
        else
          self.class.expand(queue, cell(y, x))
        end
      end
    end
  end

  def to_s
    @rows.map { |line|
      line.map { |c|
        case c
        when nil  ; '.'
        when true ; '1'
        when false; '0'
        end
      }.join
    }.join('\n')
  end

  protected def self.expand(queue, cells)
    cells.each { |y, x|
      queue << {y, x}
      queue << {y, nil}
      queue << {nil, x}
    }
  end

  private def cell(y : UInt32, x : UInt32)
    value = @rows[y][x].not_nil!
    changed = [] of Cell

    [{-1, 0}, {1, 0}, {0, -1}, {0, 1}].each { |dy, dx|
      next unless in_bounds?(y + dy, x + dx)

      [{2, 1}, {1, 2}, {1, -1}].each { |a, b|
        next unless {a, b}.all? { |m| in_bounds?(y + m * dy, x + m * dx) }
        neighbor = @rows[y + a * dy][x + a * dx]
        next unless neighbor == value
        coord = {(y + b * dy).to_u32, (x + b * dx).to_u32}
        next unless propose(coord, !value)
        self[coord] = !value
        changed << coord
      }
    }

    changed
  end

  private def in_bounds?(y : UInt32, x : UInt32)
    row = @rows[y]?
    return false unless row
    x >= 0 && x < row.size
  end

  private def col(x : UInt32) : Array(Cell)
    group(@columns[x], @columns, ->(y : Int32) { {y.to_u32, x} })
  end

  private def row(y : UInt32) : Array(Cell)
    group(@rows[y], @rows, ->(x : Int32) { {y, x.to_u32} })
  end

  private def group(g : Array(Bool?), gs : Array(Array(Bool?)), cell : Int32 -> Cell) : Array(Cell)
    changed = [] of Cell

    [true, false].each { |v|
      vs = g.count(v)
      if vs == g.size / 2
        g.each_with_index { |c, i|
          next unless c.nil?
          coord = cell.call(i)
          self[coord] = !v
          changed << coord
        }
      elsif vs + 1 == g.size / 2 && g.count(nil) > 2
        # If there is only one of this value left to place,
        # check if placing it somewhere would force a three-in-a-row.
        # If such a thing would be forced, !v needs to be placed in that location.
        g.each_cons(3).each_with_index { |three, i|
          next unless three.count(nil) == 2 && three.count(!v) == 1
          g.each_with_index { |c, j|
            next unless c.nil?
            next if j == i || j == i + 1 || j == i + 2
            coord = cell.call(j)
            self[coord] = !v
            changed << coord
          }
        }
      end
    }

    if g.count(nil) == 2
      # We can only get here if the nils are different.
      # If they are the same, they would have been handled above.
      # Check for any completed rows that match this one.
      # If there are any, un-match it.
      gs.each { |og|
        next unless og.count(nil) == 0
        next unless g.zip(og).all? { |c, oc| c.nil? || c == oc }
        g.zip(og).each_with_index { |(c, oc), i|
          next unless c.nil?
          coord = cell.call(i)
          self[coord] = !oc
          changed << coord
        }
      }
    end

    changed
  end

  private def propose(c : Cell, v : Bool)
    y, x = c
    current_value = @rows[y][x]
    return true if current_value.nil?
    raise "#{v} conflicts with #{current_value} at #{y}, #{x}" if v != current_value
    false
  end

  private def []=(c : Cell, v : Bool)
    y, x = c
    @rows[y][x] = v
    @columns[x][y] = v
  end
end
