require 'test_helper'

class JobTest < Minitest::Test
  describe "API Call: job" do
    before do
      api_url = 'http://api.sailthru.com'
      @secret = 'my_secret'
      @api_key = 'my_api_key'
      @sailthru_client = Sailthru::Client.new(@api_key, @secret, api_url)
      @api_call_url = sailthru_api_call_url(api_url, 'job')
    end

    it "can create or update content from a JSON file" do
      file_path = fixture_file_path('job_content_update_file.json')
      stub_post(@api_call_url, 'job_content_update_post_valid.json')
      response = @sailthru_client.process_job('content_update', { 'file' => file_path }, nil, nil, 'file')
      assert_equal 'Content Update', response['name']
      assert_equal 'pending', response['status']
    end
  end
end
