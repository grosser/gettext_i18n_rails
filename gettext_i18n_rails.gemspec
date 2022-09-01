name = "gettext_i18n_rails"
require "./lib/#{name}/version"

Gem::Specification.new name, GettextI18nRails::VERSION do |s|
  s.summary = "Simple FastGettext Rails integration."
  s.authors = ["Michael Grosser"]
  s.email = "michael@grosser.it"
  s.homepage = "http://github.com/grosser/#{name}"
  s.files = `git ls-files lib MIT-LICENSE.txt`.split("\n")
  s.license = "MIT"
  s.required_ruby_version = '>= 2.1.0'
  s.add_runtime_dependency "fast_gettext", ">= 0.9.0"

  s.add_development_dependency "bump"
  s.add_development_dependency "gettext", ">= 3.0.2"
  s.add_development_dependency "haml"
  # s.add_development_dependency "hamlit" # breaks ruby 1.9 ... TODO remove once we bump to 2.0
  s.add_development_dependency "rake"
  s.add_development_dependency "rails"
  s.add_development_dependency "ruby_parser", ">= 3.7.1" # sync with lib/gettext_i18n_rails/ruby_gettext_extractor.rb
  s.add_development_dependency "sexp_processor"
  s.add_development_dependency "rspec"
  s.add_development_dependency "slim"
  s.add_development_dependency "sqlite3"
end
