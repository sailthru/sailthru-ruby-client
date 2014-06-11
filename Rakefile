require "rdoc/task"
require 'rake/testtask'

task :default => :test

desc "Run the test suite"
Rake::TestTask.new do |t|
  t.libs = [File.expand_path("lib"), "test"]
  t.test_files = FileList["test/**/*_test.rb"]
end


Rake::RDocTask.new do |rd|
  rd.main = "README.md"
  rd.rdoc_files.include("README.md", "lib/**/*.rb")
  rd.rdoc_dir = "rdoc"
end

desc 'Clear out RDoc and generated packages'
task :clean do
  rm_rf "rdoc"
end

desc "Publish gem to rubygems.org"
task :publish do
  require File.join(File.dirname(__FILE__), 'lib', 'sailthru')
  sh "gem build sailthru-client.gemspec"
  sh "gem push sailthru-client-#{Sailthru::VERSION}.gem"
  sh "git commit -am 'BUMP #{Sailthru::Version}'"
  sh "git tag v#{Sailthru::Version}"
  sh "git push origin v#{Sailthru::Version}"
  sh "git push origin master"
end
