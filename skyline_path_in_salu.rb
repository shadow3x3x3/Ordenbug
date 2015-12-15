require_relative 'graph'

FILE_PATH        = "salu_data/edges/edag_400mm.txt"
TEST_CONSTRAINED = 6

salu_data = File.read(FILE_PATH)
# salu_data_150 = File.read("test.txt")

puts "\nuse data: #{FILE_PATH}\n"

times = 0

TEST_CONSTRAINED.times do
  times += 1
  graph = Graph.new(data: salu_data, dim: 4, constrained_times: times)
  graph.testing_unit_single 159, 381
end



# graph.shortest_path 0, 99
# graph.testing_unit_multiple
# graph.testing_unit_single 78, 458 # 1311, 1298
