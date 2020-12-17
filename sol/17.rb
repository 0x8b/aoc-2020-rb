require 'set'

initial_layer = DATA.lines.map do |line| line.strip.split("").map { |e| e == ?# ? 1 : 0} end

cube = Hash.new { |h, k| h[k] = 0 }

initial_layer.size.times do |y|
  initial_layer[0].size.times do |x|
    cube[[x, y, 0]] = initial_layer[y][x]
  end
end

def print_cube cube, label
  xs, ys, zs = cube.keys.transpose
  min_x, max_x = xs.minmax
  min_y, max_y = ys.minmax
  min_z, max_z = zs.minmax

  puts "\n#{label}:\n"
  for z in (min_z..max_z)
    puts "\nz=#{z}"
    for y in (min_y..max_y)
      for x in (min_x..max_x)
        print cube[[x, y, z]] == 1 ? ?# : ?.
      end
      print "\n"
    end
  end
  puts ""
end

print_cube cube, "Before any cycles"

1.upto(6) do |i|
  new_cube = Hash.new { |h, k| cube[k] = 0 }

  extended_keys = cube.keys.flat_map do |x, y, z|
    [-1, 0, 1].repeated_permutation(3).map do |dx, dy, dz|
      [x + dx, y + dy, z + dz]
    end
  end.to_set

  extended_keys.each do |key|
    value = cube[key]
    x, y, z = key

    neighbours = ([-1, 0, 1].repeated_permutation(3).to_a - [[0, 0, 0]]).map do |dx, dy, dz|
      [x + dx, y + dy, z + dz]
    end

    # new_cube[key] = cube[key]
    if cube[key] == 1 && ((2..3) === neighbours.count { |k| cube[k] == 1 })
      new_cube[key] = 1
    else
      new_cube[key] = 0
    end

    if cube[key] == 0 && (neighbours.count { |k| cube[k] == 1} == 3)
      new_cube[key] = 1
    else
      # new_cube[key] = 0
    end
  end

  cube = new_cube

  print_cube cube, "After #{i} cycle#{i == 1 ? '' : ?s}"

  puts "Active  after #{i} cycle#{i == 1 ? '' : ?s}: #{cube.values.count(1)}" # 271
end

__END__
#......#
##.#..#.
#.#.###.
.##.....
.##.#...
##.#....
#####.#.
##.#.###