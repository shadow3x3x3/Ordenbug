from Edge import Edge

class Graph:

  def __init__(self, file_name, attr_num):
    self.attr_num             = attr_num
    self.edges                = []
    self.skyline_path         = []
    self.skyline_path_attr    = []
    self.partial_skyline      = []
    self.partial_skyline_attr = []

  def __new__(self, file_name, attr_num):
    self.data = data_to_object(file_name)

  def data_to_object(file_name):
    file = open(file_name, 'r', encoding = 'UTF-8')
    while True:
      line = file.readline()
      if not line: break
      print(line, end='')
    file.close()


  def dijastra(src, dst):
    pass