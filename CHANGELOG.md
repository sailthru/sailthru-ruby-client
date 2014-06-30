## 4.0.1 (Jun 27, 2014)
  - Bug fix for https://github.com/sailthru/sailthru-ruby-client/pull/48

## 4.0.0 (Jun 17, 2014)
  - Rename Sailthru::SailthruClient to Sailthru::Client
  - Rework custom exceptions to be StandardErrors
  - Add `Sailthru.credentials` for easy initialization in Rails apps
  - Split sailthru.rb into several smaller files

## 3.0.0 (Jun 16, 2014)
  - Remove Ruby 1.8.7 support.

## 2.0.0 (Sep 6, 2013)
  - Added triggers and events
  - Changed push_content to handle additional parameters
  - Added verification for postbacks
  - Removed Horizon calls
  - Remvoed create_new_user method
  - Added change_email method
  - Added stats_send method

## 1.14 (Feb 10, 2012)
  - Remove contact API call
  - Update list API call: save_list() cannot be used for saving emails
  - Added get_lists() for retrieving all available lists information

## 1.13 (September 8, 2011)
  - Explicitly convert Exception to string for Ruby 1.9 (Robert Coker)
  - Update purchase() call


## 1.12 (July 22, 2011)
  - Fix send / multisend api call bug

## 1.11 (June 15, 2011)
  - Job API docs
  - SSL verification disabled
  - Typed variable values can be passed now

## 1.10 (May 14, 2011)
 - Support for Job API call
 - Support for typed parameters
 - By default, make request to https://api.sailthru.com so, default constructor call would be Sailthru::SailthruClient.new("api-key", "api_secret")
