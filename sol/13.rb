data = DATA.map &:strip

earliest_timestamp = data[0].to_i
timestamps = data[1].split(",").zip(0..).filter_map { |id, i| [id.to_i, i] if id != ?x }

ids = timestamps.map &:first

minutes, bus_id = ids.map { |id| ((earliest_timestamp / id) + 1) * id }.zip(ids).min_by { |t, id| t - earliest_timestamp }

puts bus_id * (minutes - earliest_timestamp) # 1835

__END__
1001171
17,x,x,x,x,x,x,41,x,x,x,37,x,x,x,x,x,367,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,19,x,x,x,23,x,x,x,x,x,29,x,613,x,x,x,x,x,x,x,x,x,x,x,x,13