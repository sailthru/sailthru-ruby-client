require "rubygems"
require "rake/gempackagetask"
require "rake/rdoctask"


#
## Tests
#

task :default => :test

require 'rake/testtask'
desc "Run the test suite"
Rake::TestTask.new do |t|
  t.libs = [File.expand_path("lib"), "test"]
  t.test_files = FileList["test/**/*_test.rb"]
  t.verbose = true
end


# This builds the actual gem. For details of what all these options
# mean, and other ones you can add, check the documentation here:
#
#   http://rubygems.org/read/chapter/20
#
spec = Gem::Specification.new do |s|
  require 'lib/sailthru'
  # Change these as appropriate
  s.name              = "sailthru-client"
  s.version           = "#{Sailthru::Version}"
  s.summary           = "A simple client library to remotely access the Sailthru REST API."
  s.author            = "Prajwal Tuladhar"
  s.email             = "praj@sailthru.com"
  s.homepage          = "http://docs.sailthru.com"

  s.has_rdoc          = true
  s.extra_rdoc_files  = %w(README.md)
  s.rdoc_options      = %w(--main README.md)

  # Add any extra files to include in the gem
  s.files             = %w(README.md) + Dir.glob("{lib}/**/*")
  s.require_paths     = ["lib"]

  # If you want to depend on other gems, add them here, along with any
  # relevant versions
  s.add_dependency("json")

  s.add_development_dependency("fakeweb") # for example
end

# This task actually builds the gem. We also regenerate a static
# .gemspec file, which is useful if something (i.e. GitHub) will
# be automatically building a gem for this project. If you're not
# using GitHub, edit as appropriate.
#
# To publish your gem online, install the 'gemcutter' gem; Read more
# about that here: http://gemcutter.org/pages/gem_docs
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "Build the gemspec file #{spec.name}.gemspec"
task :gemspec do
  file = File.dirname(__FILE__) + "/#{spec.name}.gemspec"
  File.open(file, "w") {|f| f << spec.to_ruby }
end

# If you don't want to generate the .gemspec file, just remove this line. Reasons
# why you might want to generate a gemspec:
#  - using bundler with a git source
#  - building the gem without rake (i.e. gem build blah.gemspec)
#  - maybe others?
task :package => :gemspec

# Generate documentation
Rake::RDocTask.new do |rd|
  rd.main = "README.md"
  rd.rdoc_files.include("README.md", "lib/**/*.rb")
  rd.rdoc_dir = "rdoc"
end

desc 'Clear out RDoc and generated packages'
task :clean => [:clobber_rdoc, :clobber_package] do
  rm "#{spec.name}.gemspec"
end


#
# Publishing
#
desc "Push a new version to Gemcutter"
task :publish do
    require 'lib/sailthru'
    sh "rake clean"
    sh "rake gem"
    sh "rake gemspec"
    sh "git commit -am 'new gemspec for tag #{Sailthru::Version}'"
    sh "git tag v#{Sailthru::Version}"
    sh "git push origin v#{Sailthru::Version}"
    sh "git push origin master"
end
