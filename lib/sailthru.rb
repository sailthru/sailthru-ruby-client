require 'sailthru/version'
require 'sailthru/client'

module Sailthru
  class ClientError < StandardError
  end

  class UnavailableError < StandardError
  end

  # Provides a global place to configure the credentials for an application.
  # For instance, in your Rails app, create +config/initializers/sailthru.rb+
  # and place this line in it:
  #
  #     Sailthru.credentials('apikey', 'secret')
  #
  # Now you can create a client instance easily via Sailthru::Client.new
  #
  def self.credentials(api_key, secret)
    @api_key = api_key
    @secret = secret
  end

  def self.api_key
    @api_key
  end

  def self.secret
    @secret
  end
end
