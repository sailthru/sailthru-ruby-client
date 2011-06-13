$:.unshift File.join(File.dirname(__FILE__),'..')
require 'test_helper'

class ListTest < Test::Unit::TestCase
  context "API Call: list" do
    setup do
       api_url = 'http://api.sailthru.com'
      @secret = 'my_secret'
      @api_key = 'my_api_key'
      @sailthru_client = Sailthru::SailthruClient.new(@api_key, @secret, api_url)
      @api_call_url = sailthru_api_call_url(api_url, 'list')
    end

    should "be able to get list data in text format when list is valid" do
      list = 'listname'
      format = 'txt'
      params = {'format' => format, 'api_key' => @api_key, 'list' => list}
      query_string = create_query_string(@secret, params)
      stub_get(@api_call_url + '?' + query_string, 'list_get_valid.txt')
      response = @sailthru_client.get_list(list, format)
      line_count = response.split("\n").length
      assert(line_count == 3)
    end

    should "get empty response for invalid list in text format" do
      list = 'invalidlistname'
      format = 'txt'
      params = {'format' => format, 'api_key' => @api_key, 'list' => list}
      query_string = create_query_string(@secret, params)
      stub_get(@api_call_url + '?' + query_string, 'list_get_invalid.txt')
      response = @sailthru_client.get_list(list, format)
      assert(response.split("\s").length == 0)
    end

    should "be able to get list data in json format when list is valid" do
      list = 'listname'
      format = 'json'
      params = {:list => list, :format => format}
      query_string = create_json_payload(@api_key, @secret, params)
      stub_get(@api_call_url + '?' + query_string, 'list_get_valid.json')
      response = @sailthru_client.get_list(list, format)
      assert(response['result'].length == 3)
    end

    should "get empty response for invalid list in json format" do
      list = 'invalidlistname'
      format = 'json'
      params = {:list => list, :format => 'json'} 
      query_string = create_json_payload(@api_key, @secret, params)
      stub_get(@api_call_url + '?' + query_string, 'list_get_invalid.json')
      response = @sailthru_client.get_list(list, format)
      assert_not_nil response['errormsg']
      assert_not_nil response['error']
    end

    should "be able to save list with given emails array" do
      emails = ['praj@sailthru.com', 'ian@sailtru.com']
      list = 'my-list'
      stub_post(@api_call_url, 'list_save_valid.json')
      response = @sailthru_client.save_list(list, emails)
      assert_equal(emails.length, response['email_count'])
      assert_equal(list, response['list'])
    end

    should "not be able to delete invalid list" do
      list = 'invalid-list'
      params = {'list' => list}
      query_string = create_json_payload(@api_key, @secret, params)
      stub_delete(@api_call_url + '?' + query_string, 'list_delete_invalid.json')
      response = @sailthru_client.delete_list(list)
      assert_not_nil response['error']
    end

    should "be able to delete invalid list" do
      list = 'my-list'
      params = {:list => list}
      query_string = create_json_payload(@api_key, @secret, params)
      stub_delete(@api_call_url + '?' + query_string, 'list_delete_valid.json')
      response = @sailthru_client.delete_list(list)
      assert_equal(list, response['list'])
    end
  end
end
