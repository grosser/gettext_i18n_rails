# We need a rails engine so that the asset pipeline knows there are assets
# provided by this gem
module GettextI18nRails
  module Rails
    class Engine < ::Rails::Engine
    end
  end
end
