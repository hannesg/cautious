$:.unshift File.expand_path( "lib", File.dirname(__FILE__) )

require 'rubygems'
require 'bundler'
Bundler.setup(:default, :development)
Bundler.require(:default, :development)

require 'rubygems/package_task'
require 'rspec/core/rake_task'

task :default => [:spec] 

spec = Gem::Specification.load "cautious.gemspec"

Rake::PackageTask.new("cautious", "0.0.1") do |pkg|
  pkg.need_tar = true
end

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ["-c", "-f progress"]
  t.pattern = 'spec/**/*_spec.rb'
end
