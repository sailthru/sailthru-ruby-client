$:.unshift File.join(File.dirname(__FILE__),'..')
require 'test_helper'

class EmailTest < Test::Unit::TestCase
  context "API Call: email" do
    setup do
      api_url = 'http://api.sailthru.com'
      @api_key = 'my_api_key'
      @secret = 'my_secret'
      @sailthru_client = Sailthru::SailthruClient.new(@api_key, @secret, api_url)
      @api_call_url = sailthru_api_call_url(api_url, 'email')
    end

    should "be able to get email information for one of the client's user" do
      email = 'praj@sailthru.com'
      params = {'format' => 'json', 'api_key' => @api_key, 'sig' => '', 'email' => email}
      query_string = create_query_string(@secret, params)
      stub_get(@api_call_url + '?' + query_string, 'email_get_listed_email.json')
      response = @sailthru_client.get_email(email)
      assert_not_nil response['verified']
      assert_equal email, response['email']
    end
  end
end