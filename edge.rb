class Edge
  attr_accessor :id, :src, :dst, :dist, :lv, :population_density, :vulnerable_sum, :vulnerable_max, :flooding_sum, :flooding_max, :used_state

  def initialize(*attrs, dim_times_array: nil)
    if attrs.size == 10
      @id                 = attrs[0]
      @src                = attrs[1]
      @dst                = attrs[2]
      @used_state         = false
      if dim_times_array.nil?
        @dist               = attrs[3]
        @lv                 = attrs[4]
        @population_density = attrs[5]
        @vulnerable_sum     = attrs[6]
        @vulnerable_max     = attrs[7]
        @flooding_sum       = attrs[8]
        @flooding_max       = attrs[9]
      else
        raise "dim times number wrong" if attrs.size - 3 != dim_times_array.size
        @dist               = attrs[3] * dim_times_array[0]
        @lv                 = attrs[4] * dim_times_array[1]
        @population_density = attrs[5] * dim_times_array[2]
        @vulnerable_sum     = attrs[6] * dim_times_array[3]
        @vulnerable_max     = attrs[7] * dim_times_array[4]
        @flooding_sum       = attrs[8] * dim_times_array[5]
        @flooding_max       = attrs[9] * dim_times_array[6]
      end
    else
      raise "edge got wrong"
    end

  end

  def attr_array
    [@dist, @lv, @population_density, @vulnerable_sum, @flooding_sum, @vulnerable_max, @flooding_max]
  end
end
