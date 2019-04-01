require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Gestsol
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.assets.paths << Rails.root.join("vendor", "assets", "fonts")
    config.time_zone = 'America/Santiago'

    config.i18n.load_path += Dir[Rails.root.join('config','locales','**','*{rb,yml}')]
    config.i18n.default_locale = :es
    config.endpoints = config_for(:endpoints)
  end
end
