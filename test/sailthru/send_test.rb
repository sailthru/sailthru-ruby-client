$:.unshift File.join(File.dirname(__FILE__),'..')
require 'test_helper'

class SendTest < Test::Unit::TestCase
  context "API Call: send" do
    setup do
      api_url = 'http://api.sailthru.com'
      @secret = 'my_secret'
      @api_key = 'my_api_key'
      @sailthru_client = Sailthru::SailthruClient.new("my_api_key", "my_secret", api_url)
      @api_call_url = sailthru_api_call_url(api_url, 'send')
    end

    should "be able to get the status of a send when send_id is valid" do
      valid_send_id = "TT1ClGdj2bRHAAP6"
      #query_string = create_json_payload(@api_key, @secret, {:send_id => valid_send_id})
      params = {
        'send_id' => valid_send_id
      }
      query_string = create_json_payload(@api_key, @secret, params)
      stub_get(@api_call_url + '?' + query_string , 'send_get_valid.json')
      response = @sailthru_client.get_send(valid_send_id)
      assert_equal valid_send_id, response['send_id']
    end

    should "be able to get send error message when send_id is invalid" do
      invalid_send_id = "aaaaTT1ClGdj2bRHAAP6"
      query_string = create_json_payload(@api_key, @secret, {'send_id' => invalid_send_id})
      stub_get(@api_call_url + '?' + query_string, 'send_get_invalid.json')
      response = @sailthru_client.get_send(invalid_send_id)
      assert_equal 12, response['error']
    end

    should "be able to post send with valid template name and email using deprecated 'send' method" do
      template_name = 'default'
      email = 'example@example.com'
      stub_post(@api_call_url, 'send_get_valid.json')
      response = @sailthru_client.send template_name, email, {"name" => "Unix",  "myvar" => [1111,2,3], "mycomplexvar" => {"tags" => ["obama", "aaa", "c"]}}
      assert_equal template_name, response['template']
    end

    should "not be able to post send with invalid template name and/or email using deprecated 'send' method" do
      template_name = 'invalid-template'
      email = 'example@example.com'
      stub_post(@api_call_url, 'send_post_invalid.json')
      response = @sailthru_client.send template_name, email, {"name" => "Unix",  "myvar" => [1111,2,3], "mycomplexvar" => {"tags" => ["obama", "aaa", "c"]}}
      assert_equal 14, response['error']
    end

    should "be able to post send with valid template name and email" do
      template_name = 'default'
      email = 'example@example.com'
      stub_post(@api_call_url, 'send_get_valid.json')
      response = @sailthru_client.send_email template_name, email, {"name" => "Unix",  "myvar" => [1111,2,3], "mycomplexvar" => {"tags" => ["obama", "aaa", "c"]}}
      assert_equal template_name, response['template']
    end

    should "not be able to post send with invalid template name and/or email" do
      template_name = 'invalid-template'
      email = 'example@example.com'
      stub_post(@api_call_url, 'send_post_invalid.json')
      response = @sailthru_client.send_email template_name, email, {"name" => "Unix",  "myvar" => [1111,2,3], "mycomplexvar" => {"tags" => ["obama", "aaa", "c"]}}
      assert_equal 14, response['error']
    end

    should "be able to send multiple emails with valid template" do
      template_name = 'default'
      emails = 'example@example.com, example3@example.com'
      stub_post(@api_call_url, 'send_post_multiple_valid.json')
      response = @sailthru_client.multi_send(template_name, emails)
      assert_equal 2, response['sent_count']
    end

    should "be able to cancel scheduled send" do
      send_id = 'TT4gSGdj2Z17AAGb'
      query_string = create_json_payload(@api_key, @secret, {'send_id' => send_id})
      stub_delete(@api_call_url + '?' + query_string, 'send_cancel.json')
      response = @sailthru_client.cancel_send(send_id)
      assert_equal response['send_id'], send_id
    end
  end
end
