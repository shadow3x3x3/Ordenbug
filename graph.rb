require_relative 'edge'

class Graph
  attr_reader :edges

  def initialize data, attr_num
    @data         = data
    @edges        = []
    @skyline_path = []
    data_to_object @data, attr_num
  end

  def test
    # p "#{@edges}"
  end

  private
  # clear data
  def data_to_object data, attr_num
    norm_data = data.split(" ").map.each_with_index do |value, index|
      if (0..2) === index % (attr_num + 3)
        value.to_i
      else
        value.to_f
      end
    end
    i = 0
    norm_data.each_with_index do |value, index|
      if index % (attr_num + 3) == 0
        @edges.push Edge.new(*norm_data[i+1..i+2+attr_num])
        i += (attr_num + 3)
      end
    end
  end # data to object done

end