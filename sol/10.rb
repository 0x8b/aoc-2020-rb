data = DATA.each_line.map(&:to_i).sort

data.unshift(0)
data.push(data.max + 3)

counter = Hash.new(0)

data.each_cons(2) do |a, b| counter[b - a] += 1 end

puts counter[1] * counter[3] # 2482


ways = [0] * data.size

ways[0] = 1

for i in (1...data.size) do
  for j in (1..3) do
    if i - j >= 0
      if data[i] - data[i - j] <= 3
        ways[i] += ways[i - j]
      end
    end
  end
end

puts ways.last # 96717311574016

__END__
66
7
73
162
62
165
157
158
137
125
138
59
36
40
94
95
13
35
136
96
156
155
24
84
42
171
142
3
104
149
83
129
19
122
68
103
74
118
20
110
54
127
88
31
135
26
126
2
51
91
16
65
128
119
67
48
111
29
49
12
132
17
41
166
75
146
50
30
1
164
112
34
18
72
97
145
11
117
58
78
152
90
172
163
89
107
45
37
79
159
141
105
10
115
69
170
25
100
80
4
85
169
106
57
116
23