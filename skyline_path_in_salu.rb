require_relative 'graph'

FILE_PATH = "salu_data/edges/edag_400mm.txt"

salu_data = File.read(FILE_PATH)
# salu_data_150 = File.read("test.txt")

puts "\nuse data: #{FILE_PATH}\n"


graph = Graph.new salu_data, 4
# graph.shortest_path 0, 99
# graph.testing_unit_multiple
graph.testing_unit_single 159, 381
# graph.testing_unit_single 78, 458 # 1311, 1298
