require 'bundler/setup'
require 'bundler/gem_tasks'
require 'wwtd/tasks'
require 'bump/tasks'

task :spec do
  sh "rspec spec"
end

task :default => "wwtd:local"
