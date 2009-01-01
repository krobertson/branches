require 'rubygems'
require "rake/gempackagetask"
require "spec/rake/spectask"

spec = Gem::Specification.new do |s|
  s.name         = 'branches'
  s.version      = '0.1'
  s.platform     = Gem::Platform::RUBY
  s.author       = 'Ken Robertson'
  s.email        = 'ken@invalidlogic.com'
  s.homepage     = 'http://krobertson.github.com/branches'
  s.summary      = 'Simplified, secure, private git repository serving'
  s.bindir       = 'bin'
  s.description  = 'Simplified, secure, private git repository serving'
  s.executables  = %w( branches )
  s.require_path = 'lib'
  s.files        = %w( MIT-LICENSE README.textile Rakefile ) + Dir["{bin,lib}/**/*"]

  s.add_dependency 'trollop'

  # rdoc
  s.has_rdoc         = true
#  s.extra_rdoc_files = %w( README LICENSE TODO )
end

Rake::GemPackageTask.new(spec) do |package|
  package.gem_spec = spec
end

desc "Run all specs"
Spec::Rake::SpecTask.new("spec") do |t|
  t.spec_opts = ["--format", "specdoc", "--colour"]
  t.spec_files = Dir["spec/*_spec.rb"].sort
  t.rcov = true
  t.rcov_opts << '--sort' << 'coverage' << '--sort-reverse'
  t.rcov_opts << '--exclude' << "spec"
end