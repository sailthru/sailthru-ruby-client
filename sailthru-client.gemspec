# -*- encoding: utf-8 -*-
require File.expand_path('../lib/sailthru/version', __FILE__)
require 'date'

Gem::Specification.new do |s|
  s.name = "sailthru-client"
  s.version = Sailthru::VERSION

  s.authors = ["Prajwal Tuladhar", "Dennis Yu", "George Liao"]
  s.date = Date.today.to_s
  s.email = "gliao@sailthru.com"
  s.extra_rdoc_files = ["README.md"]
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- test/*`.split("\n")
  s.homepage = "http://docs.sailthru.com"
  s.rdoc_options = ["--main", "README.md"]
  s.require_paths = ["lib"]
  s.summary = "A simple client library to remotely access the Sailthru REST API. "
  s.license = "MIT"

  s.add_dependency(%q<json>, [">= 0"])
  s.add_dependency(%q<multipart-post>, [">= 0"])
  s.add_development_dependency(%q<rake>, [">= 0"])
  s.add_development_dependency(%q<fakeweb>, [">= 0"])
  s.add_development_dependency(%q<minitest>, [">= 5"])
  s.add_development_dependency(%q<mocha>, [">= 0"])
end
