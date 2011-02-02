$:.unshift File.join(File.dirname(__FILE__),'..')
require 'test_helper'

class ContentTest < Test::Unit::TestCase
  context "API Call: content" do
    setup do
      api_url = 'http://api.sailthru.com'
      @secret = 'my_secret'
      @api_key = 'my_api_key'
      @sailthru_client = Sailthru::SailthruClient.new(@api_key, @secret, api_url)
      @api_call_url = sailthru_api_call_url(api_url, 'content')
    end

    should "be able to push content with title, url, *array* tags and vars" do
      title = 'unix is awesome'
      url = 'http://example.com/hello-world'
      date = nil
      tags = ['unix', 'linux']
      vars = {:price => 55, :description => 'Hello World'}
      stub_post(@api_call_url, 'content_valid.json')
      response = @sailthru_client.push_content(title, url, date = nil, tags = tags, vars = vars)
      assert_not_nil response['content']
    end

    should "be able to push content with title, url, *string* tags and vars" do
      title = 'unix is awesome'
      url = 'http://example.com/hello-world'
      date = nil
      tags = 'unix, linux'
      vars = {:price => 55, :description => 'Hello World'}
      stub_post(@api_call_url, 'content_valid.json')
      response = @sailthru_client.push_content(title, url, date = nil, tags = tags, vars = vars)
      assert_not_nil response['content']
    end

  end
end