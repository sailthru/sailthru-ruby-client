$:.unshift File.join(File.dirname(__FILE__),'..')
require 'test_helper'

class PurchaseTest < Test::Unit::TestCase
  context "API Call: purchase" do
    setup do
      api_url = 'http://api.sailthru.com'
      @sailthru_client = Sailthru::SailthruClient.new("my_api_key", "my_secret", api_url)
      @api_call_url = sailthru_api_call_url(api_url, 'purchase')
    end

    should "be able to post purchase items with valid email and single items array" do
      email = 'praj@sailthru.com'
      item_price1 = 1099
      item_qty1 = 22
      total_price = item_price1 * item_qty1
      total_qty = 22
      items = [{'qty' => item_qty1, 'title' => 'High-Impact Water Bottle', 'price' => item_price1, 'id' => '234', 'url' => 'http://example.com/234/high-impact-water-bottle'}]
      stub_post(@api_call_url, 'purchase_post_valid_single_item.json')
      response = @sailthru_client.purchase(email, items)
      assert_equal total_price, response['purchase']['price']
      assert_equal total_qty, response['purchase']['qty']
    end

    should "be able to post purchase items with valid email and multiple items array" do
      email = 'praj@sailthru.com'
      items = []

      item_price1 = 1099
      item_qty1 = 22
      items.push({'qty' => item_qty1, 'title' => 'High-Impact Water Bottle', 'price' => item_price1, 'id' => '234', 'url' => 'http://example.com/234/high-impact-water-bottle'})

      item_price2 = 500
      item_qty2 = 2
      items.push({'qty' => item_qty2, 'title' => 'Lorem Ispum', 'price' => item_price2, 'id' => '2304', 'url' => 'http://example.com/2304/lorem-ispum'})

      total_qty = 0
      total_price = 0
      items.each do |v|
        total_price += v['price'] * v['qty']
        total_qty += v['qty']
      end
      
      stub_post(@api_call_url, 'purchase_post_valid_multiple_items.json')
      response = @sailthru_client.purchase(email, items)
      assert_equal total_price, response['purchase']['price']
      assert_equal total_qty, response['purchase']['qty']
    end

    should "not be able to post purchase items with empty items array" do
      email = 'praj@sailthru.com'
      item_price1 = 1099
      item_qty1 = 22
      total_price = 1099 * 22
      total_qty = 22
      items = [{'qty' => '22', 'title' => 'High-Impact Water Bottle', 'price' => '1099', 'id' => '234', 'url' => 'http://example.com/234/high-impact-water-bottle'}]
      stub_post(@api_call_url, 'purchase_post_invalid_empty_items.json')
      response = @sailthru_client.purchase(email, items)
      assert_not_nil response['errormsg']
      assert_not_nil response['error']
    end

    should "not be able to post purchase items with invalid email" do
      invalid_email = 'prajsailthru.com'
      item_price1 = 1099
      item_qty1 = 22
      total_price = 1099 * 22
      total_qty = 22
      items = [{'qty' => '22', 'title' => 'High-Impact Water Bottle', 'price' => '1099', 'id' => '234', 'url' => 'http://example.com/234/high-impact-water-bottle'}]
      stub_post(@api_call_url, 'purchase_post_invalid_email.json')
      response = @sailthru_client.purchase(invalid_email, items)
      assert_not_nil response['errormsg']
      assert_not_nil response['error']
    end
  end
  end