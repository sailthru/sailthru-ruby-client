require 'test_helper'

class ErrorTest < Minitest::Test
  describe "Server is misbehaving" do
    before do
      api_url = 'http://api.sailthru.com'
      @secret = 'my_secret'
      @api_key = 'my_api_key'
      @sailthru_client = Sailthru::Client.new(@api_key, @secret, api_url)
      @api_call_url = sailthru_api_call_url(api_url, 'blast')
    end

    it "raises an error when server misbehaves" do
      stub_exception(@api_call_url, 'blast_post_update_valid.json')
      assert_raises Sailthru::ClientError do
        @sailthru_client.cancel_blast(123)
      end
    end

    it "shows the true origin of the exception" do
      stub_exception(@api_call_url, 'blast_post_update_valid.json')
      error = assert_raises(Sailthru::ClientError) do
        @sailthru_client.cancel_blast(123)
      end
      assert_match /simulated network failure/, error.message
      assert_match /simulated network failure/, error.cause.message
    end
  end
end

