class Edge
  attr_accessor :id, :src, :dst, :dist, :lv, :population_density, :vulnerable_sum, :vulnerable_max, :flooding_sum, :flooding_max, :used_state

  def initialize(*attrs)
    if attrs.size == 10
      @id                 = attrs[0]
      @src                = attrs[1]
      @dst                = attrs[2]
      @dist               = attrs[3]
      @lv                 = attrs[4]
      @population_density = attrs[5]
      @vulnerable_sum     = attrs[6]
      @vulnerable_max     = attrs[7]
      @flooding_sum       = attrs[8]
      @flooding_max       = attrs[9]
      @used_state         = false
    else
      raise "edge got wrong"
    end

  end

  def attr_array
    [@dist, @lv, @population_density, @vulnerable_sum, @flooding_sum, @vulnerable_max, @flooding_max]
  end
end
