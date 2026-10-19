# Sailthru Ruby Library

An [API client library](https://getstarted.sailthru.com/developers/api-client/libraries-overview/) that enables you to access the `Sailthru API` using Ruby.

For installation instructions, documentation, and examples please visit:
[https://getstarted.sailthru.com/developers/api-client/ruby/](https://getstarted.sailthru.com/developers/api-client/ruby/)

## Running tests

Install the development dependencies and run all checks:

```bash
bundle install
bundle exec rake verify
```

`verify` runs the existing Minitest suite and `test:package`. The package check
builds the gem through the existing Bundler build task, installs that gem and its
runtime dependencies in a temporary gem home, and loads it in a separate Ruby
process without the development bundle. It creates a client with fake credentials
and completes a POST request to a loopback HTTP server, checking request fields,
signature format, and response parsing. It does not contact the Sailthru API or
change customer data. The temporary installation is removed when the check exits.

To run only the unit tests, use `bundle exec rake test`. To run only the packaged
gem check, use `bundle exec rake test:package`. The built gem is left in `pkg/`;
`bundle exec rake clobber` removes it. These validation commands do not publish.

The existing `rake release` tasks run `verify` before their source-control push
and RubyGems publish steps. A direct `gem push` does not run Rake tasks; run
`bundle exec rake verify` first when using that publishing path.

The unit suite uses Mocha's Minitest integration and WebMock for HTTP stubs.
Unstubbed network requests are disabled during unit tests. The package smoke
check runs separately, without these mocks.

## Ruby compatibility checks

CI runs on Ruby 3.3, 3.4, and the latest stable MRI Ruby. The engine-only `ruby`
target in `ruby/setup-ruby` follows new stable releases without editing the
workflow. Early-access and `ruby-head` builds are not included. These are tested
runtime targets, rather than a guarantee for every older or future Ruby release.

The full checks run on pull requests, pushes to `master`, and weekly on Mondays
at 04:37 UTC. A manual run is also available. Schedules start after the workflow
is merged into the default branch. Maintainers should check that schedules remain
enabled: GitHub automatically disables scheduled workflows in public repositories
after 60 days without repository activity; see
[GitHub's schedule documentation](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#schedule).
