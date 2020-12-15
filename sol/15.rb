numbers = DATA.read.split(",").map &:to_i

def number_on_nth_turn initial_numbers, nth
  counter = Hash.new { |h, k| h[k] = 0 }
  history = Hash.new { |h, k| h[k] = [] }

  lns = nil

  (1..nth).each do |turn|
    if turn <= initial_numbers.size
      lns = initial_numbers[turn - 1]
    else
      if history[lns].size < 2
        lns = 0
      else
        lns = history[lns].last(2).reverse.inject :-
      end
    end

    counter[lns] += 1
    history[lns].push turn
  end

  lns
end

puts number_on_nth_turn numbers, 2020 # 1238
puts number_on_nth_turn numbers, 30000000 # 3745954

__END__
9,6,0,10,18,2,1