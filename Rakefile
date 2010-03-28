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