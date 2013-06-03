require 'bundler/setup'
require 'bundler/gem_tasks'
require 'appraisal'
require 'bump/tasks'

task :spec do
  sh "rspec spec"
end

task :default do
  sh "rake appraisal:install && rake appraisal spec"
end
