require 'fast_gettext'
require 'gettext_i18n_rails'

module Dockerro
  # Inherit from the Rails module of the parent app (Foreman), not the plugin.
  # Thus, inherits from ::Rails::Engine and not from Rails::Engine
  class Engine < ::Rails::Engine
    engine_name 'dockerro'

    config.autoload_paths += Dir["#{config.root}/app/lib"]
    config.autoload_paths += Dir["#{config.root}/app/controllers"]

    initializer 'dockerro.load_app_instance_data' do |app|
      app.config.paths['db/migrate'] += Dockerro::Engine.paths['db/migrate'].existent
    end

    initializer 'dockerro.load_default_settings', :before => :load_config_initializers do
      require_dependency File.expand_path('../../../app/models/setting/dockerro.rb', __FILE__) if (Setting.table_exists? rescue(false))
    end

    initializer "dockerro.register_actions", :before => 'foreman-tasks.initialize_dynflow' do |_app|
      ForemanTasks.dynflow.require!
            ForemanTasks.dynflow.config.eager_load_paths.concat(%W[#{ForemanTasks::Engine.root}/app/lib/actions])
      action_paths = %W(#{Dockerro::Engine.root}/app/lib/actions)
      ForemanTasks.dynflow.config.eager_load_paths.concat(action_paths)
    end

    # initializer 'dockerro.register_gettext', :after => :load_config_initializers do
    #   locale_dir = File.join(File.expand_path('../../..', __FILE__), 'locale')
    #   locale_domain = 'dockerro'
    #
    #   Foreman::Gettext::Support.add_text_domain locale_domain, locale_dir
    # end

    initializer "dockerro.assets.paths", :group => :all do |app|
      if Rails.env.production?
        app.config.assets.paths << Bastion::Engine.root.join('vendor', 'assets', 'stylesheets', 'bastion',
                                                             'font-awesome', 'scss')
      else
        app.config.sass.load_paths << Bastion::Engine.root.join('vendor', 'assets', 'stylesheets', 'bastion',
                                                                'font-awesome', 'scss')
      end
    end

    initializer 'dockerro.register_plugin', :after=> :finisher_hook do |app|
      Foreman::Plugin.register :dockerro do
        sub_menu :top_menu, :dockerro_menu, :caption => N_('Dockerro'),
                 :after => :monitor_menu do
          menu :top_menu, :new_image, :caption => N_('New image'),
               :url_hash => { :controller => 'dockerro/images',
                              :action => :new }
        end
      end
    end

    # config.to_prepare do
    #   ::Katello::ContentView.send :include, ::Dockerro::Concerns::ContentViewExtensions
    # end
  end
end
