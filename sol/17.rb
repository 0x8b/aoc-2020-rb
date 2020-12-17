require 'set'

initial_layer = DATA.each_line.map do |line|
  line.strip.chars.map do |c|
    c == ?# ? :active : :inactive
  end
end

cube = Hash.new do |h, k|
  if k.size == 3
    h[k] = :inactive
  end
end

tesseract = Hash.new do |h, k|
  if k.size == 4
    h[k] = :inactive
  end
end

initial_layer[0].size.times do |x|
  initial_layer.size.times do |y|
    cube[[x, y, 0]] = initial_layer[x][y]
    tesseract[[x, y, 0, 0]] = initial_layer[x][y]
  end
end

def run space, dimensions
  1.upto(6) do |i|
    new_space = Hash.new { |h, k| h[k] = :inactive }

    extended_keys = space.keys.flat_map do |point|
      [-1, 0, 1].repeated_permutation(dimensions).map do |deltas|
        point.zip(deltas).map &:sum
      end
    end.to_set

    extended_keys.each do |point|
      value = space[point]

      neighbours = ([-1, 0, 1].repeated_permutation(dimensions).to_a - [[0] * dimensions]).map do |deltas|
        point.zip(deltas).map &:sum
      end

      if space[point] == :active && ((2..3) === neighbours.count { |pt| space[pt] == :active })
        new_space[point] = :active
      else
        new_space[point] = :inactive
      end

      if space[point] == :inactive && (neighbours.count { |pt| space[pt] == :active } == 3)
        new_space[point] = :active
      end
    end

    space = new_space

    puts "Number of active after #{i} cycle#{i == 1 ? '' : ?s}: #{space.values.count :active }"
  end
end

run cube, 3 # 271
run tesseract, 4 # 2064

__END__
#......#
##.#..#.
#.#.###.
.##.....
.##.#...
##.#....
#####.#.
##.#.###