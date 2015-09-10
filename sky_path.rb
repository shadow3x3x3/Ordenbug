class SkyPath
  def initialize data, attr_num
    @data          = data
    @norm_data     = data_to_hash @data, attr_num
    @skyline_path  = []
  end

  def test
    puts "hash #{@norm_data}"
    puts "skyline path #{@skyline_path}"
  end

  def find_skyline_path start, terminal
    find_first_skyline start, terminal, @norm_data
    # puts "hash #{@norm_data}"
    find_all_skyline_path start, terminal
  end

  private
  # clear data
  # hash key: no ; hash value: used flag, connect[], atrributes...
  def data_to_hash data, attr_num
    new_content  = []
    connect_node = []
    data_hash    = {}
    data_array   = data.split(" ").map.with_index do |value, index|
      if (0..2) === index % (attr_num + 3)
        value.to_i
      else
        value.to_f
      end
    end

    data_array.each_with_index do |elem, index|
      check_connect_index = index % (attr_num + 3)
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
      if index % (attr_num + 3) == 0
        data_hash["no_#{elem}".to_sym] = new_content[index+1..index+attr_num+2]
      end
    end
    data_hash
  end

  # find first skyline with shorst distance
  # value[0]: used or not
  # value[1]: connect nodes
  # value[2]: distance
  def find_first_skyline start, terminal, edges, path = Array.new
    temp_distance = [nil, -1, 10000000000] # node, distance
    next_node     = true                   # next node exists or not

    # save edges states from upper
    edges_connect_state = edges

    path << start
    puts "#{path}"

    #### Confirm Terminal ####
    if start != terminal
      # No any node can be connected
      while next_node
        # Find nodes that can be connected the edge that's shortest in stack - greedy
        edges_connect_state.each do |key, value|
          if value[0] == false
            # First node connects
            if value[1][1] == start    # put this edge into stack
              temp_distance = [value[1][0], key, value[2]] if value[2] < temp_distance[2]
            # Second node connects
            elsif value[1][0] == start # put this edge into stack
              temp_distance = [value[1][1], key, value[2]] if value[2] < temp_distance[2]
            end
          end
        end
        next_node = false if temp_distance[0].nil?
        if next_node
          # Next node
          edges_connect_state[temp_distance[1]][0] = true
          find_first_skyline temp_distance[0], terminal, edges_connect_state, path
          temp_distance = [nil, -1, 10000000000]
          unless @skyline_path.empty?
            return
          end
        else
          # puts "return"
          path.pop
          return
        end

      end # while end

    elsif start == terminal # We arrive at terminal!
      puts "--Start is terminal. Complete skyline first path.--"
      # puts "final #{path}"
      skyline_path = Array.new(path)
      @skyline_path << skyline_path
      puts "skyline_path  #{@skyline_path}"
    end



  end

  def find_all_skyline_path start, terminal, level = 0
    puts "skyline: #{@skyline_path}"
  end

end # class end