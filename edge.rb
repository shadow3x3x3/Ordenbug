class Edge
  attr_accessor :id, :src, :dst, :dist, :lv, :risk, :flooding_potential, :used_state

  def initialize(id, src, dst, dist, lv = nil, risk = nil, flooding_potential = nil)
    @id                 = id
    @src                = src
    @dst                = dst
    @dist               = dist
    @lv                 = lv
    @risk               = risk
    @flooding_potential = flooding_potential
    @used_state         = false
  end

  def attr_array
    [@dist, @lv, @risk, @flooding_potential]
  end
end
