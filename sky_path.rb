class SkyPath
  def initialize data
    @data          = data
    @norm_data     = data_to_hash @data
    @skyline_path  = []
  end

  def test
    puts "hash #{@norm_data}"
  end

  def find_skyline_path start, terminal
    find_first_skyline start, terminal
    # find_all_skyline_path start, terminal
    puts "skyline path #{@skyline_path}"
  end

  private
  # clear data
  # hash key: no ; hash value: used flag, connect[], atrributes...
  def data_to_hash data
    new_content  = []
    connect_node = []
    data_hash    = {}
    data_array   = data.split(" ").map.with_index do |value, index|
      if (0..2) === index % 7
        value.to_i
      else
        value.to_f
      end
    end

    data_array.each_with_index do |elem, index|
      check_connect_index = index % 7
      # making connecting nodes array
      if check_connect_index == 0         # used flag
        new_content  << elem
        new_content  << false
      elsif (1..2) === check_connect_index # connect node
        connect_node << elem
        if check_connect_index == 2
          new_content << connect_node
          connect_node = []
        end
      else                                 # not connect node
        new_content << elem
      end

    end

    new_content.each_with_index do |elem, index|
      if index % 7 == 0
        data_hash["no_#{elem}".to_sym] = new_content[index+1..index+6]
      end
    end
    data_hash
  end

  # find first skyline with shorst distance
  # value[0]: used or not
  # value[1]: connect nodes
  # value[2]: distance
  def find_first_skyline start, terminal, path = Array.new
    temp_distance = [terminal, 10000000000] # node, distance
    node_stack = []
    path << start

    if start != terminal
      puts "Start is unterminal."
      @norm_data.each do |key, value|
        if value[0] == false
          if value[1][0] == start
            node_stack << value[1][1]
            temp_distance = [value[1][1], value[2]] if value[2] < temp_distance[1]
            @norm_data[key.to_sym][0] = true
          elsif value[1][1] == start
            node_stack << value[1][0]
            temp_distance = [value[1][0], value[2]] if value[2] < temp_distance[1]
            @norm_data[key.to_sym][0] = true
          end
        end

      end

      if

      puts "#{path}"
      puts "temp_distance #{temp_distance}"

      until node_stack.empty?
          find_first_skyline node_stack.pop, terminal, path
      end


    else
      puts "--Start is terminal. Complete skyline first path.--"
      @skyline_path << path
    end

  end

  def find_all_skyline_path start, terminal, level = 0

    if start != terminal
      puts "Start is unterminal."
      @norm_data.each do |key, value|
        if value[0] == false
          if value[1][0] == start && value[1][0] != @skyline_path

          elsif value[1][1] == start && value[1][1] != @skyline_path

          end
        end
      end
      puts "#{path}"
      find_first_skyline temp_distance[0], terminal, level + 1
    else
      puts "--Start is terminal. Complete skyline first path.--"
      @skyline_path << path
    end
  end

end # class end