require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Spacecommander
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # lib/netapp_sdk is the vendored NetApp SDK, whose files `require` each
    # other by bare filename (e.g. `require 'NaElement'`), relying on
    # autoload paths being on $LOAD_PATH. Rails 7.1 defaults this to false.
    config.add_autoload_paths_to_load_path = true

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.autoload_paths += %W(#{config.root}/lib/netapp_sdk)
    config.nas = config_for(:nas)
  end
end
