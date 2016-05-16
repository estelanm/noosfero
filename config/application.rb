require_relative 'boot'

require 'rails/all'
require 'active_support/dependencies'

# Silence Rails 5 deprecation warnings
ActiveSupport::Deprecation.silenced = true

Bundler.require(:default, :assets, Rails.env)
$: << File.expand_path('../lib', File.dirname(__FILE__))

require_dependency 'noosfero'
require_dependency 'noosfero/plugin'
require_dependency 'noosfero/multi_tenancy'

module Noosfero
  class Application < Rails::Application

    # The plugin xss_terminator(located in vendor/plugins/xss_terminator) and the helper
    # SanitizeHelper(located in app/helpers/sanitize_helper.rb) use
    # ALLOWED_TAGS and ALLOWED_ATTRIBUTES to make a sanitize with html.

    ALLOWED_TAGS = %w(object embed param table tr th td applet comment iframe audio video source
    strong em b i p code pre tt samp kbd var sub sup dfn cite big small address hr br div span h1
    h2 h3 h4 h5 h6 ul ol li dl dt dd abbr acronym a img blockquote del ins a)

    ALLOWED_ATTRIBUTES = %w(name href cite class title src xml:lang height datetime alt abbr width
      vspace hspace heigth value type data style target codebase archive data-macro align border
      classid code flashvars scrolling frameborder controls autoplay colspan id rowspan)

    config.action_view.sanitized_allowed_tags = ALLOWED_TAGS
    config.action_view.sanitized_allowed_attributes = ALLOWED_ATTRIBUTES

    config.action_controller.include_all_helpers = false

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths << config.root.join('lib')
    config.autoload_paths << config.root.join('app/jobs')
    config.autoload_paths << config.root.join('app/sweepers')
    config.autoload_paths.concat Dir["#{config.root}/app/controllers/**/"]
    config.autoload_paths << config.root.join('test', 'mocks', Rails.env)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # Sweepers are observers
    # don't load the sweepers while loading the database
    ignore_rake_commands = %w[
      db:schema:load
      gems:install
      clobber
      noosfero:translations:compile
      makemo
    ]
    if $PROGRAM_NAME =~ /rake$/ && (ignore_rake_commands.include?(ARGV.first))
      Noosfero::Plugin.should_load = false
    else
      config.active_record.observers = :article_sweeper, :role_assignment_sweeper, :friendship_sweeper, :category_sweeper, :block_sweeper
    end

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = 'Brasilia'


    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = nil

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :password_confirmation]

    # Enable escaping HTML in JSON.
    ActiveSupport::JSON::Encoding.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    config.active_record.whitelist_attributes = true

    # Asset pipeline
    config.assets.paths =
      Dir.glob("app/assets/plugins/*/{,stylesheets,javascripts}") +
      Dir.glob("app/assets/{,stylesheets,javascripts}") +
      # no precedence over core
      Dir.glob("app/assets/designs/{icons,themes,user_themes}/*")

    # disable strong_parameters before migration from protected_attributes
    config.action_controller.permit_all_parameters = true
    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.sass.preferred_syntax = :scss
    config.sass.cache = true
    config.sass.line_comments = false

    config.action_dispatch.session = {
      :key    => '_noosfero_session',
    }
    config.session_store :active_record_store, key: '_noosfero_session'

    config.paths['db/migrate'].concat Dir.glob("#{Rails.root}/{baseplugins,config/plugins}/*/db/migrate")
    config.i18n.load_path.concat Dir.glob("#{Rails.root}/{baseplugins,config/plugins}/*/locales/*.{rb,yml}")

    config.eager_load = true

    config.middleware.use Noosfero::MultiTenancy::Middleware

    Noosfero::Plugin.setup(config)
  end
end
