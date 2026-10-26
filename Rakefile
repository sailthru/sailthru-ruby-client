require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rake/clean'
require 'rdoc/task'

CLOBBER.include 'pkg'

task :default => :test

Rake::TestTask.new do |t|
  t.libs = %w(lib test)
  t.test_files = FileList["test/**/*_test.rb"]
end

desc 'Install and exercise the built gem with runtime dependencies only'
task 'test:package' => :build do
  spec = Bundler::GemHelper.gemspec
  package = File.expand_path("pkg/#{spec.name}-#{spec.version}.gem")
  ruby 'scripts/test-package.rb', package
end

desc 'Run the test suite and packaged-gem smoke check'
task :verify => [:test, 'test:package']

# Check before the existing release task tags/pushes or publishes the gem.
Rake::Task['release:guard_clean'].enhance([:verify])
Rake::Task['release:rubygem_push'].enhance([:verify])

RDoc::Task.new do |rd|
  rd.main = "README.md"
  rd.rdoc_files.include("README.md", "lib/**/*.rb")
  rd.rdoc_dir = "rdoc"
end
