require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'uri'

gem 'fakeweb', ">= 1.2.6"
require 'fakeweb'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'sailthru'

FakeWeb.allow_net_connect = false

class Test::Unit::TestCase

  include Sailthru::Helpers

  def setup
    FakeWeb.clean_registry
  end

  def fixture_file(filename)
    return '' if filename == ''
    file_path = File.expand_path(File.dirname(__FILE__) + '/fixtures/' + filename)
    File.read(file_path)
  end

  def sailthru_api_base_url(url)
    url
  end

  def sailthru_api_call_url(url, action)
    url += '/' if !url.end_with?('/')
    sailthru_api_base_url(url + action)
  end

  def stub_get(url, filename)
    options = { :body => fixture_file(filename), :content_type => 'application/json' }
    FakeWeb.register_uri(:get, URI.parse(url), options)
  end

  def stub_delete(url, filename)
    options = { :body => fixture_file(filename), :content_type => 'application/json' }
    FakeWeb.register_uri(:delete, URI.parse(url), options)
  end

  def stub_post(url, filename)
    FakeWeb.register_uri(:post, URI.parse(url), :body => fixture_file(filename), :content_type => 'application/json')
  end

  def create_query_string(secret, params)
    params['sig'] = get_signature_hash(params, secret)
    params.map{ |key, value| "#{CGI::escape(key.to_s)}=#{CGI::escape(value.to_s)}" }.join("&")
  end
end