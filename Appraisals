versions = ['3.0', '3.1', '3.2']
versions.unshift '2.3' if RUBY_VERSION =~ /^1/
versions.each do |version|
  appraise "rails#{version.sub(".", "")}" do
    gem "rails", "~>#{version}.0"
  end
end
