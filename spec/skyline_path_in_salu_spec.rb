require "spec_helper"
require_relative "../graph.rb"

=begin Test Graph
    1 - 3
  /  \   \
0     \   5
  \    \ /
    2 - 4
=end

TEST_DATA =
"1 0 1 2 4 6 7 2 1 2
 2 3 5 4 2 3 1 1 3 9
 3 1 3 3 7 9 7 5 4 3
 4 1 4 142.645049  2 0.002553  0.051150  0.014166  0.110000  0.010000
 5 2 4 142.645049  2 0.002553  0.051150  0.014166  0.110000  0.010000
 6 3 4 142.645049  2 0.002553  0.051150  0.014166  0.110000  0.010000
 7 0 2 142.645049  2 0.002553  0.051150  0.014166  0.110000  0.010000
 8 4 5 142.645049  2 0.002553  0.051150  0.014166  0.110000  0.010000 "




describe Graph do
  before(:each) do
    @graph = Graph.new(data: TEST_DATA, dim: 7, constrained_times: 1.3)
  end

  describe "#aggregate_min" do
     it "the test path should be 1, 1, 1" do
       temp_path  = [1, 1, 6]
       temp_path2 = [2, 3, 1]
       result = temp_path.aggregate_min(temp_path2)
       expect(result).to eq([1, 1, 1])
     end
   end

  describe "#attr_in" do
    it "attributes in 013 is [5.0, 11.0, 15.0, 14.0, 5.0, 2.0, 2.0]" do
      test_path = @graph.attr_in([0, 1, 3])
      expect(test_path).to eq([5.0, 11.0, 15.0, 14.0, 5.0, 2.0, 2.0])
    end

    it "attributes in 0135 is [9, 13, 18, 15, 8, 1, 2]" do
      test_path = @graph.attr_in([0, 1, 3, 5])
      expect(test_path).to eq([9.0, 13.0, 18.0, 15.0, 8.0, 1.0, 2.0])
    end
  end





end
