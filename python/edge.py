class Edge:
  def __init__(self, src, dst, dist, lv, risk, flooding_potential):
    self.arg                = arg
    self.src                = dst
    self.dist               = dist
    self.lv                 = lv
    self.risk               = risk
    self.flooding_potential = flooding_potential
    self.used_state         = false

  def attr_array():
    return [dist, lv, risk, flooding_potential]
