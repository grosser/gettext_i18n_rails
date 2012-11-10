require 'bundler/gem_tasks'
require 'appraisal'
require 'bump/tasks'

task :spec do
  sh "rspec spec"
end

task :default do
  sh "bundle exec rake appraisal:install && bundle exec rake appraisal spec"
end
