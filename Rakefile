require 'rubygems'
require "spec/rake/spectask"

desc "Run all specs"
Spec::Rake::SpecTask.new("spec") do |t|
  t.spec_opts = ["--format", "specdoc", "--colour"]
  t.spec_files = Dir["spec/*_spec.rb"].sort
  t.rcov = true
  t.rcov_opts << '--sort' << 'coverage' << '--sort-reverse'
  t.rcov_opts << '--exclude' << "spec"
end