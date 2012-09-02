$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
name = "gettext_i18n_rails"
require "#{name}/version"

Gem::Specification.new name, GettextI18nRails::VERSION do |s|
  s.summary = "Simple FastGettext Rails integration."
  s.authors = ["Michael Grosser"]
  s.email = "michael@grosser.it"
  s.homepage = "http://github.com/grosser/#{name}"
  s.files = `git ls-files`.split("\n")
  s.license = "MIT"
  s.add_runtime_dependency "fast_gettext", ">=0.4.8"
end
