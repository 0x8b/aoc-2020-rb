TILES = DATA.read.split("\n\n").map do |tile_metadata|
  tile_id, *tile = tile_metadata.lines.map &:strip

  [tile_id[5..].to_i, tile.map(&:chars)]
end.to_h

W = H = 12

def change_orientation tile, mode
  case mode
  when 0
    return tile
  when 1
    return tile.transpose.map(&:reverse)
  when 2
    return tile.reverse.map(&:reverse)
  when 3
    return tile.map(&:reverse).transpose
  when 4
    return tile.transpose
  when 5
    return tile.transpose.transpose.map(&:reverse)
  when 6
    return tile.transpose.reverse.map(&:reverse)
  when 7
    return tile.transpose.map(&:reverse).transpose
  end
end

def edge tile, side
  case side
  when :top
    tile.first.join
  when :bottom
    tile.last.join
  when :left
    tile.map(&:first).join
  when :right
    tile.map(&:last).join
  end
end

root_id = TILES.keys.first
root = [root_id, 0, [:top, :right, :bottom, :left].map { |side| edge(TILES[root_id], side) }]

sides = TILES.keys.reject { |id| id == root_id }.flat_map do |id|
  (0..7).map do |mode|
    o = change_orientation(TILES[id], mode)
    [id, mode, [:top, :right, :bottom, :left].map {|side| edge(o, side)}]
  end
end

sides << root
queue = [root]
processed = []

graph = Hash.new do |hash, key|
  hash[key] = {
    top: [],
    bottom: [],
    left: [],
    right: [],
  }
end

reversed = {
  top: :bottom,
  bottom: :top,
  left: :right,
  right: :left,
}

def side sides, dir
  sides[[:top, :right, :bottom, :left].index(dir)]
end

while queue.size > 0
  tile_id, tile_mode, tile_sides = queue.shift

  for dir in [:top, :bottom, :left, :right]
    graph[tile_id][dir] = sides.reject do |id, _, _|
      id == tile_id
    end.select do |i, m, s|
      side(tile_sides, dir) == side(s, reversed[dir])
    end

    for i, m, s in graph[tile_id][dir]
      unless processed.include? i
        queue << [i, m, s]
      end

      processed << i
    end
  end

  processed << tile_id
end

m = graph.select { |k, v| [v[:top], v[:bottom], v[:left], v[:right]].map(&:size).count(0) == 2 }.keys.inject(:*)

puts m # 59187348943703

top_left_id, _ = graph.find do |k,v|
  v[:left].empty? && v[:top].empty?
end

mapa_1 = Array.new(H) { |r| Array.new(W) { |c| 0 } }

queue = [
  [top_left_id, 0, 0, 0]
]

while queue.size > 0 do
  id, mode, r, c = queue.shift

  mapa_1[r][c] = change_orientation(TILES[id], mode)

  right  = graph[id][:right].first
  bottom = graph[id][:bottom].first

  if bottom
    queue << [graph[id][:bottom].first[0], graph[id][:bottom].first[1], r + 1, c]
  end

  if right
    queue << [graph[id][:right].first[0], graph[id][:right].first[1], r, c + 1]
  end
end

mapa_2 = Array.new(H * 8) { |r| Array.new(W * 8) { |c| 0 } }

H.times do |rr|
  W.times do |cc|
    8.times do |r|
      8.times do |c|
        mapa_2[rr * 8 + r][cc * 8 + c] = mapa_1[rr][cc][r + 1][c + 1]
      end
    end
  end
end

sea_monster = [
  "                  # ",
  "#    ##    ##    ###",
  " #  #  #  #  #  #   ",
].map &:chars

monster_points = []

sea_monster.size.times do |r|
  sea_monster.first.size.times do |c|
    if sea_monster[r][c] == ?#
      monster_points << [r, c]
    end
  end
end

for mode in 0..7
  transformed_map = change_orientation(mapa_2, mode)

  points_to_remove = []

  for r in (0..(mapa_2.size - sea_monster.size + 1))
    for c in (0..(mapa_2.first.size - sea_monster.first.size + 1))
      points = monster_points.map { |rr, cc| [r + rr, c + cc] }

      if points.all? { |y,x| transformed_map[y][x] == ?# }
        points_to_remove.push *points
      end
    end
  end

  points_to_remove.each do |r, c|
    transformed_map[r][c] = " "
  end

  if points_to_remove.size > 0
    puts transformed_map.flatten.count ?# # 1565
  end
end

__END__
Tile 3371:
##...###.#
........#.
..#.#...#.
##..#.....
##.......#
##........
...#......
.........#
#.#......#
.#..###...

Tile 2663:
.#.##..#..
.#..#.....
#........#
....#....#
.......###
....##....
##.#.##.##
.##..##..#
.........#
........#.

Tile 1063:
####...###
..##.....#
.#..#....#
##...#....
#..##...#.
#........#
##.......#
..........
.#.#....#.
.###....#.

Tile 2731:
.####.#.##
#.........
.#.#.##.#.
##..#..#.#
#.#.#....#
####...#.#
#.....#.##
##.##.....
..#..#..##
......#..#

Tile 2711:
#.##..#..#
#...#...##
.#.###...#
......#..#
#.....#..#
....#.#...
.#......##
....#.#..#
..........
###..####.

Tile 1087:
...#.#####
#.........
.....#...#
#.#..#...#
####.#..##
..#.#..#.#
.#..##...#
##...##..#
........#.
##...#....

Tile 2767:
###...#.#.
#.###....#
......##.#
.#........
##....#...
.#.#......
.#..#.##.#
#.#.###...
#........#
..##..###.

Tile 1951:
#...#...##
..........
#.......#.
.........#
...#....##
#.##...###
#.##.#..##
...##....#
...#......
##.#######

Tile 2347:
#..##.###.
.........#
#.#......#
.#....#...
..........
###......#
...###.#.#
#...#.....
......##.#
#.......##

Tile 2243:
.#.#...#..
#.........
#..#.#...#
.........#
#........#
#....#...#
#.....#..#
........#.
#.........
.#.#.#..#.

Tile 3019:
.##...#.##
......###.
......##.#
..#.....##
#.#.....#.
##.....#..
...#......
#.##..#...
###....#.#
##..##.##.

Tile 2851:
...#.##..#
........##
###..#...#
#......#..
#...#.....
..#..##...
##.#...#.#
...#..##..
..#..#..#.
#####.....

Tile 2267:
#####.##..
.....##..#
#.#.......
#........#
#.#...##..
...###....
#.#.....#.
.##.......
..#.......
.#..####..

Tile 2351:
#.#....#..
#..#..#...
###....#.#
#..#.#...#
##...#.#.#
#.#..#.##.
.#..#.##.#
......#.#.
###....#.#
....###.#.

Tile 1373:
..###..##.
..##....##
##..#.##.#
.#...#....
..#..#...#
###....#.#
..##..#..#
...#.....#
#.#...##..
#..##..##.

Tile 2917:
###.#.#.#.
#........#
.#......##
....##...#
.........#
#......#.#
...#......
..#.##..#.
#..###..#.
.#..##.#..

Tile 2423:
#.......##
#......#..
.....#....
##.#......
.#.#..##.#
..#....###
#........#
.....#....
#.....#.##
..###.#...

Tile 3331:
.....##.##
#........#
#.........
#....#...#
.#.#....#.
#.#...#...
#..#......
.#.......#
..........
.#....#.#.

Tile 1297:
.##.##....
.......#..
....#.#.#.
.#........
....#.....
..#..#..#.
#.......##
#...#.....
#..#....##
.#.###.#..

Tile 3923:
...###.##.
#...#.....
.#........
.#.#......
#...#.....
.....##.#.
.....#...#
#...#.#...
#.....#...
.#.......#

Tile 1571:
..##..##.#
..#..#..#.
#........#
...#......
#.......#.
##........
#.........
#...#.#...
.##.#....#
.##.#..#..

Tile 3461:
.#....#..#
........##
#...#...#.
.#...##...
.###......
..........
#..#....#.
#........#
.##..#...#
.##.#.#.#.

Tile 1291:
#.#.#...#.
####....##
..#..#.#.#
....##...#
.......#..
#.....##..
....#...#.
..#..#..#.
#.###....#
...####.#.

Tile 2179:
#.###.#...
#....###..
...#.....#
#.........
...#.....#
...#.#....
#........#
#........#
.........#
.#..##....

Tile 2153:
#...#....#
##...###.#
#...#..#..
#....#...#
#.........
.#..#....#
#....#...#
#..#.#..#.
....#.#..#
##..###.##

Tile 2621:
###..#..##
.......#.#
#........#
....##...#
##..##...#
#.........
..#......#
.....##..#
###.#....#
..##.##.##

Tile 3347:
#.#..#..##
.#.......#
###..###.#
#...#.#..#
#....###..
.##.#.##.#
#...#.##..
.##.##....
##..##..##
#.#.......

Tile 3001:
#...###...
#......#.#
#.....####
#....#....
##.##.#...
#.#.......
.....#..#.
....#.#.##
#.....##..
#.#..#.###

Tile 2707:
.###..#..#
..##...#.#
##.##.#..#
....##...#
#...#..###
#......#..
#.........
#.#......#
.........#
#...#.#...

Tile 3041:
#....##.#.
.#..#..#.#
.........#
###....###
...#.....#
..##..#..#
.#......#.
##.......#
..###.##..
#.#..##..#

Tile 1709:
.##.#....#
.........#
#.#.##....
###.....##
#.....#...
#.....##..
.........#
#........#
..#..#..##
.####.##.#

Tile 2837:
.#...#.##.
###..#...#
#..###..##
....#.....
#........#
..........
#......#.#
....#...#.
..#..#....
...#....##

Tile 1741:
.####.##..
.##......#
#.###.....
...#...#.#
..........
##.#......
....#....#
........#.
..........
#....#..#.

Tile 2383:
...##.....
....#..#..
......#...
#####....#
.........#
......#...
#......#.#
##.....#.#
#.#...##.#
##.#.#..#.

Tile 1823:
######..##
....#.....
..#...#...
##........
.##.......
...#......
#.......#.
##.#.#..##
#...###.##
#...#....#

Tile 2003:
##..##.###
#.##.#.#.#
.#.#......
...#...#..
..#.#.....
.#........
..#.....#.
#.#..#.#.#
##..##..#.
.##....#..

Tile 1367:
..#.###...
..#.##.###
##.####..#
#......###
##......#.
#.#...#..#
#..#.##...
.##....###
#...#..###
.####..#..

Tile 3733:
..#.###..#
.#....##..
.##..#..##
..###....#
.........#
.#........
.##.....#.
#....#...#
....#.#..#
.####....#

Tile 3607:
..##..####
.........#
.........#
..........
#..#......
#.#.##..##
.#..#...##
#....###.#
.#.#..#...
#...###...

Tile 1559:
####.#..#.
##.#......
.#..#.#.#.
#...#....#
##.##...#.
...#....#.
##.......#
...#...#.#
##..#...#.
#.#####.##

Tile 2617:
.#..#.....
.........#
...##..#.#
...#.#.#..
.#..#.....
#.#...#...
#......#..
#....#...#
.##.##.##.
...####..#

Tile 1249:
..##.###..
.........#
#.....#..#
.#..#.....
#..#.....#
#........#
......#...
......##..
#.#..#...#
#.##.....#

Tile 1019:
##.##.###.
##....##..
##........
...#.##...
#.......#.
#........#
....##....
..#.#..#..
#.........
.#..#.##.#

Tile 1451:
#.#.#..#.#
#.......##
#...#...##
#..#......
..##...##.
....#....#
.#.#......
....##....
....#....#
.##...##..

Tile 1433:
##..###..#
...#...##.
#.##.....#
###....#..
.....#..##
#...###..#
#.........
.....#...#
#...##....
###..#....

Tile 3803:
.#..##....
.###.....#
...#.....#
#........#
#.......##
#.##.....#
#.......#.
#.........
......###.
#..#.###..

Tile 3181:
###.#...#.
#.#......#
...#.#.#..
.....#...#
..........
........#.
###.......
#.###....#
###....#..
.###.#.##.

Tile 1831:
#..#..#.##
##...#.#.#
##......##
#..#....#.
##..#...#.
..#.......
#.##.....#
##.#....#.
#.#....#.#
##.###.##.

Tile 2843:
.###...#.#
......##.#
#.#......#
##.#...#.#
.##.#.....
.#......#.
#.#.#....#
##........
..........
###.##..#.

Tile 3691:
..#####...
.........#
#....#...#
.#...#..##
..........
##....#.#.
#........#
#.#.#.....
#.#...#...
..#..##.##

Tile 1327:
.#...#...#
#.....#.##
#..#.#..#.
##.......#
..#......#
#.#.......
..#..#..##
.#....##..
#.#......#
.##..#..#.

Tile 1669:
##.#.....#
.........#
......#.#.
..##....##
#.#.......
.###......
#..#......
.#.#...#.#
#..#......
#..#..#.#.

Tile 2819:
...#..##..
#........#
#.......#.
#.........
.......#..
#...#.....
.........#
#.#.#..#..
#...#..#..
#####..#.#

Tile 1873:
....#.####
#.#.#..###
..........
.....#....
#.#.....#.
#..##.#...
..#...###.
.#........
#.#..#...#
##.#.#....

Tile 2441:
.####.#.#.
...#...##.
....#.....
#...#.....
#.........
#.....#.##
#.#....#..
#...#....#
.........#
#####....#

Tile 1867:
#..##..##.
#..#......
#..#.#..##
....#...##
.#.##....#
....#.....
#......#..
##......#.
#...#....#
###.#..#.#

Tile 1993:
.#..######
#.###...#.
...###....
......##..
#...#...#.
...###.#.#
..##...#..
#.###.###.
...#.....#
...#.#.##.

Tile 2087:
####...#.#
#..###..#.
..##..#..#
#....#...#
.#..#..#..
.......#..
#.#..#....
.##.##.#.#
..##..#...
##..#.##.#

Tile 1973:
#.###.#.##
.......#.#
.##...#...
....#.####
#.#......#
#..#..#.#.
#......##.
...#...##.
#..#.##..#
#.....#.##

Tile 2579:
#....###..
...#...#.#
#.......#.
....#....#
#.........
......#.##
.....##...
...#.###..
.#.#...#.#
#.####.#..

Tile 1583:
#.#...###.
#.....#..#
##....#..#
........##
...#....##
....#.#...
.##....#.#
.......#.#
..#.......
.#....##.#

Tile 2971:
...#.###..
#....##..#
##...##..#
##..##.##.
..##....##
#.........
##....#..#
#.........
..#.....#.
.#.....###

Tile 3719:
#..##..#..
..........
#...#....#
......#..#
#.#..#....
#..#...#..
##.....###
#.#....#..
#.##.#..##
..##...#..

Tile 1151:
.#...##...
#....#...#
.........#
#...#....#
.........#
..........
##.......#
..##......
.......#..
##.##.####

Tile 3373:
...###....
##...##..#
##...#....
#....#...#
#.......#.
.........#
#...#....#
#.....#..#
#........#
#..##...##

Tile 3571:
.#.#.#.###
#...#.#..#
#..#.....#
#..#.#.##.
..#.......
####....##
....##.#..
#....#...#
.#......#.
.#..#.#...

Tile 2137:
.#...###..
#..#......
.###......
#...#.....
#...##..##
#...#..#..
##.#......
.....#...#
.......#..
.#...#.#..

Tile 2377:
.....##...
..#......#
...#......
#...#.....
..#...#..#
.#.#....#.
..##..#.##
.........#
.......#..
#.#.##...#

Tile 3407:
#..#..####
.#......##
###....##.
...##.#...
###...#..#
##...##..#
...#.....#
..........
...#.#.#..
......#...

Tile 1733:
###.####.#
...#..#.##
#....#....
##..#.#...
#.........
#.#...#..#
.#..##..##
.#.....###
#........#
#...#.#.##

Tile 3989:
.##.######
........#.
.#....####
#....#....
..........
..........
.......#.#
#.##.#..##
##.#..##..
..##..####

Tile 1051:
.####.####
..........
#.##....##
....#....#
..........
#........#
.....#.#.#
##.....#.#
......###.
.#...####.

Tile 3643:
.#.....#.#
.###...#.#
..........
.#.##....#
##..#..#.#
##...#....
.......#.#
.........#
..#.#....#
#.#...##..

Tile 3677:
...#.##...
#..###.#.#
.#.#..#..#
.##..#....
#.........
.........#
#..#.....#
#..#..#..#
#..#....##
..#..#....

Tile 2063:
#.###.####
#....###.#
......#..#
.........#
.###.....#
.#..#.####
...#.##..#
..........
#.#...#..#
..#..##..#

Tile 3821:
...#...#..
#..#.#...#
....#....#
..#.##...#
#.#.#.....
#......#.#
.......##.
......#..#
..#..#....
#.###...##

Tile 2477:
#..######.
....##....
.#.#....##
..........
..#...#..#
#.........
#...#...##
##......#.
#........#
#####.....

Tile 2647:
##.#...###
##...##...
#..#......
..#......#
#.#......#
#.........
##.#.....#
..#...####
#........#
..####...#

Tile 2749:
...#...###
##.......#
.....#..#.
#...#....#
#.#.....##
#...#.....
......#.##
.#.###.#..
#.#.#..#.#
..#.#..##.

Tile 2531:
#...##.#..
.#..#..#..
####.....#
#.#....#..
...#.#...#
#.......##
####......
###......#
.#.#.#...#
..##.##...

Tile 3833:
.#.#.##..#
..##...#..
..##.....#
###.....#.
.#...#....
.##......#
...#......
......#..#
.##.......
.##...#...

Tile 2777:
....#.#.##
.#..##...#
#........#
#.........
..#....#.#
..#.......
#...#....#
.#..#.....
#.#.#.....
..##..#...

Tile 2417:
####..#.#.
#..#.....#
#...#...##
......#...
.#....#..#
#...#....#
.......#..
.#..#....#
#........#
##..#.##.#

Tile 1531:
###...#.##
....#.#..#
..........
..#.#.....
.#.....#..
...#...#..
#...#.....
##..#.#..#
#.........
.#.#.###..

Tile 2969:
#.##.###.#
..###.#.##
..#....#.#
##......##
........#.
#........#
##......#.
..#..##...
...#......
.#....##..

Tile 1567:
##...##...
#....#...#
##.......#
#....#...#
........##
#.#..#....
..#.....#.
#...#.....
.........#
#..###.#..

Tile 3779:
..######.#
###..#....
....#.....
#........#
....#.....
#.#.#....#
.....#...#
...#.#....
##..#.#...
###.###.##

Tile 3467:
##..####.#
#.....#...
.....#...#
...#...#..
....#.....
##..#.#...
#.##.....#
.#........
##........
##..#.#...

Tile 2381:
#..#.#####
..###...#.
#..##.##..
###...###.
#.#.....##
.....#....
.......#.#
#.......##
#....#.#.#
##..#.#.#.

Tile 3433:
#####..#.#
......#.##
.#..#.....
#......#..
##.......#
....#.#..#
.......#..
....#....#
....#....#
.#.###.###

Tile 3559:
##..##.#..
#.........
..#......#
..##.....#
#..#..#..#
######...#
#.....#..#
.....#....
#.........
##..#..#.#

Tile 1321:
.#...#....
.#....#..#
#...#....#
#.........
#.........
#.##.##.#.
.#..#..###
..##.###..
#...#...##
.#..#.#...

Tile 1597:
##.##.##..
..........
#........#
#...###..#
#..#......
#...##...#
###.......
#.........
####.#.#.#
.#.#.#...#

Tile 2833:
.......###
.#.#.....#
#.........
#....#...#
###.......
..#....###
#.....#...
#..###....
.#..#....#
.###...#..

Tile 3911:
.###.##..#
......#.##
#........#
......#...
.#........
..........
...#......
..#.#....#
.#....#.##
..#.#..#..

Tile 1663:
####...#.#
#...#.#..#
.#.....###
.....##.#.
#......#..
..#.....##
.........#
##.#.....#
#......##.
.#..#.....

Tile 3469:
.#.##..#.#
.###....##
#.....#...
....##.#.#
....##....
....###..#
..#.###..#
#...#....#
#........#
##.##..#..

Tile 1427:
#.#.##.###
#....#.#.#
###......#
#..#......
#..##..#.#
..#..#..##
#....#.#..
.#....##.#
#..##.#...
#...#.#...

Tile 2311:
..###..#.#
..........
...##.#...
#.........
#.........
#.....##..
.#..#....#
.....#...#
#....##...
#####.##.#

Tile 1997:
.####....#
##.....#.#
#.......##
...#....#.
.###..#.##
#....##..#
#.......##
..##......
#..#..#..#
##.###.#.#

Tile 1987:
####...##.
##....#..#
.#...#....
#.....#..#
..........
#.........
#.#.......
..........
..........
#.#.#.#..#

Tile 3527:
#....##.#.
..###.#.##
....#....#
##......#.
....#....#
#..##.....
#....#...#
..##.#..#.
#........#
..#.#####.

Tile 3023:
#...#...#.
.###......
......#..#
#..#......
#...#.#..#
....#.....
#.......#.
....#.....
.......#.#
..#.##..#.

Tile 2539:
#.....#.#.
....#....#
#...##....
##....#.##
.#.#.....#
..#....#.#
#..#....#.
..#.#....#
#.#.......
###..####.

Tile 1033:
..#....##.
.........#
#........#
.......###
.....#.###
...#...#.#
...#....#.
##.......#
........#.
#...#..#..

Tile 1301:
.#.#....#.
#...#..#..
....#.....
..#......#
...#.#....
#......#..
#..#.#....
..#.......
...##.....
..#...##.#

Tile 3169:
###..##...
#....#...#
.....##...
.##.#..#..
#....##...
......#.##
..##.....#
#..#.....#
....####..
.#.##..##.

Tile 1021:
#.##..#..#
...#.....#
##........
.........#
#..#......
....#.....
......#..#
#........#
#......#..
.#.#.####.

Tile 1303:
.#.#.#.#.#
..####....
#...#..#..
#...#..###
..........
...##.#..#
.##....#.#
#.....#...
##.......#
..##.####.

Tile 3631:
.#.##..##.
#....#.#.#
##.......#
#......#.#
#..#....##
....#.....
........#.
..#....#.#
#.#......#
##.#..###.

Tile 2957:
.....###.#
#..#......
#..#...#.#
...#.....#
.........#
..#....#.#
#......#.#
....#....#
#.##.#...#
####..#.##

Tile 3229:
##.#####.#
.....#...#
......#..#
......#...
#.....#...
#..####...
.....#..#.
#...##....
#...##....
..###...##

Tile 3089:
#####.#.##
#.........
##...#..#.
....#..#..
##.##.....
.#..#...##
#.#....#..
#.....#..#
.....##...
#...######

Tile 2791:
.##.##.#.#
#.......#.
..##.##...
###.......
.......#.#
###..#.#..
#.#.#.#.#.
#...#.#...
#........#
##..###..#

Tile 2273:
...#..##.#
...##....#
.#........
......#.##
#####....#
##...#.##.
........#.
.......##.
#..#....##
#.##..#.#.

Tile 3919:
##.##.##.#
...##...##
#......#..
#.....#.#.
..#.#...#.
..#....#.#
##.#...###
....#.....
#.#.#..#..
..#.##...#

Tile 3637:
##.##.....
#...###...
.........#
#.........
#...#..#..
#...#.#...
...#.....#
....##..##
..#..#...#
#..#####..

Tile 2161:
#..###...#
..........
...#......
.#.......#
#...#.....
#..##.##.#
.####..#.#
....###...
##......#.
..##.#.###

Tile 3449:
.###.##.#.
.........#
...##....#
#.#..#....
.#.#.##..#
#....###.#
.#...##.##
..##.#...#
....#....#
.##.##.###

Tile 2287:
#..#.....#
...#.#...#
....#...#.
.#.......#
#....#.#.#
.........#
#......###
#..##.#...
#.#....#..
....#...##

Tile 2789:
#.#.#.##..
....#...##
###.#.#...
#..#.##..#
#.....#..#
......#...
..#..#..##
..#.###..#
#.....#...
.....###.#

Tile 2143:
#.#...#...
#.#.#...#.
...###.#.#
#..##...#.
#........#
........##
..........
##....##.#
..#.....#.
#.#####..#

Tile 2089:
.##....###
.#.#...#.#
.#...##..#
#....#....
##....#...
#....#...#
......#...
...#.#....
..##.#...#
.##.......

Tile 3457:
#...###..#
#...###...
#.......#.
##......#.
#.....##.#
..........
##..#.#...
....#....#
.#...#.#.#
..####....

Tile 2609:
........#.
......#..#
#.##......
#........#
..###....#
#.#..#..##
......#.#.
##........
#.....#.#.
#.#.###.##

Tile 1187:
.#######.#
#....#.#.#
#.#.###...
.##.###..#
#.#.#....#
#.......##
..#..#....
.##...#..#
.....##..#
.#...#....

Tile 2341:
###.##.#..
#...#..###
#...#....#
....###..#
..##.....#
.##.......
##...#..##
###.#.....
......#.#.
.#..###...

Tile 1171:
##....###.
........##
#........#
.......##.
.#.#....#.
.....##..#
#..#......
....#....#
##....#..#
##..#####.

Tile 1949:
.....###..
...#.#...#
#..##..##.
#...#.....
...#....#.
..#.#..###
#..##.....
#.##.....#
#.#.#.#.#.
..#.#..###

Tile 1871:
##.##.####
###.......
#..#..#...
#..#.....#
#....#....
..##....##
......#...
..#.......
#..#.#.###
#..#.##...

Tile 3907:
####......
#....#...#
....#.#...
#..#...###
....##.##.
..........
#........#
.....##.#.
#...#..##.
.##.#...#.

Tile 1723:
..#.#..#.#
#.........
.#..##...#
#.........
#..##..#.#
..####..#.
#........#
#.....#..#
#..#......
.#.#.##.#.

Tile 1237:
#.#.......
#..##.....
..........
.#..#..#..
####...###
..##.#...#
#.....#...
..#.......
.....#..##
....#..###

Tile 2897:
#.#...#..#
......#...
#...##...#
........#.
#........#
#....#.#..
.....#...#
#..#......
#......#.#
.##.......

Tile 2659:
##.##..#.#
##..#....#
###.....##
..#.....##
#.#...#...
##......##
#..###...#
#........#
.##.....#.
#.##.###.#

Tile 1931:
#...#.#.#.
#....#....
....#..#..
..........
#....#....
....#...#.
.....#...#
.......#.#
#..#..#..#
####...##.

Tile 1423:
#......#..
#...#....#
#........#
#........#
#..#......
..........
##..#..#.#
..........
......#..#
#.#.#.####

Tile 1163:
.####...##
.........#
#..##.....
#.........
#...#.....
....#..#.#
.#.......#
##........
#.....#.#.
...##.##..

Tile 1429:
.#.#.#.#..
##.#.##..#
....#....#
##....##.#
##.#.....#
#....#...#
...#..#..#
..........
#.....#..#
.#####..##

Tile 1523:
.##.#..##.
.....##...
##..##....
....##.###
##.#...#.#
..#......#
....#.....
##...#...#
##...#....
...###.##.

Tile 2029:
#.###...#.
.##.......
........#.
#.........
#..#....##
....#.##.#
#.#...#...
..#..#..##
#..##....#
..###..#.#

Tile 1213:
.##.##.#..
##....#..#
#.#..###..
.......#..
#...#.....
#....##..#
#........#
#....#....
..#..#...#
.##.##...#

Tile 1697:
.#.......#
..####....
....#.....
#....#....
........#.
#.....#...
#........#
...#......
..........
..#......#

Tile 3389:
###....#..
#..#......
##..##.#.#
#.##....##
#.....#..#
.........#
...##.....
##.....#..
#.........
.####.#...