class Edge
  attr_accessor :src, :dst, :dist, :lv, :risk, :flooding_potential

  def initialize(src, dst, dist, lv, risk, flooding_potential)
    @src                = src
    @dst                = dst
    @dist               = dist
    @lv                 = lv
    @risk               = risk
    @flooding_potential = flooding_potential
  end

  def attr_array
    [@dist, @lv, @risk, @flooding_potential]
  end
end