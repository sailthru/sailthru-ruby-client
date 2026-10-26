# frozen_string_literal: true

require 'bundler'
require 'rbconfig'
require 'rubygems/package'
require 'tmpdir'

package = File.expand_path(ARGV.fetch(0))
spec = Gem::Package.new(package).spec
abort 'Expected a sailthru-client gem' unless spec.name == 'sailthru-client'
smoke_script = File.expand_path('../test/smoke-package.rb', __dir__)

Dir.mktmpdir('sailthru-client-smoke-') do |temporary_directory|
  gem_home = File.join(temporary_directory, 'gems')
  environment = {
    'GEM_HOME' => gem_home,
    'GEM_PATH' => gem_home,
    'GEM_SPEC_CACHE' => File.join(temporary_directory, 'spec-cache'),
    'RUBYLIB' => '',
    'RUBYOPT' => ''
  }

  # Remove Bundler's development environment before installing/loading the gem.
  Bundler.with_unbundled_env do
    installed = system(environment, RbConfig.ruby, '-S', 'gem',
      'install', package, '--install-dir', gem_home, '--no-document',
      chdir: temporary_directory)
    abort 'Packaged gem installation failed' unless installed

    checked = system(environment, RbConfig.ruby, smoke_script,
      chdir: temporary_directory)
    abort 'Packaged client smoke check failed' unless checked
  end
end
