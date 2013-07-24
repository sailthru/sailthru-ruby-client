$:.unshift File.join(File.dirname(__FILE__),'..')
require 'test_helper'

class ErrorTest < Test::Unit::TestCase
  context "Server is misbehaving" do
    setup do
      api_url = 'http://api.sailthru.com'
      @secret = 'my_secret'
      @api_key = 'my_api_key'
      @sailthru_client = Sailthru::SailthruClient.new(@api_key, @secret, api_url)
      @api_call_url = sailthru_api_call_url(api_url, 'blast')
    end

    should "raise an error when server misbehaves" do
      stub_exception(@api_call_url, 'blast_post_update_valid.json')
      assert_raise Sailthru::SailthruClientException do
        @sailthru_client.cancel_blast(123)
      end
    end

    should "show the true origin of the exception" do
      stub_exception(@api_call_url, 'blast_post_update_valid.json')
      begin
        @sailthru_client.cancel_blast(123)
      rescue Exception => e
        assert(e.message =~ /Exception from FakeWeb/)
      end
    end
  end
end

