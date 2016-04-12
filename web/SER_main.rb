#coding: utf-8
require 'sinatra'
require 'tilt/erb'
require_relative './dot_creater.rb'
require_relative '../graph'


DataChoices = {
    "350" => "使用350mm",
    "450" => "使用450mm"
  }

get '/' do
  @title = "沙鹿地區淹水逃生路線模擬"
  # FILE_PATH = "../salu_data/edges/salu_edge_160203_定量降雨350mm_無權重.txt"
  # salu_data = File.read(FILE_PATH)

  # dot_creater = DotCreater.new(salu_data, 7, "SaluNetwork")
  # @dot = dot_creater.dot

  erb :index
end

post '/SkylinePathResult' do
  @title = "模擬結果"
  if params["data"] == "350"
    path = "../salu_data/edges/salu_edge_160203_定量降雨350mm_無權重.txt"
  else
    path = "../salu_data/edges/salu_edge_160203_定量降雨450mm_無權重.txt"
  end

  dim_times_array = [params[:dim_1].to_i, params[:dim_2].to_i, params[:dim_3].to_i, params[:dim_4].to_i, params[:dim_5].to_i, params[:dim_6].to_i, params[:dim_7].to_i]
  @filename = "#{params[:source]}to#{params[:destination]}_in_#{params[:constrained].to_f}_times_skyline_path_result.txt"
  @filename_5 = "top_5_#{params[:source]}to#{params[:destination]}_in_#{params[:constrained].to_f}_times_skyline_path_result.txt"
  @filename_sum = "sum_best_#{params[:source]}to#{params[:destination]}_in_#{params[:constrained].to_f}_times_skyline_path_result.txt"
  @result = skyline_path_in_salu(path, dim_times_array, params[:source].to_i, params[:destination].to_i, params[:constrained].to_f)
  erb :result
end

def skyline_path_in_salu(path, dim_times_array, source, destination, constrained_times)
  salu_data = File.read(path)
  graph = Graph.new(data: salu_data, dim: 7, constrained_times: constrained_times, dim_times_array: dim_times_array)
  graph.testing_unit_single(source, destination)
end

get '/download/:filename' do |filename|
  send_file "../history/new/#{filename}", :filename => filename, :type => 'Application/octet-stream'
end
