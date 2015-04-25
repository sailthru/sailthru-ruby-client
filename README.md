# sailthru-ruby-client

For installation instructions, documentation, and examples please visit:
[http://getstarted.sailthru.com/new-for-developers-overview/api-client-library/ruby-gem](http://getstarted.sailthru.com/new-for-developers-overview/api-client-library/ruby-gem/)

A simple client library to remotely access the `Sailthru REST API` as per [http://getstarted.sailthru.com/api](http://getstarted.sailthru.com/api)

By default, it will make requests in `JSON` format.

## Installation

    $ gem install sailthru-client

## Requirements

This gem supports Ruby 1.9.3 and up.

## Optional parameters for connection/read timeout settings

Increase timeout from 10 (default) to 30 seconds.

   sailthru = Sailthru::Client.new("api-key", "api-secret", "https://api.sailthru.com", nil, nil, 
			          {:http_read_timeout => 30, :http_ssl_timeout => 30, :http_open_timeout => 30})


## License

Please see MIT-LICENSE for license.
