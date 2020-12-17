singularity = DATA.each_line.map do |line|
  line.strip.chars.map do |c|
    c == ?# ? :active : :inactive
  end
end

setup = {
  3 => {
    space: Hash.new { |space, point| space[point] = :inactive },
    directions: [-1, 0, 1].repeated_permutation(3).to_a - [[0] * 3],
  },
  4 => {
    space: Hash.new { |space, point| space[point] = :inactive },
    directions: [-1, 0, 1].repeated_permutation(4).to_a - [[0] * 4],
  }
}

singularity.size.times do |y|
  singularity.first.size.times do |x|
    setup[3][:space][[x, y, 0]]    = singularity[x][y]
    setup[4][:space][[x, y, 0, 0]] = singularity[x][y]
  end
end

def bigbang space:, directions:
  (1..6).each do |i|
    next_space = Hash.new { |space, point| space[point] = :inactive }

    extra_points = space.keys.flat_map do |point|
      directions.map do |dir|
        point.zip(dir).map &:sum
      end
    end

    extra_points.each do |point|
      neighbors = directions.map do |dir|
        point.zip(dir).map &:sum
      end

      if space[point] == :active && (2..3) === neighbors.count { |pt| space[pt] == :active }
        next_space[point] = :active
      else
        next_space[point] = :inactive
      end

      if space[point] == :inactive && (neighbors.count { |pt| space[pt] == :active } == 3)
        next_space[point] = :active
      end
    end

    space = next_space

    puts "Number of active after #{i} cycle#{i == 1 ? '' : ?s}: #{space.values.count :active }"
  end
end

bigbang **setup[3] # 271
bigbang **setup[4] # 2064

__END__
#......#
##.#..#.
#.#.###.
.##.....
.##.#...
##.#....
#####.#.
##.#.###