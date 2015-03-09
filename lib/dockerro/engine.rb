require 'fast_gettext'
require 'gettext_i18n_rails'

module Dockerro
  # Inherit from the Rails module of the parent app (Foreman), not the plugin.
  # Thus, inherits from ::Rails::Engine and not from Rails::Engine
  class Engine < ::Rails::Engine
    isolate_namespace Dockerro
    engine_name 'dockerro'

    config.autoload_paths += Dir["#{config.root}/app/lib"]
    config.autoload_paths += Dir["#{config.root}/app/controllers"]

    initializer 'dockerro.mount_engine', :after => :build_middleware_stack do |app|
      app.routes_reloader.paths << "#{Dockerro::Engine.root}/config/mount_engine.rb"
    end

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

    # initializer "dockerro.assets.paths", :group => :all do |app|
    #   if Rails.env.production?
    #     app.config.assets.paths << Bastion::Engine.root.join('vendor', 'assets', 'stylesheets', 'bastion',
    #                                                          'font-awesome', 'scss')
    #   else
    #     app.config.sass.load_paths << Bastion::Engine.root.join('vendor', 'assets', 'stylesheets', 'bastion',
    #                                                             'font-awesome', 'scss')
    #   end
    # end

    initializer 'dockerro.register_plugin', :after=> :finisher_hook, :after => 'foreman_docker.register_plugin'  do |app|
      Foreman::Plugin.register :dockerro do
        requires_foreman '> 1.3'
        divider :top_menu, :parent => :containers_menu
          menu :top_menu, :new_image,
               :caption => N_('New image'),
               :url => '/docker_images/new',
               :url_hash => {:controller => 'dockerro/api/v2/docker_images',
                             :action => 'new'},
               :engine => Dockerro::Engine,
               :parent => :containers_menu,
               :turbolink => false

        security_block :docker_images do
          permission :create_docker_images,
                     :docker_images          => [:create, :new],
                     :'api/v2/docker_images' => [:create, :new]
        end

      end
    end

    config.to_prepare do
      Bastion.register_plugin({
        :name       => 'dockerro',
        :javascript => 'dockerro/dockerro',
        :stylesheet => 'dockerro/dockerro',
        :pages      => %w(
          docker_images
        )
        })
    end
  end
end
