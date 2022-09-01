require 'bundler/setup'
require 'bundler/gem_tasks'
require 'bump/tasks'

task :spec do
  sh "rspec spec"
end

task :default => "spec"

desc "bundle all gemfiles [EXTRA=]"
task :bundle_all do
  extra = ENV["EXTRA"] || "install"

  gemfiles = (["Gemfile"] + Dir["gemfiles/*.gemfile"])
  gemfiles.each do |gemfile|
    Bundler.with_unbundled_env do
      sh "GEMFILE=#{gemfile} bundle #{extra}"
    end
  end
end
