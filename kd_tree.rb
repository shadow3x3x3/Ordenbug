require 'knnball'

def convert_to_kdtData path
  txt_data = File.read(path)
  kdt_data = []

  # FORMAT
  norm_data = txt_data.split(" ").map.each_with_index do |value, index|
    if index % 3 == 0
      value.to_i
    else
      value.to_f
    end
  end

  norm_data.each_with_index do |value, index|
    if index % 3 == 2
      kdt_data << {:id => norm_data[index - 2], :point => [norm_data[index-1], norm_data[index]]}
    end
  end

  kdt_data
end

def get_eNode path
  txt_data   = File.read(path)
  eNode_data = []

  norm_data = txt_data.split(" ").map.each_with_index do |value, index|
    if index % 3 == 0
      value.to_i
    else
      value.to_f
    end
  end

  norm_data.each_with_index do |value, index|
    if index % 3 == 2
      eNode_data << [norm_data[index-1], norm_data[index]]
    end
  end
  eNode_data
end

result = []
kdt_data   = convert_to_kdtData "salu_data/nodes/salu_node.txt"
eNode_data = get_eNode "salu_data/nodes/salu_evacuationNode.txt"
kdtree = KnnBall.build kdt_data


eNode_data.each_with_index do |eNode_location, index|
  result = kdtree.nearest(eNode_location)
  puts "#{index + 1285} nearest #{result[:id]}"
end
