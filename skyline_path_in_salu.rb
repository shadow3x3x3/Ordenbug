require_relative 'sky_path'

salu_data_150 = File.read("edag_150mm.txt")
# salu_data_150 = File.read("test.txt")

sky_path = SkyPath.new salu_data_150
# sky_path.test
sky_path.find_skyline_path 0, 1163

