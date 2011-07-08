task :spec do
  sh "rspec spec"
end

task :default do
  sh "RAILS=2.3.12 bundle && bundle exec rake spec"
  sh "RAILS=3.0.9 bundle && bundle exec rake spec"
#  sh "RAILS=3.1.0.rc4 bundle && bundle exec rake spec"
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
