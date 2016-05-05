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

```ruby
sailthru = Sailthru::Client.new("api-key", "api-secret", "https://api.sailthru.com", nil, nil, 
			          {:http_read_timeout => 30, :http_ssl_timeout => 30, :http_open_timeout => 30})
```

## Rate Limit Information

The library allows inspection of the 'X-Rate-Limit-*' headers returned by the Sailthru API. The `get_last_rate_limit_info(endpoint, method)` function allows you to retrieve the last known rate limit information for the given endpoint / method combination. It must follow an API call. For example, if you do a `/send POST`, you can follow up with a call to `get_last_rate_limit_info(:send, :post)` as shown below:

``` ruby
# make API call as normal
response = sailthru.send_email template_name, email, {foo: "bar"}

# check rate limit information
rate_limit_info = sailthru.get_last_rate_limit_info :send, :post
```

The return type will be `nil` if there is no rate limit information for the given endpoint / method combination (e.g. if you have not yet made a request to that endpoint). Otherwise, it will be a hash in the following format:

``` ruby
{
    limit: 1234, # <Number representing the limit of requests/minute for this action / method combination>
    remaining: 1230, # <Number representing how many requests remain in the current minute>
    reset: 1459381680 # <Number representing the UNIX epoch timestamp of when the next minute starts, and when the rate limit resets>
}
```

## License

Please see MIT-LICENSE for license.
