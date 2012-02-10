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
      params = {'stat' => stat_field}
      query_string = create_json_payload(@api_key, @secret, params)
      stub_get(@api_call_url + '?' + query_string, 'stat_get_valid.json')
      response = @sailthru_client.get_stats(stat_field)
      assert_nil response['error']
      assert_nil response['errormsg']
    end

    should "not be able to get information about given field when it's invalid" do
      stat_field = 'invalid_field'
      params = {'stat' => stat_field}
      query_string = create_json_payload(@api_key, @secret, params)
      stub_get(@api_call_url + '?' + query_string, 'stat_get_invalid.json')
      response = @sailthru_client.get_stats(stat_field)
      assert_not_nil response['error']
      assert_not_nil response['errormsg']
    end

    should "be able to get stats list data when list and date are not null" do
      params = {'stat' => 'list'}
      query_string = create_json_payload(@api_key, @secret, params)
      stub_get(@api_call_url + '?' + query_string, 'stats_lists_valid.json')
      response = @sailthru_client.stats_list()
      assert_not_nil response['lists_signup_count']
    end

    should "not be able to stats list data when list is given and invalid" do
      list = 'not-listed'
      params = {}
      params[:stat] = 'list'
      params[:list] = list
      query_string = create_json_payload(@api_key, @secret, params)
      stub_get(@api_call_url + '?' + query_string, 'stats_lists_invalid.json')
      response = @sailthru_client.stats_list(list)
      assert_not_nil response['error']
      assert_not_nil response['errormsg']
    end
  end
end
