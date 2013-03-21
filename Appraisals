if RUBY_VERSION =~ /^2\.0/
  ['3.0', '3.1', '3.2'].each do |version|
    appraise "rails.#{version}" do
      gem "rails", "~>#{version}.0"
    end
  end
else
  ['2.3', '3.0', '3.1', '3.2'].each do |version|
    appraise "rails.#{version}" do
      gem "rails", "~>#{version}.0"
    end
  end
end
