#coding: utf-8
require 'sinatra'
require 'tilt/erb'
require_relative '../graph'

DataChoices = {
    '350' => '使用350mm',
    '450' => '使用450mm'
  }

full_food = {}

get '/' do
  @title = "沙鹿地區淹水逃生路線模擬"
  erb :index
end

post '/SkylinePathResult' do
  @result = params["data"].to_s + params["source"].to_s + params["destination"].to_s + params["dim_1"].to_s
  erb :result
end
