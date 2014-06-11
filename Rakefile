require "rdoc/task"
require 'rake/testtask'
require "bundler/gem_tasks"

task :default => :test

desc "Run the test suite"
Rake::TestTask.new do |t|
  t.libs = ["lib", "test"]
  t.test_files = FileList["test/**/*_test.rb"]
end

Rake::RDocTask.new do |rd|
  rd.main = "README.md"
  rd.rdoc_files.include("README.md", "lib/**/*.rb")
  rd.rdoc_dir = "rdoc"
end
