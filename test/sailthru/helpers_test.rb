$:.unshift File.join(File.dirname(__FILE__),'..')
require 'test_helper'

class HelpersTest < Test::Unit::TestCase
  context "Helper tests" do
    should "convert simple hash to array" do
      expected_array = ["xyz", "my_secret", "my template"].sort
      simple_hash = {'api_key'=> expected_array[0], 'secret'=> expected_array[1], 'template'=> expected_array[2]}
      converted_array = extract_param_values(simple_hash).sort
      assert_equal converted_array[0], expected_array[0]
      assert_equal converted_array[1], expected_array[1]
      assert_equal converted_array[2], expected_array[2]
      assert_equal converted_array.length, expected_array.length
    end

    should "convert nested hash to array" do
      nested_hash = {"name" => "Unix",  "myvar" => [1111, 2], "api_key" => "363636avdsfdfd", "myvar2" => {"myvar3" => "hello", "myvar4" => ["hello", "world"]}}
      expected_array = ["Unix", "1111", "2", "363636avdsfdfd", "hello", "hello", "world"].sort
      converted_array = extract_param_values(nested_hash).sort
      assert((expected_array == converted_array))
    end

    should "return false when verify purchase items is not of type non empty Array" do
      assert_equal false, verify_purchase_items({}), "hash type"
      assert_equal false, verify_purchase_items(1), "interger type"
      assert_equal false, verify_purchase_items([]), "empty array"
    end

    should "return false when verify purchase item field hash does not include all of qty, title, price, if, url" do
      items = [{"price"=>1099, "title"=>"High-Impact Water Bottle", "url"=>"http://example.com/234/high-impact-water-bottle", "id"=>"234"}, {"price"=>500, "qty"=>2, "title"=>"Lorem Ispum", "url"=>"http://example.com/2304/lorem-ispum", "id"=>"2304"}]
      assert_equal false, verify_purchase_items(items), 'first hash item does not include qty field'

      [{"price"=>1099, "title"=>"High-Impact Water Bottle", "url"=>"http://example.com/234/high-impact-water-bottle", "id"=>"234"}, {"price"=>500, "qty"=>2, "title"=>"Lorem Ispum", "url"=>"http://example.com/2304/lorem-ispum"}]
      assert_equal false, verify_purchase_items(items), 'first hash item does not include qty field while 2nd hash does not include id field'
    end

    should "return true when verify purchase item field hash include all of qty, title, price, if, url" do
      multiple_items = [{"price"=>1099, "qty"=>22, "title"=>"High-Impact Water Bottle", "url"=>"http://example.com/234/high-impact-water-bottle", "id"=>"234"}, {"price"=>500, "qty"=>2, "title"=>"Lorem Ispum", "url"=>"http://example.com/2304/lorem-ispum", "id"=>"2304"}]
      assert_equal true, verify_purchase_items(multiple_items)

      single_items = [{"price"=>1099, "qty"=>22, "title"=>"High-Impact Water Bottle", "url"=>"http://example.com/234/high-impact-water-bottle", "id"=>"234"}]
      assert_equal true, verify_purchase_items(single_items)
    end
  end
end