require_relative 'edge'
require 'benchmark'
include Benchmark

# 避難區找最短點

# Open Array Class
class Array
  # dominate function in skyline for array
  def dominate?(array)
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
  # skyline attributes aggregate for array
  def aggregate(array)
    aggregate_array = []
    raise "Need Array not #{array.class}"    unless array.class == Array
    raise "Two Arrays are not the same size" unless self.size == array.size
    self.each_with_index do |attr, index|
      aggregate_array << attr + array[index]
    end
    aggregate_array
  end
  # finding smaller attr
  def aggregate_min(array)
    aggregate_array = []
    raise "Need Array not #{array.class}"    unless array.class == Array
    raise "Two Arrays are not the same size" unless self.size == array.size
    self.each_with_index do |attr, index|
      if attr > array[index]
        aggregate_array << array[index]
      else
        aggregate_array << attr
      end
    end
    aggregate_array
  end
end

class Graph < Array
  attr_reader :edges

  def initialize(data: nil, dim: nil, constrained_times: nil)
    @data              = data
    @dim               = dim
    @constrained_times = constrained_times
    @edges             = []
    @skyline_path      = []
    @skyline_path_attr = []
    @part_skyline_attr = {}
    data_to_object @data, dim
  end

  def testing_unit_multiple
    count_times      = 0
    ten_sec_times    = 0
    thirty_sec_times = 0
    one_min_times    = 0
    two_min_times    = 0
    five_min_times   = 0
    ten_min_times    = 0
    thirty_min_times = 0
    one_hr_times     = 0
    over_hr_times    = 0

    300.times do
      src = rand(1284)
      dst = rand(1284)
      unless src == dst
        query_time = sky_path src, dst
        case query_time
        when 0..10
          ten_sec_times    += 1
        when 11..30
          thirty_sec_times += 1
        when 31..60
          one_min_times    += 1
        when 61..120
          two_min_times    += 1
        when 121..300
          five_min_times   += 1
        when 301..600
          ten_min_times    += 1
        when 601..1800
          thirty_min_times += 1
        when 1801..3600
          one_hr_times     += 1
        else # over 1 hour
          over_hr_times    += 1
        end
        count_times += 1

        puts "In #{count_times}ed"
        puts "We found #{@skyline_path.size} skylines"
        @skyline_path      = []
        @skyline_path_attr = []
        @part_skyline_attr = {}
        puts ""
        puts "under 10  : #{ten_sec_times}"
        puts "10 to 30  : #{thirty_sec_times}"
        puts "30 to 60  : #{one_min_times}"
        puts "60 to 2m  : #{two_min_times}"
        puts "2m to 5m  : #{five_min_times}"
        puts "5m to 10m : #{ten_min_times}"
        puts "10m to 30m: #{thirty_min_times}"
        puts "30m to 1h : #{one_hr_times}"
        puts "over 1hr  : #{over_hr_times}"
        puts ""
      else
        redo
      end
    end

  end

  def testing_unit_single(src, dst)
    sky_path src, dst
    puts "We found #{@skyline_path.size} skylines"
    puts ""
    # @skyline_path.each do |sp|
    #   puts "skyline : #{sp}"
    #   puts "attr: #{attr_in sp}"
    #   puts ""
    #   # puts "edges id: #{path_to_edges_id sp} "
    # end
    write_into_txt(src, dst)
  end

  # WRITE
  def write_into_txt(src, dst)
    File.open("history/new/#{src}to#{dst}_in_#{@constrained_times}_times_skyline_path_result.txt", "w") do |file|
      @skyline_path.each do |sp|
        sp_id_array = path_to_edges_id(sp)

        sp_id_array.each_with_index do |sp_id, index|
          unless index == sp_id_array.size - 1
            file.write("\"id\" = #{sp_id} OR ")
          else
            file.write("\"id\" = #{sp_id}\n")
          end

        end
        # "id" = 34 OR "id" = 33....

      end
    end
  end

  # dijkstra
  def shortest_path(src, dst)
    @skyline_path      = []
    @skyline_path_attr = []
    @part_skyline_attr = {}
    (0..3328).each {|node| self.push node }
    @skyline_path      << dijkstra(src, dst)[:path]
    # clac skyline path attr
    @skyline_path_attr << attr_in(@skyline_path.first)
    # Insert partial skyline from skyline
    @skyline_path.first.each_with_index do |vertex, index|
      unless index < 1
        no = "#{@skyline_path.first.first.to_s}_#{vertex}"
        path_attr_sum = attr_in @skyline_path.first[0..index]
        @part_skyline_attr["p#{no}".to_sym] = path_attr_sum
      end
    end
  end

  def dijkstra(src, dst)
    distances  = {}
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
        # p "path: #{path}, distance: #{distances[dst]}"
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
  def neighbors(vertex)
    neighbors = []
    @edges.each do |edge|
      neighbors.push(edge.dst) if edge.src == vertex
      neighbors.push(edge.src) if edge.dst == vertex
    end
    neighbors.uniq
  end

  # sky path algorithm
  def sky_path(src, dst)
    puts ""
    puts "     ******* SkyPath - Source: #{src}, destination: #{dst}, Constrained Times: #{@constrained_times}  ******"
    t1 = t2 = t3 = total = 0

    Benchmark.benchmark(CAPTION, 22, FORMAT, "total:") do |step|
      t1 = step.report("Find First Skyline") { shortest_path(src, dst)}
      t2 = step.report("Dominance Test")     { dominance_test(src, dst, [src]) }
      # t3 = step.report("Check Skyline")      { skyline_check }
      total = [t1+t2]
    end
    total[0].to_a.last
  end # sky path end

  # Dominance Test Function
  def dominance_test(src, dst, path, vertices = self.clone, edges = @edges.clone, attr_previous = nil)
    vertex_stack = []
    # puts ""
    # puts "path: #{path}"
    neighbors_vertex = neighbors(src)
    neighbors_vertex.each do |vertex|
      if vertices.include?(vertex)
        edges.each do |edge|
          if (edge.src == src && edge.dst == vertex) || (edge.src == vertex && edge.dst == src)
            vertex_stack << vertex unless edge.used_state
          end
        end
      end
    end
    # puts "neighbors: #{vertex_stack}"
    # Find next vertex and attributes
    until vertex_stack.empty?
      temp_edge     = []
      # Adding attributes with new node
      path << vertex_stack.pop # take a candicate vertex to path
      next_attr = attr_between(src, path.last)
      # puts "Add #{path.last}, #{path} is current path"
      unless attr_previous.nil?
        path_attr_sum = attr_previous[0..4].aggregate(next_attr[0..4]) + attr_previous[5..6].aggregate_min(next_attr[5..6])
      else
        path_attr_sum = attr_between(src, path.last)
      end


      # Step 2-1 - Constrained length test
      unless @constrained_times.nil?
        unless constrained_length_test(path_attr_sum)
          path.pop
          next
        end
      end

      # Step 2-2 - Partial path dominance test
      unless partial_path_dominance_test(path, path_attr_sum)
        # p "#{path} is dominated by partial path "
        path.pop
        next
      end

      # Step 2-3 - Full path dominance test
      unless full_path_dominance_test path_attr_sum
        # p "#{path} is dominated by full path "
        path.pop
        next
      end

      unless path.last == dst # not arrived dst
        part_skyline = Array.new(path)
        no = "#{part_skyline.first.to_s}_#{part_skyline.last}"
        @part_skyline_attr["p#{no}".to_sym] = path_attr_sum

        edges.each do |edge|
          if (edge.src == path[-2] && edge.dst == path.last) || (edge.src == path.last && edge.dst == path[-2])
            edge.used_state = true
            temp_edge = edge
          end
        end
        vertices.delete(path.last)
        dominance_test(path.last, dst, path, vertices, edges, path_attr_sum)
        # puts "Back to: #{path}"
        edges.each do |edge|
          if (edge == temp_edge)
            edge.used_state = false
          end
        end

      else                     # arrived dst
        skyline_path_candidate = Array.new(path)
        skyline_check(skyline_path_candidate)
      end

      vertices << path.last
      path.pop
    end # until End

  end # Dominance Test End

  def constrained_length_test(path_attr_sum)
    return false if path_attr_sum[0] > @skyline_path_attr.first.first * @constrained_times # over length
    true
  end

  def partial_path_dominance_test(path, path_attr_sum)
    path_key = "p#{path.first}_#{path.last}".to_sym
    test_result =
      @part_skyline_attr[path_key].dominate?(path_attr_sum) unless @part_skyline_attr[path_key].nil?
    return false if test_result
    true # path isn't dominated by any ps
  end

  def full_path_dominance_test(path_attr_sum)
    @skyline_path_attr.each do |sp|
      return false if sp.dominate?(path_attr_sum)
    end
    true
  end

  def skyline_check(skyline_path_candidate)
    candidate = attr_in(skyline_path_candidate)
    @skyline_path.uniq!
    @skyline_path_attr.uniq!
    @skyline_path_attr.each_with_index do |sp_a, index|
      case sp_a.dominate?(candidate)
      when true
        return
      when false
        @skyline_path.delete_at(index)
        @skyline_path_attr.delete_at(index)
      when nil
        next
      end
    end
    @skyline_path      << skyline_path_candidate
    @skyline_path_attr << candidate
  end

  # find distance with src and dst
  def distance_between(src, dst)
    @edges.each do |edge|
      return edge.dist if edge.src == src && edge.dst == dst
      return edge.dist if edge.src == dst && edge.dst == src
    end
    nil
  end

  # find attr in path
  def attr_in(path)
    sum_array = []
    if path.size > 2
      (@dim - 2).times { sum_array << 0 }
      sum_array << 99999
      sum_array << 99999
      edges_of_path = path_to_edges(path)
      attr_full = edges_of_path.inject(sum_array) do |attrs, edges|
        next_attr = attr_between(edges[0], edges[1])
        attrs[0..4].aggregate(next_attr[0..4]) + attrs[5..6].aggregate_min(next_attr[5..6])
      end
    else
      attr_full = attr_between(path.first, path.last)
    end
    attr_full
  end

  # find attr with src and dst
  def attr_between(src, dst)
    @edges.each do |edge|
      return edge.attr_array if edge.src == src && edge.dst == dst
      return edge.attr_array if edge.src == dst && edge.dst == src
    end
    nil
  end

  # cut path into edges
  def path_to_edges(path)
    edges_of_path = []
    path.each_with_index do |vertex, index|
      edges_of_path << [vertex, path[index+1]] unless vertex == path.last
    end
    edges_of_path
  end

  # clear data
  def data_to_object(data, dim)
    norm_data = data.split(" ").map.each_with_index do |value, index|
      if (0..2) === index % (dim + 3)
        value.to_i
      else
        value.to_f
      end
    end
    i = 0
    norm_data.each_with_index do |value, index|
      if index % (dim + 3) == 0
        @edges.push Edge.new(*norm_data[i..i+2+dim])
        i += (dim + 3)
      end
    end
  end # data to object done

  def path_to_edges_id(path)
    edges_id_of_path = []
    path.each_with_index do |vertex, index|
      unless index == path.size - 1
        next_vertex = path[index+1]
        @edges.each do |edge|
          edges_id_of_path << edge.id if edge.src == vertex && edge.dst == next_vertex
          edges_id_of_path << edge.id if edge.src == next_vertex && edge.dst == vertex
        end
      end
    end
    edges_id_of_path
  end

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

  # combine skyline and these attributes
  def combine_skyline(key_array, attrs_array)
    raise "can't match skyline path and attribtes!" unless key_array.size != attrs_array
    result_hash = {}
    key_array.each_with_index do |array, index|
      path_key = "path_#{array.join('_')}".to_sym
      result_hash[path_key] = attrs_array[index]
    end
    result_hash
  end

  # sort skylines with dim
  def sort_by_dim(ori_array)

  end

end
