require "spec_helper"
require_relative "../graph.rb"

=begin Test Graph
    1 - 3
  /  \   \
0     \   5
  \    \ /
    2 - 4
=end

TEST_PATH_DATA =
"1 0 1 2 4 6 7 2 1 2
 2 3 5 4 2 3 1 1 3 9
 3 1 3 3 7 9 7 5 4 3
 4 1 4 142.645049  2 0.002553  0.051150  0.014166  0.110000  0.010000
 5 2 4 142.645049  2 0.002553  0.051150  0.014166  0.110000  0.010000
 6 3 4 142.645049  2 0.002553  0.051150  0.014166  0.110000  0.010000
 7 0 2 142.645049  2 0.002553  0.051150  0.014166  0.110000  0.010000
 8 4 5 142.645049  2 0.002553  0.051150  0.014166  0.110000  0.010000"

TEST_SKYLINE_PATH =
[
  [0, 3, 4],
  [0, 3, 1, 5],
  [0, 4, 9],
  [2, 3, 7, 87],
  [6, 0, 1, 2]
]

TEST_SKYLINE_ATTR_ARRAY =
[
  [2, 6, 7, 8],
  [1, 9, 3, 5],
  [3, 4, 8, 7],
  [8, 3, 2, 1],
  [4, 2, 9, 3]
]

TEST_SKYLINE_ATTR_HASH =
{
  :a => [2, 6, 7, 8],
  :b => [1, 9, 3, 5],
  :c => [3, 4, 8, 7],
  :d => [8, 3, 2, 1],
  :e => [4, 2, 9, 3]
}

TEST_SKYLINE_ARRAY =
[
  [
    [:b, [1, 9, 3, 5]],
    [:a, [2, 6, 7, 8]],
    [:c, [3, 4, 8, 7]],
    [:e, [4, 2, 9, 3]],
    [:d, [8, 3, 2, 1]]
  ],
  [
    [:e, [4, 2, 9, 3]],
    [:d, [8, 3, 2, 1]],
    [:c, [3, 4, 8, 7]],
    [:a, [2, 6, 7, 8]],
    [:b, [1, 9, 3, 5]]
  ],
  [
    [:d, [8, 3, 2, 1]],
    [:b, [1, 9, 3, 5]],
    [:a, [2, 6, 7, 8]],
    [:c, [3, 4, 8, 7]],
    [:e, [4, 2, 9, 3]]
  ],
  [
    [:d, [8, 3, 2, 1]],
    [:e, [4, 2, 9, 3]],
    [:b, [1, 9, 3, 5]],
    [:c, [3, 4, 8, 7]],
    [:a, [2, 6, 7, 8]]
  ]
]

TEST_TWO_LAYER_ARRAY =
[
  ["2", "1", "7", "8", "6", "3"],
  ["1", "9", "2", "5", "3", "7"],
  ["3", "1", "8", "2", "3", "7"],
  ["8", "1", "2", "6", "7", "5"]
]

describe Graph do
  before(:each) do
    @graph = Graph.new(data: TEST_PATH_DATA, dim: 7, constrained_times: 1.3)
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

  describe "#combine_skyline" do
    it "should return a hash with key in path and its attribtes" do
      result_hash = @graph.combine_skyline(TEST_SKYLINE_PATH, TEST_SKYLINE_ATTR_ARRAY)
      expect(result_hash[:path_0_4_9]).to eq([3, 4, 8, 7])
      expect(result_hash[:path_6_0_1_2]).to eq([4, 2, 9, 3])
    end
  end

  describe "#sort_by_dim" do
    it "result must be sorted" do
      result = @graph.sort_by_dim(TEST_SKYLINE_ATTR_HASH)
      expect(result[0]).to eq([
        [:b, [1, 9, 3, 5]],
        [:a, [2, 6, 7, 8]],
        [:c, [3, 4, 8, 7]],
        [:e, [4, 2, 9, 3]],
        [:d, [8, 3, 2, 1]],
        ])
        # b a c d e
      expect(result[1]).to eq([
        [:e, [4, 2, 9, 3]],
        [:d, [8, 3, 2, 1]],
        [:c, [3, 4, 8, 7]],
        [:a, [2, 6, 7, 8]],
        [:b, [1, 9, 3, 5]],
        ])
        # e d c a b
      expect(result[2]).to eq([
        [:d, [8, 3, 2, 1]],
        [:b, [1, 9, 3, 5]],
        [:a, [2, 6, 7, 8]],
        [:c, [3, 4, 8, 7]],
        [:e, [4, 2, 9, 3]],
        ])
        # d b a c e
      expect(result[3]).to eq([
        [:d, [8, 3, 2, 1]],
        [:e, [4, 2, 9, 3]],
        [:b, [1, 9, 3, 5]],
        [:c, [3, 4, 8, 7]],
        [:a, [2, 6, 7, 8]],
        ])
        # d e b c  a
    end
  end

  describe "#get_skyline_path_set" do
    it "should get the paht" do
      result = @graph.get_skyline_path_set(TEST_SKYLINE_ARRAY)
      expect(result).to match_array([
          ["b", "a", "c", "e", "d"],
          ["e", "d", "c", "a", "b"],
          ["d", "b", "a", "c", "e"],
          ["d", "e", "b", "c", "a"]
        ])
    end
  end

  describe "#filter_array_top_k" do
    it "result are 1, 2 when top_k = 2" do
      result = @graph.filter_array_top_k(TEST_TWO_LAYER_ARRAY, 2)
      expect(result).to match_array(["1", "2"])
    end
  end


end
