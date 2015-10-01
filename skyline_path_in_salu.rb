require_relative 'graph'
require_relative 'sky_path'

salu_data_150 = File.read("edag_150mm.txt")
# salu_data_150 = File.read("test.txt")
# salu_data_150 = File.read("new_edge2.txt")
# salu_data_150 = File.read("new_edge3.txt")


# sky_path = SkyPath.new salu_data_150, 4
# sky_path.find_skyline_path 0, 5

graph = Graph.new salu_data_150, 4
# graph.neighbors 78
# graph.shortest_path 0, 99
graph.testing_unit_multiple
# graph.testing_unit_single


