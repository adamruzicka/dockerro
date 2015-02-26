module BastionDockerro
  class Engine < ::Rails::Engine
    isolate_namespace BastionDockerro

    initializer 'bastion.assets_dispatcher', :before => :build_middleware_stack do |app|
      app.middleware.use ::ActionDispatch::Static, "#{BastionDockerro::Engine.root}/app/assets/javascripts/bastion_dockerro"
    end

    initializer "bastion.assets.paths", :group => :all do |app|
      app.middleware.use ::ActionDispatch::Static, "#{BastionDockerro::Engine.root}/app/assets/javascripts/bastion_dockerro"

      if defined? Less::Rails
        app.config.less.paths << "#{BastionDockerro::Engine.root}/app/assets/stylesheets/bastion_dockerro"
      end
    end

    config.to_prepare do
      Bastion.register_plugin(
        :name => 'bastion_dockerro',
        :javascript => 'bastion_dockerro/bastion_dockerro',
        :stylesheet => 'bastion_dockerro/bastion_dockerro',
        :pages => %w(
          docker-images
        )
      )
    end
  end
end
