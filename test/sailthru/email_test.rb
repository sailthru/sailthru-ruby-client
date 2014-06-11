require 'test_helper'

class EmailTest < Minitest::Test
  describe "API Call: email" do
    before do
      api_url = 'http://api.sailthru.com'
      @api_key = 'my_api_key'
      @secret = 'my_secret'
      @sailthru_client = Sailthru::SailthruClient.new(@api_key, @secret, api_url)
      @api_call_url = sailthru_api_call_url(api_url, 'email')
    end

    it "can get email information for one of the client's user" do
      email = 'praj@sailthru.com'
      params = {'email' => email}
      query_string = create_json_payload(@api_key, @secret, params)
      stub_get(@api_call_url + '?' + query_string, 'email_get_listed_email.json')
      response = @sailthru_client.get_email(email)
      refute_nil response['verified']
      assert_equal email, response['email']
    end
  end
end
