require_relative 'edge'
require 'benchmark'
include Benchmark

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
    @data              = data
    @attr_num          = attr_num
    @edges             = []
    @skyline_path      = []
    @skyline_path_attr = []
    @part_skyline_attr = {}
    data_to_object @data, attr_num
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

  def testing_unit_single src, dst
    sky_path src, dst
    puts  "We found #{@skyline_path.size} skylines"
    puts ""
    @skyline_path.each do |sp|
      puts "skyline: #{sp} #{attr_in sp}"
    end
  end

  def shortest_path src, dst
    (0..1283).each {|node| self.push node }
    @skyline_path      << dijkstra(src, dst)[:path]
    # clac skyline path attr
    @skyline_path_attr << attr_in(@skyline_path.first)
    # Insert partial skyline from skyline
    @skyline_path.first.each_with_index do |vertex, index|
      unless index < 1
        no = "#{@skyline_path.first[0].to_s}_#{vertex}"
        path_attr_sum = attr_in @skyline_path.first[0..index]
        @part_skyline_attr["p#{no}".to_sym] = path_attr_sum
      end
    end
  end

  def dijkstra src, dst
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
  def neighbors vertex
    neighbors = []
    @edges.each do |edge|
      neighbors.push edge.dst if edge.src == vertex
      neighbors.push edge.src if edge.dst == vertex
    end
    # p neighbors
    neighbors.uniq
  end

  # sky path algorithm
  def sky_path src, dst
    puts ""
    puts "     ******* SkyPath - Source: #{src}, destination: #{dst} ******"
    path = [src]
    t1 = t2 = t3 = total = 0

    Benchmark.benchmark(CAPTION, 22, FORMAT, "total:") do |step|
      t1 = step.report("Find First Skyline") { shortest_path src, dst }
      t2 = step.report("Dominance Test")     { dominance_test src, dst, path }
      t3 = step.report("Check Skyline")      { skyline_check }
      total = [t1+t2+t3]
    end

    return total[0].to_a.last

  end # sky path end

  # Dominance Test Function
  def dominance_test src, dst, path, vertices = self.clone, edges = @edges.clone, attr_previous = nil
    vertex_stack = []
    neighbors_vertex = neighbors src
    neighbors_vertex.each do |vertex|
      if vertices.include? vertex
        edges.each do |edge|
          if (edge.src == src and edge.dst == vertex) or (edge.src == vertex and edge.dst == src)
            vertex_stack << vertex unless edge.used_state
          end
        end
      end
    end

    # Find next vertex and attributes
    until vertex_stack.empty?
      path << vertex_stack.pop # take a candicate vertex to path

      #Step 2-1 - Partial path dominance test
      unless attr_previous.nil?
        path_attr_sum = attr_previous.aggregate(attr_between src, path.last)
      else
        path_attr_sum = attr_between src, path.last
      end

      unless partial_path_dominance_test path, path_attr_sum
        # p "#{path} is dominated by partial path "
        path.pop
        next
      end

      #Step 2-2 - Full path dominance test
      unless full_path_dominance_test path_attr_sum
        # p "#{path} is dominated by full path "
        path.pop
        next
      end

      unless path.last == dst # not arrived dst
        part_skyline = Array.new(path)
        no = "#{part_skyline[0].to_s}_#{part_skyline.last}"
        @part_skyline_attr["p#{no}".to_sym] = path_attr_sum

        edges.each do |edge|
          if (edge.src == path[path.size - 2] and edge.dst == path.last) or (edge.src == path.last and edge.dst == path[path.size - 2])
              edge.used_state = true
          end
        end
        vertices.delete path.last
        dominance_test path.last, dst, path, vertices, edges, path_attr_sum

      else                    # arrived dst
        skyline_path       = Array.new(path)
        skyline_path_attr  = attr_in(skyline_path)
        @skyline_path      << skyline_path
        @skyline_path_attr << attr_in(skyline_path)
      end

      edges.each do |edge|
        if (edge.src == path[path.size - 2] and edge.dst == path.last) or (edge.src == path.last and edge.dst == path[path.size - 2])
            edge.used_state =  false
        end
      end
      vertices << path.last
      path.pop
    end # until End

  end

  def partial_path_dominance_test path, path_attr_sum
    path_key = "p#{path.first}_#{path.last}".to_sym
    test_result =
      @part_skyline_attr[path_key].dominate? path_attr_sum unless @part_skyline_attr[path_key].nil?
    return false if test_result
    return true # path isn't dominated by any ps
  end

  def full_path_dominance_test path_attr_sum
    @skyline_path_attr.each do |sp|
      return false if sp.dominate? path_attr_sum
    end
    true
  end

  def skyline_check
    @skyline_path = @skyline_path.uniq
    @skyline_path_attr.each_with_index do |sp_a, index|
      @skyline_path_attr.each_with_index do |comp_sp, comp_index|
        if (index != comp_index) && (sp_a.dominate? comp_sp)
          @skyline_path.delete_at(@skyline_path_attr.index(comp_sp))
          @skyline_path_attr.delete_at(@skyline_path_attr.index(comp_sp))
        end
      end
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

  # find attr in path
  def attr_in path
    sum_array = []
    unless path.size <= 2
      @attr_num.times { sum_array << 0 }
      edges_of_path = path_to_edges path
      attr_full = edges_of_path.inject(sum_array) do |attrs, edges|
        attrs.aggregate(attr_between edges[0], edges[1])
      end
    else
      attr_full = attr_between path.first, path.last
    end
    attr_full
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