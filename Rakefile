require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rake/clean'
require 'rdoc/task'

CLOBBER.include 'pkg'

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
