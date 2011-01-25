$:.unshift File.join(File.dirname(__FILE__),'..')
require 'test_helper'

class StatsTest < Test::Unit::TestCase
  context "API Call: stats" do
    setup do
      api_url = 'http://api.sailthru.com'
      @secret = 'my_secret'
      @api_key = 'my_api_key'
      @sailthru_client = Sailthru::SailthruClient.new(@api_key, @secret, api_url)
      @api_call_url = sailthru_api_call_url(api_url, 'stats')
    end

    should "be able to get information about given valid field" do
      stat_field = 'list'
      params = {'format' => 'json', 'api_key' => @api_key, 'stat' => stat_field}
      query_string = create_query_string(@secret, params)
      stub_get(@api_call_url + '?' + query_string, 'stat_get_valid.json')
      response = @sailthru_client.get_stats(stat_field)
      assert_nil response['error']
      assert_nil response['errormsg']
    end

    should "not be able to get information about given field when it's invalid" do
      stat_field = 'invalid_field'
      params = {'format' => 'json', 'api_key' => @api_key, 'stat' => stat_field}
      query_string = create_query_string(@secret, params)
      stub_get(@api_call_url + '?' + query_string, 'stat_get_invalid.json')
      response = @sailthru_client.get_stats(stat_field)
      assert_not_nil response['error']
      assert_not_nil response['errormsg']
    end
  end
end
