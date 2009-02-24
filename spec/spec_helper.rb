# ---- requirements
require 'rubygems'
$LOAD_PATH << File.expand_path("../lib", File.dirname(__FILE__))
require 'active_support'
require 'activerecord'
require 'action_controller'
require 'action_mailer'
require 'fast_gettext'
require 'gettext_i18n_rails'

# ---- bugfix
#`exit?': undefined method `run?' for Test::Unit:Module (NoMethodError)
#can be solved with require test/unit but this will result in extra test-output
module Test
  module Unit
    def self.run?
      true
    end
  end
end

# ---- Helpers
def pending_it(text,&block)
  it text do
    pending(&block)
  end
end