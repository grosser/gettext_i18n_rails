['2.3', '3.0', '3.1', '3.2'].each do |version|
  appraise "rails#{version.sub(".", "")}" do
    gem "rails", "~>#{version}.0"
    gem "haml", "~> 3.0" if version == "2.3"
  end
end
