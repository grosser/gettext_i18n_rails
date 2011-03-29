require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '--backtrace --color'
end

task :rails2 do
  sh "cd spec/rails2 && RAILS=rails rspec ../../spec"
end

task :default do
  sh "rake spec && rake rails2"
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = 'gettext_i18n_rails'
    gem.summary = "Simple FastGettext Rails integration."
    gem.email = "grosser.michael@gmail.com"
    gem.homepage = "http://github.com/grosser/#{gem.name}"
    gem.authors = ["Michael Grosser"]
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install jeweler"
end
