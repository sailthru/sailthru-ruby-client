# Sailthru Ruby Library

An [API client library](https://getstarted.sailthru.com/developers/api-client/libraries-overview/) that enables you to access the `Sailthru API` using Ruby.

For installation instructions, documentation, and examples please visit:
[https://getstarted.sailthru.com/developers/api-client/ruby/](https://getstarted.sailthru.com/developers/api-client/ruby/)

## Running tests

```bash
bundle install
bundle exec rake verify
```

`verify` runs unit tests and installs the built gem in a temporary consumer for a
local request with dummy credentials. Use `bundle exec rake test` for unit tests
only, or `bundle exec rake test:package` for the package check. These commands do
not publish; the existing Rake release tasks run `verify` before publishing.

CI tests Ruby 3.3, 3.4, and the latest stable MRI Ruby on PRs, pushes to `master`,
weekly, and manual runs. These are tested targets, not a guarantee for all runtimes.
