$:.unshift File.join(File.dirname(__FILE__),'..')
require 'test_helper'

class BlastTest < Test::Unit::TestCase

  include Sailthru::Helpers

  context "API Call: blast" do
    setup do
      api_url = 'http://api.sailthru.com'
      @secret = 'my_secret'
      @api_key = 'my_api_key'
      @sailthru_client = Sailthru::SailthruClient.new(@api_key, @secret, api_url)
      @api_call_url = sailthru_api_call_url(api_url, 'blast')
    end

    should "be able to get the status of a blast when blast_id is valid" do
      valid_blast_id = '665215'
      params = {'format' => 'json', 'api_key' => @api_key, 'blast_id' => valid_blast_id}
      query_string = create_query_string(@secret, params)
      stub_get(@api_call_url + '?' + query_string, 'blast_get_valid.json')
      response = @sailthru_client.get_blast(valid_blast_id)
      assert_not_nil response['name']
      assert_equal valid_blast_id, response['blast_id'].to_s
    end

    should "be able to get blast error message when blast_id is invalid" do
      invalid_blast_id = '88787'
      params = {'format' => 'json', 'api_key' => @api_key, 'blast_id' => invalid_blast_id}
      query_string = create_query_string(@secret, params)
      stub_get(@api_call_url + '?' + query_string, 'blast_get_invalid.json')
      response =  @sailthru_client.get_blast(invalid_blast_id)      
      assert_not_nil response['error']
      assert_not_nil response['errormsg']
    end
  end
end
