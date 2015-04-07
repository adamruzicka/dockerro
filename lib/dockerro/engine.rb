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
      app.config.autoload_paths += Dir["#{config.root}/app/lib"]
    end

    initializer 'dockerro.load_default_settings', :before => :load_config_initializers do
      require_dependency File.expand_path('../../../app/models/setting/dockerro.rb', __FILE__) if (Setting.table_exists? rescue(false))
    end

    initializer "dockerro.register_actions", :before => 'foreman_tasks.initialize_dynflow' do |_app|
      ForemanTasks.dynflow.require!
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
               :turbolinks => false
          menu :top_menu, :docker_image_build_configs,
               :caption => N_('Docker image build configs'),
               :url => '/docker_image_build_configs',
               :url_hash => { :controller => 'dockerro/api/v2/docker_image_build_configs',
                              :action => 'index' },
               :engine => Dockerro::Engine,
               :parent => :containers_menu,
               :turbolinks => false
          divider :top_menu, :parent => :infrastructure_menu
            menu :top_menu, :build_resource,
                :caption => N_('Build resources'),
                :url => '/build_resources',
                :url_hash => { :controller => 'dockerro/build_resources',
                                :action => 'index' },
                :engine => Dockerro::Engine,
                :parent => :infrastructure_menu,
                :turbolinks => false

        security_block :docker_images do
          permission :create_docker_images,
                     :docker_images          => [:create],
                     :'api/v2/docker_images' => [:create]
          permission :view_docker_image_build_configs,
                     :docker_image_build_configs => [:index, :show],
                     :'api/v2/docker_image_build_configs' => [:index, :show]
          permission :create_docker_image_build_configs,
                     :docker_image_build_configs => [:create],
                     :'api/v2/docker_image_build_configs' => [:create]
          permission :destroy_docker_image_build_configs,
                     :docker_image_build_configs => [:destroy],
                     :'api/v2/docker_image_build_configs' => [:destroy]
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
          docker_image_build_configs
        )
        })

      require 'strong_parameters'

      ::Katello::ContentView.send :include, Dockerro::Concerns::ContentViewExtensions
      ::Katello::ContentViewVersion.send :include, Dockerro::Concerns::ContentViewVersionExtensions
      ::Katello::DockerImage.send :include, Dockerro::Concerns::DockerImageExtensions
      ::Katello::Repository.send :include, Dockerro::Concerns::RepositoryExtensions
      ::Katello::System.send :include, Dockerro::Concerns::SystemExtensions
      ::Taxonomy.send :include, Dockerro::Concerns::TaxonomyExtensions
    end
  end
end
