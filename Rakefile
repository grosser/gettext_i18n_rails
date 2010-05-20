require 'spec/rake/spectask'
Spec::Rake::SpecTask.new {|t| t.spec_opts = ['--color']}

task :default do
  # test with 2.x
  puts `VERSION='~>2' rake spec RSPEC_COLOR=1`

  # gem 'activerecord', '>=3' did not work for me, but just require gets the right version...
  require 'active_record'
  if ActiveRecord::VERSION::MAJOR >= 3
    puts `rake spec RSPEC_COLOR=1`
  else
    'install rails 3 to get full test coverage...'
  end
end

begin
  require 'jeweler'
  project_name = 'gettext_i18n_rails'
  Jeweler::Tasks.new do |gem|
    gem.name = project_name
    gem.summary = "Simple FastGettext Rails integration."
    gem.email = "grosser.michael@gmail.com"
    gem.homepage = "http://github.com/grosser/#{project_name}"
    gem.authors = ["Michael Grosser"]
    gem.add_dependency 'fast_gettext'
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install jeweler"
end