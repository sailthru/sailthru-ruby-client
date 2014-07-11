require 'test_helper'

class HelpersTest < Minitest::Test
  describe "Helper tests" do
    it "converts simple hash to array" do
      expected_array = ["xyz", "my_secret", "my template"].sort
      simple_hash = {'api_key'=> expected_array[0], 'secret'=> expected_array[1], 'template'=> expected_array[2]}
      converted_array = extract_param_values(simple_hash).sort
      assert_equal converted_array[0], expected_array[0]
      assert_equal converted_array[1], expected_array[1]
      assert_equal converted_array[2], expected_array[2]
      assert_equal converted_array.length, expected_array.length
    end

    it "converts nested hash to array" do
      nested_hash = {"name" => "Unix",  "myvar" => [1111, 2], "api_key" => "363636avdsfdfd", "myvar2" => {"myvar3" => "hello", "myvar4" => ["hello", "world"]}}
      expected_array = ["Unix", "1111", "2", "363636avdsfdfd", "hello", "hello", "world"].sort
      converted_array = extract_param_values(nested_hash).sort
      assert((expected_array == converted_array))
    end

    it "converts nested custom hash to array" do
      class CustomHash < Hash; end
      h = CustomHash[{"Hash" => "Regular Hash", "HashWithIndifferentAccess" => "Hash accessible by strings or symbols"}]
      nested_hash = {"framework" => "Rails", "hash_types" => h}
      expected_array = ["Rails", "Regular Hash", "Hash accessible by strings or symbols"].sort
      assert_equal expected_array, extract_param_values(nested_hash).sort
    end

  end
end
