require_relative 'edge'

class Array
  def dominate? array
    flag       = 0
    check_flag = self.size
    raise "Need Array not #{array.class}"    unless array.class == Array
    raise "Two Arrays are not the same size" unless self.size == array.size
    self.each_with_index do |attr, index|
      flag += 1       if attr >  array[index]
      flag -= 1       if attr <  array[index]
      check_flag -= 1 if attr == array[index]
    end
    return false if flag == check_flag     # be dominated
    return true  if flag == 0 - check_flag # dominate
    return nil                             # not dominate
  end

  def aggregate array
    aggregate_array = []
    raise "Need Array not #{array.class}"    unless array.class == Array
    raise "Two Arrays are not the same size" unless self.size == array.size
    self.each_with_index do |attr, index|
      aggregate_array << attr + array[index]
    end
    aggregate_array
  end
end

class Graph < Array
  attr_reader :edges

  def initialize data, attr_num
    @data         = data
    @attr_num     = attr_num
    @edges        = []
    @skyline_path = []
    data_to_object @data, attr_num
  end

  def testing_unit
    attr_in @skyline_path.first
    p "first skyline #{attr_in @skyline_path.first}"
  end

  def shortest_path src, dst
    (0..1284).each {|node| self.push node }
    @skyline_path << dijkstra(src, dst)[:path]
  end

  def dijkstra src, dst
    distances = {}
    previouses = {}
    self.each do |vertex|
      distances[vertex]  = nil # Infinity
      previouses[vertex] = nil
    end
    distances[src] = 0
    vertices = self.clone
    until vertices.empty?
      nearest_vertex = vertices.inject do |a, b|
        next b unless distances[a]
        next a unless distances[b]
        next a if distances[a] < distances[b]
        b
      end
      break unless distances[nearest_vertex] # Infinity
      if dst and nearest_vertex == dst
        path = get_path(previouses, src, dst)
        p "path: #{path}, distance: #{distances[dst]}"
        return { path: path, distance: distances[dst] }
      end
      neighbors = vertices.neighbors(nearest_vertex)
      neighbors.each do |vertex|
        alt = distances[nearest_vertex] + vertices.distance_between(nearest_vertex, vertex)
        if distances[vertex].nil? or alt < distances[vertex]
          distances[vertex] = alt
          previouses[vertex] = nearest_vertex
        end
      end
      vertices.delete nearest_vertex
    end

    if dst
      return nil
    else
      paths = {}
      distances.each { |k, v| paths[k] = get_path(previouses, src, k) }
      p "path: #{path}, distance: #{distances[dst]}"
      return { paths: paths, distances: distances }
    end
  end # dijkstra end

  # find neighbors(connecting) vertices
  def neighbors vertex
    neighbors = []
    @edges.each do |edge|
      neighbors.push edge.dst if edge.src == vertex
      neighbors.push edge.src if edge.dst == vertex
    end

    neighbors.uniq
  end

  # main algorithm
  def sky_path src, dst
    path         = [src]
    vertex_stack = []

    # Step 1 - Find First Skyline in shortest path
    shortest_path src, dst

    unless path.last == dst # arrived dst
      neighbors_vertex = neighbors src
      neighbors_vertex.each { |vertex| vertex_stack << vertex }
      path << vertex_stack.pop

      partial_path_dominance_test path
    else
      @skyline_path << path
    end

  end

  # find distance with src and dst
  def distance_between src, dst
    @edges.each do |edge|
      return edge.dist if edge.src == src and edge.dst == dst
      return edge.dist if edge.src == dst and edge.dst == src
    end
    nil
  end

  def partial_path_dominance_test path
    edges_of_path = path_to_edges path

  end

  def full_path_dominance_test path

  end

  # find attr in path
  def attr_in path
    sum_array = []
    @attr_num.times { sum_array << 0 }

    edges_of_path = path_to_edges path

    attr_ful = edges_of_path.inject(sum_array) do |attrs, edges|
      attrs.aggregate(attr_between edges[0], edges[1])
    end

    attr_ful
  end

  # find attr with src and dst
  def attr_between src, dst
    @edges.each do |edge|
      return edge.attr_array if edge.src == src and edge.dst == dst
      return edge.attr_array if edge.src == dst and edge.dst == src
    end
    nil
  end

  # cut path into edges
  def path_to_edges path
    edges_of_path = []
    path.each_with_index do |vertex, index|
      edges_of_path << [vertex, path[index+1]] unless vertex == path.last
    end

    edges_of_path
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

  def get_path(previouses, src, dest)
    path = get_path_recursively(previouses, src, dest)
    path.is_a?(Array) ? path.reverse : path
  end

  # Unroll through previouses array until we get to source
  def get_path_recursively(previouses, src, dest)
    return src if src == dest
    raise ArgumentException, "No path from #{src} to #{dest}" if previouses[dest].nil?
    [dest, get_path_recursively(previouses, src, previouses[dest])].flatten
  end

end