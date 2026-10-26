require 'minitest/autorun'
require 'minitest/pride'
require 'mocha/minitest'
require 'uri'
require 'json'
require 'webmock/minitest'

require 'sailthru'

WebMock.disable_net_connect!

class Minitest::Test

  include Sailthru::Helpers

  def setup
    WebMock.reset!
    @last_request_body = nil
  end

  def fixture_file(filename)
    return '' if filename == ''
    File.read(fixture_file_path(filename))
  end

  def fixture_file_path(filename)
    File.expand_path(File.dirname(__FILE__) + '/fixtures/' + filename)
  end

  def sailthru_api_base_url(url)
    url
  end

  def sailthru_api_call_url(url, action)
    url += '/' if !url.end_with?('/')
    sailthru_api_base_url(url + action)
  end

  def stub_get(url, filename, headers={})
    stub_request(:get, url).to_return(:body => fixture_file(filename),
      :headers => response_headers(headers))
  end

  def stub_delete(url, filename, headers={})
    stub_request(:delete, url).to_return(:body => fixture_file(filename),
      :headers => response_headers(headers))
  end

  def stub_post(url, filename, headers={})
    response = { :body => fixture_file(filename), :headers => response_headers(headers) }
    stub_request(:post, url).to_return do |request|
      @last_request_body = request.body
      response
    end
  end

  def stub_exception(url, filename)
    stub_request(:any, url).to_raise(StandardError.new('simulated network failure'))
  end

  def response_headers(headers)
    normalized = headers.each_with_object({}) do |(name, value), result|
      result[name.to_s.tr('_', '-')] = value.to_s
    end
    { 'Content-Type' => 'application/json' }.merge(normalized)
  end

  def form_parameters(body)
    URI.decode_www_form(body).each_with_object({}) do |(name, value), params|
      (params[name] ||= []) << value
    end
  end

  def create_query_string(secret, params)
    params['sig'] = get_signature_hash(params, secret)
    params.map{ |key, value| "#{CGI::escape(key.to_s)}=#{CGI::escape(value.to_s)}" }.join("&")
  end

  def create_json_payload(api_key, secret, params)
      data = {}
      data['api_key'] = api_key
      data['format'] = 'json'
      data['json'] = params.to_json
      data['sig'] = get_signature_hash(data, secret)
      data.map{ |key, value| "#{CGI::escape(key.to_s)}=#{CGI::escape(value.to_s)}" }.join("&")
  end

  def get_rate_info_headers(limit, remaining, reset)
      {
              :x_rate_limit_limit => limit,
              :x_rate_limit_remaining => remaining,
              :x_rate_limit_reset => reset
      }
  end

end
