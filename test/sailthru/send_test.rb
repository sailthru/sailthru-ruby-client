$:.unshift File.join(File.dirname(__FILE__),'..')
require 'test_helper'

class SendTest < Test::Unit::TestCase
  context "API Call: send" do
    setup do
      api_url = 'http://api.sailthru.com'
      @sailthru_client = SailthruClient.new("my_api_key", "my_secret", api_url)
      @api_call_url = sailthru_api_call_url(api_url, 'send')
    end

    should "be able to get the status of a send when send_id is valid" do
      valid_send_id = "TT1ClGdj2bRHAAP6"
      stub_get(@api_call_url + '?format=json&send_id=' + valid_send_id + '&api_key=my_api_key&sig=f63a4fae823eb683ece4bae3b2d4eb2c', 'send_get_valid.json')
      response = @sailthru_client.get_send(valid_send_id)
      assert_equal valid_send_id, response['send_id']
    end

    should "be able to get send error message when send_id is invalid" do
      invalid_send_id = "aaaaTT1ClGdj2bRHAAP6"
      stub_get(@api_call_url + '?format=json&send_id=' + invalid_send_id + '&api_key=my_api_key&sig=bf14b806c8da5f80263bab6e6a848f1e', 'send_get_invalid.json')
      response = @sailthru_client.get_send(invalid_send_id)
      assert_equal 12, response['error']
    end

    should "be able to post send with valid template name and email" do
      template_name = 'default'
      email = 'example@example.com'
      stub_post(@api_call_url, 'send_get_valid.json')
      response = @sailthru_client.send template_name, email, {"name" => "Unix",  "myvar" => [1111,2,3], "mycomplexvar" => {"tags" => ["obama", "aaa", "c"]}}
      assert_equal template_name, response['template']
    end

    should "be able to post send with invalid template name and/or email" do
      template_name = 'invalid-template'
      email = 'example@example.com'
      stub_post(@api_call_url, 'send_post_invalid.json')
      response = @sailthru_client.send template_name, email, {"name" => "Unix",  "myvar" => [1111,2,3], "mycomplexvar" => {"tags" => ["obama", "aaa", "c"]}}
      assert_equal 14, response['error']
    end
  end
end